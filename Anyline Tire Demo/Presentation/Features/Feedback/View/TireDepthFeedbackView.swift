import UIKit

class TireDepthFeedbackView: UIView {
    
    // MARK: - UI properties
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        return stackView
    }()
    
    private lazy var triangleImage: UIImageView = {
        let imageView = UIImageView()
        let font = UIFont.systemFont(ofSize: 30)
        let symbol = "triangle.fill"
        let attributes: [NSAttributedString.Key : Any] = [.font: font]
        let attributedString = NSAttributedString(string: symbol, attributes: attributes)
        let symbolImage = UIImage.init(systemName: symbol)?.withTintColor(ColorStruct.stoneGrey, renderingMode: .alwaysOriginal)
        imageView.image = symbolImage
        return imageView
    }()
    
    lazy var tireTreadDepth: ATDTextField = {
        let textField = ATDTextField(backgroundColor: ColorStruct.skyGrey)
        textField.layer.cornerRadius = 5
        textField.placeholder = UserDefaultsManager.shared.imperialSystem ? "32”" : "mm"
        textField.placeholderColor = .lightGray
        textField.paragraphStyle.alignment = .center
        textField.textAlignment = .center
        textField.font = FontStruct.proximaNovaRegular12
        textField.keyboardType = .numbersAndPunctuation
        return textField
    }()
    
    // MARK: - Private Properties
    private let spacing: CGFloat = 3
    
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
private extension TireDepthFeedbackView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(triangleImage)
        self.contentVStackView.addArrangedSubview(tireTreadDepth)
    }
    
    func setupLayout() {
        
        contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        triangleImage.snp.makeConstraints { make in
            make.width.equalTo(35)
        }
        
        tireTreadDepth.snp.makeConstraints { make in
            make.width.equalTo(63)
            make.height.equalTo(35)
        }
    }
}
