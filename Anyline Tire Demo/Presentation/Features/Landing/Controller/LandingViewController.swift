import UIKit
import SnapKit

class LandingViewController: UIViewController {
    
    // MARK: - UI properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var customView: LandingView = {
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
        customView.delegate = self
    }
}

// MARK: - Private Functions
private extension LandingViewController {
    func configureView() {
        view.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(customView)
    }
    
    func setupLayout() {
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        customView.snp.makeConstraints({ make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
}

// MARK: - LandingButtonActionsDelegate
extension LandingViewController: LandingButtonActionsDelegate {
    func startButtonTapped() {
        customView.startButton.isEnabled = false
        landingViewModel.tryInitializeSdk(context: self)
    }
    
    func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
}

// MARK: - LandingViewModelDelegate
extension LandingViewController: LandingViewModelDelegate {
    func authenticationSuccessfully() {
        customView.startButton.isEnabled = true
        let scanVC = ScanViewController()
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    func showError(error: String) {
        customView.startButton.isEnabled = true
        self.displayAlert(title: "error.title".localized(), message: error)
    }
}
