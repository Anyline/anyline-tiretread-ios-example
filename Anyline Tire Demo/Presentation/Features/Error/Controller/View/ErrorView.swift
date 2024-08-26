import UIKit
import AnylineTireTreadSdk

class ErrorView: UIView {
    
    // MARK: - UI properties
    
    private lazy var errorView: DescriptionErrorView = {
        let view = DescriptionErrorView()
        return view
    }()
    
    lazy var measurementUUIDLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Scan ID: {UUID}")
        label.textAlignment = .left
        return label
    }()
    
    private lazy var okButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.ok".localized())
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ErrorButtonActionsDelegate?
    
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
    
    // MARK: - Setup UI
    func setError(code: String?, message: String?) {
        errorView.setError(code: code, message: message)
    }
    
    func setUUID(uuid: String) {
        measurementUUIDLabel.text = "Scan ID: \(uuid)"
    }
}

// MARK: - Private functions
private extension ErrorView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(okButton)
        self.addSubview(errorView)
        self.addSubview(measurementUUIDLabel)
    }
    
    func setupLayout() {
        self.okButton.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        }
        
        self.measurementUUIDLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.errorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalTo(120)
            make.width.equalTo(500)
            make.bottom.equalTo(measurementUUIDLabel.snp.top).offset(-30)
        }
    }
    
    // MARK: - Actions
    @objc
    func okButtonTapped() {
        delegate?.okButtonTapped()
    }
}
