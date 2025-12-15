import UIKit
import AnylineTireTreadSdk

enum MeasurementUnit: Int {
    case millimeters = 0
    case inches = 1
    case thirtySeconds = 2
}

class UcrViewController: UIViewController {

    // MARK: - Properties

    var measurementUUID: String = "8f2b96bc-8f0a-4a0a-8bbd-92f39270a0e7"
    var selectedUnit: MeasurementUnit = .millimeters
    var regionalResults: [TreadResultRegion] = []
    var regionalTextFields: [UITextField] = []

    // MARK: - UI Components

    var scrollView: UIScrollView!
    var contentView: UIView!
    var uuidTextField: UITextField!
    var loadResultsButton: UIButton!
    var unitSegmentedControl: UISegmentedControl!
    var regionalFieldsStackView: UIStackView!
    var sendResultButton: UIButton!
    var commentTextView: UITextView!
    var sendCommentButton: UIButton!
    var statusLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var loadingOverlay: UIView!
    var isLoading: Bool = false
    var shouldLoadOnAppear: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // Mark that we should load results when view appears
        if !measurementUUID.isEmpty {
            shouldLoadOnAppear = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Load results after view has appeared so loading overlay is visible
        if shouldLoadOnAppear {
            shouldLoadOnAppear = false
            loadResults()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "ucr.title".localized
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

        // Setup scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // UUID Text Field
        uuidTextField = UITextField()
        uuidTextField.placeholder = "ucr.uuid.placeholder".localized
        uuidTextField.text = measurementUUID
        uuidTextField.borderStyle = .roundedRect
        uuidTextField.autocapitalizationType = .none
        uuidTextField.autocorrectionType = .no
        uuidTextField.inputAccessoryView = createDoneToolbar()
        uuidTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(uuidTextField)

        // Load Results Button
        loadResultsButton = UIButton(type: .system)
        loadResultsButton.setTitle("Load Results", for: .normal)
        loadResultsButton.addTarget(self, action: #selector(loadResultsTapped), for: .touchUpInside)
        loadResultsButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(loadResultsButton)
        contentView.addSubview(loadResultsButton)

        // Unit Segmented Control
        unitSegmentedControl = UISegmentedControl(items: [
            "ucr.unit.mm".localized,
            "ucr.unit.inch".localized,
            "ucr.unit.32nds".localized
        ])
        unitSegmentedControl.selectedSegmentIndex = 0
        unitSegmentedControl.addTarget(self, action: #selector(unitChanged), for: .valueChanged)
        unitSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unitSegmentedControl)

        // Regional Fields Stack View
        regionalFieldsStackView = UIStackView()
        regionalFieldsStackView.axis = .horizontal
        regionalFieldsStackView.spacing = 8
        regionalFieldsStackView.distribution = .fillEqually
        regionalFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(regionalFieldsStackView)

        // Send Result Button
        sendResultButton = UIButton(type: .system)
        sendResultButton.setTitle("ucr.send_result.button".localized, for: .normal)
        sendResultButton.addTarget(self, action: #selector(sendResultTapped), for: .touchUpInside)
        sendResultButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(sendResultButton)
        contentView.addSubview(sendResultButton)

        // Comment Text View
        commentTextView = UITextView()
        commentTextView.text = "ucr.comment.placeholder".localized
        commentTextView.textColor = .placeholderText
        commentTextView.font = .systemFont(ofSize: 16)
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        commentTextView.layer.cornerRadius = 8
        commentTextView.delegate = self
        commentTextView.inputAccessoryView = createDoneToolbar()
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentTextView)

        // Send Comment Button
        sendCommentButton = UIButton(type: .system)
        sendCommentButton.setTitle("ucr.send_comment.button".localized, for: .normal)
        sendCommentButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
        sendCommentButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(sendCommentButton)
        contentView.addSubview(sendCommentButton)

        // Status Label
        statusLabel = UILabel()
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)

        // Loading Overlay (on top of main view, not in scroll view)
        loadingOverlay = UIView()
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingOverlay.isHidden = true
        view.addSubview(loadingOverlay)

        // Activity Indicator (inside loading overlay)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        loadingOverlay.addSubview(activityIndicator)

        // Layout Constraints
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

            uuidTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            uuidTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uuidTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uuidTextField.heightAnchor.constraint(equalToConstant: 44),

            loadResultsButton.topAnchor.constraint(equalTo: uuidTextField.bottomAnchor, constant: 12),
            loadResultsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loadResultsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loadResultsButton.heightAnchor.constraint(equalToConstant: 44),

            unitSegmentedControl.topAnchor.constraint(equalTo: loadResultsButton.bottomAnchor, constant: 20),
            unitSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            unitSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            regionalFieldsStackView.topAnchor.constraint(equalTo: unitSegmentedControl.bottomAnchor, constant: 12),
            regionalFieldsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            regionalFieldsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            regionalFieldsStackView.heightAnchor.constraint(equalToConstant: 80),

            sendResultButton.topAnchor.constraint(equalTo: regionalFieldsStackView.bottomAnchor, constant: 12),
            sendResultButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sendResultButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sendResultButton.heightAnchor.constraint(equalToConstant: 44),

            commentTextView.topAnchor.constraint(equalTo: sendResultButton.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 100),

            sendCommentButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 12),
            sendCommentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sendCommentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sendCommentButton.heightAnchor.constraint(equalToConstant: 44),

            statusLabel.topAnchor.constraint(equalTo: sendCommentButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Loading overlay constraints (covers entire view)
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Activity indicator centered in loading overlay
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }

    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
    }

