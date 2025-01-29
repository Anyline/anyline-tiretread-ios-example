import UIKit
import AnylineTireTreadSdk

class SettingsTableViewController: UITableViewController, UITextViewDelegate {

    // MARK: - Constants

    fileprivate enum CellType: String, CaseIterable {
        case labelCell,
             switchCell,
             selectionCell,
             startButtonCell,
             resetButtonCell
    }

    let scanSpeeds: [String] = [
        "settings.scan_speeds.slow".localized,
        "settings.scan_speeds.fast".localized
    ]

    let measurementUnitsOptions: [String] = [
        "settings.measurement_units.metric".localized,
        "settings.measurement_units.imperial".localized
    ]

    // MARK: - UI Properties

    var sdkStatus = "settings.sdk_status.uninitialized".localized {
        didSet {
            startButton.isEnabled = isStartScanningEnabled
            tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        }
    }

    var customScanSpeedStr: String? = nil

    var customMeasurementUnitStr: String? = nil

    var isCustomShowGuidanceEnabled = true

    var isStartScanningEnabled: Bool {
        return sdkStatus == "settings.sdk_status.initialized".localized
    }

    var isResetToDefaultsEnabled: Bool = false {
        didSet {
            resetToDefaultsButton.isEnabled = isResetToDefaultsEnabled
        }
    }

    var selectedConfigFile: String = "settings.configs.default_name".localized {
        didSet {
            configJSON = SettingsTableViewController.loadConfigJSONFromFile(selectedConfigFile)

            if configJSON == nil {
                configJSON = [String: Any]()
                customScanSpeedStr = nil
                customMeasurementUnitStr = nil
                isCustomShowGuidanceEnabled = true
            }

            if let scanSpeed = configJSON?["scanSpeed"] as? String, !scanSpeed.isEmpty {
                customScanSpeedStr = scanSpeed
            }

            if let measurementUnit = configJSON?["measurementSystem"] as? String, !measurementUnit.isEmpty {
                customMeasurementUnitStr = measurementUnit
            }
            tableView.reloadData()
        }
    }

    fileprivate var configJSON: [String: Any]?

    // MARK: - UI Controls

