import UIKit

class AnimationLoadingView: UIView {
    
    private var titlesWithMessages: [(title: String, message: String)] = [
        ("Fun fact!", "A tire check today, keeps you safe and on your way!"),
        ("Did you know?", "Worn tires have less grip.\nReplace them when signs of wear appear!"),
        ("Did you know?","Tires are designed for diverse driving conditions.\nTread patterns keep you safe in rain and snow!"),
        ( "Fun fact!","The world’s largest tire is over 24 meters tall.\nIt was used as a Ferris wheel in the 1964 World’s Fair!"),
        ("Fun fact!","Lego is the world's largest tire producer.\nThey make over 300 million tires annually!"),
        ("Did you know?","11,000 accidents per year are due to a bad tire.\nMake sure to check your tires regularly!"),
        ("Did you know?","Tires are getting quieter.\nTread patterns play a key role in minimising road noise!"),
        ("Did you know?","In the early 1900s, tires were grey or beige.\nAdding carbon made them change colour to black.")
    ]
    
    private var title: ATDTitleLabel? = nil
    private var message: ATDTextLabel? = nil

    
    private func getTitle(text: String) -> ATDTitleLabel {
        let label = ATDTitleLabel(textColor: ColorStruct.stoneGrey, text: text)
        label.textAlignment = .center
        return label
    }
    
    private func getMessage(text: String) -> ATDTextLabel {
        let label = ATDTextLabel(text: text)
        label.textAlignment = .center
        return label
    }
    
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_loading_screen_tire"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var measurementUUIDLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Scan ID: {UUID}")
        label.textAlignment = .left
        return label
    }()
    
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
        
        let randomInt = Int.random(in: 0..<8)
        
        title = getTitle(text: titlesWithMessages[randomInt].title)
        message = getMessage(text: titlesWithMessages[randomInt].message)
        message?.makeMultiline()
    }
    
    func addSubviews() {
        if(title != nil){
            self.addSubview(title!)
        }
        if(message != nil) {
            self.addSubview(message!)
        }
        self.addSubview(loadingImageView)
        self.addSubview(measurementUUIDLabel)
    }
    
    func setupLayout() {
        self.title?.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalTo(self)
        }
        
        self.message?.snp.makeConstraints { make in
            make.top.equalTo(60)
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