    private func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }

    private func createRegionalTextField(index: Int, value: Double) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.placeholder = String(format: "ucr.region.label".localized, index)
        textField.text = formatValue(value)
        textField.tag = index
        textField.inputAccessoryView = createDoneToolbar()
        textField.delegate = self

        return textField
    }

    private func formatValue(_ value: Double) -> String {
        switch selectedUnit {
        case .millimeters:
            return String(format: "%.2f", value)
        case .inches:
            return String(format: "%.3f", value)
        case .thirtySeconds:
            return "\(Int(value))"
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func loadResultsTapped() {
        measurementUUID = uuidTextField.text ?? measurementUUID
        loadResults()
    }

    @objc private func unitChanged(_ sender: UISegmentedControl) {
        selectedUnit = MeasurementUnit(rawValue: sender.selectedSegmentIndex) ?? .millimeters
        updateRegionalFieldsForCurrentUnit()
    }

    @objc private func sendResultTapped() {
        guard let correctedResults = validateAndCollectValues() else {
            showStatus(message: "ucr.validation.invalid_values".localized, isError: true)
            return
        }

        guard !isLoading else { return }

        showLoading()
        statusLabel.text = ""

        Task { [weak self] in
            guard let self = self else { return }

            let result = await SDKUtilities.sendTreadDepthResultFeedback(
                uuid: self.measurementUUID,
                treadResultRegions: correctedResults
            )

            await MainActor.run {
                self.hideLoading()

                switch result {
                case .success:
                    self.showStatus(message: "ucr.status.success_result".localized, isError: false)
                case .failure(let error):
                    let errorMessage = self.getErrorMessage(from: error)
                    self.showStatus(message: String(format: "ucr.status.error".localized, errorMessage), isError: true)
                }
            }
        }
    }

    @objc private func sendCommentTapped() {
        let comment = commentTextView.text ?? ""
        guard !comment.isEmpty && comment != "ucr.comment.placeholder".localized else {
            showStatus(message: "ucr.validation.empty_comment".localized, isError: true)
            return
        }

        guard !isLoading else { return }

        showLoading()
        statusLabel.text = ""

        Task { [weak self] in
            guard let self = self else { return }

            let result = await SDKUtilities.sendCommentFeedback(
                uuid: self.measurementUUID,
                comment: comment
            )

            await MainActor.run {
                self.hideLoading()

                switch result {
                case .success:
                    self.showStatus(message: "ucr.status.success_comment".localized, isError: false)
                    self.commentTextView.text = "ucr.comment.placeholder".localized
                    self.commentTextView.textColor = .placeholderText
                case .failure(let error):
                    let errorMessage = self.getErrorMessage(from: error)
                    self.showStatus(message: String(format: "ucr.status.error".localized, errorMessage), isError: true)
                }
            }
        }
    }

    // MARK: - Data Methods

    private func loadResults() {
        guard !isLoading else { return }

        showLoading()

        Task { [weak self] in
            guard let self = self else { return }

            let result = await SDKUtilities.fetchTreadDepthResult(uuid: self.measurementUUID)

            await MainActor.run {
                self.hideLoading()

                switch result {
                case .success(let treadDepthResult):
                    self.displayResults(treadDepthResult)
                    self.statusLabel.text = ""
                case .failure(let error):
                    let errorMessage = self.getErrorMessage(from: error)
                    self.showStatus(message: String(format: "ucr.status.error".localized, errorMessage), isError: true)
                }
            }
        }
    }

    private func showLoading() {
        isLoading = true
        uuidTextField.isEnabled = false
        loadResultsButton.isEnabled = false
        sendResultButton.isEnabled = false
        sendCommentButton.isEnabled = false
        view.bringSubviewToFront(loadingOverlay)
        loadingOverlay.alpha = 1.0
        loadingOverlay.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoading() {
        isLoading = false
        uuidTextField.isEnabled = true
        loadResultsButton.isEnabled = true
        sendResultButton.isEnabled = true
        sendCommentButton.isEnabled = true
        activityIndicator.stopAnimating()
        loadingOverlay.isHidden = true
    }

    private func displayResults(_ result: TreadDepthResult) {
        // Clear existing fields
        regionalFieldsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        regionalTextFields.removeAll()
        regionalResults.removeAll()

        // Create regional result objects from the result
        for (index, region) in result.regions.enumerated() {
            // Simply use the existing region from the result
            regionalResults.append(region)

            let textField = createRegionalTextField(index: index, value: region.valueMm)
            regionalTextFields.append(textField)
            regionalFieldsStackView.addArrangedSubview(textField)
        }
    }

    private func updateRegionalFieldsForCurrentUnit() {
        for (index, textField) in regionalTextFields.enumerated() {
            guard index < regionalResults.count else { continue }
            let region = regionalResults[index]

            let value: Double
            switch selectedUnit {
            case .millimeters:
                value = region.valueMm
            case .inches:
                value = region.valueInch
            case .thirtySeconds:
                value = Double(region.valueInch32nds)
            }

            textField.text = formatValue(value)
        }
    }

    private func parseDecimalValue(_ text: String) -> Double? {
        // Normalize decimal separator: replace comma with dot for parsing
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedText)
    }

    private func validateAndCollectValues() -> [TreadResultRegion]? {
        var correctedRegions: [TreadResultRegion] = []

        for (index, textField) in regionalTextFields.enumerated() {
            guard index < regionalResults.count else { continue }

            let originalRegion = regionalResults[index]

            guard let text = textField.text, !text.isEmpty else {
                // If empty, preserve original availability status
                correctedRegions.append(
                    TreadResultRegion.Companion.shared.doInitMm(
                        isAvailable: originalRegion.isAvailable,
                        value: originalRegion.valueMm
                    )
                )
                continue
            }

            guard let value = parseDecimalValue(text), value >= 0 else {
                return nil  // Invalid input
            }

            // Create new region with corrected value based on current unit
            let region: TreadResultRegion
            switch selectedUnit {
            case .millimeters:
                region = TreadResultRegion.Companion.shared.doInitMm(
                    isAvailable: true,
                    value: value
                )
            case .inches:
                region = TreadResultRegion.Companion.shared.doInitInch(
                    isAvailable: true,
                    value: value
                )
            case .thirtySeconds:
                region = TreadResultRegion.Companion.shared.doInitInch32nds(
                    isAvailable: true,
                    value: Int32(value)
                )
            }

            correctedRegions.append(region)
        }

        return correctedRegions
    }

    private func showStatus(message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen
    }

    private func getErrorMessage(from error: TireTreadError) -> String {
        switch error {
        case .responseError(let message):
            return message
        case .responseException(let message):
            return message
        }
    }
}

// MARK: - UITextFieldDelegate

extension UcrViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Convert comma to dot in real-time for decimal input
        if string == "," {
            // Get the current text
            let currentText = textField.text ?? ""
            let nsString = currentText as NSString
            let newText = nsString.replacingCharacters(in: range, with: ".")

            // Update the text field with dot instead of comma
            textField.text = newText

            // Return false to prevent the comma from being inserted
            return false
        }

        return true
    }
}

// MARK: - UITextViewDelegate

extension UcrViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "ucr.comment.placeholder".localized
            textView.textColor = .placeholderText
        }
    }
}
