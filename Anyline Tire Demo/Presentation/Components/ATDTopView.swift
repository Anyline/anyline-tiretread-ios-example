import UIKit

class ATDTopView: UIView {
    
    // MARK: - UI Properties
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "anyline_logo_black")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var appNameLabel: UILabel = {
        let label = UILabel()
        let boldText = "TIRE TREAD"
        let regularText = " Showcase"
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: FontStruct.proximaNovaBold24!]
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: FontStruct.proximaNovaRegular24!]
        let attributedString1 = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
        let attributedString2 = NSAttributedString(string: regularText, attributes: regularAttributes)
        attributedString1.append(attributedString2)
        label.attributedText = attributedString1
        label.textColor = ColorStruct.snowWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Properties

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

    // MARK: - Functions
}

// MARK: - Private functions
private extension ATDTopView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.stoneGrey
    }
    
    func addSubviews() {
        self.addSubview(logoImageView)
        self.addSubview(appNameLabel)
    }
    
    func setupLayout() {
        
        self.logoImageView.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.width.equalTo(150)
            make.leading.equalTo(25)
            make.top.equalTo(9)
            make.bottom.equalTo(-9)
        }
        
        self.appNameLabel.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.trailing.equalTo(16)
            make.top.equalTo(11)
            make.bottom.equalTo(-11)
        }
    }
}
