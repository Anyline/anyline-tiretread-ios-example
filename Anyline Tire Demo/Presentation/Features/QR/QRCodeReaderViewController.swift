import UIKit
import AVFoundation

class QRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    enum ScanMode {
        case `default`
        case tireId
    }

    private var scanMode: ScanMode = .default

    private var captureSession: AVCaptureSession!
    
    private var previewLayer: AVCaptureVideoPreviewLayer!

    private var completionBlock: ((QRCodeReaderViewController, String?) -> Void)?

    private var cancelButton: UIButton?

    private var instructionView: UIView?

    private var guideText: String?

    private var scannedString: String? {
        didSet {
            if let scannedString = scannedString {
                completionBlock?(self, scannedString)
            }
        }
    }

    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showReader(over presenter: UIViewController,
                          scanMode: ScanMode = .default,
                          msg: String? = nil,
                          animated: Bool = true,
                          completion: ((QRCodeReaderViewController, String?) -> Void)? = nil) {
        let qrViewController = QRCodeReaderViewController()
        qrViewController.completionBlock = completion
        qrViewController.guideText = msg ?? "qrcodereader.guide_text.tire_id".localized()
        qrViewController.scanMode = scanMode
        qrViewController.modalPresentationStyle = .automatic
        presenter.present(qrViewController, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func restart() {
        scannedString = nil
        self.instructionView?.isHidden = false
        self.cancelButton?.isHidden = false
        self.previewLayer.isHidden = false
    }

    private func addAccessoryViews() {
        let cancelBtn = UIButton(type: .custom,
                                 primaryAction: .init(title: "Cancel") { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: false)
            self.completionBlock?(self, nil)
        })
        view.addSubview(cancelBtn)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        cancelBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        cancelBtn.titleLabel?.font = FontStruct.proximaNovaBold20
        cancelButton = cancelBtn

        let label = UILabel()
        label.textColor = ColorStruct.snowWhite
        label.font = UIFont(name: "ProximaNova-Bold", size: 16)
        label.text = guideText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        let holder = UIView()
        holder.backgroundColor = ColorStruct.anylineBlue
        holder.layer.cornerRadius = 15
        holder.layer.masksToBounds = true
        holder.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(label)
        view.addSubview(holder)

        self.instructionView = holder

        label.leadingAnchor.constraint(equalTo: holder.leadingAnchor, constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: holder.topAnchor, constant: 20.0).isActive = true
        label.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: holder.centerYAnchor).isActive = true

        holder.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -170.0).isActive = true
        holder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        holder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40.0).isActive = true
        holder.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true

        // fade them in
        cancelBtn.alpha = 0
        holder.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
            cancelBtn.alpha = 1
            holder.alpha = 1
        }, completion: nil)
    }

    func setup() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
        } catch {
            print("Exception while setting up video input: \(error.localizedDescription)")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        DispatchQueue.main.async { [weak self] in
            guard let previewLayer = self?.previewLayer, let view = self?.view else { return }
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
            previewLayer.videoGravity = .resizeAspectFill

            // Set the preview layer orientation based on the window scene orientation
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let orientation = windowScene?.windows.first?.windowScene?.interfaceOrientation
            var rotationAngle = CGFloat(0)
            var videoOrientation: AVCaptureVideoOrientation = .landscapeRight
            switch orientation {
            case .landscapeLeft:
                rotationAngle = 180
                videoOrientation = .landscapeLeft
            default:
                break
            }
            if #available(iOS 17.0, *) {
                previewLayer.connection?.videoRotationAngle = rotationAngle
            } else {
                previewLayer.connection?.videoOrientation = videoOrientation
            }
            self?.addAccessoryViews()
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, 
                        didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard scannedString == nil else { return }
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadataObject.stringValue {
            if scanMode == .tireId {
                // only if we can extract tire_id from a URL string
                if let tireId = tireIdFromScannedQRCode(code) {
                    self.scannedString = tireId
                    self.hideUIElements()
                }
            } else {
                self.scannedString = code
                self.hideUIElements()
            }
        }
    }

    private func tireIdFromScannedQRCode(_ urlString: String) -> String? {
        let queryItems = URLComponents(string: urlString)?.queryItems
        let tireIdParam = queryItems?.filter { $0.name == "tire_id" }.first
        return tireIdParam?.value
    }

    fileprivate func hideUIElements() {
        self.instructionView?.isHidden = true
        self.cancelButton?.isHidden = true
        self.previewLayer.isHidden = true
    }
}
