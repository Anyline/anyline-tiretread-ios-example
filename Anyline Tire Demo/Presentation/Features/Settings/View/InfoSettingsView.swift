import UIKit

class InfoSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var appVersionLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.app_version".localized() + " \(SystemInfo.getAppVersion())")
        return label
    }()
    
    private lazy var deviceNameLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.device_name".localized() + " \(SystemInfo.getDeviceName())")
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
            make.height.equalTo(100)
        }
    }
}
