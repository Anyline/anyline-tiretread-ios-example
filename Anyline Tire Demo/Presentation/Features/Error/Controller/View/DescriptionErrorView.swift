import UIKit

class DescriptionErrorView: UIView {
    
    // MARK: - UI properties
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
    }
    
    func setupLayout() {
        errorDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.bottom.equalTo(-40)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
    }
}
