import UIKit

class SettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var buttonsView: ButtonsSettingsView = {
        let view = ButtonsSettingsView()
        return view
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        return stackView
    }()

    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var settingsLabel: ATDTitleLabel = {
        let label = ATDTitleLabel(textColor: ColorStruct.stoneGrey, text: "settings.label.settings".localized())
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imperialSystemView: ImperialSystemSettingsView = {
        let view = ImperialSystemSettingsView()
        return view
    }()
    
    lazy var licenseView: LicenseSettingsView = {
        let view = LicenseSettingsView()
        return view
    }()
    
    lazy var infoView: InfoSettingsView = {
        let view = InfoSettingsView()
        return view
    }()

    lazy var captureSpeedView: CaptureSpeedView = {
        let view = CaptureSpeedView()
        view.delegate = self
        return view
    }()

    @objc func didTapQRCode(sender: UIButton) {
        delegate?.scanQRCodeTapped()
    }

    // MARK: - Private Properties
    private let spacing: CGFloat = 15
    
    // MARK: - Public properties
    weak var delegate: SettingsButtonActionsDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
        setupLayout()
        setDelegates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Private functions
private extension SettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
        licenseView.scanQRCodeButton.addTarget(self,
                                               action: #selector(didTapQRCode),
                                               for: .touchUpInside)
    }
    
    func addSubviews() {
        self.addSubview(buttonsView)
        self.addSubview(contentVStackView)

        contentVStackView.addArrangedSubview(settingsLabel)
        contentVStackView.addArrangedSubview(imperialSystemView)
        contentVStackView.addArrangedSubview(licenseView)
        contentVStackView.addArrangedSubview(captureSpeedView)
        contentVStackView.addArrangedSubview(infoView)
    }
    
    func setupLayout() {
        buttonsView.snp.makeConstraints { make in
            make.trailing.bottom.top.equalToSuperview()
            make.width.equalTo(200).priority(.low)
        }

        contentVStackView.snp.makeConstraints { make in
            make.leading.equalTo(80)
            make.width.equalTo(500)
            make.top.equalTo(20)
            make.bottom.equalTo(0)
        }

        captureSpeedView.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        settingsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaInsets.top)
            make.centerX.equalTo(self)
        }
    }
    
    func setDelegates() {
        buttonsView.delegate = self
        imperialSystemView.delegate = self
    }
}

// MARK: - ButtonsSettingsViewDelegate
extension SettingsView: ButtonsSettingsViewDelegate {
    
    func okButtontapped() {
        delegate?.okButtonTapped()
    }
    
    func testUploadButtonTapped() {
        delegate?.testUploadButtonTapped()
    }
    
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
}

// MARK: - ImperialSystemViewDelegate
extension SettingsView: ImperialSystemSettingsViewDelegate {
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.imageTapped(tapGestureRecognizer: tapGestureRecognizer)
    }
}

extension SettingsView: CaptureSpeedViewDelegate {
    func buttonTapped(sender: UIButton) {
        delegate?.scanSpeedDialogRequested(sender: sender, options: [.fast, .slow], completion: { scanSpeed in
            if let scanSpeed = scanSpeed {
                self.captureSpeedView.scanSpeed = scanSpeed
            }
        })
    }
}
