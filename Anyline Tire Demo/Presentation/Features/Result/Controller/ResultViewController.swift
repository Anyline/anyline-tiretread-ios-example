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
    
    // MARK: - Private Properties
    private var topTireTreadValue: String?
    private var leftTireTreadValue: String?
    private var middleTireTreadValue: String?
    private var rightTireTreadValue: String?
    
    // MARK: - Public Properties
    var measurementResult: TreadDepthResult
    var uuid: String
    
    // MARK: - Init
    init(uuid: String, measurementResult: TreadDepthResult) {
        self.uuid = uuid
        self.measurementResult = measurementResult
        
        super.init(nibName: nil, bundle: nil)
        setTireTreadValues()
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
    
    func setTireTreadValues() {

        let useImperial = UserDefaultsManager.shared.imperialSystem

        topTireTreadValue = String(useImperial ? Double(measurementResult.global.valueInch32nds) : measurementResult.global.valueMm)

        if measurementResult.regions[0].isAvailable {
            leftTireTreadValue = String(useImperial ?
                                        Double(measurementResult.regions[0].valueInch32nds) : measurementResult.regions[0].valueMm)
        }

        if measurementResult.regions[1].isAvailable {
            middleTireTreadValue = String(useImperial ?
                                          Double(measurementResult.regions[1].valueInch32nds) : measurementResult.regions[1].valueMm)
        }

        if measurementResult.regions[2].isAvailable {
            rightTireTreadValue = String(useImperial ?
                                         Double(measurementResult.regions[2].valueInch32nds) : measurementResult.regions[2].valueMm)
        }
    }
    
    func setupMeasurements() {
        self.resultView.tireTreadMeasurementView.topMeasurementView.measurementValue = self.topTireTreadValue
        self.resultView.tireTreadMeasurementView.leftMeasurementView.measurementValue = self.leftTireTreadValue
        self.resultView.tireTreadMeasurementView.middleMeasurementView.measurementValue = self.middleTireTreadValue
        self.resultView.tireTreadMeasurementView.rightMeasurementView.measurementValue = self.rightTireTreadValue
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
