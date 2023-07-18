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
    
    private lazy var accuracySpeedView: AccuracySpeedSettingsView = {
        let view = AccuracySpeedSettingsView()
        return view
    }()
    
    lazy var infoView: InfoSettingsView = {
        let view = InfoSettingsView()
        return view
    }()
    
    // MARK: - Private Properties
    private let spacing: CGFloat = 20
    
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
    }
    
    func addSubviews() {
        self.addSubview(buttonsView)
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(settingsLabel)
        self.contentVStackView.addArrangedSubview(imperialSystemView)
        self.contentVStackView.addArrangedSubview(licenseView)
        self.contentVStackView.addArrangedSubview(accuracySpeedView)
        self.contentVStackView.addArrangedSubview(infoView)
    }
    
    func setupLayout() {
        buttonsView.snp.makeConstraints { make in
            make.trailing.bottom.top.equalToSuperview()
            make.width.equalTo(200)
        }
        
        contentVStackView.snp.makeConstraints { make in
            make.leading.equalTo(80)
            make.trailing.equalTo(buttonsView.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(20)
            make.bottom.equalTo(0)
        }
        
        settingsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaInsets.top)
            make.centerX.equalTo(self)
        }
    }
    
    func setDelegates() {
        buttonsView.delegate = self
        imperialSystemView.delegate = self
        accuracySpeedView.delegate = self
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

// MARK: - AccuracySpeedSettingsViewDelegate
extension SettingsView: AccuracySpeedSettingsViewDelegate {
    
    func switchChanged(mySwitch: UISwitch) {
        delegate?.switchChanged(mySwitch: mySwitch)
    }
}
