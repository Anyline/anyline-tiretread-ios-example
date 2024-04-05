import UIKit
import AnylineTireTreadSdk

class MeasurementView: UIView {
    
    enum Location {
        case global
        case regional
    }
    
    var location: Location = .global
    
    private var isRegional: Bool { location == .regional }
    
    // MARK: - UI properties
    private lazy var tireTreadValueLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: measurementValue ?? "")
        label.font = isRegional ? FontStruct.proximaNovaBold16 : FontStruct.proximaNovaBold23
        label.textColor = ColorStruct.snowWhite
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tireTreadMeasurementLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: unitStr)
        label.font = isRegional ? FontStruct.proximaNovaBold16 : FontStruct.proximaNovaBold23
        label.textColor = ColorStruct.snowWhite
        label.textAlignment = .center
        return label
    }()
    
    private var unitStr: String {
        UserDefaultsManager.shared.imperialSystem ? "32\"" : "mm"
    }
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var emptyMeasurementLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private lazy var contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = UserDefaultsManager.shared.imperialSystem ? 0 : -15
        return stackView
    }()
    
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    var measurementValue: String? = nil {
        didSet {
            guard let measurementValue = measurementValue else {
                self.backgroundColor = .init(white: 0.8, alpha: 1)
                emptyMeasurementLine.isHidden = false
                contentVStackView.isHidden = true
                return
            }
            let metricValue = Double(measurementValue) ?? 0.0
            tireTreadMeasurementLabel.text = unitStr
            
            if UserDefaultsManager.shared.imperialSystem {
                if let doubleValue = Double(measurementValue) {
                    let intValue = Int(doubleValue)
                    tireTreadValueLabel.text = "\(intValue)"
                    self.backgroundColor = getColorFromInchFraction(intValue)
                }
            } else {
                tireTreadValueLabel.text = String(format: "%.1f", metricValue)
                self.backgroundColor = getColorForMetricValue(metricValue)
            }
        }
    }

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(location: MeasurementView.Location = .global) {
        super.init(frame: .zero)
        self.location = location
        
        configureView()
        addSubviews()
        setupLayout()
    }
}

// MARK: - Private functions
private extension MeasurementView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.leafGreen
        layer.cornerRadius = isRegional ? 4 : 5
    }
    
    func addSubviews() {
        self.addSubview(contentVStackView)
        self.contentVStackView.addArrangedSubview(tireTreadValueLabel)
        if UserDefaultsManager.shared.imperialSystem {
            self.contentVStackView.addArrangedSubview(dividerView)
        }
        self.contentVStackView.addArrangedSubview(tireTreadMeasurementLabel)
        self.addSubview(emptyMeasurementLine)
    }
    
    func setupLayout() {
        
        self.snp.makeConstraints { make in
            make.height.equalTo(UserDefaultsManager.shared.imperialSystem ? 61 : 51)
            make.width.equalTo(57)
        }
        
        self.contentVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if UserDefaultsManager.shared.imperialSystem {
            self.dividerView.snp.makeConstraints { make in
                make.height.equalTo(2)
                make.width.equalTo(20)
            }
        }
        
        self.emptyMeasurementLine.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(16)
            make.center.equalToSuperview()
        }
    }
    
    func getColorForMetricValue(_ value: Double) -> UIColor {
        if value < 3.0 {
            return ColorStruct.seaCoral
        } else if value < 4.0 {
            return ColorStruct.beeYellow
        } else {
            return ColorStruct.leafGreen
        }
    }
    
    func getColorFromInchFraction(_ numerator: Int) -> UIColor {
        switch numerator {
        case 0...3:
            return ColorStruct.seaCoral
        case 4...5:
            return ColorStruct.beeYellow
        default:
            return ColorStruct.leafGreen
        }
    }
    
}

