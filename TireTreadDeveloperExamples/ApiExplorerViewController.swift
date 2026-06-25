import UIKit
import AnylineTireTreadSdk

class ApiExplorerViewController: UIViewController {

    // Generated once when this screen loads; reused for both the tread-depth
    // and sidewall scans (a v4 UUID is required).
    private let correlationId = UUID().uuidString

    // MARK: - Properties

    var measurementUUID: String = ""

    // MARK: - UI Components

    private var scrollView: UIScrollView!
    private var contentView: UIView!

    // Device Support
    private var deviceSupportButton: UIButton!
    private var deviceSupportStatusLabel: UILabel!
    private var deviceSupportSpinner: UIActivityIndicatorView!

    // Init
    private var sdkVersionLabel: UILabel!
    private var initButton: UIButton!
    private var initStatusLabel: UILabel!
    private var initSpinner: UIActivityIndicatorView!
    private var setupCompleteChip: UIView!
    private var deviceSupportCircle: StatusCircle!
    private var initCircle: StatusCircle!

    // Config controls
    private var appearanceControl: UISegmentedControl!
    private var scanSpeedControl: UISegmentedControl!
    private var measurementSystemControl: UISegmentedControl!
    private var heatmapStyleControl: UISegmentedControl!
    private var tireWidthField: UITextField!
    private var tireWidthFromTag: ChipLabel!
    private var correlationIdSwitch: UISwitch!
    private var correlationMonoInset: UIView!
    private var tirePositionSwitch: UISwitch!

    // Scan
    private var scanButton: UIButton!
    private var treadStatusChip: ChipLabel!
    private var uuidTextField: UITextField!
    private var scanStatusLabel: UILabel!

