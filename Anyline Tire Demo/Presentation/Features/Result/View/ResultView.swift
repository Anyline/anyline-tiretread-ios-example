import UIKit

class ResultView: UIView {
    
    // MARK: - UI properties
    private lazy var buttonsView: ButtonsResultView = {
        let view = ButtonsResultView()
        return view
    }()
    
    lazy var tireTreadMeasurementView: TireTreadMeasurementView = {
        let view = TireTreadMeasurementView()
        return view
    }()

    lazy var UUIDLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "Scan ID: {UUID}")
        label.font = FontStruct.proximaNovaRegular12
        return label
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: ResultButtonActionsDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
        setupLayout()
        setDelegates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: - Private functions
private extension ResultView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(buttonsView)
        self.addSubview(tireTreadMeasurementView)
        self.addSubview(UUIDLabel)
    }
    
    func setupLayout() {
        self.buttonsView.snp.makeConstraints { make in
            make.trailing.bottom.top.equalToSuperview()
            make.width.equalTo(170)
        }
        
        self.tireTreadMeasurementView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(buttonsView.snp.leading)
        }

        self.UUIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(0)
            make.trailing.equalTo(-20)
        }
    }
    
    func setDelegates() {
        buttonsView.delegate = self
    }
}

// MARK: - ButtonsResultViewDelegate
extension ResultView: ButtonsResultViewDelegate {
    
    func okButtonTapped() {
        delegate?.okButtonTapped()
    }
    
    func detailsButtonTapped() {
        delegate?.detailsButtonTapped()
    }
    
    func feedbackButtonTapped() {
        delegate?.feedbackButtonTapped()
    }
}
