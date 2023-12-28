import UIKit

class InfoSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var appVersionLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.app_sdk_version".localized() + " App: \(SystemInfo.getAppVersion()) - SDK: \(SystemInfo.getSDKVersion())")
        return label
    }()
    
    private lazy var deviceNameLabel: ATDTextLabel = {
        let deviceName = SystemInfo.getDeviceName()
        let label = ATDTextLabel(text: "settings.label.device_name".localized() + " \(deviceName)")
        return label
    }()
    
    lazy var uploadLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.upload".localized() + " {SPEED}")
        label.alpha = 0
        return label
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: - Private functions
private extension InfoSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(appVersionLabel)
        self.contentVStackView.addArrangedSubview(deviceNameLabel)
        self.contentVStackView.addArrangedSubview(uploadLabel)
    }
    
    func setupLayout() {
        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
