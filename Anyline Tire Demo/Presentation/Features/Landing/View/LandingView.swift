import UIKit

class LandingView: UIView {
    
    // MARK: - UI properties
    lazy var startButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.start".localized())
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.settings".localized())
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: TextLandingView = {
        let view = TextLandingView()
        return view
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: LandingButtonActionsDelegate?
    
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
private extension LandingView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(startButton)
        self.addSubview(settingsButton)
        self.addSubview(textView)
    }
    
    func setupLayout() {
        startButton.snp.makeConstraints({ make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        settingsButton.snp.makeConstraints({ make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        textView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.equalTo(40)
            make.trailing.equalTo(startButton.snp.leading).offset(-40)
        }
    }
    
    // MARK: - Actions
    @objc
    func startButtonTapped() {
        delegate?.startButtonTapped()
    }
    
    @objc
    func settingsButtonTapped() {
        delegate?.settingsButtonTapped()
    }
}
