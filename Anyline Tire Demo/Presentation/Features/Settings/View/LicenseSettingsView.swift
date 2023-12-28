import UIKit

class LicenseSettingsView: UIView {

    enum Constants {
        static let emailAddress = "presales@anyline.com"
    }

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
        textField.returnKeyType = .done
        return textField
    }()

    // button tap is handled by owner
    lazy var scanQRCodeButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(named: "qr_code_icon"), for: .normal)
        return button
    }()

    private lazy var licenseHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 20
        return stackView
    }()

    private lazy var supportLabel: ATDTextLabel = {
        let emailAddress = Constants.emailAddress
        let label = ATDTextLabel(text: "")

        // Create a string with the email address
        let string = "If you need a license please reach out to \(emailAddress)."

        // Create an attributed string with a link attribute for the email address
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: emailAddress)
        let url = URL(string: "mailto:\(emailAddress)")!
        attributedString.addAttribute(.link, value: url, range: range)

        // NOTE: you cannot set a foreground color at the same range which you
        // also set as a .link, unless you change the underlying type, currently
        // label, to UITextView.

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
        self.licenseHStackView.addArrangedSubview(scanQRCodeButton)
        self.contentVStackView.addArrangedSubview(supportLabel)
    }

    func setupLayout() {

        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        licenseIdLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        licenseIdLabel.snp.makeConstraints { make in
            make.centerY.equalTo(licenseIdTextField.snp.centerY)
        }

        licenseIdTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(280)
            make.trailing.equalTo(scanQRCodeButton.snp.leading).offset(-10)
        }

        scanQRCodeButton.snp.makeConstraints { make in
            make.trailing.equalTo(supportLabel)
            make.centerY.equalTo(licenseIdTextField)
        }
    }

    // MARK: - Actions
    @objc func handleLinkTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        guard let attributedString = label.attributedText else { return }
        let range = (attributedString.string as NSString).range(of: Constants.emailAddress)
        if range.location != NSNotFound,
           let emailURL = attributedString.attribute(.link, at: range.location, effectiveRange: nil) as? URL {
            UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
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

