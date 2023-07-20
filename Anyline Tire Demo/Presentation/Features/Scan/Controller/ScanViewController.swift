import UIKit
import AVFoundation
import CoreHaptics
import MediaPlayer
import AnylineTireTreadSdk

class ScanViewController: UIViewController, ScannerViewControllerHolder {
    
    // MARK: - Private Var's & Let's
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = ColorStruct.skyGrey
        progressView.progressTintColor = ColorStruct.anylineBlue
        progressView.progress = 0.0
        progressView.isHidden = true
        return progressView
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "\("scan.distance.ok".localized()): 20"
        label.textColor = .clear
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = FontStruct.proximaNovaBold23
        return label
    }()
    
    private var scanTimer: Timer?
    private var progress: Float = 0
    private let totalTime = 10.0 // Total time for scanning
    private let interval = 0.1 // Time interval to update progressView
    private var volumeButtonObserver: VolumeButtonObserver?
    
    // Audio properties
    var highBeepAudioPlayer: AVAudioPlayer?
    var lowBeepAudioPlayer: AVAudioPlayer?
    var focusAudioPlayer: AVAudioPlayer?
    var startAudioPlayer: AVAudioPlayer?
    var stopAudioPlayer: AVAudioPlayer?
    var hapticPlayer: CHHapticPatternPlayer?
    var engine: CHHapticEngine?
    var beepingTimer: Timer?
    var previousDistance = 0
    
    var scannerViewController: UIViewController?
    var dismissViewController: (() -> Void)?
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTireTreadScanView()
        setupSubviews()
        setupAudioFiles()
        setupHapticEngine()
        setupVolumeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupVolumeButtonObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopBeeping()
        self.stopAudioPlayers()
        self.resetVolumeButtonObserver()
    }
}

// MARK: - Private Actions
private extension ScanViewController {
    
    private func setupTireTreadScanView() {

        let config = TireTreadScanViewConfig(measurementSystem: UserDefaultsManager.shared.imperialSystem ? .imperial : .metric, useDefaultUi: true, useDefaultHaptic: true)

        // creates a TireTreadScannerViewController. You can later refer to it here
        // as self.scannerViewController.
        TireTreadScanViewKt.TireTreadScanView(context: UIViewController(), config: config, callback: self) { [weak self] error in
            self?.displayError()
            print("Initialization failed: \(error)")
        }

        self.dismissViewController = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        addScanViewControllerAsChild()
    }
    
    private func addScanViewControllerAsChild() {
        guard let scannerViewController = scannerViewController else {
            displayError()
            return
        }
        addChild(scannerViewController)
        view.addSubview(scannerViewController.view)
        scannerViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scannerViewController.didMove(toParent: self)
    }
    
    func setupVolumeView() {
        let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))
        view.addSubview(volumeView)
    }
    
    func updateUI(status: DistanceStatus, distance: Int) {
        let measurementUnit = UserDefaultsManager.shared.imperialSystem ? "in" : "cm"
        let textAndColor = textAndColor(for: status)
        
        self.distanceLabel.text = "\(textAndColor.text): \(distance) \(measurementUnit)"
        self.distanceLabel.textColor = textAndColor.color
    }
    
    func textAndColor(for status: DistanceStatus) -> (text: String, color: UIColor) {
        var text: String
        var color: UIColor
        
        switch status {
        case .close, .tooClose:
            text = "scan.distance.increase".localized()
            color = (status == .close) ? .yellow : .red
        case .far, .tooFar:
            text = "scan.distance.decrease".localized()
            color = (status == .far) ? .yellow : .red
        case .ok:
            text = "scan.distance.ok".localized()
            color = .green
        default:
            text = "scan.distance.ok".localized()
            color = .green
        }

        return (text, color)
    }
    
    @objc func updateProgressView() {
        // Update the progress
        progress += Float(interval / totalTime)
        progressView.progress = progress
        
        // Check if the scanning process is completed
        if progress >= 1.0 {
            // Stop the timer
            scanTimer?.invalidate()
            scanTimer = nil
        }
    }
}

