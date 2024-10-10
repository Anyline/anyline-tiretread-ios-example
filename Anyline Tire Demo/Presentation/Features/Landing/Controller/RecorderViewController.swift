import UIKit
import AnylineTireTreadSdk

class RecorderViewController: UIViewController {
    
    var uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var topView: ATDTopView = {
        return ATDTopView()
    }()
    
    private var textView: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.contentInset = .zero
        textView.isEditable = false
        textView.isSelectable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let tutorialText = "recorder.loading.message".localized()
        var attributedString = NSMutableAttributedString(string: tutorialText)
        
        let string = attributedString.string as NSString
        let range = NSRange(location: 0, length: string.length)
        
        // Set the font
        attributedString.addAttribute(.font, value: FontStruct.proximaNovaRegular24!, range: range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
        
        // line height
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        textView.attributedText = attributedString
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupLayout()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) { [weak self] in
            guard let self = self else { return }
            self.startQRCodeScanForTireIDFeedback(uuid: self.uuid)
        }
    }
    
    private func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(textView)
    }
    
    private func setupLayout() {
        view.backgroundColor = ColorStruct.snowWhite
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func startQRCodeScanForTireIDFeedback(uuid: String) {
        
        // scannerViewController?.view.isHidden = true
        // show the QR Code
        let message = "qrcodereader.guide_text.tire_id".localized()
        QRCodeReaderViewController.showReader(over: self.navigationController!,
                                              scanMode: .tireId,
                                              msg: message,
                                              animated: true) { [weak self] qrViewController, value in
            guard let value = value else {
                // User tapped Cancel
                self?.navigationController?.popViewController(animated: false)
                return
            }
            self?.showSendFeedbackConfirmation(over: qrViewController, uuid: uuid, tireId: value)
        }
        
        textView.isHidden = true
    }
    
    private func showSendFeedbackConfirmation(over qrViewController: QRCodeReaderViewController, uuid: String, tireId: String) {
        
        let message = String(format: "%@\n\n%@\n\n%@",
                             "recorder.msg.scanned_tire_id_1".localized(),
                             tireId, "recorder.msg.scanned_tire_id_2".localized())
        let alert = UIAlertController(title: "recorder.alert.title".localized(),
                                      message: message, preferredStyle: .alert)
        
        // buttons shown in this order.
        let buttonTitles = [
            "recorder.button.send",
            "recorder.button.title.rescan",
            "recorder.button.title.abort"
        ]
        
        for buttonTitle in buttonTitles {
            let title = buttonTitle.localized()
            
            alert.addAction(.init(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                switch buttonTitle {
                case "recorder.button.title.rescan":
                    qrViewController.restart()
                    break
                case "recorder.button.send":
                    self.sendTireIdFeedback(uuid: uuid, tireId: tireId, qrViewController: qrViewController)
                    break
                case "recorder.button.title.abort":
                    qrViewController.dismiss(animated: false)
                    self.navigationController?.popToRootViewController(animated: true)
                    break
                default:
                    break
                }
            })
        }
        qrViewController.present(alert, animated: true)
    }
    
    private func sendTireIdFeedback(uuid: String, tireId: String, qrViewController: QRCodeReaderViewController) {
        
        AnylineTireTreadSdk.shared.sendTireIdFeedback(measurementUuid: uuid, tireId: tireId) { [weak self] (response: Response<MeasurementInfo>) in
            switch(response) {
            case _ as ResponseSuccess<MeasurementInfo>:
                
                let userDefaults = UserDefaultsManager.shared
                userDefaults.addNewTireRegistration(tireId: tireId)
                let registrationCount = userDefaults.loadTireRegistration(tireId: tireId)
                
                let alertTitle = "recorder.alert.title.succeeded".localized()
                let alertMessage = "recorder.alert.message_success".localized() + "\n\nTire Id: \(tireId)\n Registries: \(registrationCount)"
                let okButtonTitle = "recorder.button.title.ok".localized()
                
                var actions: [UIAlertAction] = []
                actions.append(.init(title: okButtonTitle, style: .default) { [weak self] _ in
                    qrViewController.dismiss(animated: false)
                    self?.navigationController?.popToRootViewController(animated: true)
                })
                
                self?.presentAlert(over: qrViewController, title: alertTitle, message: alertMessage, actions: actions)
                break;
            default:
                self?.onError(over: qrViewController, uuid: uuid, tireId: tireId)
                break;
            }
        }
    }
    
    private func onError(over qrViewController: QRCodeReaderViewController, uuid: String, tireId: String) {
        let alertTitle = "recorder.alert.title".localized()
        var actions: [UIAlertAction] = []
        actions.append(.init(title: "recorder.alert.btn_failure".localized(), style: .default) { [weak self] _ in
            self?.sendTireIdFeedback(uuid: uuid, tireId: tireId, qrViewController: qrViewController)
        })
        actions.append(.init(title: "recorder.button.title.abort".localized(), style: .default) { [weak self] _ in
            qrViewController.dismiss(animated: false)
            self?.navigationController?.popViewController(animated: true)
        })
        self.presentAlert(
            over: qrViewController,
            title: alertTitle,
            message: "recorder.alert.message_failure".localized(),
            actions: actions)
    }
    
    private func presentAlert(over qrViewController: QRCodeReaderViewController, title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        qrViewController.present(alert, animated: true)
    }
}
