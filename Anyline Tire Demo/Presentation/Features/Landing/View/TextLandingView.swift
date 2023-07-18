import UIKit

class TextLandingView: UIView {
    
    // MARK: - UI properties
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStruct.proximaNovaBold40
        label.textColor = ColorStruct.anylineBlue
        label.textAlignment = .left
        label.numberOfLines = 2
        label.text = "landing.label.welcome".localized()
        return label
    }()
    
    private lazy var startLabel: UILabel = {
        let label = UILabel()
        let string = "To start scanning, press the START button"
        let attributedString = NSMutableAttributedString(string: string)

        // Set the font to Helvetica
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaRegular24!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: string.count))

        // Set the color and font weight for the word "START"
        let startRange = (string as NSString).range(of: "START")
        attributedString.addAttribute(.foregroundColor, value: ColorStruct.anylineBlue, range: startRange)
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaBold24!, range: startRange)

        // Create a label and set the attributed text
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        let string = "For best scanning practices, please go to tiretreaddocu.anyline.com"
        let attributedString = NSMutableAttributedString(string: string)

        attributedString.addAttribute(.font, value: FontStruct.proximaNovaRegular20!, range: NSRange(location: 0, length: string.count))

        // Add an underline to the URL
        let urlRange = (string as NSString).range(of: "tiretreaddocu.anyline.com")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: urlRange)
        
        // Add a tap gesture recognizer to handle clicks on the URL
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        label.textAlignment = .left
        label.attributedText = attributedString
        label.textColor = .black
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Actions
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let url = URL(string: "https://tiretreaddocu.anyline.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

// MARK: - Private functions
private extension TextLandingView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(welcomeLabel)
        self.addSubview(startLabel)
        self.addSubview(infoLabel)
    }
    
    func setupLayout() {
        welcomeLabel.snp.makeConstraints({ make in
            make.leading.top.trailing.equalTo(20)
        })
        
        startLabel.snp.makeConstraints({ make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(30)
            make.leading.trailing.equalTo(20)
        })
        
        infoLabel.snp.makeConstraints({ make in
            make.leading.trailing.equalTo(20)
            make.bottom.equalTo(-20)
        })
    }
}
