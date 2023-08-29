import UIKit
import AnylineTireTreadSdk

class FeedbackViewController: UIViewController {
    
    // MARK: - UI Properties
    private var topView: ATDTopView = {
        let view = ATDTopView()
        return view
    }()
    
    private var feedbackView: FeedbackView = {
        let view = FeedbackView()
        return view
    }()
    
    // MARK: - Private Properties
    private var uuid: String
    private lazy var feedbackViewModel: FeedbackViewModel = {
        return FeedbackViewModel(delegate: self)
    }()
    
    // MARK: - Public Properties
    
    // MARK: - Init
    init(uuid: String) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addSubviews()
        setupLayout()
        feedbackView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

// MARK: - Private Functions
private extension FeedbackViewController {
    
    func configureView() {
        self.view.backgroundColor = ColorStruct.snowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        feedbackView.measurementUUIDLabel.text = "Scan ID: \(self.uuid)"

        let label = feedbackView.measurementUUIDLabel

        // add tap-to-copy-to-clipboard
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
    }

    @objc func labelTapped() {
        if feedbackView.measurementUUIDLabel.text != nil {
            // Copy the label's text to the clipboard
            let uuid = self.uuid
            UIPasteboard.general.string = uuid
            feedbackView.measurementUUIDLabel.text = "\(uuid) Copied!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.feedbackView.measurementUUIDLabel.text = "Scan ID: \(uuid)"
            }
        }
    }
    
    func addSubviews() {
        self.view.addSubview(topView)
        self.view.addSubview(feedbackView)
    }
    
    func setupLayout() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalToSuperview()
            make.top.leading.trailing.equalToSuperview()
        }
        
        feedbackView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let keyboardHeight = keyboardFrame.size.height - 50
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - FeedbackButtonActionsDelegate
extension FeedbackViewController: FeedbackButtonActionsDelegate {
    func submitButtonTapped() {
        let tireDepthTreads = feedbackView.tireDepthsView
        if
            let leftValue = tireDepthTreads.tireTreadDepth1.tireTreadDepth.text, !leftValue.isEmpty,
            let middleValue = tireDepthTreads.tireTreadDepth2.tireTreadDepth.text, !middleValue.isEmpty,
            let rightValue = tireDepthTreads.tireTreadDepth3.tireTreadDepth.text, !rightValue.isEmpty,
            let feedbackComment = feedbackView.feedbackTextField.text, !feedbackComment.isEmpty
        {
            if
                let safeLeftValue = Double(leftValue),
                let safeMiddleValue = Double(middleValue),
                let safeRightValue = Double(rightValue)
            {
                let leftTreadResultRegion = TreadResultRegion.companion.doInitMm(isAvailable: true, confidence: 100, value: safeLeftValue)
                let middleTreadResultRegion = TreadResultRegion.companion.doInitMm(isAvailable: true, confidence: 100, value: safeMiddleValue)
                let rightTreadResultRegion = TreadResultRegion.companion.doInitMm(isAvailable: true, confidence: 100, value: safeRightValue)

                let treadResultRegions = [leftTreadResultRegion, middleTreadResultRegion, rightTreadResultRegion]

                feedbackViewModel.postFeedbackData(resultUuid: self.uuid, treadResultRegions: treadResultRegions, comment: feedbackComment)
            } else {
                self.displayAlert(title: "error.title".localized(), message: "error.feedback.number.values.description".localized())
            }
        } else {
            self.displayAlert(title: "error.title".localized(), message: "error.feedback.values.description".localized())
        }
    }
    
    func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - FeedbackViewModelDelegate
extension FeedbackViewController: FeedbackViewModelDelegate {
    func didSendData() {
        navigationController?.popViewController(animated: true)
    }
    
    func showError(error: Int) {
        self.displayErrorAlert(for: error)
    }
}
