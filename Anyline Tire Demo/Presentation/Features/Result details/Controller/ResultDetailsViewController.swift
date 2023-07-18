import UIKit
import PDFKit

class ResultDetailsViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var resultDetailsView: ResultDetailsView = {
        let view = ResultDetailsView()
        view.pdfData = Data(base64Encoded: pdfData ?? Data())
        return view
    }()
    
    // MARK: - Private Properties
    var pdfData: Data? {
        didSet {
            resultDetailsView.pdfData = pdfData
        }
    }
    
    private var uuid: String
    
    private lazy var resultDetailsViewModel: ResultDetailsViewModel = {
        return ResultDetailsViewModel(delegate: self, uuid: uuid)
    }()
    
    // MARK: - Public Properties
    
    // MARK: - Init
    init(uuid: String) {
        self.uuid = uuid
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await resultDetailsViewModel.requestPDF(context: self)
        }
        configureView()
        addSubviews()
        setupLayout()
        setDelegates()
    }
    
}

// MARK: - Private Functions
private extension ResultDetailsViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.view.addSubview(resultDetailsView)
    }
    
    func setupLayout() {
        self.resultDetailsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setDelegates() {
        self.resultDetailsView.delegate = self
    }
}

// MARK: - ResultDetailsViewModelDelegate
extension ResultDetailsViewController: ResultDetailsViewModelDelegate {
    
    func showPDF(pdfData: Data) {
        self.pdfData = pdfData
    }
    
    func showError(error: String) {
        self.displayAlert(title: "error.title".localized(), message: "error.pdf.description".localized())
    }
}

// MARK: - ResultDetailsViewDelegate
extension ResultDetailsViewController: ResultDetailsViewDelegate {
    func downloadButtonTapped() {
        // Create a PDFDocument object from your PDF data
        guard let pdfData = self.pdfData else { return }
        let pdfDocument = PDFDocument(data: pdfData)
        
        // Create an activity item provider for the PDF data
        let pdfItemProvider = NSItemProvider(item: pdfDocument?.dataRepresentation() as NSData?, typeIdentifier: "com.adobe.pdf")
        pdfItemProvider.suggestedName = "tireMeasurement.pdf"
        
        // Create the UIActivityViewController and present it
        let activityViewController = UIActivityViewController(activityItems: [pdfItemProvider], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                // The user completed the action
            } else {
                // The user cancelled the action
            }
        }
        
        present(activityViewController, animated: true)
    }
    
    func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