    lazy var startButton: UIButton = {
        let startButton = UIButton(type: .system)
        startButton.setTitle("settings.button.start_scanning.name".localized, for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        startButton.setTitleColor(.white, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        startButton.layer.cornerRadius = 20.0
        startButton.layer.masksToBounds = true
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()

    lazy var resetToDefaultsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("settings.button.reset_to_defaults.name".localized, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        button.setTitleColor(.red.withAlphaComponent(0), for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UI Actions
    @objc func resetButtonTapped() {
        selectedConfigFile = "settings.configs.default_name".localized
        isResetToDefaultsEnabled = false
    }

    @objc func startButtonTapped() {
        let tireScanViewController = TireScannerViewController(config: getTireTreadScanViewConfig())
        tireScanViewController.modalPresentationStyle = .fullScreen
        present(tireScanViewController, animated: true, completion: nil)
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        switch sender.tag {
        case 1: customScanSpeedStr = sender.isOn ? (configJSON?["scanSpeed"] as? String ?? scanSpeeds.first!) : nil
        case 2: customMeasurementUnitStr = sender.isOn ? (configJSON?["measurementSystem"] as? String ?? measurementUnitsOptions.first!) : nil
        case 3: isCustomShowGuidanceEnabled = sender.isOn
        default: break
        }
        isResetToDefaultsEnabled = true
        startButton.isEnabled = isStartScanningEnabled
        tableView.reloadData()
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings.title".localized

        configJSON = [String: Any]()

        Task {
            // "Start Scanning" will only be enabled after the initSDK() call succeeds.
            // To retry this after a failure, tap the SDK status row again.
            await initSDK()
        }

        for cellType in CellType.allCases {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellType.rawValue)
        }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        tableView.tableHeaderView = headerView
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        isResetToDefaultsEnabled = false
    }

    // MARK: - Methods

    fileprivate func initSDK() async {
        sdkStatus = "settings.sdk_status.initializing".localized
        let result = await SDKUtilities.initializeSDK()
        switch result {
        case .success:
            sdkStatus = "settings.sdk_status.initialized".localized
        case .failure(let error):
            if let ttrError = error as? TireTreadError {
                switch ttrError {
                case .responseError(let message): sdkStatus = message
                case .responseException(let message): sdkStatus = message
                }
            } else {
                sdkStatus = error.localizedDescription
            }
        }
    }

    fileprivate static func loadConfigJSONFromFile(_ selectedConfigFile: String) -> [String: Any]? {
        if selectedConfigFile == "settings.configs.default_name".localized {
            return nil
        }
        let fileName = selectedConfigFile.split(separator: ".").first
        guard let fileName = fileName,
              let url = Bundle.main.url(forResource: String(fileName), withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return jsonDict
            } else {
                print("Failed to parse JSON")
                return nil
            }
        } catch {
            return nil
        }
    }

    /// Returns a new TireTreadScanViewConfig object, populated with values supplied by
    /// the Settings UI. This is passed to TireScannerViewController which then uses it
    /// to construct the TireTreadScanView.
    fileprivate func getTireTreadScanViewConfig() -> TireTreadScanViewConfig {

        let tireConfig = TireTreadScanViewConfig()

        // Set scan speed property
        var scanSpeedStr: String = configJSON?["scanSpeed"] as? String ?? ""
        if let customScanSpeedStr = customScanSpeedStr, !customScanSpeedStr.isEmpty {
            scanSpeedStr = customScanSpeedStr
        }

        switch scanSpeedStr {
        case "settings.scan_speeds.slow".localized:
            tireConfig.scanSpeed = .slow
        case "settings.scan_speeds.fast".localized:
            tireConfig.scanSpeed = .fast
        default: break
        }

        // Set measurement units property
        var measurementUnitStr: String = configJSON?["measurementSystem"] as? String ?? ""
        if let customMeasurementUnitStr = customMeasurementUnitStr, !customMeasurementUnitStr.isEmpty {
            measurementUnitStr = customMeasurementUnitStr
        }

        switch measurementUnitStr {
        case "settings.measurement_units.metric".localized:
            tireConfig.measurementSystem = .metric
        case "settings.measurement_units.imperial".localized:
            tireConfig.measurementSystem = .imperial
        default: break
        }

        // Set user guidance properties
        tireConfig.defaultUiConfig.scanDirectionConfig.visible = isCustomShowGuidanceEnabled
        tireConfig.defaultUiConfig.countdownConfig.visible = isCustomShowGuidanceEnabled
        tireConfig.defaultUiConfig.tireOverlayConfig.visible = isCustomShowGuidanceEnabled

        // Set miscellaneous properties
        tireConfig.useDefaultUi = true
        tireConfig.useDefaultHaptic = true

        return tireConfig
    }

    fileprivate func getCellWithType(_ cellType: CellType, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath)
        configureCell(cell, with: cellType)
        return cell
    }

    private func configureCell(_ cell: UITableViewCell, with cellType: CellType) {
        cell.textLabel?.isEnabled = true
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = (cellType == .switchCell) ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 16)
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .label
        cell.accessoryType = .none

        // avoid labels occassionally "forgetting" their indentations when reloaded
        cell.textLabel?.frame.origin = CGPoint(x: 0, y: 0)

        if cellType == .startButtonCell {
            cell.selectionStyle = .none
            cell.contentView.addSubview(startButton)

            NSLayoutConstraint.activate([
                startButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                startButton.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
                startButton.widthAnchor.constraint(equalToConstant: 250),
                startButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else if cellType == .resetButtonCell {
            cell.selectionStyle = .none
            cell.contentView.addSubview(resetToDefaultsButton)

            NSLayoutConstraint.activate([
                resetToDefaultsButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                resetToDefaultsButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])
        } else if cellType == .labelCell {
            cell.textLabel?.font = .boldSystemFont(ofSize: 16)
            cell.selectionStyle = .none
        }
    }

    private func configureSwitchCell(_ cell: UITableViewCell, isOn: Bool, section: Int) {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(isOn, animated: true)
        switchView.tag = section
        switchView.isEnabled = true
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
    }

    // MARK: - UITableView (DataSource/Delegate)

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return customScanSpeedStr != nil ? 2 : 1
        case 2: return customMeasurementUnitStr != nil ? 2 : 1
        case 3: return 1 // show guidance
        case 4: return 1 // dismiss button
        case 5: return 1 // reset button
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 4: // start button
            return 80
        case 5: // reset button
            return 30
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            cell = getCellWithType(.selectionCell, for: indexPath)
            cell.textLabel?.text = "\("settings.sdk_status.heading_text".localized)\(sdkStatus)"
            cell.accessoryType = .disclosureIndicator
        case (1, 0):
            cell = getCellWithType(.switchCell, for: indexPath)
            cell.textLabel?.text = "settings.scan_speeds.heading_text".localized
            configureSwitchCell(cell, isOn: customScanSpeedStr != nil, section: indexPath.section)
        case (1, _):
            cell = getCellWithType(.selectionCell, for: indexPath)
            cell.textLabel?.text = customScanSpeedStr
        case (2, 0):
            cell = getCellWithType(.switchCell, for: indexPath)
            cell.textLabel?.text = "settings.measurement_units.heading_text".localized
            configureSwitchCell(cell, isOn: customMeasurementUnitStr != nil, section: indexPath.section)
        case (2, _):
            cell = getCellWithType(.selectionCell, for: indexPath)
            cell.textLabel?.text = customMeasurementUnitStr
        case (3, _):
            cell = getCellWithType(.switchCell, for: indexPath)
            cell.textLabel?.text = "settings.show_guidance.heading_text".localized
            configureSwitchCell(cell, isOn: isCustomShowGuidanceEnabled, section: indexPath.section)
        case (4, _):
            cell = getCellWithType(.startButtonCell, for: indexPath)
        case (5, _):
            cell = getCellWithType(.resetButtonCell, for: indexPath)
        default:
            cell = UITableViewCell()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            Task { await initSDK() }
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                if let switchView = cell?.accessoryView as? UISwitch {
                    switchView.isOn.toggle()
                    switchChanged(switchView)
                }
            } else if indexPath.row == 1 {
                let alert = UIAlertController(title: "settings.scan_speeds.select_prompt".localized, message: nil, preferredStyle: .actionSheet)
                scanSpeeds.forEach { scanSpeed in
                    alert.addAction(UIAlertAction(title: scanSpeed, style: .default, handler: { _ in
                        self.customScanSpeedStr = scanSpeed
                        self.isResetToDefaultsEnabled = true
                        tableView.reloadData()
                    }))
                }
                alert.addAction(UIAlertAction(title: "settings.configs.select_cancel_text".localized, style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        case 2:
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                if let switchView = cell?.accessoryView as? UISwitch {
                    switchView.isOn.toggle()
                    switchChanged(switchView)
                }
            } else if indexPath.row == 1 {
                let alert = UIAlertController(title: "settings.measurement_units.select_prompt".localized, message: nil, preferredStyle: .actionSheet)
                measurementUnitsOptions.forEach { measurementUnitsOption in
                    alert.addAction(UIAlertAction(title: measurementUnitsOption, style: .default, handler: { _ in
                        self.customMeasurementUnitStr = measurementUnitsOption
                        self.isResetToDefaultsEnabled = true
                        tableView.reloadData()
                    }))
                }
                alert.addAction(UIAlertAction(title: "settings.configs.select_cancel_text".localized, style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                if let switchView = cell?.accessoryView as? UISwitch {
                    switchView.isOn.toggle()
                    switchChanged(switchView)
                }
            }
        case 4:
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                if let switchView = cell?.accessoryView as? UISwitch {
                    switchView.isOn.toggle()
                    switchChanged(switchView)
                }
            }
        default:
            break
        }
    }
}
