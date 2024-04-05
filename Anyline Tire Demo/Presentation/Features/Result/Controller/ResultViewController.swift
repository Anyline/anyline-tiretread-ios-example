import UIKit
import AnylineTireTreadSdk

class ResultViewController: UIViewController {
    
    // MARK: - UI Properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var resultView: ResultView = {
        let view = ResultView()
        return view
    }()
    
    // MARK: - Public Properties
    var measurementResult: TreadDepthResult
    var uuid: String
    
    // MARK: - Init
    init(uuid: String, measurementResult: TreadDepthResult) {
        self.uuid = uuid
        self.measurementResult = measurementResult
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        setupLayout()
        setupMeasurements()
        resultView.delegate = self
    }
}

// MARK: - Private Functions
private extension ResultViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
        
        resultView.UUIDLabel.text = "Scan ID: \(self.uuid)"
        
        let label = resultView.UUIDLabel
        
        // add tap-to-copy-to-clipboard
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped() {
        if resultView.UUIDLabel.text != nil {
            // Copy the label's text to the clipboard
            let uuid = self.uuid
            UIPasteboard.general.string = uuid
            resultView.UUIDLabel.text = "\(uuid) Copied!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.resultView.UUIDLabel.text = "Scan ID: \(uuid)"
            }
        }
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(resultView)
    }
    
    func setupLayout() {
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        resultView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(35)
            make.leading.bottom.trailing.equalToSuperview()
            make.bottom.equalTo(-35)
        }
    }
    
    func setupMeasurements() {
        
        // TreadDepths can be retrieved in the 'measurementResult.global' and 'measurementResult.regions' properties.
        // more information about the measurement can be retrieved in 'measurementResult.measurement' property.
        
        let useImperial = UserDefaultsManager.shared.imperialSystem
        
        // Display the Global Result
        let globalResult = String(useImperial ? Double(measurementResult.global.valueInch32nds) : measurementResult.global.valueMm)
        self.resultView.tireTreadMeasurementView.globalMeasurementView.measurementValue = globalResult
        
        // Display the Regions
        if(measurementResult.regions.count > 0) {
            self.resultView.tireTreadMeasurementView.bottomTireTreadMeasurementHStackView.spacing = 180 / CGFloat(measurementResult.regions.count)
            
            // Display the Region Results dynamically, from left to right.
            for region in measurementResult.regions {
                
                let measurementView = MeasurementView(location: .regional)
                if(region.isAvailable){
                    measurementView.measurementValue = String(useImperial ? Double(region.valueInch32nds) : region.valueMm)
                }
                else {
                    measurementView.measurementValue = nil
                }
                
                self.resultView.tireTreadMeasurementView.bottomTireTreadMeasurementHStackView.addArrangedSubview(measurementView)
                
                measurementView.snp.makeConstraints { make in
                    make.width.equalTo(resultView.tireTreadMeasurementView.globalMeasurementView).multipliedBy(0.8)
                    make.height.equalTo(resultView.tireTreadMeasurementView.globalMeasurementView).multipliedBy(0.8)
                }
            }
        }
    }
}

// MARK: - SettingsButtonActionsDelegate
extension ResultViewController: ResultButtonActionsDelegate {
    func okButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func detailsButtonTapped() {
        let vc = ResultDetailsViewController(uuid: uuid)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackButtonTapped() {
        let vc = FeedbackViewController(uuid: uuid)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
