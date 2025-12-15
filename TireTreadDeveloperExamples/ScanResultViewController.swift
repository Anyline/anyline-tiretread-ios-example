import UIKit
import AnylineTireTreadSdk

class ScanResultViewController: UIViewController {

    // MARK: - Layout Constants
    private enum Layout {
        static let cornerRadius: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 24
        static let standardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 20
        static let stackSpacing: CGFloat = 5

        static let textFieldHeight: CGFloat = 40
        static let buttonHeight: CGFloat = 40
        static let dismissButtonHeight: CGFloat = 48
        static let dismissButtonWidth: CGFloat = 200
        static let loadButtonWidth: CGFloat = 150
        static let searchContainerHeight: CGFloat = 90

        static let globalValueWidth: CGFloat = 100
        static let globalValueHeight: CGFloat = 70
        static let regionalValueWidth: CGFloat = 70
        static let regionalValueHeight: CGFloat = 60

        static let heatmapHeight: CGFloat = 280
        static let loadingOverlayAlpha: CGFloat = 0.8
        static let animationDuration: TimeInterval = 0.15

        static let separatorHeight: CGFloat = 1
        static let regionalStackPadding: CGFloat = 40
    }

    // MARK: - Actions

    @objc func closeTapped() {
        // Handle both presentation styles:
        // 1. When presented modally (e.g., from HomeViewController)
        // 2. When embedded as child (e.g., from TireScannerViewController)
        if let navigationController = navigationController,
           navigationController.parent != nil {
            // Embedded as child - dismiss the parent (TireScannerViewController)
            navigationController.parent?.dismiss(animated: true)
        } else {
            // Presented modally - dismiss self
            dismiss(animated: true)
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func loadButtonTapped() {
        guard !isLoading else { return }
        let uuidToFetch = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !uuidToFetch.isEmpty else {
            showError(message: "Please enter a measurement UUID")
            return
        }

        guard UUID(uuidString: uuidToFetch) != nil else {
            showError(message: "Invalid UUID format. Please check and try again.")
            return
        }

        uuid = uuidToFetch
        uuidTextField.resignFirstResponder()
        fetchResults(uuid: uuidToFetch)
    }

    @objc func textFieldDone() {
        loadButtonTapped()
    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    lazy var searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    lazy var uuidTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "result.search.placeholder".localized
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(textFieldDone), for: .editingDidEndOnExit)
        return textField
    }()

    lazy var loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("result.search.button".localized, for: .normal)
        button.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Layout.cornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    lazy var resultsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "result.results_header".localized
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var heatmapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // Global value components
    lazy var globalValueTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "result.global_value".localized
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var globalDepthLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = Layout.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    // Minimum value components
    lazy var minimumValueTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "result.minimum_value".localized
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var minimumDepthLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = Layout.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    // Regional value components
    lazy var region0TitleLabel: UILabel = {
        let label = UILabel()
        label.text = "\("result.region_label".localized)[0]"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var localDepth1Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = Layout.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    lazy var region1TitleLabel: UILabel = {
        let label = UILabel()
        label.text = "\("result.region_label".localized)[1]"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var localDepth2Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = Layout.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    lazy var region2TitleLabel: UILabel = {
        let label = UILabel()
        label.text = "\("result.region_label".localized)[2]"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var localDepth3Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = Layout.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    lazy var loadingOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(Layout.loadingOverlayAlpha)
        view.isHidden = true
        return view
    }()

    var heatmapHeightConstraint: NSLayoutConstraint!
    var isLoading: Bool = false
    private var fetchTask: Task<Void, Never>?

    var uuid: String

    init(uuid: String? = nil) {
        self.uuid = uuid ?? ""
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fetchTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Pre-populate the text field if UUID was provided
        if !uuid.isEmpty {
            uuidTextField.text = uuid
            fetchResults(uuid: uuid)
        }
    }
    
    fileprivate func setupUI() {
        title = "result.title".localized

        view.backgroundColor = .systemBackground

        // Add close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        view.addSubview(scrollView)

        // Add search container with text field and button
        scrollView.addSubview(searchContainerView)
        searchContainerView.addSubview(uuidTextField)
        searchContainerView.addSubview(loadButton)

        // Add separator line
        scrollView.addSubview(separatorLine)

        // Add results section
        scrollView.addSubview(resultsHeaderLabel)

        // Global value
        scrollView.addSubview(globalValueTitleLabel)
        scrollView.addSubview(globalDepthLabel)

        // Minimum value
        scrollView.addSubview(minimumValueTitleLabel)
        scrollView.addSubview(minimumDepthLabel)

        // Heatmap
        scrollView.addSubview(heatmapImageView)

        // Regional values in a horizontal stack
        let region0Stack = UIStackView(arrangedSubviews: [region0TitleLabel, localDepth1Label])
        region0Stack.axis = .vertical
        region0Stack.spacing = Layout.stackSpacing
        region0Stack.alignment = .center

        let region1Stack = UIStackView(arrangedSubviews: [region1TitleLabel, localDepth2Label])
        region1Stack.axis = .vertical
        region1Stack.spacing = Layout.stackSpacing
        region1Stack.alignment = .center

        let region2Stack = UIStackView(arrangedSubviews: [region2TitleLabel, localDepth3Label])
        region2Stack.axis = .vertical
        region2Stack.spacing = Layout.stackSpacing
        region2Stack.alignment = .center

        let regionsStackView = UIStackView(arrangedSubviews: [
            region0Stack, region1Stack, region2Stack
        ])
        regionsStackView.axis = .horizontal
        regionsStackView.distribution = .equalSpacing
        regionsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(regionsStackView)

        // Add loading overlay and indicator on top of everything
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading overlay constraints
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
        ])
        
        heatmapHeightConstraint = heatmapImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([

            heatmapHeightConstraint,

            // Search container constraints
            searchContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.standardPadding),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.standardPadding),
            searchContainerView.heightAnchor.constraint(equalToConstant: Layout.searchContainerHeight),

            // Text field constraints
            uuidTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            uuidTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            uuidTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            uuidTextField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // Load button constraints
            loadButton.topAnchor.constraint(equalTo: uuidTextField.bottomAnchor, constant: 10),
            loadButton.centerXAnchor.constraint(equalTo: searchContainerView.centerXAnchor),
            loadButton.widthAnchor.constraint(equalToConstant: Layout.loadButtonWidth),
            loadButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            // Separator line
            separatorLine.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: Layout.sectionSpacing),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.standardPadding),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.standardPadding),
            separatorLine.heightAnchor.constraint(equalToConstant: Layout.separatorHeight),

            // Results header
            resultsHeaderLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: Layout.sectionSpacing),
            resultsHeaderLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            // Global value
            globalValueTitleLabel.topAnchor.constraint(equalTo: resultsHeaderLabel.bottomAnchor, constant: Layout.sectionSpacing),
            globalValueTitleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            globalDepthLabel.topAnchor.constraint(equalTo: globalValueTitleLabel.bottomAnchor, constant: Layout.stackSpacing),
            globalDepthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            globalDepthLabel.widthAnchor.constraint(equalToConstant: Layout.globalValueWidth),
            globalDepthLabel.heightAnchor.constraint(equalToConstant: Layout.globalValueHeight),

            // Minimum value
            minimumValueTitleLabel.topAnchor.constraint(equalTo: globalDepthLabel.bottomAnchor, constant: Layout.sectionSpacing),
            minimumValueTitleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            minimumDepthLabel.topAnchor.constraint(equalTo: minimumValueTitleLabel.bottomAnchor, constant: Layout.stackSpacing),
            minimumDepthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            minimumDepthLabel.widthAnchor.constraint(equalToConstant: Layout.globalValueWidth),
            minimumDepthLabel.heightAnchor.constraint(equalToConstant: Layout.globalValueHeight),

            // Heatmap
            heatmapImageView.topAnchor.constraint(equalTo: minimumDepthLabel.bottomAnchor, constant: Layout.sectionSpacing),
            heatmapImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.standardPadding),
            heatmapImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.standardPadding),

            // Regional values
            regionsStackView.topAnchor.constraint(equalTo: heatmapImageView.bottomAnchor, constant: Layout.sectionSpacing),
            regionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.regionalStackPadding),
            regionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.regionalStackPadding),
            regionsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),

            localDepth1Label.widthAnchor.constraint(equalToConstant: Layout.regionalValueWidth),
            localDepth1Label.heightAnchor.constraint(equalToConstant: Layout.regionalValueHeight),
            localDepth2Label.widthAnchor.constraint(equalToConstant: Layout.regionalValueWidth),
            localDepth2Label.heightAnchor.constraint(equalToConstant: Layout.regionalValueHeight),
            localDepth3Label.widthAnchor.constraint(equalToConstant: Layout.regionalValueWidth),
            localDepth3Label.heightAnchor.constraint(equalToConstant: Layout.regionalValueHeight),
        ])
    }
    
    fileprivate func processResult(_ treadDepthResult: TreadDepthResult) {
        DispatchQueue.main.async {
            let globalThreadResult = treadDepthResult.global
            let localThreadResult = treadDepthResult.regions
            self.globalDepthLabel.text = String(format: "%.2f\nmm", globalThreadResult.valueMm)
            self.minimumDepthLabel.text = String(format: "%.2f\nmm", treadDepthResult.minimumValue.valueMm)
            self.localDepth1Label.text = String(format: "%.2f\nmm", localThreadResult[0].valueMm)
            self.localDepth2Label.text = String(format: "%.2f\nmm", localThreadResult[1].valueMm)
            self.localDepth3Label.text = String(format: "%.2f\nmm", localThreadResult[2].valueMm)
        }
    }

    fileprivate func showLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.uuidTextField.isEnabled = false
            self.loadButton.isEnabled = false
            self.loadingOverlay.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    fileprivate func hideLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.uuidTextField.isEnabled = true
            self.loadButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.loadingOverlay.isHidden = true
        }
    }

    fileprivate func showError(title: String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    fileprivate func fetchHeatmapImage() async {
        let heatmap = await SDKUtilities.fetchHeatMap(uuid: uuid)
        switch heatmap {
        case .success(let heatmap):
            loadImage(url: heatmap.url)
        case .failure(let error):
            #if DEBUG
            print("Heatmap fetch failed: \(error)")
            #endif
            let errorMessage = getErrorMessage(from: error)
            showError(title: "Heatmap Unavailable", message: "Unable to load heatmap image.\n\n\(errorMessage)")
        }
    }

    fileprivate func fetchTreadDepthResult() async -> Bool {
        let result = await SDKUtilities.fetchTreadDepthResult(uuid: uuid)
        if case let .success(value) = result {
            processResult(value)
            return true
        } else if case let .failure(error) = result {
            #if DEBUG
            print("Tread depth result fetch failed: \(error)")
            #endif
            let errorMessage = getErrorMessage(from: error)
            showError(title: "Results Unavailable", message: "Unable to load measurement results.\n\n\(errorMessage)")
        }
        return false
    }

    fileprivate func getErrorMessage(from error: TireTreadError) -> String {
        switch error {
        case .responseError(let message):
            return message
        case .responseException(let message):
            return message
        }
    }
    
    fileprivate func fetchResults(uuid: String) {
        // Cancel any existing fetch
        fetchTask?.cancel()

        // Clear previous results
        DispatchQueue.main.async {
            self.heatmapImageView.image = nil
            self.heatmapHeightConstraint.constant = 0
            self.globalDepthLabel.text = "–\nmm"
            self.minimumDepthLabel.text = "–\nmm"
            self.localDepth1Label.text = "–\nmm"
            self.localDepth2Label.text = "–\nmm"
            self.localDepth3Label.text = "–\nmm"
        }

        #if DEBUG
        print("fetch tire tread depth result and heat map image for uuid: \(uuid)")
        #endif

        // Show loading indicator
        showLoading()

        fetchTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                try Task.checkCancellation()
                let success = await self.fetchTreadDepthResult()

                try Task.checkCancellation()
                if success {
                    await self.fetchHeatmapImage()
                }
            } catch {
                // Task was cancelled
            }

            await MainActor.run {
                self.hideLoading()
            }
        }
    }

    fileprivate func loadImage(url: String) {
        guard let url = URL(string: url) else {
            showError(title: "Invalid Image URL", message: "The heatmap image URL is invalid.")
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }

                await MainActor.run {
                    self.heatmapImageView.image = image
                    UIView.animate(withDuration: Layout.animationDuration) {
                        self.heatmapHeightConstraint.constant = Layout.heatmapHeight
                        self.view.layoutIfNeeded()
                    }
                }
            } catch {
                #if DEBUG
                print("Error loading image: \(error.localizedDescription)")
                #endif
                await MainActor.run {
                    self.showError(
                        title: "Image Load Failed",
                        message: "Failed to load heatmap image: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
