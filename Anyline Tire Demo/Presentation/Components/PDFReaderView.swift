import PDFKit

class PDFReaderView: UIView {
    
    // MARK: - UI Properties
    private lazy var pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.displayMode = .singlePage
        pdfView.displaysPageBreaks = true
        pdfView.autoScales = true
        pdfView.scaleFactor = 1.5
        return pdfView
    }()
    
    // MARK: - Private Properties

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

    // MARK: - Functions
    /**
      Display a PDF document in the PDFView.

      - Parameters:
        - url: The file URL of the PDF document.
        - data: The binary data of the PDF document.

      - Note:
        One of the parameters must be provided, either url or data.
        Providing both url and data is not allowed.
    */
    func displayPDF(data: Data) {
        DispatchQueue.main.async {
            self.pdfView.document = PDFDocument(data: data)
        }
    }
}

// MARK: - Private functions
private extension PDFReaderView {
    
    // MARK: - Setup UI
    func configureView() {
        backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(pdfView)
    }
    
    func setupLayout() {
        pdfView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
