import UIKit
import AnylineTireTreadSdk

class HomeViewController: UIViewController {

    var configFiles: [String] = []

    var sdkStatusLabel: UILabel!

    var activityIndicator: UIActivityIndicatorView!

    var retryInitSdkButton: UIButton!

    var stackView: UIStackView!

    var scrollView: UIScrollView!

    var contentView: UIView!

    // MARK: - UIButton onpress methods

    @objc func defaultConfigTapped() {
        // create a TireTreadScanViewConfig without parameters
        let config = TireTreadScanViewConfig()
        let tireScanViewController = TireScannerViewController(config: config)
        tireScanViewController.modalPresentationStyle = .fullScreen
        present(tireScanViewController, animated: true, completion: nil)
    }

    @objc func manualConfigTapped() {
        // manually specify TireTreadScanViewConfig parameters with settings UI
        let settingsViewController = SettingsTableViewController()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @objc func jsonConfigTapped(_ button: UIButton) {

        var alertStyle: UIAlertController.Style = .actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = .alert
        }

        let alertController = UIAlertController(title: "home.json_select.prompt".localized,
                                                message: nil,
                                                preferredStyle: alertStyle)
        for configFile in configFiles {
            alertController.addAction(.init(title: configFile, style: .default, handler: { [weak self] _ in
                guard let configStr = self?.readConfigFile(named: configFile) else { return }
                let tireTreadViewController = TireScannerViewController(configString: configStr)
                tireTreadViewController.modalPresentationStyle = .fullScreen
                self?.present(tireTreadViewController, animated: true, completion: nil)
            }))
        }

        alertController.addAction(.init(title: "home.json_select.cancel".localized,
                                        style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func didPressInitializeSDK() {
        initializeSDK()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareConfigFiles()

        setupUI()

        initializeSDK()
    }


    private func initializeSDK() {
        // Disable buttons and show status indicator
        setButtonsEnabled(false)
        sdkStatusLabel.text = "home.sdk_status.initializing".localized
        sdkStatusLabel.isHidden = false
        activityIndicator.startAnimating()
        retryInitSdkButton.isHidden = true

        Task {
            let result = await SDKUtilities.initializeSDK()
            switch result {
            case .success:
                print("home.sdk_status.success".localized)
                sdkStatusLabel.isHidden = true
                activityIndicator.stopAnimating()
                setButtonsEnabled(true)
            case .failure(let error):
                var sdkStatus = ""
                if let ttrError = error as? TireTreadError {
                    switch ttrError {
                    case .responseError(let message): sdkStatus = message
                    case .responseException(let message): sdkStatus = message
                    }
                } else {
                    sdkStatus = error.localizedDescription
                }
                sdkStatusLabel.text = "\("home.sdk_status.error".localized)\(sdkStatus)"
                activityIndicator.stopAnimating()
                retryInitSdkButton.isHidden = false
            }
        }
    }

    private func setupUI() {

        title = "home.title".localized

        view.backgroundColor = .systemBackground

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let defaultConfigButton = UIButton(type: .system)
        defaultConfigButton.setTitle("home.button.title.default".localized, for: .normal)
        styleButton(defaultConfigButton)
        defaultConfigButton.addTarget(self, action: #selector(defaultConfigTapped), for: .touchUpInside)

        let manualConfigButton = UIButton(type: .system)
        manualConfigButton.setTitle("home.button.title.manual".localized, for: .normal)
        styleButton(manualConfigButton)
        manualConfigButton.addTarget(self, action: #selector(manualConfigTapped), for: .touchUpInside)

        let jsonConfigButton = UIButton(type: .system)
        jsonConfigButton.setTitle("home.button.title.json".localized, for: .normal)
        styleButton(jsonConfigButton)
        jsonConfigButton.addTarget(self, action: #selector(jsonConfigTapped), for: .touchUpInside)
        
        let appVersionLabel = UILabel()
        appVersionLabel.text = "TTR SDK: \(AnylineTireTreadSdk.shared.sdkVersion)"
        
        stackView = UIStackView(arrangedSubviews: [defaultConfigButton, manualConfigButton, jsonConfigButton, appVersionLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        defaultConfigButton.translatesAutoresizingMaskIntoConstraints = false
        manualConfigButton.translatesAutoresizingMaskIntoConstraints = false
        jsonConfigButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 70),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240),

            defaultConfigButton.heightAnchor.constraint(equalToConstant: 48),
            manualConfigButton.heightAnchor.constraint(equalToConstant: 48),
            jsonConfigButton.heightAnchor.constraint(equalToConstant: 48),

            defaultConfigButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            manualConfigButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            jsonConfigButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])

        sdkStatusLabel = UILabel()
        sdkStatusLabel.text = "home.sdk_status.initializing".localized
        sdkStatusLabel.textAlignment = .center
        sdkStatusLabel.numberOfLines = 0
        sdkStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sdkStatusLabel)

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)

        retryInitSdkButton = UIButton(type: .system)
        retryInitSdkButton.setTitle("home.button.retry".localized, for: .normal)
        retryInitSdkButton.addTarget(self, action: #selector(didPressInitializeSDK), for: .touchUpInside)
        retryInitSdkButton.translatesAutoresizingMaskIntoConstraints = false
        retryInitSdkButton.isHidden = true
        contentView.addSubview(retryInitSdkButton)

        NSLayoutConstraint.activate([
            sdkStatusLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            sdkStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sdkStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityIndicator.topAnchor.constraint(equalTo: sdkStatusLabel.bottomAnchor, constant: 10),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryInitSdkButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            retryInitSdkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryInitSdkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setButtonsEnabled(_ enabled: Bool) {
        for view in stackView.arrangedSubviews {
            if let button = view as? UIButton {
                button.isEnabled = enabled
            }
        }
    }

    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
    }

    private func prepareConfigFiles() {
        if let bundleURL = Bundle.main.url(forResource: "configs", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil)
                configFiles = fileURLs.filter { $0.pathExtension == "json" }.map { $0.lastPathComponent }
            } catch {
                print("Error loading config files: \(error)")
            }
        }
    }

    // return the string content of the named (config) file
    private func readConfigFile(named fileName: String) -> String? {
        if let bundleURL = Bundle.main.url(forResource: "configs", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL),
           let fileURL = bundle.url(forResource: fileName, withExtension: nil) {
            do {
                let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                return fileContents
            } catch {
                print("Error reading file \(fileName): \(error)")
            }
        }
        return nil
    }
}
