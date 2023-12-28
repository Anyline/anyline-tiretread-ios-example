import UIKit

protocol ButtonsSettingsViewDelegate: AnyObject {
    func okButtontapped()
    func testUploadButtonTapped()
    func cancelButtonTapped()
}

class ButtonsSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var okButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.ok".localized())
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var testUploadButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.test_setup".localized())
        button.addTarget(self, action: #selector(testUploadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.cancel".localized())
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ButtonsSettingsViewDelegate?
    
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
private extension ButtonsSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(okButton)
        self.addSubview(testUploadButton)
        self.addSubview(cancelButton)
    }
    
    func setupLayout() {
        okButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        }
        
        testUploadButton.snp.makeConstraints { make in
            make.top.equalTo(okButton.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(cancelButton.snp.top).offset(-10)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        }
    }
    
    // MARK: - Actions
    @objc
    func okButtonTapped() {
        delegate?.okButtontapped()
    }
    
    @objc
    func testUploadButtonTapped() {
        delegate?.testUploadButtonTapped()
    }
    
    @objc
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
    
}
