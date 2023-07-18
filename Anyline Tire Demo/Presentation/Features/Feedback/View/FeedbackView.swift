import UIKit

class FeedbackView: UIView {
    
    // MARK: - UI properties
    private lazy var buttonsView: ButtonsFeedbackView = {
        let view = ButtonsFeedbackView()
        return view
    }()
    
    private lazy var feedbackLabel: ATDSideTitleLabel = {
        let label = ATDSideTitleLabel(text: "feedback.title".localized())
        return label
    }()
    
    lazy var tireDepthsView: TireDepthsFeedbackView = {
       let view = TireDepthsFeedbackView()
        return view
    }()
    
    lazy var feedbackTextField: ATDTextField = {
        let textField = ATDTextField(backgroundColor: ColorStruct.skyGrey)
        textField.placeholder = "Insert your feedback here..."
        textField.font = FontStruct.proximaNovaRegular12
        textField.placeholderColor = .lightGray
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    lazy var measurementUUIDLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Scan ID: {UUID}")
        label.font = FontStruct.proximaNovaRegular12
        return label
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = spacing
        return stackView
    }()
    
    // MARK: - Private Properties
    private let spacing: CGFloat = 15
    
    // MARK: - Public properties
    weak var delegate: FeedbackButtonActionsDelegate?
    
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
private extension FeedbackView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(buttonsView)
        self.addSubview(feedbackLabel)
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(tireDepthsView)
        self.contentVStackView.addArrangedSubview(feedbackTextField)
        self.contentVStackView.addArrangedSubview(measurementUUIDLabel)
    }
    
    func setupLayout() {
        self.buttonsView.snp.makeConstraints { make in
            make.trailing.bottom.top.equalToSuperview()
            make.width.equalTo(200)
        }
        
        self.feedbackLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.leading.equalTo(0)
            make.width.equalTo(210)
            make.height.equalTo(40)
        }
        
        self.feedbackTextField.snp.makeConstraints { make in
            make.width.equalTo(440)
            make.height.equalTo(90)
        }
        
        self.contentVStackView.snp.makeConstraints { make in
            make.trailing.equalTo(buttonsView.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(feedbackLabel.snp.bottom).offset(3)
            make.bottom.leading.equalTo(0)
        }
  
    }
    
    func setDelegates() {
        buttonsView.delegate = self
        feedbackTextField.delegate = self
    }
}

// MARK: - ButtonsFeedbackViewDelegate
extension FeedbackView: ButtonsFeedbackViewDelegate {
    func submitButtonTapped() {
        delegate?.submitButtonTapped()
    }
    
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
}

// MARK: - UITextFieldDelegate
extension FeedbackView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.feedbackTextField.resignFirstResponder()
        return true
    }
}