// MARK: - AVAudioSession for Volume buttons
private extension ScanViewController {
    func setupVolumeButtonObserver() {
        volumeButtonObserver = VolumeButtonObserver()
        volumeButtonObserver?.onVolumeButtonPressed = { [weak self] in
            self?.handleVolumeButtonPressed()
        }
    }

    func resetVolumeButtonObserver() {
        self.volumeButtonObserver = nil
    }
    
    private func handleVolumeButtonPressed() {
        if TireTreadScanner.companion.isInitialized {
            if TireTreadScanner.companion.instance.isScanning {
                TireTreadScanner.companion.instance.stopScanning()
            } else {
                TireTreadScanner.companion.instance.startScanning()
            }
        }
    }

}

// MARK: - Private setup methods
private extension ScanViewController {
    func setupSubviews() {
        setupBottomDistanceView()
        setupProgressView()
    }
    
    func setupProgressView() {
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.leading.equalTo(200)
            $0.trailing.equalTo(-200)
        }
    }
    
    func setupBottomDistanceView() {
        self.view.addSubview(distanceLabel)
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(-50)
        }
    }
}

// MARK: - AVAudioSession for Audio feedback
private extension ScanViewController {
    
    // Load audio files
    func setupAudioFiles() {
        
        let focusBeepUrl = Bundle.main.url(forResource: "tiretread_focuspoint_found", withExtension: "wav")!
        focusAudioPlayer = try? AVAudioPlayer(contentsOf: focusBeepUrl)
        focusAudioPlayer?.prepareToPlay()
        
        let startBeepUrl = Bundle.main.url(forResource: "tiretread_sound_start", withExtension: "mp3")!
        startAudioPlayer = try? AVAudioPlayer(contentsOf: startBeepUrl)
        startAudioPlayer?.prepareToPlay()
        
        let stopBeepUrl = Bundle.main.url(forResource: "tiretread_sound_stop", withExtension: "wav")!
        stopAudioPlayer = try? AVAudioPlayer(contentsOf: stopBeepUrl)
        stopAudioPlayer?.prepareToPlay()
        stopAudioPlayer?.delegate = self
        
        let highBeepUrl = Bundle.main.url(forResource: "tiretread_sound_high_beep", withExtension: "wav")!
        highBeepAudioPlayer = try? AVAudioPlayer(contentsOf: highBeepUrl)
        highBeepAudioPlayer?.prepareToPlay()
        
        let lowBeepUrl = Bundle.main.url(forResource: "tiretread_sound_low_beep", withExtension: "wav")!
        lowBeepAudioPlayer = try? AVAudioPlayer(contentsOf: lowBeepUrl)
        lowBeepAudioPlayer?.prepareToPlay()
        
    }
    
    func playStartSound() {
        startAudioPlayer?.play()
    }
    
    func playStopSound() {
        stopAudioPlayer?.play()
    }
    
    func playFocusSound() {
        focusAudioPlayer?.play()
        playHapticFeedback()
    }
    
