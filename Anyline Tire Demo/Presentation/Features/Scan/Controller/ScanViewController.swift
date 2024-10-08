import UIKit
import AVFoundation
import CoreHaptics
import MediaPlayer
import AnylineTireTreadSdk

protocol ScanViewControllerDelegate {
    func startRecorderFlow(uuid: String)
}

class ScanViewController: UIViewController, ScannerViewControllerHolder {

    // MARK: - Private Var's & Let's
    private var volumeButtonObserver: VolumeButtonObserver?

    var delegate: ScanViewControllerDelegate?

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
        //setupVolumeView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.setupVolumeButtonObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate = nil
        // self.resetVolumeButtonObserver()
        self.scannerViewController = nil
    
    }
}

// MARK: - Private Actions
private extension ScanViewController {

    private func setupTireTreadScanView() {

        let userDefaults = UserDefaultsManager.shared

        /*
         * You can optionally provide additional context to a scan.
         * This makes sense in a workflow, where a scan is connected to other TireTread scans or
         * other information in a larger context.
         * Check the official documentation for more details.
        */
        // let tirePosition = TirePosition(axle: 1, side: TireSide.left, positionOnAxle: 1)
        // let additionalContext = AdditionalContext(tirePosition: tirePosition)
        let customUiConfig = DefaultUiConfig()

        let shouldShowGuidance = UserDefaultsManager.shared.showGuidance

        customUiConfig.howToScanTooltipConfig.visible = shouldShowGuidance
        customUiConfig.tireOverlayConfig.visible = shouldShowGuidance
        customUiConfig.lineProgressBarConfig.visible = shouldShowGuidance

        let config = TireTreadScanViewConfig()
        config.measurementSystem = userDefaults.imperialSystem ? .imperial : .metric
        // ScanSpeed is experimental, may impact scan performance and may be removed with any major SDK release.
        config.scanSpeed = userDefaults.scanSpeed
        config.defaultUiConfig = customUiConfig
        // You are advised to ignore this configuration on your implementation.
        // config.additionalContext = additionalContext
        
        // creates a TireTreadScannerViewController. You can later refer to it here
        // as self.scannerViewController.

        // Alternatively initialise scan process with a JSON config
        // let config = "default_config.json"
        TireTreadScanViewKt.TireTreadScanView(context: UIViewController(), config: config, callback: self) { [weak self] error in
            self?.displayError(uuid: "")
            print("Initialization failed: \(error)")
        }

        self.dismissViewController = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        addScanViewControllerAsChild()
    }

    private func addScanViewControllerAsChild() {
        guard let scannerViewController = scannerViewController else {
            displayError(uuid: "")
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
                if (TireTreadScanner.companion.instance.captureDistanceStatus == DistanceStatus.ok)
                {
                    TireTreadScanner.companion.instance.startScanning()
                }
                else {
                    // Notify user to move the phone to the correct position before starting
                    print("Move the phone to the correct position before starting")
                }
            }
        }
    }

}

// MARK: - ScanViewModelDelegate
extension ScanViewController: ScanViewModelDelegate {

    func displayError(uuid: String) {
        let vc = ErrorViewController(uuid: uuid)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func displayLoading(uuid: String) {
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
    
    // We're using the SDK's defaultUi, so we only really need to implement the behavior
    // for the "onScanAbort", "onUploadCompleted", "onUploadAborted", and "onUploadFailed" callbacks

    func onScanAbort(uuid: String?) {
        print("scan aborted for uuid: \(uuid ?? "")")
        self.navigationController?.popViewController(animated: true)
    }
    
    func onUploadAborted(uuid: String?) {
        print("upload aborted for uuid: \(uuid ?? "")")
        self.navigationController?.popViewController(animated: true)
    }
    
    func onUploadFailed(uuid: String?, exception: KotlinException) {
        self.displayError(uuid: uuid ?? "")
    }
    
    func onUploadCompleted(uuid: String?) {
        // On upload complete, we should check for Results.
        
        // the "shouldRequestTireIdFeedback" is only intended for feedback and
        // does not need to be implemented
        if let uuid = uuid {
            var shouldRequestForFeedback: Bool = false
            do {
                shouldRequestForFeedback = try AnylineTireTreadSdk.shared.shouldRequestTireIdFeedback()
            } catch {
                print("caught exception: \(error.localizedDescription)")
            }
            if shouldRequestForFeedback {
                delegate?.startRecorderFlow(uuid: uuid)
            } else {
                // Your application should directly fetch Results
                self.displayLoading(uuid: uuid)
            }
        } else {
            self.displayError(uuid: uuid ?? "")
        }
    }
    
    func onFocusFound(uuid: String?) {
    }
    
    func onScanStart(uuid: String?) {
    }
    
    func onScanStop(uuid: String?) {
        print("Showcase iOS: Scan stopped for uuid: \(uuid ?? "unknown")")
    }
    
    func onImageUploaded(uuid: String?, uploaded: Int32, total: Int32) {
        print("Showcase iOS: Image uploaded (\(uploaded)/\(total)) for uuid: \(uuid ?? "unknown")")
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
        
    }
}