    // Sidewall Scanner
    private var sidewallScanButton: UIButton!
    private var sidewallScanSpinner: UIActivityIndicatorView!
    private var sidewallSupportChip: ChipLabel!
    private var sidewallAttachedChip: UIView!
    private var sidewallStatusIcon: UIImageView!
    private var sidewallScanAttributedTitle: NSAttributedString?
    private var sidewallStatusLabel: UILabel!
    private var sidewallImageView: UIImageView!
    private var sidewallSizeTitleLabel: UILabel!
    private var sidewallSizeLabel: UILabel!
    private var sidewallHandoffChip: ChipLabel!
    private var sidewallJsonLabel: UILabel!
    private var sidewallJsonHeader: UIView!
    private var sidewallJsonChevron: UIImageView!
    private var sidewallJsonExpanded = false

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
        checkSidewallSupport()
    }

    private func checkSidewallSupport() {
        AnylineTireSidewallScanner.companion.isSupported { [weak self] status, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let supported = status is TswSupportStatus.Supported
                self.sidewallSupportChip.configure(
                    text: supported ? "Supported" : "Not supported",
                    kind: .soft(supported ? Accent.success : .systemRed)
                )
            }
        }
    }

    @objc private func initButtonTapped() {
        initializeSDK()
    }

    @objc private func deviceSupportTapped() {
        checkDeviceSupport()
    }

    // MARK: - Device Support

    private func checkDeviceSupport() {
        setSoftButtonLoading(deviceSupportButton, spinner: deviceSupportSpinner, loading: true, title: "")
        deviceSupportStatusLabel.text = "Checking…"
        deviceSupportStatusLabel.textColor = .secondaryLabel

        AnylineTireTread.shared.isDeviceSupported { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var supported = false
                if result.isOk {
                    supported = result.result?.boolValue ?? false
                    self.deviceSupportStatusLabel.text = supported ? "Device is supported" : "Device is not supported"
                    self.deviceSupportStatusLabel.textColor = supported ? Accent.success : .systemRed
                } else if let error = result.error {
                    self.deviceSupportStatusLabel.text = "\(error.code): \(error.message)"
                    self.deviceSupportStatusLabel.textColor = .systemRed
                }
                self.deviceSupportCircle.done = supported
                self.setSoftButtonLoading(self.deviceSupportButton, spinner: self.deviceSupportSpinner, loading: false, title: "Re-check")
            }
        }
    }

    // MARK: - SDK Init

    private func initializeSDK() {
        scanButton.isEnabled = false
        setSoftButtonLoading(initButton, spinner: initSpinner, loading: true, title: "")
        initStatusLabel.text = "Initializing SDK…"
        initStatusLabel.textColor = .secondaryLabel

        Task {
            let result = await SDKUtilities.initializeSDK()

            await MainActor.run {
                switch result {
                case .success:
                    self.scanButton.isEnabled = true
                    self.initStatusLabel.text = "Initialized · ready to scan"
                    self.initStatusLabel.textColor = Accent.success
                    self.sdkVersionLabel.text = AnylineTireTread.shared.sdkVersion
                    self.initCircle.done = true
                    self.setupCompleteChip.isHidden = false
                    self.treadStatusChip.configure(text: "Ready", kind: .soft(Accent.success))
                    self.setSoftButtonLoading(self.initButton, spinner: self.initSpinner, loading: false, title: "Initialize")
                    self.initButton.isEnabled = false
                case .failure(let error):
                    self.initStatusLabel.text = "Init failed: \(error.localizedDescription)"
                    self.initStatusLabel.textColor = .systemRed
                    self.setSoftButtonLoading(self.initButton, spinner: self.initSpinner, loading: false, title: "Initialize")
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
            additionalContext["correlationId"] = correlationId
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

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    /// The "from sidewall" tag only applies while the field still holds the
    /// detected width — clear it as soon as the user edits the value by hand.
    @objc private func tireWidthEdited() {
        tireWidthFromTag.isHidden = true
    }

    /// The generated UUID is only relevant while correlation is enabled.
    @objc private func correlationToggled() {
        let on = correlationIdSwitch.isOn
        correlationMonoInset.isHidden = !on
        sidewallAttachedChip.isHidden = !on
    }

    @objc private func toggleSidewallJson() {
        sidewallJsonExpanded.toggle()
        UIView.animate(withDuration: 0.2) {
            self.sidewallJsonLabel.isHidden = !self.sidewallJsonExpanded
            self.sidewallJsonChevron.transform = self.sidewallJsonExpanded
                ? CGAffineTransform(rotationAngle: .pi / 2)
                : .identity
            self.view.layoutIfNeeded()
        }
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
                    self.globalDepthLabel.text = String(format: "%.2f", treadDepthResult.global.valueMm)
                    self.minimumDepthLabel.text = String(format: "%.2f", treadDepthResult.minimumValue.valueMm)
                    let regions = treadDepthResult.regions
                    if regions.count >= 3 {
                        self.localDepth1Label.text = String(format: "%.2f", regions[0].valueMm)
                        self.localDepth2Label.text = String(format: "%.2f", regions[1].valueMm)
                        self.localDepth3Label.text = String(format: "%.2f", regions[2].valueMm)
                    }
                    self.resultsStatusLabel.text = "Results loaded"
                    self.resultsStatusLabel.textColor = Accent.success
                case .failure(let error):
                    self.resultsStatusLabel.text = error.localizedDescription
                    self.resultsStatusLabel.textColor = .systemRed
                }
            }
        }
    }

    // MARK: - Sidewall Scanner

    @objc private func sidewallScanTapped() {
        launchSidewallScan()
    }

    private func launchSidewallScan() {
        sidewallStatusLabel.text = "Scanning…"
        sidewallStatusLabel.textColor = .secondaryLabel
        sidewallStatusIcon.isHidden = true
        sidewallImageView.image = nil
        sidewallImageView.isHidden = true
        sidewallSizeTitleLabel.isHidden = true
        sidewallSizeLabel.isHidden = true
        sidewallHandoffChip.isHidden = true
        sidewallJsonHeader.isHidden = true
        sidewallJsonLabel.isHidden = true
        sidewallJsonLabel.text = nil
        sidewallJsonExpanded = false
        sidewallJsonChevron.transform = .identity
        setButtonLoading(sidewallScanButton, spinner: sidewallScanSpinner, loading: true)

        // Optional TswScannerConfig. Two things you can set:
        //
        //  • config.texts — override the UI strings shown in the scanner
        //    overlay, e.g.:
        //
        //        config.texts.textAlignTire = NSLocalizedString("tsw_align_tire", comment: "")
        //        config.texts.textHoldSteady = NSLocalizedString("tsw_hold_steady", comment: "")
        //
        //    Any field you don't set keeps its English default.
        //
        //  • config.correlationId — an optional v4 UUID multiple Anyline scans can be correlated.
        //    It must be a valid version-4 UUID, otherwise the scan fails fast with
        //    ErrorCode.INVALID_UUID. Here it's driven by the shared
        //    "Include correlationId" switch, which applies to both scans.
        let env = Bundle.main.infoDictionary?["LSEnvironment"] as? [String: String]

        let config = TswScannerConfig()
        config.correlationId = correlationIdSwitch.isOn ? correlationId : nil

        AnylineTireSidewallScanner().scan(
            from: self,
            clientId: env?["TSW_CLOUD_API_CLIENT_ID"] ?? "",
            config: config
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setButtonLoading(self.sidewallScanButton, spinner: self.sidewallScanSpinner, loading: false)

                if let completed = result as? TswScanResult.Completed {
                    self.sidewallStatusLabel.textColor = Accent.success
                    self.sidewallStatusLabel.text = "Completed"
                    self.setSidewallStatusIcon("checkmark", color: Accent.success)
                    if let image = UIImage(data: completed.imageBytes.toNSData() as Data) {
                        self.sidewallImageView.image = image
                        self.sidewallImageView.isHidden = false
                    }
                    self.sidewallJsonHeader.isHidden = false
                    self.sidewallJsonLabel.isHidden = true // collapsed; tap header to expand
                    self.sidewallJsonLabel.text = Self.prettyJson(completed.resultJson)
                    let parsed = completed.resultJson.data(using: .utf8)
                        .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
                    if let sizeString = parsed?["size"] as? String, !sizeString.isEmpty {
                        self.sidewallSizeLabel.text = sizeString
                        self.sidewallSizeTitleLabel.isHidden = false
                        self.sidewallSizeLabel.isHidden = false
                        if let width = Self.extractTireWidthFromTireSizeString(sizeString) {
                            self.tireWidthField.text = "\(width)"
                            self.tireWidthFromTag.isHidden = false
                            self.sidewallHandoffChip.configure(text: "Width \(width) mm sent to Tread", kind: .soft(Accent.brand))
                            self.sidewallHandoffChip.isHidden = false
                        }
                    }
                } else if result is TswScanResult.Aborted {
                    self.sidewallStatusLabel.text = "Sidewall scan aborted"
                    self.sidewallStatusLabel.textColor = Accent.warning
                    self.setSidewallStatusIcon("exclamationmark.triangle", color: Accent.warning)
                } else if let failed = result as? TswScanResult.Failed {
                    self.sidewallStatusLabel.text = "Failed (\(failed.error.code)): \(failed.error.message)"
                    self.sidewallStatusLabel.textColor = .systemRed
                    self.setSidewallStatusIcon("exclamationmark.triangle", color: .systemRed)
                }
            }
        }
    }

    // MARK: - Helpers

    private func setButtonLoading(_ button: UIButton, spinner: UIActivityIndicatorView, loading: Bool) {
        button.isEnabled = !loading
        if loading {
            button.setTitle("", for: .normal)
            if button === sidewallScanButton { button.setAttributedTitle(NSAttributedString(string: ""), for: .normal) }
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            if button === getResultsButton { button.setTitle("Get Results", for: .normal) }
            else if button === sidewallScanButton { button.setAttributedTitle(sidewallScanAttributedTitle, for: .normal) }
        }
    }

    private func setSoftButtonLoading(_ button: UIButton, spinner: UIActivityIndicatorView, loading: Bool, title: String) {
        if loading {
            button.setTitle("", for: .normal)
            button.isEnabled = false
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            button.setTitle(title, for: .normal)
            button.isEnabled = true
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
            scanStatusLabel.textColor = Accent.success
        case "ScanAborted":
            if let uuid = outcome.measurementUUID, !uuid.isEmpty {
                measurementUUID = uuid
                uuidTextField.text = uuid
            }
            scanStatusLabel.text = "Outcome: aborted"
            scanStatusLabel.textColor = Accent.warning
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
        title = "API Explorer"
        view.backgroundColor = .systemGroupedBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // === 1 · SET UP =====================================================

        sdkVersionLabel = makeValuePill()
        sdkVersionLabel.text = AnylineTireTread.shared.sdkVersion

        deviceSupportCircle = StatusCircle()
        deviceSupportButton = makeSoftButton(title: "Check", action: #selector(deviceSupportTapped))
        deviceSupportSpinner = makeButtonSpinner(in: deviceSupportButton, color: Accent.brand)
        deviceSupportStatusLabel = makeDetailLabel("Not checked yet")

        initCircle = StatusCircle()
        initButton = makeSoftButton(title: "Initialize", action: #selector(initButtonTapped))
        initSpinner = makeButtonSpinner(in: initButton, color: Accent.brand)
        initStatusLabel = makeDetailLabel("Not initialized")

        setupCompleteChip = makeStatusChipView(text: "Complete", color: Accent.success, systemIcon: "checkmark.circle.fill")
        setupCompleteChip.isHidden = true

        let setupCard = makeCard([
            makeMetaRow(key: "TTR SDK version", value: sdkVersionLabel),
            makeHairline(),
            makeSetupRow(circle: deviceSupportCircle, title: "Check device support", detailLabel: deviceSupportStatusLabel, button: deviceSupportButton),
            makeHairline(),
            makeSetupRow(circle: initCircle, title: "Initialize SDK", detailLabel: initStatusLabel, button: initButton),
        ])

        // === CORRELATION ID (optional, shared) ==============================

        correlationIdSwitch = UISwitch()
        correlationIdSwitch.isOn = true
        correlationIdSwitch.onTintColor = Accent.brand
        correlationIdSwitch.addTarget(self, action: #selector(correlationToggled), for: .valueChanged)

        correlationMonoInset = makeMonoInset(tag: "UUID", value: correlationId, tagColor: Accent.correlation)

        let correlationCard = makeCard([
            makeCardHeader(
                icon: makeIconTile(image: UIImage(systemName: "link") ?? UIImage(), accent: Accent.correlation, size: 34),
                title: "Correlation ID",
                subtitle: "Links one sidewall + one tread scan as a pair. Applies to both scanners below.",
                titleTrailing: makeMutedChip("Optional"),
                status: correlationIdSwitch
            ),
            correlationMonoInset,
        ])

        // === 2 · SCAN — Tire Sidewall =======================================

        sidewallScanButton = makeActionButton(title: "Sidewall Scan", color: Accent.brand, icon: TireGlyphs.centerFocusStrong(), action: #selector(sidewallScanTapped))
        sidewallScanSpinner = makeButtonSpinner(in: sidewallScanButton, color: .white)
        sidewallScanAttributedTitle = sidewallScanButton.attributedTitle(for: .normal)

        sidewallSupportChip = ChipLabel()
        sidewallSupportChip.configure(text: "Checking…", kind: .muted)

        sidewallAttachedChip = makeAttachedChip()
        sidewallAttachedChip.isHidden = !correlationIdSwitch.isOn

        sidewallStatusIcon = UIImageView()
        sidewallStatusIcon.contentMode = .scaleAspectFit
        sidewallStatusIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        sidewallStatusIcon.setContentHuggingPriority(.required, for: .horizontal)
        sidewallStatusIcon.isHidden = true
        sidewallStatusLabel = makeStatusLabel()
        let sidewallStatusRow = UIStackView(arrangedSubviews: [sidewallStatusIcon, sidewallStatusLabel])
        sidewallStatusRow.axis = .horizontal
        sidewallStatusRow.alignment = .center
        sidewallStatusRow.spacing = 7

        sidewallImageView = UIImageView()
        // The sidewall scanner returns a 3:4 (portrait) capture — match that
        // ratio and fill the frame so the thumbnail isn't letterboxed.
        sidewallImageView.contentMode = .scaleAspectFill
        sidewallImageView.backgroundColor = UIColor(rgb: 0x101114)
        sidewallImageView.isHidden = true
        sidewallImageView.layer.cornerRadius = 12
        sidewallImageView.layer.masksToBounds = true
        sidewallImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sidewallImageView.widthAnchor.constraint(equalToConstant: 90),
            sidewallImageView.heightAnchor.constraint(equalToConstant: 120),
        ])

        sidewallSizeTitleLabel = UILabel()
        sidewallSizeTitleLabel.text = "DETECTED SIZE"
        sidewallSizeTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        sidewallSizeTitleLabel.textColor = .secondaryLabel
        sidewallSizeTitleLabel.isHidden = true

        sidewallSizeLabel = UILabel()
        sidewallSizeLabel.font = .systemFont(ofSize: 22, weight: .bold)
        sidewallSizeLabel.textColor = .label
        sidewallSizeLabel.isHidden = true

        sidewallHandoffChip = ChipLabel()
        sidewallHandoffChip.isHidden = true

        let sidewallDetails = UIStackView(arrangedSubviews: [sidewallSizeTitleLabel, sidewallSizeLabel, sidewallHandoffChip])
        sidewallDetails.axis = .vertical
        sidewallDetails.spacing = 5
        sidewallDetails.alignment = .leading

        let sidewallImageRow = UIStackView(arrangedSubviews: [sidewallImageView, sidewallDetails])
        sidewallImageRow.axis = .horizontal
        sidewallImageRow.spacing = 12
        sidewallImageRow.alignment = .top

        let jsonChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        jsonChevron.tintColor = .secondaryLabel
        jsonChevron.contentMode = .scaleAspectFit
        jsonChevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        jsonChevron.setContentHuggingPriority(.required, for: .horizontal)
        sidewallJsonChevron = jsonChevron

        let jsonHeaderSpacer = UIView()
        jsonHeaderSpacer.isUserInteractionEnabled = false
        jsonHeaderSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let jsonHeader = UIStackView(arrangedSubviews: [jsonChevron, makeSubhead("Result JSON"), jsonHeaderSpacer])
        jsonHeader.axis = .horizontal
        jsonHeader.alignment = .center
        jsonHeader.spacing = 6
        jsonHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSidewallJson)))
        jsonHeader.isHidden = true
        sidewallJsonHeader = jsonHeader

        let jsonLabel = InsetLabel()
        jsonLabel.contentInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        jsonLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        jsonLabel.textColor = .label
        jsonLabel.numberOfLines = 0
        jsonLabel.backgroundColor = .tertiarySystemGroupedBackground
        jsonLabel.layer.cornerRadius = 10
        jsonLabel.layer.masksToBounds = true
        jsonLabel.isHidden = true
        sidewallJsonLabel = jsonLabel

        let sidewallCard = makeCard([
            makeCardHeader(
                icon: makeIconTile(image: TireGlyphs.sidewall(), accent: Accent.brand),
                title: "Tire Sidewall",
                subtitle: "Reads tire size markings off the sidewall",
                status: sidewallSupportChip
            ),
            sidewallAttachedChip,
            sidewallScanButton,
            sidewallStatusRow,
            sidewallImageRow,
            sidewallJsonHeader,
            sidewallJsonLabel,
        ])

        // === 2 · SCAN — Tire Tread ==========================================

        appearanceControl = makeSegmentedControl(items: ["Classic", "Neon"], selected: 1)
        scanSpeedControl = makeSegmentedControl(items: ["Fast", "Slow"], selected: 0)
        measurementSystemControl = makeSegmentedControl(items: ["Metric", "Imperial"], selected: 0)
        heatmapStyleControl = makeSegmentedControl(items: ["Colored", "Grayscale"], selected: 0)

        tireWidthField = UITextField()
        tireWidthField.placeholder = "not set"
        tireWidthField.borderStyle = .roundedRect
        tireWidthField.keyboardType = .numberPad
        tireWidthField.textAlignment = .right
        tireWidthField.font = .systemFont(ofSize: 14)
        tireWidthField.translatesAutoresizingMaskIntoConstraints = false
        tireWidthField.widthAnchor.constraint(equalToConstant: 90).isActive = true
        tireWidthField.addTarget(self, action: #selector(tireWidthEdited), for: .editingChanged)

        tireWidthFromTag = ChipLabel()
        tireWidthFromTag.configure(text: "from sidewall", kind: .soft(Accent.sidewall))
        tireWidthFromTag.isHidden = true

        tirePositionSwitch = UISwitch()
        tirePositionSwitch.isOn = true
        tirePositionSwitch.onTintColor = Accent.brand

        scanButton = makeActionButton(title: "Tread Scan", color: Accent.brand, icon: TireGlyphs.cropFree(), action: #selector(scanTapped))
        scanButton.isEnabled = false

        treadStatusChip = ChipLabel()
        treadStatusChip.configure(text: "Needs setup", kind: .muted)

        uuidTextField = UITextField()
        uuidTextField.placeholder = "Measurement UUID (auto-filled after scan)"
        uuidTextField.borderStyle = .roundedRect
        uuidTextField.autocapitalizationType = .none
        uuidTextField.autocorrectionType = .no
        uuidTextField.font = .systemFont(ofSize: 14)
        uuidTextField.translatesAutoresizingMaskIntoConstraints = false
        uuidTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        scanStatusLabel = makeStatusLabel()

        let treadCard = makeCard([
            makeCardHeader(
                icon: makeIconTile(image: TireGlyphs.tread(), accent: Accent.brand),
                title: "Tire Tread",
                subtitle: "Measures tread depth across the tire",
                status: treadStatusChip
            ),
            makeSubhead("Scan configuration"),
            makeSegmentRow("Appearance", appearanceControl),
            makeSegmentRow("Scan speed", scanSpeedControl),
            makeSegmentRow("Units", measurementSystemControl),
            makeSegmentRow("Heatmap", heatmapStyleControl),
            makeTireWidthRow(),
            makeHairline(),
            makeSwitchRow("Include tirePosition", sub: "Added to additionalContext", tirePositionSwitch),
            scanButton,
            scanStatusLabel,
            makeUuidBlock(),
        ])

        // === 3 · RESULTS ====================================================

        getResultsButton = makeOutlineButton(title: "Get Results", action: #selector(getResultsTapped))
        resultsSpinner = makeButtonSpinner(in: getResultsButton, color: Accent.brand)
        resultsStatusLabel = makeStatusLabel()

        globalDepthLabel = UILabel()
        minimumDepthLabel = UILabel()
        localDepth1Label = UILabel()
        localDepth2Label = UILabel()
        localDepth3Label = UILabel()

        let metricsRow = UIStackView(arrangedSubviews: [
            makeMetricTile(title: "Global", valueLabel: globalDepthLabel, highlight: false),
            makeMetricTile(title: "Minimum", valueLabel: minimumDepthLabel, highlight: true),
        ])
        metricsRow.axis = .horizontal
        metricsRow.distribution = .fillEqually
        metricsRow.spacing = 10

        let regionsRow = UIStackView(arrangedSubviews: [
            makeRegionTile(title: "R[0]", valueLabel: localDepth1Label),
            makeRegionTile(title: "R[1]", valueLabel: localDepth2Label),
            makeRegionTile(title: "R[2]", valueLabel: localDepth3Label),
        ])
        regionsRow.axis = .horizontal
        regionsRow.distribution = .fillEqually
        regionsRow.spacing = 8

        let resultsCard = makeCard([
            getResultsButton,
            resultsStatusLabel,
            metricsRow,
            makeSubhead("Per region"),
            regionsRow,
        ])

        // === Assemble ========================================================

        let group1 = makeGroupHeader(1, "Set up", trailing: setupCompleteChip)
        let group2 = makeGroupHeader(2, "Scan", hint: "Two independent scanners")
        let group3 = makeGroupHeader(3, "Results", hint: "From the Tread scan above")

        let rootStack = UIStackView(arrangedSubviews: [
            group1, setupCard,
            correlationCard,
            group2, sidewallCard, treadCard,
            group3, resultsCard,
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        // Tight gap below a group header; extra breathing room above the next one.
        rootStack.setCustomSpacing(6, after: group1)
        rootStack.setCustomSpacing(6, after: group2)
        rootStack.setCustomSpacing(6, after: group3)
        rootStack.setCustomSpacing(22, after: correlationCard)
        rootStack.setCustomSpacing(22, after: treadCard)
        contentView.addSubview(rootStack)

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

            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }

    // MARK: - Card / group toolkit

    private func makeCard(_ items: [UIView]) -> CardView {
        let card = CardView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.translatesAutoresizingMaskIntoConstraints = false

        let body = UIStackView(arrangedSubviews: items)
        body.axis = .vertical
        body.spacing = 10
        body.isLayoutMarginsRelativeArrangement = true
        body.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        body.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: card.topAnchor),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])
        return card
    }

    private func makeGroupHeader(_ number: Int, _ title: String, hint: String? = nil, trailing: UIView? = nil) -> UIView {
        let numberBox = UILabel()
        numberBox.text = "\(number)"
        numberBox.font = .systemFont(ofSize: 12, weight: .bold)
        numberBox.textColor = .systemBackground
        numberBox.textAlignment = .center
        numberBox.backgroundColor = .label
        numberBox.layer.cornerRadius = 7
        numberBox.layer.masksToBounds = true
        numberBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberBox.widthAnchor.constraint(equalToConstant: 22),
            numberBox.heightAnchor.constraint(equalToConstant: 22),
        ])

        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(
            string: title.uppercased(),
            attributes: [
                .kern: 1.1,
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor.secondaryLabel,
            ]
        )
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [numberBox, titleLabel, spacer])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        if let trailing {
            trailing.setContentHuggingPriority(.required, for: .horizontal)
            row.addArrangedSubview(trailing)
        } else if let hint {
            let hintLabel = UILabel()
            hintLabel.text = hint
            hintLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            hintLabel.textColor = .secondaryLabel
            row.addArrangedSubview(hintLabel)
        }
        return row
    }

    private func makeCardHeader(icon: UIView?, title: String, subtitle: String?, titleTrailing: UIView? = nil, status: UIView?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label

        let titleLine: UIView
        if let titleTrailing {
            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleTrailing.setContentHuggingPriority(.required, for: .horizontal)
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            let line = UIStackView(arrangedSubviews: [titleLabel, titleTrailing, spacer])
            line.axis = .horizontal
            line.alignment = .center
            line.spacing = 8
            titleLine = line
        } else {
            titleLine = titleLabel
        }

        let textStack = UIStackView(arrangedSubviews: [titleLine])
        textStack.axis = .vertical
        textStack.spacing = 2
        if let subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = .systemFont(ofSize: 12.5)
            sub.textColor = .secondaryLabel
            sub.numberOfLines = 0
            textStack.addArrangedSubview(sub)
        }
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        if let icon { row.addArrangedSubview(icon) }
        row.addArrangedSubview(textStack)
        if let status {
            status.setContentHuggingPriority(.required, for: .horizontal)
            status.setContentCompressionResistancePriority(.required, for: .horizontal)
            row.addArrangedSubview(status)
        }
        return row
    }

    private func makeIconTile(image: UIImage, accent: UIColor, size: CGFloat = 38) -> UIView {
        let tile = UIView()
        tile.backgroundColor = accent.withAlphaComponent(0.12)
        tile.layer.cornerRadius = 11
        tile.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(imageView)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: size),
            tile.heightAnchor.constraint(equalToConstant: size),
            imageView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: size * 0.62),
            imageView.heightAnchor.constraint(equalToConstant: size * 0.62),
        ])
        return tile
    }

    private func makeHairline() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func makeMetaRow(key: String, value: UILabel) -> UIView {
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        keyLabel.textColor = .secondaryLabel
        keyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        value.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [keyLabel, value])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func makeSoftButton(title: String, action: Selector) -> SoftButton {
        let button = SoftButton()
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeDetailLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12.5, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func makeSetupRow(circle: UIView, title: String, detailLabel: UILabel, button: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .label

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [circle, textStack, button])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    private func makeStatusChipView(text: String, color: UIColor, systemIcon: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: systemIcon))
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = color

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)
        row.translatesAutoresizingMaskIntoConstraints = false

        let pill = PillView()
        pill.backgroundColor = color.withAlphaComponent(0.12)
        pill.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: pill.topAnchor),
            row.leadingAnchor.constraint(equalTo: pill.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: pill.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: pill.bottomAnchor),
        ])
        return pill
    }

    /// Left-aligned pill marking a scanner as carrying the shared correlationId.
    private func makeAttachedChip() -> UIView {
        let chip = makeStatusChipView(text: "correlationId attached", color: Accent.correlation, systemIcon: "link")
        chip.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.addSubview(chip)
        NSLayoutConstraint.activate([
            chip.topAnchor.constraint(equalTo: container.topAnchor),
            chip.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            chip.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            chip.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
        ])
        return container
    }

    private func setSidewallStatusIcon(_ systemName: String, color: UIColor) {
        sidewallStatusIcon.image = UIImage(systemName: systemName)
        sidewallStatusIcon.tintColor = color
        sidewallStatusIcon.isHidden = false
    }

    private func makeMonoInset(tag: String, value: String, tagColor: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .tertiarySystemGroupedBackground
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false

        let tagLabel = UILabel()
        tagLabel.text = tag
        tagLabel.font = .systemFont(ofSize: 9, weight: .bold)
        tagLabel.textColor = tagColor
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        valueLabel.textColor = .secondaryLabel
        valueLabel.lineBreakMode = .byTruncatingTail

        let row = UIStackView(arrangedSubviews: [tagLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 9, left: 11, bottom: 9, right: 11)
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }

    private func makeTireWidthRow() -> UIView {
        let label = UILabel()
        label.text = "Tire width (mm)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [label, tireWidthFromTag, tireWidthField])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func makeUuidBlock() -> UIView {
        let header = makeSubhead("Measurement UUID")
        let stack = UIStackView(arrangedSubviews: [header, uuidTextField])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeMetricTile(title: String, valueLabel: UILabel, highlight: Bool) -> UIView {
        let tile = UIView()
        tile.backgroundColor = highlight ? Accent.brand.withAlphaComponent(0.12) : .tertiarySystemGroupedBackground
        tile.layer.cornerRadius = 13
        tile.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = highlight ? Accent.brand : .secondaryLabel

        valueLabel.text = "\u{2013}"
        valueLabel.font = .systemFont(ofSize: 26, weight: .bold)
        valueLabel.textColor = highlight ? Accent.brand : .label
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let unitLabel = UILabel()
        unitLabel.text = "mm"
        unitLabel.font = .systemFont(ofSize: 12, weight: .bold)
        unitLabel.textColor = highlight ? Accent.brand : .secondaryLabel

        let valueRow = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueRow.axis = .horizontal
        valueRow.spacing = 3
        valueRow.alignment = .lastBaseline

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueRow])
        stack.axis = .vertical
        stack.spacing = 6
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        stack.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: tile.topAnchor),
            stack.leadingAnchor.constraint(equalTo: tile.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: tile.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: tile.bottomAnchor),
        ])
        return tile
    }

    private func makeRegionTile(title: String, valueLabel: UILabel) -> UIView {
        let tile = UIView()
        tile.backgroundColor = .tertiarySystemGroupedBackground
        tile.layer.cornerRadius = 11
        tile.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        valueLabel.text = "\u{2013}"
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        stack.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: tile.topAnchor),
            stack.leadingAnchor.constraint(equalTo: tile.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: tile.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: tile.bottomAnchor),
        ])
        return tile
    }

    // MARK: - Control / label factory

    private func makeActionButton(title: String, color: UIColor, titleColor: UIColor = .white, icon: UIImage? = nil, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = color
        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(titleColor.withAlphaComponent(0.6), for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true

        if let icon {
            func titled(_ tint: UIColor) -> NSAttributedString {
                let attachment = NSTextAttachment()
                attachment.image = icon.withTintColor(tint, renderingMode: .alwaysOriginal)
                attachment.bounds = CGRect(x: 0, y: -4, width: icon.size.width, height: icon.size.height)
                let attributed = NSMutableAttributedString(attachment: attachment)
                attributed.append(NSAttributedString(
                    string: "  " + title,
                    attributes: [.foregroundColor: tint, .font: UIFont.boldSystemFont(ofSize: 15)]
                ))
                return attributed
            }
            button.setAttributedTitle(titled(titleColor), for: .normal)
            button.setAttributedTitle(titled(titleColor.withAlphaComponent(0.6)), for: .disabled)
        } else {
            button.setTitle(title, for: .normal)
        }
        return button
    }

    private func makeOutlineButton(title: String, action: Selector) -> OutlineButton {
        let button = OutlineButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(Accent.brand, for: .normal)
        button.setTitleColor(Accent.brand.withAlphaComponent(0.4), for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.borderColorProvider = Accent.brand
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    private func makeButtonSpinner(in button: UIButton, color: UIColor) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = color
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
        return spinner
    }

    private func makeSegmentedControl(items: [String], selected: Int) -> UISegmentedControl {
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selected
        control.selectedSegmentTintColor = Accent.brand
        control.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 13)], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }

    private func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSubhead(_ text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: text.uppercased(),
            attributes: [
                .kern: 0.6,
                .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                .foregroundColor: UIColor.secondaryLabel,
            ]
        )
        return label
    }

    private func makeValuePill() -> InsetLabel {
        let label = InsetLabel()
        label.contentInsets = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.backgroundColor = .tertiarySystemGroupedBackground
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true
        return label
    }

    private func makeSwitchRow(_ title: String, sub: String? = nil, _ toggle: UISwitch) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label

        let textStack = UIStackView(arrangedSubviews: [label])
        textStack.axis = .vertical
        textStack.spacing = 2
        if let sub {
            let subLabel = UILabel()
            subLabel.text = sub
            subLabel.font = .systemFont(ofSize: 11.5)
            subLabel.textColor = .secondaryLabel
            subLabel.numberOfLines = 0
            textStack.addArrangedSubview(subLabel)
        }
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [textStack, toggle])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func makeSegmentRow(_ title: String, _ control: UISegmentedControl) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    private func makeMutedChip(_ text: String) -> ChipLabel {
        let chip = ChipLabel()
        chip.configure(text: text, kind: .muted)
        return chip
    }

    private static func extractTireWidthFromTireSizeString(_ tireSizeString: String) -> Int? {
        guard let match = tireSizeString.range(of: #"[A-Za-z]*\d{3}"#, options: .regularExpression) else { return nil }
        let digits = String(tireSizeString[match].filter { $0.isNumber }.prefix(3))
        guard let width = Int(digits), (100...500).contains(width) else { return nil }
        return width
    }

    private static func prettyJson(_ raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: pretty, encoding: .utf8)
        else { return raw }
        return str
    }
}