    // Function to start the beeping sound
    func startBeeping(distanceInCm: Double) {
        // Cancel any existing timer
        beepingTimer?.invalidate()

        // Calculate the interval for the timer based on the distance
        let roundedDistance = Int(distanceInCm)
        var interval: Double
        var playerToUse: AVAudioPlayer?

        if roundedDistance < 16 {
            interval = 500 * (distanceInCm / 16)
            playerToUse = self.highBeepAudioPlayer
        } else if roundedDistance > 22 {
            interval = max(500 + (distanceInCm - 22) * (0 - 500) / (40 - 22), 0)
            playerToUse = self.lowBeepAudioPlayer
        } else {
            // Distance is in the optimal range - no need to beep
            return
        }

        // Create a new timer
        beepingTimer = Timer.scheduledTimer(withTimeInterval: interval / 1000, repeats: true) { _ in
            DispatchQueue.global(qos: .userInitiated).async {
                playerToUse?.play()
            }
        }
        
        // Ensure the timer is scheduled on the main thread
        DispatchQueue.main.async {
            self.beepingTimer?.fire()
        }
    }

    
    func setupHapticEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch let error {
            print("Failed to create haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playHapticFeedback() {
        let sharpTap = CHHapticEvent(eventType: .hapticTransient, parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 1), CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)], relativeTime: 0)
        let vibration = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        ], relativeTime: 0, duration: 0.1)
        let pattern = try? CHHapticPattern(events: [sharpTap, vibration], parameters: [])
        do {
            hapticPlayer = try engine?.makePlayer(with: pattern!)
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Handle the error
            print("Failed to play haptic feedback: \(error.localizedDescription)")
        }
    }
    
    // Function to stop the beeping sound
    func stopBeeping() {
        // Cancel the timer
        beepingTimer?.invalidate()
        beepingTimer = nil
    }
    
    func stopAudioPlayers() {
        focusAudioPlayer?.stop()
        startAudioPlayer?.stop()
        highBeepAudioPlayer?.stop()
        lowBeepAudioPlayer?.stop()
        try? hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        
        focusAudioPlayer = nil
        startAudioPlayer = nil
        highBeepAudioPlayer = nil
        lowBeepAudioPlayer = nil
        beepingTimer = nil
        hapticPlayer = nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension ScanViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlayer?.stop()
        stopAudioPlayer = nil
    }
    
}

// MARK: - ScanViewModelDelegate
extension ScanViewController: ScanViewModelDelegate {
    
    func displayError() {
        let vc = ErrorViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func displayLoading(uuid: String) {
        self.scanTimer?.invalidate()
        self.playStopSound()
        DispatchQueue.main.async {
            let vc = LoadingViewController(uuid: uuid)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - LoadingViewControllerDelegate
extension ScanViewController: LoadingViewControllerDelegate {
    func resetScan() {
        
    }
}

// MARK: - ErrorViewControllerDelegate
extension ScanViewController: ErrorViewControllerDelegate {
    func didAbort() {
        
    }
}

extension ScanViewController: TireTreadScanViewCallback {

    func onScanAbort(uuid: String?) {

    }

    func onUploadAborted(uuid: String?) {

    }

    
    func onFocusFound(uuid: String?) {
        self.playFocusSound()
    }
    
    func onUploadCompleted(uuid: String?) {
        // Implement this method
        self.playStopSound()
        if let safeUuid = uuid {
            self.displayLoading(uuid: safeUuid)
        } else {
            self.displayError()
        }
    }
    
    func onImageUploaded(uuid: String?, uploaded: Int32, total: Int32) {
        print("Native iOS: Image uploaded (\(uploaded)/\(total)) for uuid: \(uuid ?? "unknown")")
    }
    
    func onUploadFailed(uuid: String?, exception: KotlinException) {
        self.displayError()
    }
    
    func onScanStart(uuid: String?) {
        self.playStartSound()
        self.progressView.isHidden = false
        self.scanTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    func onScanStop(uuid: String?) {
        print("Native iOS: Scan stopped for uuid: \(uuid ?? "unknown")")
    }
    
    /// Called when the distance has changed.
    ///
    /// - Parameters:
    ///   - uuid: The UUID associated with the distance change.
    ///   - previousStatus: The previous distance status.
    ///   - newStatus: The new distance status.
    ///   - previousDistance: The previous distance value.
    ///   - newDistance: The new distance value.
    ///
    /// Note: The distance values are provided in millimeters if the metric system is selected (`UserDefaultsManager.shared.imperialSystem = false`), and in inches if the imperial system is selected (`UserDefaultsManager.shared.imperialSystem = true`).
    func onDistanceChanged(uuid: String?, previousStatus: DistanceStatus, newStatus: DistanceStatus, previousDistance: Float, newDistance: Float) {
        if Int(newDistance) != Int(previousDistance) {
            let distanceInCentimeters = UserDefaultsManager.shared.imperialSystem ? (newDistance * 2.54) : (newDistance / 10.0)
            startBeeping(distanceInCm: Double(distanceInCentimeters))
            DispatchQueue.main.async { [weak self] in
                self?.updateUI(status: newStatus, distance: Int(UserDefaultsManager.shared.imperialSystem ? newDistance : distanceInCentimeters))
            }
        }
    }
}
