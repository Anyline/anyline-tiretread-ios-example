import UIKit

protocol ButtonsFeedbackViewDelegate: AnyObject {
    func submitButtonTapped()
    func cancelButtonTapped()
}

class ButtonsFeedbackView: UIView {
    
    // MARK: - UI properties
    private lazy var submitButton: ATDSideButton = {
        let button = ATDSideButton(title: "feedback.button.submit".localized())
        button.titleLabel?.font = FontStruct.proximaNovaBold23
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: ATDSideButton = {
        let button = ATDSideButton(title: "feedback.button.cancel".localized())
        button.titleLabel?.font = FontStruct.proximaNovaBold23
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ButtonsFeedbackViewDelegate?
    
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
private extension ButtonsFeedbackView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(submitButton)
        self.addSubview(cancelButton)
    }
    
    func setupLayout() {
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(140)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
    }
    
    // MARK: - Actions
    @objc
    func submitButtonTapped() {
        delegate?.submitButtonTapped()
    }

    @objc
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
    
}
