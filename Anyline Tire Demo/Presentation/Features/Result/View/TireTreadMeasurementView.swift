import UIKit

class TireTreadMeasurementView: UIView {
    
    // MARK: - UI properties
    lazy var globalMeasurementView: MeasurementView = {
        var view = MeasurementView()
        return view
    }()
    
    private lazy var tireImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "tire_image_large")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var bottomTireTreadMeasurementHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        return stackView
    }()
    
    // MARK: - Private Properties
    private let spacing: CGFloat = 10
    
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
private extension TireTreadMeasurementView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = .clear
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(globalMeasurementView)
        self.contentVStackView.addArrangedSubview(tireImageView)
        self.contentVStackView.addArrangedSubview(bottomTireTreadMeasurementHStackView)
    }
    
    func setupLayout() {
        self.contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.bottomTireTreadMeasurementHStackView.snp.makeConstraints { make in
            make.height.equalTo(UserDefaultsManager.shared.imperialSystem ? 61 : 51)
        }
        
        self.tireImageView.snp.makeConstraints { make in
            make.width.equalTo(450)
            make.height.equalTo(150)
        }
    }
}

