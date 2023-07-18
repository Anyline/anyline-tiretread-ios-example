import UIKit

class LoadingView: UIView {
    
    // MARK: - UI properties
    private lazy var abortButton: ATDSideButton = {
        let button = ATDSideButton(title: "scan.button.abort".localized())
        button.addTarget(self, action: #selector(abortButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var customView: AnimationLoadingView = {
        let view = AnimationLoadingView()
        return view
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: LoadingButtonActionsDelegate?
    
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
private extension LoadingView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(customView)
        self.addSubview(abortButton)
    }
    
    func setupLayout() {
        
        customView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        abortButton.snp.makeConstraints { make in
            make.bottom.equalTo(-60)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
    }
    
    // MARK: - Actions
    @objc
    func abortButtonTapped() {
        delegate?.abortButtonTapped()
    }
}
