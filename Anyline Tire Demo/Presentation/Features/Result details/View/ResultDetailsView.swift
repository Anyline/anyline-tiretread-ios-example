import UIKit

protocol ResultDetailsViewDelegate: AnyObject {
    func cancelButtonTapped()
    func downloadButtonTapped()
}

class ResultDetailsView: UIView {
    
    // MARK: - UI properties
    private lazy var pdfView: PDFReaderView = {
        let view = PDFReaderView()
        return view
    }()
    
    private lazy var cancelButton: ATDSideButton = {
        let button = ATDSideButton(title: "settings.button.ok".localized())
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var downloadButton: ATDSideButton = {
        let button = ATDSideButton(title: "details.button.download".localized())
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private let spacing: CGFloat = 0
    
    // MARK: - Public properties
    var pdfData: Data? {
        didSet {
            pdfView.displayPDF(data: pdfData!)
        }
    }
    weak var delegate: ResultDetailsViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
    
    @objc
    func downloadButtonTapped() {
        delegate?.downloadButtonTapped()
    }
    
}

// MARK: - Private functions
private extension ResultDetailsView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(pdfView)
        self.addSubview(cancelButton)
        self.addSubview(downloadButton)
    }
    
    func setupLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(140)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
        
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.trailing.equalTo(0)
            make.width.equalTo(170)
            make.height.equalTo(55)
        }
        
        self.pdfView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

