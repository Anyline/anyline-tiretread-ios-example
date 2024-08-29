import UIKit
import SnapKit
import AnylineTireTreadSdk

enum LandingViewDisplayMode {
    case `default`
    case intro
}

class LandingViewController: UIViewController {
    
    enum Constants {
        static let userDefaultsFlag_seenIntroVideo = "userDefaultsFlag_seenIntroVideo"
    }
    
    private var displayMode: LandingViewDisplayMode? {
        didSet {
            if let displayMode = displayMode {
                landingView.setDisplayMode(displayMode)
                landingView.startButton.isEnabled = true
            }
        }
    }
    
    // MARK: - UI properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var landingView: LandingView = {
        let view = LandingView()
        return view
    }()
    
    // MARK: - Private properties
    private lazy var landingViewModel: LandingViewModel = {
        return LandingViewModel(delegate: self)
    }()
    
    // MARK: - Public Properties
    
    // MARK: - Init
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        setupLayout()
        landingView.delegate = self

        landingView.startButton.isEnabled = false
        landingViewModel.tryInitializeSdk(context: self) { [weak self] success, errorMsg in
            self?.landingView.startButton.isEnabled = true
            if !success {
                self?.showError(error: errorMsg ?? "Unknown error")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        landingView.startButton.isEnabled = true
        landingView.resetOpenButton()
    }
}

// MARK: - Private Functions
private extension LandingViewController {
    func configureView() {
        view.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(landingView)
    }
    
    func setupLayout() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        landingView.snp.makeConstraints({ make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
}

// MARK: - LandingButtonActionsDelegate
extension LandingViewController: LandingButtonActionsDelegate {
    func startButtonTapped() {
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultsFlag_seenIntroVideo) {
            displayMode = .intro
            UserDefaults.standard.set(true, forKey: Constants.userDefaultsFlag_seenIntroVideo)
        } else {
            displayMode = .default
            landingView.startButton.isEnabled = false
                DispatchQueue.global().async {
                    self.landingViewModel.tryInitializeSdk(context: self) { [weak self] success, errorMsg in
                        DispatchQueue.main.async {
                            guard let self = self else {
                                return
                            }
                            self.landingView.startButton.isEnabled = true
                            guard success else {
                                self.showError(error: errorMsg ?? "Unknown error")
                                self.landingView.resetOpenButton()
                                return
                            }
                            self.landingViewModel.requestPermissionsAndProceed(context: self) { success, errorMsg in
                                
                                    self.startScanningScreen()
                            }
                        }
                }
            }
        }
    }
    
    func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func cancelButtonTapped() {
        displayMode = .default
    }
    
    func tutorialButtonTapped() {
        displayMode = .intro
    }

    func startScanningScreen() {
        landingView.startButton.isEnabled = true
        let scanVC = ScanViewController()
        scanVC.delegate = self
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
}

// MARK: - LandingViewModelDelegate
extension LandingViewController: LandingViewModelDelegate {
    func authenticationSuccessfully() {
        startScanningScreen()
    }
    
    func showError(error: String) {
        landingView.startButton.isEnabled = true
        self.displayAlert(title: "error.title".localized(), message: error)
    }
}

extension LandingViewController: ScanViewControllerDelegate {
    
    func startRecorderFlow(uuid: String) {
        self.navigationController?.popToViewController(self, animated: false)
        let vc = RecorderViewController(uuid: uuid)
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
