import UIKit
import AnylineTireTreadSdk

class DescriptionErrorView: UIView {
    
    // MARK: - UI properties
    private lazy var errorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "error.scan.title".localized()
        label.textColor = ColorStruct.snowWhite
        label.textAlignment = .center
        label.font = FontStruct.proximaNovaBold20
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "error.scan.description".localized()
        label.textColor = ColorStruct.snowWhite
        label.textAlignment = .center
        label.font = FontStruct.proximaNovaBold20
        label.numberOfLines = 0
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
    
    
    func setError(code: String?, message: String?) {
        if(code != nil) {
            let errorCode = code ?? "error.scan.title".localized()
            errorTitleLabel.text = "Error: " + errorCode
        }
        errorDescriptionLabel.text = message
    }
}

// MARK: - Private functions
private extension DescriptionErrorView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.seaCoral
        layer.cornerRadius = 10
    }
    
    func addSubviews() {
        self.addSubview(errorDescriptionLabel)
        self.addSubview(errorTitleLabel)
    }
    
    func setupLayout() {
        errorTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        errorDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(errorTitleLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
