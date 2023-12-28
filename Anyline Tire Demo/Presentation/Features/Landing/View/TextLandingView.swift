import UIKit

class TextLandingView: UIView, UIGestureRecognizerDelegate {

    enum Constants {
        static let documentationUrlFull = "https://tiretreaddocu.anyline.com"
        static let documentationUrlShort = "tiretreaddocu.anyline.com"
    }

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
    
    private lazy var startTextView: UITextView = {
        let textView = UITextView()

        textView.backgroundColor = .white
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.contentInset = .zero
        textView.isEditable = false
        textView.isSelectable = false

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10

        let tutorialText = "landing.text.tutorial".localized()
        let startScanningText = "landing.text.start".localized()

        var attributedString = NSMutableAttributedString(string: tutorialText)
        attributedString.append(.init(string: "\n"))
        attributedString.append(.init(.init(startScanningText)))

        let string = attributedString.string as NSString
        let range = NSRange(location: 0, length: string.length)

        // Set the font
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaRegular24!, range: range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)

        // line height
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

        // Bold the tutorial line
        let tutorialRange = string.range(of: tutorialText)
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaBold24!, range: tutorialRange)

        // Set the attributes for the word "START" and "TUTORIAL"
        var blueRange = string.range(of: "landing.button.start".localized())
        attributedString.addAttribute(.foregroundColor, value: ColorStruct.anylineBlue, range: blueRange)
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaBold24!, range: blueRange)

        blueRange = string.range(of: "landing.button.tutorial".localized())
        attributedString.addAttribute(.foregroundColor, value: ColorStruct.anylineBlue, range: blueRange)
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaBold24!, range: blueRange)

        // Create a label and set the attributed text
        textView.attributedText = attributedString
        return textView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        let string = "landing.text.info".localized()
        let attributedString = NSMutableAttributedString(string: string)

        attributedString.addAttribute(.font, value: FontStruct.proximaNovaRegular20!, range: NSRange(location: 0, length: string.count))

        // Add an underline to the URL
        let urlRange = (string as NSString).range(of: Constants.documentationUrlShort)
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


    // MARK: - Public properties
    var delegate: LandingTextViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
        setupLayout()

        // add gesture recognizer for the text view
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        tap.delegate = self
        startTextView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Actions
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let url = URL(string: Constants.documentationUrlFull) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc
    func handleTextViewTap(_ sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager

        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;

        let characterIndex = layoutManager.characterIndex(for: location,
                                                          in: myTextView.textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)

        let string = myTextView.attributedText.string as NSString
        let startRange = string.range(of: "landing.button.start".localized())
        let tutorialRange = string.range(of: "landing.button.tutorial".localized())

        if characterIndex >= startRange.location && characterIndex < startRange.location + startRange.length {
            delegate?.startTapped()
        } else if characterIndex >= tutorialRange.location && characterIndex < tutorialRange.location + tutorialRange.length {
            delegate?.tutorialTapped()
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
        self.addSubview(startTextView)
        self.addSubview(infoLabel)
    }
    
    func setupLayout() {
        welcomeLabel.snp.makeConstraints({ make in
            make.leading.top.trailing.equalTo(20)
        })
        
        startTextView.snp.makeConstraints({ make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(30)
            make.leading.trailing.equalTo(20)
        })
        
        infoLabel.snp.makeConstraints({ make in
            make.leading.trailing.equalTo(20)
            make.bottom.equalTo(-20)
        })
    }
}
