import UIKit

protocol ButtonsResultViewDelegate: AnyObject {
    func okButtonTapped()
    func detailsButtonTapped()
}

class ButtonsResultView: UIView {
    
    // MARK: - UI properties
    private lazy var okButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.ok".localized())
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = FontStruct.proximaNovaBold23
        button.layer.cornerRadius = 15
        return button
    }()
    
    private lazy var detailsButton: ATDSideButton = {
        let button = ATDSideButton(title: "result.label.details".localized())
        button.addTarget(self, action: #selector(detailsButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = FontStruct.proximaNovaBold23
        button.layer.cornerRadius = 15
        return button
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ButtonsResultViewDelegate?
    
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
private extension ButtonsResultView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(okButton)
        self.addSubview(detailsButton)
    }
    
    func setupLayout() {
        okButton.snp.makeConstraints { make in
            make.bottom.equalTo(detailsButton.snp.top).offset(-20)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
        
        detailsButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-35)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
    }
    
    // MARK: - Actions
    @objc
    func okButtonTapped() {
        delegate?.okButtonTapped()
    }
    
    @objc
    func detailsButtonTapped() {
        delegate?.detailsButtonTapped()
    }
}
