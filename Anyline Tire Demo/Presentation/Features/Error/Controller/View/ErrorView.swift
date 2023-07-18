import UIKit

class ErrorView: UIView {
    
    // MARK: - UI properties
    
    private lazy var errorView: DescriptionErrorView = {
        let view = DescriptionErrorView()
        return view
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
    }
    
    func setupLayout() {
        self.okButton.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        }
        
        self.errorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalTo(120)
            make.width.equalTo(500)
            make.height.equalTo(250)
        }
    }
    
    // MARK: - Actions
    @objc
    func okButtonTapped() {
        delegate?.okButtonTapped()
    }
}
