import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var customView: SettingsView = {
        let view = SettingsView()
        return view
    }()
    
    // MARK: - Private Properties
    private var switchValueButton: Bool = UserDefaultsManager.shared.imageQualitySwitchValue
    private var imperialSystem: Bool = UserDefaultsManager.shared.imperialSystem
    private lazy var settingsViewModel: SettingsViewModel = {
        return SettingsViewModel(delegate: self)
    }()
    
    // MARK: - Public Properties
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        setupLayout()
        customView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    func saveImageQuality() {
        if switchValueButton {
            // High accuracy
            UserDefaultsManager.shared.imageQuality = 95
        } else {
            // High speed
            UserDefaultsManager.shared.imageQuality = 50
        }
        UserDefaultsManager.shared.imageQualitySwitchValue = switchValueButton
    }
    
    func saveImperialSystem() {
        if imperialSystem {
            // Use inch
            UserDefaultsManager.shared.imperialSystem = true
        } else {
            // Use mm
            UserDefaultsManager.shared.imperialSystem = false
        }
    }
    
    func saveLicenseID() {
        let keychainManager = KeychainManager()
        let licenseIDText = customView.licenseView.licenseIdTextField.text
        if let licenceID = keychainManager.getValue(forKey: KeychainKeys.licenseID) {
            if licenceID != licenseIDText {
                if let safeLicenseIDText = licenseIDText {
                    keychainManager.save(safeLicenseIDText, forKey: KeychainKeys.licenseID)
                }
            }
        } else {
            if let safeLicenseIDText = licenseIDText {
                keychainManager.save(safeLicenseIDText, forKey: KeychainKeys.licenseID)
            }
        }
    }
    
}

// MARK: - Private UI Functions
private extension SettingsViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        
        customView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Private Actions
private extension SettingsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let keyboardHeight = keyboardFrame.size.height - 100
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - SettingsButtonActionsDelegate
extension SettingsViewController: SettingsButtonActionsDelegate {
    func okButtonTapped() {
        saveImperialSystem()
        saveLicenseID()
        saveImageQuality()
        navigationController?.popViewController(animated: true)
    }
    
    func testUploadButtonTapped() {
        self.settingsViewModel.testSetup(context: self)
    }
    
    func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.image == UIImage(systemName: "checkmark.square") {
            tappedImage.image = UIImage(systemName: "square")
            self.imperialSystem = false
        } else {
            tappedImage.image = UIImage(systemName: "checkmark.square")
            self.imperialSystem = true
        }
    }
    
    func switchChanged(mySwitch: UISwitch) {
        self.switchValueButton = mySwitch.isOn
    }
    
}

extension SettingsViewController: SettingsViewModelDelegate {
    
    func showSuccess() {
        self.displayAlert(title: "success.title".localized(), message: "success.description".localized())
    }
    
    func showError(error: String) {
        self.displayAlert(title: "error.title".localized(), message: error)
    }
}
