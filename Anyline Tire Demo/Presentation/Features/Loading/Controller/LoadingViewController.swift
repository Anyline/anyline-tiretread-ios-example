import UIKit
import AnylineTireTreadSdk

protocol LoadingViewControllerDelegate: AnyObject {
    func resetScan()
}

class LoadingViewController: UIViewController {
    
    // MARK: - UI properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var customView: LoadingView = {
        let view = LoadingView()
        return view
    }()
    
    // MARK: - Private properties
    private lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel(delegate: self, uuid: uuid)
    }()
    
    // MARK: - Public Properties
    weak var delegate: LoadingViewControllerDelegate?
    var uuid: String
    
    // MARK: - Init
    init(uuid: String) {
        self.uuid = uuid
        self.customView.customView.measurementUUIDLabel.text = "Scan ID: \(self.uuid)"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureUUIDLabel()
        addSubviews()
        setupLayout()
        setDelegates()
        startProcessing()
    }
}

// MARK: - Private Functions
private extension LoadingViewController {
    func configureView() {
        view.backgroundColor = ColorStruct.snowWhite
    }

    func configureUUIDLabel() {
        let label = self.customView.customView.measurementUUIDLabel

        // add tap-to-copy-to-clipboard
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
    }

    @objc func labelTapped() {
        if let _ = self.customView.customView.measurementUUIDLabel.text {
            // Copy the label's text to the clipboard
            let uuid = self.uuid
            UIPasteboard.general.string = uuid
            self.customView.customView.measurementUUIDLabel.text = "\(uuid) Copied!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.customView.customView.measurementUUIDLabel.text = "Scan ID: \(uuid)"
            }
        }
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(customView)
    }
    
    func setupLayout() {
        self.topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.customView.snp.makeConstraints({ make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
    
    func setDelegates() {
        self.customView.delegate = self
    }
    
    func startProcessing() {
        self.loadingViewModel.startDataProcessing()
    }
}

// MARK: - LoadingButtonActionsDelegate
extension LoadingViewController: LoadingButtonActionsDelegate {
    func abortButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - LoadingViewModelDelegate
extension LoadingViewController: LoadingViewModelDelegate {
    
    func displayDepthResultView(uuid: String, treadDepthResult: TreadDepthResultDTO) {
        let vc = ResultViewController(uuid: uuid, measurementResult: treadDepthResult)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func displayError() {
        DispatchQueue.main.async { [weak self] in
            let vc = ErrorViewController()
            vc.delegate = self
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - ErrorViewControllerDelegate
extension LoadingViewController: ErrorViewControllerDelegate {
    
    func didAbort() {
        self.delegate?.resetScan()
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
