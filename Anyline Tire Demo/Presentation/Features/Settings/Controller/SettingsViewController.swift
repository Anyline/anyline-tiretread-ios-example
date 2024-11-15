import UIKit
import AnylineTireTreadSdk

class SettingsViewController: UIViewController {
    
    // MARK: - UI Properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var settingsView: SettingsView = {
        let view = SettingsView()
        return view
    }()
    
    // MARK: - Private Properties
    private var imperialSystem: Bool = UserDefaultsManager.shared.imperialSystem
    private var showGuidance: Bool = UserDefaultsManager.shared.showGuidance
    private var scanSpeed: ScanSpeed = UserDefaultsManager.shared.scanSpeed
    private var customTag: String? = UserDefaultsManager.shared.customTag

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
        settingsView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func saveShowGuidance() {
        if showGuidance {
            UserDefaultsManager.shared.showGuidance = true
        } else {
            UserDefaultsManager.shared.showGuidance = false
        }
    }
    
    func saveLicenseID() {
        let keychainManager = KeychainManager()
        let licenseIDText = settingsView.licenseView.licenseIdTextField.text
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
    
    func saveCustomTag() {
        let text = settingsView.customTagView.customTagTextField.text
        
        if(text != nil) {
            UserDefaultsManager.shared.customTag = text
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
        self.view.addSubview(settingsView)
    }
    
    func setupLayout() {
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        settingsView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Private Actions
private extension SettingsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {

        // the field that caused the software keyboard to display
        // TODO: maybe use the main responder
        let field = self.settingsView.licenseView.licenseIdTextField

        guard let userInfo = notification.userInfo else { return }

        // Get the keyboard’s frame at the end of its animation.
        guard let screen = notification.object as? UIScreen,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let fromCoordinateSpace = screen.coordinateSpace

        let toCoordinateSpace: UICoordinateSpace = view

        // Convert the keyboard's frame from the screen's coordinate space to your view's coordinate space.
        let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)

        let yMargin = 10.0 // min distance we allow between the field's bottom and the keyboard
        
        let fieldBottomY = (field.convert(field.frame.origin, to: screen.coordinateSpace).y +
                            field.bounds.height +
                            yMargin)

        var shift = 0.0
        if convertedKeyboardFrameEnd.minY < fieldBottomY {
            shift = convertedKeyboardFrameEnd.minY - fieldBottomY
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = shift
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

    func scanQRCodeTapped() {
        QRCodeReaderViewController.showReader(over: self.navigationController!,
                                              msg: "qrcodereader.guide_text.license_key".localized(),
                                              animated: true) { [weak self] qrViewController, decoded in
            guard let decoded = decoded else {
                return
            }
            if let licenseKeyString = self?.returnValidLicenseKey(decoded) {
                self?.settingsView.licenseView.licenseIdTextField.text = licenseKeyString
                qrViewController.dismiss(animated: true)
            } else {
                let msg = "qrcodereader.message.invalid_license_key".localized()
                self?.showAlertQRCode(over: qrViewController, msg: msg)
            }
        }
    }

    func showAlertQRCode(over qrViewController: QRCodeReaderViewController, msg: String) {
        let alert = UIAlertController(title: "Scan License Key", message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            qrViewController.restart()
        }))
        qrViewController.present(alert, animated: true)
    }

    fileprivate func returnValidLicenseKey(_ licenseKeyString: String) -> String? {
        return licenseKeyString
    }

    func scanSpeedDialogRequested(sender: UIButton, options: [ScanSpeed], completion: (ScanSpeed?) -> Void) {
        let alert = UIAlertController(title: "Select Capture Speed", message: nil, preferredStyle: .actionSheet)

        for speed in options {
            let title = speed.name
            alert.addAction(.init(title: title, style: .default, handler: { [weak self] action in
                print("preset tapped: \(title) for preset \(speed.name)")
                self?.settingsView.captureSpeedView.scanSpeed = speed
                UserDefaultsManager.shared.scanSpeed = speed
            }))
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))

        let popoverController = alert.popoverPresentationController
        popoverController?.sourceView = sender
        popoverController?.sourceRect = sender.bounds
        popoverController?.permittedArrowDirections = .up

        self.navigationController?.present(alert, animated: true)
    }
    
    func okButtonTapped() {
        saveImperialSystem()
        saveShowGuidance()
        saveLicenseID()
        saveCustomTag()
        navigationController?.popViewController(animated: true)
    }
    
    func testUploadButtonTapped() {
        let licenseKey = settingsView.licenseView.licenseIdTextField.text ?? ""
        self.settingsViewModel.testLicenseKey(licenseKey, context: self)
    }
    
    func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func imperialSystemImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.image == UIImage(systemName: "checkmark.square") {
            tappedImage.image = UIImage(systemName: "square")
            self.imperialSystem = false
        } else {
            tappedImage.image = UIImage(systemName: "checkmark.square")
            self.imperialSystem = true
        }
    }
    
    func showGuidanceImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.image == UIImage(systemName: "checkmark.square") {
            tappedImage.image = UIImage(systemName: "square")
            self.showGuidance = false
        } else {
            tappedImage.image = UIImage(systemName: "checkmark.square")
            self.showGuidance = true
        }
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
