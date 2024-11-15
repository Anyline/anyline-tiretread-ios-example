//
//  LicenseSettingsView 2.swift
//  Anyline Tire Demo
//
//  Created by Patrick Fekete on 15.11.24.
//


import UIKit

class CustomTagSettingsView: UIView {

    // MARK: - UI properties
    private lazy var customTagLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.custom_tag".localized())
        return label
    }()

    lazy var customTagTextField: ATDTextField = {
        let textField = ATDTextField(backgroundColor: ColorStruct.snowWhite)
        textField.placeholder = "settings.label.custom_tag.placeholer".localized()
        textField.returnKeyType = .done
        return textField
    }()

    private lazy var licenseHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 20
        return stackView
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
        customTagTextField.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

// MARK: - Private functions
private extension CustomTagSettingsView {

    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
        customTagTextField.text = UserDefaultsManager.shared.customTag ?? ""
    }

    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(licenseHStackView)
        self.licenseHStackView.addArrangedSubview(customTagLabel)
        self.licenseHStackView.addArrangedSubview(customTagTextField)
    }

    func setupLayout() {

        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        customTagLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        customTagLabel.snp.makeConstraints { make in
            make.centerY.equalTo(customTagTextField.snp.centerY)
        }

        customTagTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(280)
        }
    }
}

// MARK: - UITextFieldDelegate
extension CustomTagSettingsView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.customTagTextField.resignFirstResponder()
        return true
    }
}