// MARK: - Anyline design-system accents

/// Single source of truth for the accent colors, with light/dark variants so
/// the whole screen reads correctly in both appearances.
private enum Accent {
    static let brand = dynamic(light: 0x0099FF, dark: 0x0A9DFF)
    static let sidewall = dynamic(light: 0x0C93B0, dark: 0x5FD6EA)
    static let correlation = dynamic(light: 0x5246E0, dark: 0xA09DF6)
    static let success = dynamic(light: 0x00A37A, dark: 0x2EE0AB)
    static let warning = dynamic(light: 0xB5740A, dark: 0xFFB340)

    private static func dynamic(light: Int, dark: Int) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(rgb: dark) : UIColor(rgb: light)
        }
    }
}

private extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Small presentation primitives

/// Rounded, hairline-bordered surface. Refreshes its border in `layoutSubviews`
/// so the separator color tracks light/dark changes.
private final class CardView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        layer.masksToBounds = true
    }
}

/// Outlined pill button (secondary action). Border tracks light/dark.
private final class OutlineButton: UIButton {
    var borderColorProvider: UIColor = .label
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 14
        layer.borderWidth = 1.5
        layer.borderColor = borderColorProvider.resolvedColor(with: traitCollection).cgColor
        layer.masksToBounds = true
    }
}

