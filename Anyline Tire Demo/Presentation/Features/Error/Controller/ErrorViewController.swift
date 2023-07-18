import UIKit

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
    
}

// MARK: - Private Functions
private extension ErrorViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
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
}

// MARK: - ErrorButtonActionsDelegate
extension ErrorViewController: ErrorButtonActionsDelegate {
    
    func okButtonTapped() {
        delegate?.didAbort()
        navigationController?.popToRootViewController(animated: true)
    }
}
