import UIKit

class AnimationLoadingView: UIView {
    
    // MARK: - UI properties
    private lazy var waitingLabel: ATDTitleLabel = {
        let label = ATDTitleLabel(textColor: ColorStruct.stoneGrey, text: "loading.title.waiting".localized())
        label.textAlignment = .center
        return label
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tire_showcase_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var measurementUUIDLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Scan ID: {UUID}")
        label.textAlignment = .left
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
        startRotation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: - Private functions
private extension AnimationLoadingView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(waitingLabel)
        self.addSubview(loadingImageView)
        self.addSubview(measurementUUIDLabel)
    }
    
    func setupLayout() {
        self.waitingLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalTo(self)
        }
        
        self.loadingImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        self.measurementUUIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-30)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
    }
    
    // MARK: - Actions
    func startRotation() {
        // Start rotating the image after a delay to ensure that the animation runs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
            rotationAnimation.duration = 1
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = .greatestFiniteMagnitude
            self.loadingImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    }
}