/// Compact, brand-tinted secondary button used inside setup rows.
private final class SoftButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)
        titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        updateColors()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isEnabled: Bool { didSet { updateColors() } }

    private func updateColors() {
        backgroundColor = isEnabled ? Accent.brand.withAlphaComponent(0.12) : .tertiarySystemGroupedBackground
        setTitleColor(isEnabled ? Accent.brand : .tertiaryLabel, for: .normal)
    }
}

/// 26pt step indicator: a hairline-bordered dot that fills green with a check
/// once its step is done.
private final class StatusCircle: UIView {
    private let check = UIImageView(image: UIImage(systemName: "checkmark"))
    var done = false { didSet { update() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        check.tintColor = .white
        check.contentMode = .scaleAspectFit
        check.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        check.translatesAutoresizingMaskIntoConstraints = false
        addSubview(check)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 26),
            heightAnchor.constraint(equalToConstant: 26),
            check.centerXAnchor.constraint(equalTo: centerXAnchor),
            check.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        update()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        if !done { layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor }
    }

    private func update() {
        check.isHidden = !done
        backgroundColor = done ? UIColor(rgb: 0x00BB8E) : .tertiarySystemGroupedBackground
        layer.borderWidth = done ? 0 : 1
        setNeedsLayout()
    }
}

/// A view that rounds itself to a capsule.
private final class PillView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}

/// UILabel with content insets (used for value pills and the JSON block).
private class InsetLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }
}

/// Status pill — either a soft tinted capsule or a subtle outlined tag.
private final class ChipLabel: InsetLabel {
    enum Kind {
        case soft(UIColor)
        case muted
    }

    private var kind: Kind = .muted
    private var capsule = true

    func configure(text: String, kind: Kind) {
        self.kind = kind
        self.text = text
        switch kind {
        case .soft(let color):
            capsule = true
            textColor = color
            backgroundColor = color.withAlphaComponent(0.12)
            font = .systemFont(ofSize: 11, weight: .bold)
            contentInsets = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)
        case .muted:
            capsule = false
            textColor = .secondaryLabel
            backgroundColor = .clear
            font = .systemFont(ofSize: 11, weight: .semibold)
            contentInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = capsule ? bounds.height / 2 : 6
        if case .muted = kind {
            layer.borderWidth = 1
            layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
