import UIKit

class TireDepthsFeedbackView: UIView {
    
    // MARK: - UI properties
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var tireImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "tire_feedback")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var tireTreadDepthsHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var tireTreadDepth1: TireDepthFeedbackView = {
        let textField = TireDepthFeedbackView()
        textField.tireTreadDepth.tag = 1
        return textField
    }()
    
    lazy var tireTreadDepth2: TireDepthFeedbackView = {
        let textField = TireDepthFeedbackView()
        textField.tireTreadDepth.tag = 2
        return textField
    }()
    
    lazy var tireTreadDepth3: TireDepthFeedbackView = {
        let textField = TireDepthFeedbackView()
        textField.tireTreadDepth.tag = 3
        return textField
    }()
    
    private lazy var tireTreadLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Insert Manual tread depths")
        label.font = FontStruct.proximaNovaRegular12
        return label
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    
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
private extension TireDepthsFeedbackView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(tireImageView)
        self.contentVStackView.addArrangedSubview(tireTreadDepthsHStackView)
        self.tireTreadDepthsHStackView.addArrangedSubview(tireTreadDepth1)
        self.tireTreadDepthsHStackView.addArrangedSubview(tireTreadDepth2)
        self.tireTreadDepthsHStackView.addArrangedSubview(tireTreadDepth3)
        self.contentVStackView.addArrangedSubview(tireTreadLabel)
    }
    
    func setupLayout() {
        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tireImageView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        tireTreadLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
    }
    
    func setDelegates() {
        tireTreadDepth1.tireTreadDepth.delegate = self
        tireTreadDepth2.tireTreadDepth.delegate = self
        tireTreadDepth3.tireTreadDepth.delegate = self
    }
}

// MARK: - UITextFieldDelegate
extension TireDepthsFeedbackView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            tireTreadDepth2.tireTreadDepth.becomeFirstResponder()
        case 2:
            tireTreadDepth3.tireTreadDepth.becomeFirstResponder()
        case 3:
            tireTreadDepth3.tireTreadDepth.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
            let characterSet = CharacterSet(charactersIn: string)
            let isBackspace = string.isEmpty

            if !characterSet.isSubset(of: allowedCharacters) && !isBackspace {
                return false
            }
            
            if isBackspace {
                return true
            }
            
            let isNumber = Double(string) != nil || (string == "." && textField.text?.contains(".") == false)
            return isNumber
    }
}
