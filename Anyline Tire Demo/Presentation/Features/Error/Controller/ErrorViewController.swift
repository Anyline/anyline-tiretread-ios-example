import UIKit
import AnylineTireTreadSdk

protocol ErrorViewControllerDelegate: AnyObject {
    func didAbort()
}

class ErrorViewController: UIViewController {
    
    // MARK: - UI Properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var errorView: ErrorView = {
        let view = ErrorView()
        return view
    }()
    
    // MARK: - Private Properties
    private var uuid: String
    
    // MARK: - Public Properties
    weak var delegate: ErrorViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        setupLayout()
        errorView.delegate = self
    }
    
    init(uuid: String) {
        self.uuid = uuid
        self.errorView.setUUID(uuid: uuid)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setError(code: String?, message: String?) {
        errorView.setError(code: code, message: message)
    }
    
}

// MARK: - Private Functions
private extension ErrorViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
        configureUUIDLabel()
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(errorView)
    }
    
    func setupLayout() {
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        errorView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureUUIDLabel() {
        let label = self.errorView.measurementUUIDLabel

        // add tap-to-copy-to-clipboard
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped() {
        if let _ = self.errorView.measurementUUIDLabel.text {
            // Copy the label's text to the clipboard
            let uuid = self.uuid
            UIPasteboard.general.string = uuid
            self.errorView.measurementUUIDLabel.text = "\(uuid) Copied!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.errorView.measurementUUIDLabel.text = "Scan ID: \(uuid)"
            }
        }
    }
}

// MARK: - ErrorButtonActionsDelegate
extension ErrorViewController: ErrorButtonActionsDelegate {
    
    func okButtonTapped() {
        delegate?.didAbort()
        navigationController?.popToRootViewController(animated: true)
    }
}
