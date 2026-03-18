import UIKit
import AnylineTireTreadSdk

class ApiExplorerViewController: UIViewController {

    private static let defaultCorrelationId = "123e4567-e89b-12d3-a456-426614174000"

    // MARK: - Properties

    var measurementUUID: String = ""

    // MARK: - UI Components

    private var scrollView: UIScrollView!
    private var contentView: UIView!

    // Init
    private var sdkVersionLabel: UILabel!
    private var initButton: UIButton!
    private var initStatusLabel: UILabel!
    private var initSpinner: UIActivityIndicatorView!

    // Config controls
    private var appearanceControl: UISegmentedControl!
    private var scanSpeedControl: UISegmentedControl!
    private var measurementSystemControl: UISegmentedControl!
    private var heatmapStyleControl: UISegmentedControl!
    private var tireWidthField: UITextField!
    private var correlationIdSwitch: UISwitch!
    private var tirePositionSwitch: UISwitch!
    private var additionalContextSummaryLabel: UILabel!

    // Scan
    private var scanButton: UIButton!
    private var uuidTextField: UITextField!
    private var scanStatusLabel: UILabel!

    // Results
    private var getResultsButton: UIButton!
    private var resultsSpinner: UIActivityIndicatorView!
    private var globalDepthLabel: UILabel!
    private var minimumDepthLabel: UILabel!
    private var localDepth1Label: UILabel!
    private var localDepth2Label: UILabel!
    private var localDepth3Label: UILabel!
    private var resultsStatusLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateAdditionalContextSummary()
    }

    @objc private func initButtonTapped() {
        initializeSDK()
    }

    // MARK: - SDK Init

    private func initializeSDK() {
        scanButton.isEnabled = false
        initButton.isEnabled = false
        initStatusLabel.text = "Initializing SDK..."
        initStatusLabel.textColor = .secondaryLabel
        initSpinner.startAnimating()

        Task {
            let result = await SDKUtilities.initializeSDK()

            await MainActor.run {
                self.initSpinner.stopAnimating()

                switch result {
                case .success:
                    self.scanButton.isEnabled = true
                    self.initButton.isEnabled = false
                    self.initStatusLabel.text = "SDK initialized"
                    self.initStatusLabel.textColor = .systemGreen
                    self.sdkVersionLabel.text = "TTR SDK: \(AnylineTireTread.shared.sdkVersion)"
                case .failure(let error):
                    self.initButton.isEnabled = true
                    self.initStatusLabel.text = "Init failed: \(error.localizedDescription)"
                    self.initStatusLabel.textColor = .systemRed
                }
            }
        }
    }

    // MARK: - Config JSON Builder

    private func buildConfigJSON() -> String {
        var config: [String: Any] = [:]

        // scanConfig
        var scanConfig: [String: Any] = [:]
        scanConfig["heatmapStyle"] = heatmapStyleControl.selectedSegmentIndex == 0 ? "Colored" : "Grayscale"
        if let widthText = tireWidthField.text, !widthText.isEmpty, let width = Int(widthText), width > 0 {
            scanConfig["tireWidth"] = width
        }
        config["scanConfig"] = scanConfig

        var additionalContext: [String: Any] = [:]
        if correlationIdSwitch.isOn {
            additionalContext["correlationId"] = Self.defaultCorrelationId
        }
        if tirePositionSwitch.isOn {
            additionalContext["tirePosition"] = [
                "axle": 1,
                "positionOnAxle": 1,
                "side": "Left",
            ]
        }
        if !additionalContext.isEmpty {
            config["additionalContext"] = additionalContext
        }

        // uiConfig
        var uiConfig: [String: Any] = [:]
        uiConfig["measurementSystem"] = measurementSystemControl.selectedSegmentIndex == 0 ? "Metric" : "Imperial"
        uiConfig["appearance"] = ["Classic", "Neon"][appearanceControl.selectedSegmentIndex]
        uiConfig["scanSpeed"] = scanSpeedControl.selectedSegmentIndex == 0 ? "Fast" : "Slow"
        uiConfig["tireWidthInputConfig"] = [:]

        config["uiConfig"] = uiConfig

        if let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    private func updateAdditionalContextSummary() {
        additionalContextSummaryLabel.text = Self.additionalContextSummary(
            includeCorrelationId: correlationIdSwitch.isOn,
            includeTirePosition: tirePositionSwitch.isOn
        )
    }

    @objc private func configChanged() {
        updateAdditionalContextSummary()
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func scanTapped() {
        launchScan(configString: buildConfigJSON())
    }

    @objc private func getResultsTapped() {
        let uuid = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !uuid.isEmpty else {
            resultsStatusLabel.text = "Enter a UUID first"
            resultsStatusLabel.textColor = .systemRed
            return
        }
        measurementUUID = uuid

        setButtonLoading(getResultsButton, spinner: resultsSpinner, loading: true)
        resultsStatusLabel.text = ""

        Task { [weak self] in
            guard let self = self else { return }
            let result = await SDKUtilities.fetchTreadDepthResult(uuid: uuid)

            await MainActor.run {
                self.setButtonLoading(self.getResultsButton, spinner: self.resultsSpinner, loading: false)

                switch result {
                case .success(let treadDepthResult):
                    self.globalDepthLabel.text = String(format: "%.2f\nmm", treadDepthResult.global.valueMm)
                    self.minimumDepthLabel.text = String(format: "%.2f\nmm", treadDepthResult.minimumValue.valueMm)
                    let regions = treadDepthResult.regions
                    if regions.count >= 3 {
                        self.localDepth1Label.text = String(format: "%.2f\nmm", regions[0].valueMm)
                        self.localDepth2Label.text = String(format: "%.2f\nmm", regions[1].valueMm)
                        self.localDepth3Label.text = String(format: "%.2f\nmm", regions[2].valueMm)
                    }
                    self.resultsStatusLabel.text = "Results loaded"
                    self.resultsStatusLabel.textColor = .systemGreen
                case .failure(let error):
                    self.resultsStatusLabel.text = error.localizedDescription
                    self.resultsStatusLabel.textColor = .systemRed
                }
            }
        }
    }

    // MARK: - Helpers

    private func setButtonLoading(_ button: UIButton, spinner: UIActivityIndicatorView, loading: Bool) {
        button.isEnabled = !loading
        if loading {
            button.setTitle("", for: .normal)
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            if button === getResultsButton { button.setTitle("Get Results", for: .normal) }
        }
    }


    private func launchScan(configString: String?) {
        let scanner = AnylineTireTreadScanner()
        scanStatusLabel.text = "Launching scan..."
        scanStatusLabel.textColor = .secondaryLabel

        let completion: (ScanOutcome) -> Void = { [weak self] outcome in
            DispatchQueue.main.async {
                self?.handleScanOutcome(outcome)
            }
        }

        if let configString {
            scanner.scan(from: self, configJson: configString, completion: completion)
        } else {
            scanner.scan(from: self, completion: completion)
        }
    }

    private func handleScanOutcome(_ outcome: ScanOutcome) {
        switch outcome.kind {
        case "ScanCompleted":
            let uuid = outcome.measurementUUID ?? ""
            measurementUUID = uuid
            uuidTextField.text = uuid
            scanStatusLabel.text = "Outcome: success (\(uuid))"
            scanStatusLabel.textColor = .systemGreen
        case "ScanAborted":
            if let uuid = outcome.measurementUUID, !uuid.isEmpty {
                measurementUUID = uuid
                uuidTextField.text = uuid
            }
            scanStatusLabel.text = "Outcome: aborted"
            scanStatusLabel.textColor = .systemOrange
        case "ScanFailed":
            scanStatusLabel.text = "Outcome: failed (\(scanFailureMessage(from: outcome)))"
            scanStatusLabel.textColor = .systemRed
        default:
            scanStatusLabel.text = "Outcome: \(outcome.kind)"
            scanStatusLabel.textColor = .secondaryLabel
        }
    }

    private func scanFailureMessage(from outcome: ScanOutcome) -> String {
        let envelope = outcome.toMap()
        guard let error = envelope["error"] as? [AnyHashable: Any] else {
            return "unknown error"
        }

        let code = error["code"] as? String
        let message = error["message"] as? String
        if let code, let message {
            return "\(code): \(message)"
        }
        return message ?? code ?? "unknown error"
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "TireTread Developer Examples"
        view.backgroundColor = .systemBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let pad: CGFloat = 20

        // === SECTION 0: SDK Init ===

        let initHeader = makeSectionHeader("SDK Status")
        contentView.addSubview(initHeader)

        sdkVersionLabel = UILabel()
        sdkVersionLabel.text = "TTR SDK: --"
        sdkVersionLabel.font = .systemFont(ofSize: 14)
        sdkVersionLabel.textColor = .secondaryLabel
        sdkVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sdkVersionLabel)

        initButton = UIButton(type: .system)
        initButton.setTitle("Initialize", for: .normal)
        initButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        initButton.setTitleColor(.white, for: .normal)
        initButton.backgroundColor = .systemBlue
        initButton.layer.cornerRadius = 22
        initButton.translatesAutoresizingMaskIntoConstraints = false
        initButton.addTarget(self, action: #selector(initButtonTapped), for: .touchUpInside)
        contentView.addSubview(initButton)

        initStatusLabel = UILabel()
        initStatusLabel.text = ""
        initStatusLabel.font = .systemFont(ofSize: 14)
        initStatusLabel.numberOfLines = 0
        initStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(initStatusLabel)

        initSpinner = UIActivityIndicatorView(style: .medium)
        initSpinner.hidesWhenStopped = true
        initSpinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(initSpinner)

        // === SECTION 1: Scan Config ===

        let configHeader = makeSectionHeader("Scan Config")
        contentView.addSubview(configHeader)

        // Enum controls
        appearanceControl = UISegmentedControl(items: ["Classic", "Neon"])
        appearanceControl.selectedSegmentIndex = 1
        appearanceControl.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        scanSpeedControl = UISegmentedControl(items: ["Fast", "Slow"])
        scanSpeedControl.selectedSegmentIndex = 0
        scanSpeedControl.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        measurementSystemControl = UISegmentedControl(items: ["Metric", "Imperial"])
        measurementSystemControl.selectedSegmentIndex = 0
        measurementSystemControl.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        heatmapStyleControl = UISegmentedControl(items: ["Colored", "Grayscale"])
        heatmapStyleControl.selectedSegmentIndex = 0
        heatmapStyleControl.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        tireWidthField = UITextField()
        tireWidthField.placeholder = "empty = not set"
        tireWidthField.borderStyle = .roundedRect
        tireWidthField.keyboardType = .numberPad
        tireWidthField.font = .systemFont(ofSize: 14)
        tireWidthField.translatesAutoresizingMaskIntoConstraints = false

        correlationIdSwitch = UISwitch()
        correlationIdSwitch.isOn = true
        correlationIdSwitch.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        tirePositionSwitch = UISwitch()
        tirePositionSwitch.isOn = true
        tirePositionSwitch.addTarget(self, action: #selector(configChanged), for: .valueChanged)

        additionalContextSummaryLabel = UILabel()
        additionalContextSummaryLabel.font = .systemFont(ofSize: 12)
        additionalContextSummaryLabel.textColor = .secondaryLabel
        additionalContextSummaryLabel.numberOfLines = 0

        // Build config rows stack
        let configStack = UIStackView(arrangedSubviews: [
            makeSegmentRow("Appearance", appearanceControl),
            makeSegmentRow("Scan Speed", scanSpeedControl),
            makeSegmentRow("Units", measurementSystemControl),
            makeSegmentRow("Heatmap Style", heatmapStyleControl),
            makeFieldRow("Tire Width (mm)", tireWidthField),
            makeSwitchRow("Include correlationId", correlationIdSwitch),
            makeSwitchRow("Include tirePosition", tirePositionSwitch),
            additionalContextSummaryLabel,
        ])
        configStack.axis = .vertical
        configStack.spacing = 8
        configStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(configStack)

        // Scan button
        scanButton = makeActionButton(title: "Scan", color: UIColor(red: 0, green: 0.6, blue: 1, alpha: 1), action: #selector(scanTapped))
        scanButton.isEnabled = false
        contentView.addSubview(scanButton)

        uuidTextField = UITextField()
        uuidTextField.placeholder = "Measurement UUID (auto-filled after scan)"
        uuidTextField.borderStyle = .roundedRect
        uuidTextField.autocapitalizationType = .none
        uuidTextField.autocorrectionType = .no
        uuidTextField.font = .systemFont(ofSize: 14)
        uuidTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(uuidTextField)

        scanStatusLabel = makeStatusLabel()
        contentView.addSubview(scanStatusLabel)

        // === SECTION 2: Results ===

        let resultsSectionHeader = makeSectionHeader("Results")
        contentView.addSubview(resultsSectionHeader)

        getResultsButton = makeActionButton(title: "Get Results", color: .systemBlue, action: #selector(getResultsTapped))
        resultsSpinner = makeSpinner(in: getResultsButton)
        contentView.addSubview(getResultsButton)

        resultsStatusLabel = makeStatusLabel()
        contentView.addSubview(resultsStatusLabel)

        globalDepthLabel = makeDepthLabel()
        minimumDepthLabel = makeDepthLabel()
        localDepth1Label = makeDepthLabel()
        localDepth2Label = makeDepthLabel()
        localDepth3Label = makeDepthLabel()

        let topDepthRow = UIStackView(arrangedSubviews: [
            makeDepthStack(titleText: "Global", label: globalDepthLabel),
            makeDepthStack(titleText: "Minimum", label: minimumDepthLabel),
        ])
        topDepthRow.axis = .horizontal
        topDepthRow.distribution = .fillEqually
        topDepthRow.spacing = 10
        topDepthRow.translatesAutoresizingMaskIntoConstraints = false

        let bottomDepthRow = UIStackView(arrangedSubviews: [
            makeDepthStack(titleText: "R[0]", label: localDepth1Label),
            makeDepthStack(titleText: "R[1]", label: localDepth2Label),
            makeDepthStack(titleText: "R[2]", label: localDepth3Label),
        ])
        bottomDepthRow.axis = .horizontal
        bottomDepthRow.distribution = .fillEqually
        bottomDepthRow.spacing = 10
        bottomDepthRow.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(topDepthRow)
        contentView.addSubview(bottomDepthRow)

        // === Layout ===

        NSLayoutConstraint.activate([
            // Section 0: SDK Init
            initHeader.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pad),
            initHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            sdkVersionLabel.topAnchor.constraint(equalTo: initHeader.bottomAnchor, constant: 8),
            sdkVersionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            sdkVersionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            initButton.topAnchor.constraint(equalTo: sdkVersionLabel.bottomAnchor, constant: 10),
            initButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            initButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            initButton.heightAnchor.constraint(equalToConstant: 44),

            initStatusLabel.topAnchor.constraint(equalTo: initButton.bottomAnchor, constant: 8),
            initStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            initStatusLabel.trailingAnchor.constraint(equalTo: initSpinner.leadingAnchor, constant: -8),

            initSpinner.centerYAnchor.constraint(equalTo: initStatusLabel.centerYAnchor),
            initSpinner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Section 1: Config & Scan
            configHeader.topAnchor.constraint(equalTo: initStatusLabel.bottomAnchor, constant: pad),
            configHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            configStack.topAnchor.constraint(equalTo: configHeader.bottomAnchor, constant: 10),
            configStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            configStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            scanButton.topAnchor.constraint(equalTo: configStack.bottomAnchor, constant: 16),
            scanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            scanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            scanButton.heightAnchor.constraint(equalToConstant: 44),

            uuidTextField.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 12),
            uuidTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            uuidTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            uuidTextField.heightAnchor.constraint(equalToConstant: 40),

            scanStatusLabel.topAnchor.constraint(equalTo: uuidTextField.bottomAnchor, constant: 6),
            scanStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            scanStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Section 2: Results
            resultsSectionHeader.topAnchor.constraint(equalTo: scanStatusLabel.bottomAnchor, constant: pad),
            resultsSectionHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            getResultsButton.topAnchor.constraint(equalTo: resultsSectionHeader.bottomAnchor, constant: 10),
            getResultsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            getResultsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            getResultsButton.heightAnchor.constraint(equalToConstant: 44),

            resultsStatusLabel.topAnchor.constraint(equalTo: getResultsButton.bottomAnchor, constant: 6),
            resultsStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            resultsStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            topDepthRow.topAnchor.constraint(equalTo: resultsStatusLabel.bottomAnchor, constant: 10),
            topDepthRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            topDepthRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            bottomDepthRow.topAnchor.constraint(equalTo: topDepthRow.bottomAnchor, constant: 10),
            bottomDepthRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            bottomDepthRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            bottomDepthRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }

    // MARK: - UI Factory Helpers

    private func makeSectionHeader(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeActionButton(title: String, color: UIColor, titleColor: UIColor = .white, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(titleColor.withAlphaComponent(0.4), for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func makeSpinner(in button: UIButton) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
        return spinner
    }

    private func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeDepthLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "\u{2013}\nmm"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeDepthStack(titleText: String, label: UILabel) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, label])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center

        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        label.heightAnchor.constraint(equalToConstant: 55).isActive = true

        return stack
    }

    private func makeSwitchRow(_ title: String, _ toggle: UISwitch) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label

        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.axis = .horizontal
        row.distribution = .fill
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    private func makeSegmentRow(_ title: String, _ control: UISegmentedControl) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)

        control.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fill
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    private func makeFieldRow(_ title: String, _ field: UITextField) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)

        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 120).isActive = true

        let row = UIStackView(arrangedSubviews: [label, field])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fill
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    private static func additionalContextSummary(includeCorrelationId: Bool, includeTirePosition: Bool) -> String {
        var parts: [String] = []
        if includeCorrelationId { parts.append("correlationId") }
        if includeTirePosition { parts.append("tirePosition") }
        if parts.isEmpty { return "No additional context" }
        return "Additional context: " + parts.joined(separator: " + ")
    }
}
