import UIKit

protocol AccuracySpeedSettingsViewDelegate: AnyObject {
    func switchChanged(mySwitch: UISwitch)
}

class AccuracySpeedSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var accuracySpeedLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.accuraccy_speed".localized())
        return label
    }()
    
    private var accuracySpeedSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.thumbTintColor = ColorStruct.anylineBlue
        mySwitch.tintColor = ColorStruct.skyGrey
        mySwitch.onTintColor = ColorStruct.skyGrey
        mySwitch.isOn = UserDefaultsManager.shared.imageQualitySwitchValue
        mySwitch.addTarget(AccuracySpeedSettingsView.self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        return mySwitch
    }()
    
    private lazy var accuracyLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.high_accuracy".localized())
        return label
    }()
    
    private lazy var accuracySpeedHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 20
        return stackView
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: AccuracySpeedSettingsViewDelegate?
    
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
private extension AccuracySpeedSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(accuracySpeedHStackView)
        self.accuracySpeedHStackView.addArrangedSubview(accuracySpeedLabel)
        self.accuracySpeedHStackView.addArrangedSubview(accuracySpeedSwitch)
        self.accuracySpeedHStackView.addArrangedSubview(accuracyLabel)
    }
    
    func setupLayout() {
        self.accuracySpeedHStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.accuracySpeedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accuracySpeedSwitch.snp.centerY)
        }
        
        self.accuracyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accuracySpeedSwitch.snp.centerY)
        }
    }
    
    // MARK: - Actions
    @objc func switchChanged(mySwitch: UISwitch) {
        self.delegate?.switchChanged(mySwitch: mySwitch)
    }
}
