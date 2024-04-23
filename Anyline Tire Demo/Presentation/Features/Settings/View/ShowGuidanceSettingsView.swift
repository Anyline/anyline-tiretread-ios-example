import UIKit

protocol ShowGuidanceSettingsViewDelegate: AnyObject {
    func showGuidanceImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
}

class ShowGuidanceSettingsView: UIView {
    
    // MARK: - UI properties
    private lazy var showGuidanceLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.show_guidance".localized())
        label.textAlignment = .right
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UserDefaultsManager.shared.showGuidance ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square"))
        imageView.tintColor = ColorStruct.stoneGrey
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    private lazy var showGuidanceHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ShowGuidanceSettingsViewDelegate?
    
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
private extension ShowGuidanceSettingsView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(showGuidanceHStackView)
        self.showGuidanceHStackView.addArrangedSubview(showGuidanceLabel)
        self.showGuidanceHStackView.addArrangedSubview(checkmarkImageView)
    }
    
    func setupLayout() {
        showGuidanceHStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        showGuidanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkmarkImageView.snp.centerY)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
    }
    
    // MARK: - Actions
    @objc
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.showGuidanceImageTapped(tapGestureRecognizer: tapGestureRecognizer)
    }
}

