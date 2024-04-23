import UIKit

protocol ImperialSystemSettingsViewDelegate: AnyObject {
    func imperialSystemImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
}

class ImperialSystemSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var imperialSystemLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.use_imperial_system".localized())
        label.textAlignment = .right
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UserDefaultsManager.shared.imperialSystem ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square"))
        imageView.tintColor = ColorStruct.stoneGrey
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    private lazy var imperialSystemHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ImperialSystemSettingsViewDelegate?
    
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
private extension ImperialSystemSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(imperialSystemHStackView)
        self.imperialSystemHStackView.addArrangedSubview(imperialSystemLabel)
        self.imperialSystemHStackView.addArrangedSubview(checkmarkImageView)
    }
    
    func setupLayout() {
        imperialSystemHStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imperialSystemLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkmarkImageView.snp.centerY)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
    }
    
    // MARK: - Actions
    @objc
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.imperialSystemImageTapped(tapGestureRecognizer: tapGestureRecognizer)
    }
}

