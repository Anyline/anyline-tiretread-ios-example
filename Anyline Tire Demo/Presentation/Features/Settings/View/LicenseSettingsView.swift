import UIKit

class LicenseSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var licenseIdLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.license_id".localized())
        return label
    }()
    
    lazy var licenseIdTextField: ATDTextField = {
        let textField = ATDTextField(backgroundColor: ColorStruct.snowWhite)
        textField.placeholder = "settings.label.license_id".localized()
        if let licenceID = KeychainManager().getValue(forKey: KeychainKeys.licenseID) {
            textField.text = licenceID
        }
        return textField
    }()
    
    private lazy var licenseHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var supportLabel: ATDTextLabel = {
        let emailAddress = "presales@anyline.com"
        let label = ATDTextLabel(text: "")

        // Create a string with the email address
        let string = "If you need a license please reach out to \(emailAddress)."

        // Create an attributed string with a link attribute for the email address
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: emailAddress)
        let url = URL(string: "mailto:\(emailAddress)")!
        attributedString.addAttribute(.link, value: url, range: range)

        // Set the attributed string for the label
        label.attributedText = attributedString
        label.font = FontStruct.proximaNovaBold14
        // Enable user interaction for the label
        label.isUserInteractionEnabled = true

        // Add a tap gesture recognizer to the label to handle link tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap(_:)))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
        setupLayout()
        licenseIdTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: - Private functions
private extension LicenseSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
        
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(licenseHStackView)
        self.licenseHStackView.addArrangedSubview(licenseIdLabel)
        self.licenseHStackView.addArrangedSubview(licenseIdTextField)
        self.contentVStackView.addArrangedSubview(supportLabel)
    }
    
    func setupLayout() {
        
        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        licenseIdLabel.snp.makeConstraints { make in
            make.centerY.equalTo(licenseIdTextField.snp.centerY)
        }
        
        licenseIdTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(450)
        }
        
    }
    
    // MARK: - Actions
    @objc func handleLinkTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        guard let attributedString = label.attributedText else { return }
        
        let location = gesture.location(in: label)
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if let url = attributedString.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UITextFieldDelegate
extension LicenseSettingsView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.licenseIdTextField.resignFirstResponder()
        return true
    }
}

