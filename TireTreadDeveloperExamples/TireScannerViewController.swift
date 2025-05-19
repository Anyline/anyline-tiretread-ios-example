import UIKit
import AnylineTireTreadSdk

class TireScannerViewController: UIViewController {

    // if config is non-null, jsonConfig would be ignored
    init(config: TireTreadConfig) {
        scanViewConfig = config
        super.init(nibName: nil, bundle: nil)
    }

    init(configString: String) {
        scanViewConfigStr = configString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var scannerViewController: UIViewController?

    var uuid: String?

    var scanViewConfig: TireTreadConfig!

    var scanViewConfigStr: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScanView()
    }

    func addResultView(uuid: String) {

        let resultViewController = ScanResultViewController(uuid: uuid)

        addChild(resultViewController)
        view.addSubview(resultViewController.view)

        resultViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resultViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            resultViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc func dismissButtonTapped(button: UIButton) {
        dismiss(animated: true)
    }

    func setupScanView() {
        assert(scanViewConfig != nil || scanViewConfigStr != nil)

        if let scanViewConfig = scanViewConfig {
            self.scannerViewController = TireTreadScanViewKt.TireTreadScanView(
                config: scanViewConfig,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: showResult,
                callback: handleScanEvent
            ) { measurementUUID, error in
                print("Initialization failed: \(error)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        } else if let scanViewConfigStr = scanViewConfigStr {
            self.scannerViewController = TireTreadScanViewKt.TireTreadScanView(
                config: scanViewConfigStr,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: showResult,
                callback: handleScanEvent
            ) { measurementUUID, error in
                print("Initialization failed: \(error)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }

        addScanViewControllerAsChild()
    }

    private func onScanAborted(measurementUUID: String?) {
        print("onScanAbort")
        removeScanViewControllerAsChild()
        dismiss(animated: true, completion: nil)
    }
    
    private func handleScanEvent(event: ScanEvent) {
        switch(event) {
            
        case let event as OnImageUploaded:
            print("onImageUploaded: \(event.total) images uploaded in total")
            break
            
        default:
            print("ScanEvent: \(event.description)")
            break
        }
    }
    
    private func showResult(measurementUUID: String) {
        print("onUploadCompleted")
        removeScanViewControllerAsChild()
        addResultView(uuid: measurementUUID)
    }

    private func addScanViewControllerAsChild() {
        guard let scannerViewController = self.scannerViewController else {
            print("Error: scannerViewController is null")
            return
        }

        addChild(scannerViewController)
        view.addSubview(scannerViewController.view)

        scannerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scannerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scannerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scannerViewController.didMove(toParent: self)
    }

    private func removeScanViewControllerAsChild() {
        guard let scannerViewController = self.scannerViewController else {
            print("Error: scannerViewController is null")
            return
        }
        scannerViewController.willMove(toParent: nil)
        scannerViewController.view.removeFromSuperview()
        scannerViewController.removeFromParent()
    }
}
