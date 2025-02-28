import UIKit
import AnylineTireTreadSdk

class ScanResultViewController: UIViewController {
    
    @objc func dismissButtonTapped(button: UIButton) {
        dismiss(animated: true)
    }

    @objc func retryButtonTapped(button: UIButton) {
        fetchResults(uuid: uuid)
    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var heatmapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var globalDepthLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "–\nmm"
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
        return label
    }()
    
    lazy var resultTextLabel: UILabel = {
        let jsonTextView = UILabel()
        jsonTextView.numberOfLines = 0
        jsonTextView.translatesAutoresizingMaskIntoConstraints = false
        jsonTextView.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
        jsonTextView.layer.cornerRadius = 5
        jsonTextView.layer.masksToBounds = true
        return jsonTextView
    }()
    
    lazy var jsonResultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "result.label.json_result".localized
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var heatmapLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "result.label.heatmap".localized
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("result.button.title.dismiss".localized, for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        return button
    }()

    lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("result.button.title.retry".localized, for: .normal)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitleColor(.clear, for: .disabled)
        button.isEnabled = false
        return button
    }()

    var heatmapHeightConstraint: NSLayoutConstraint!
    
    var uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchResults(uuid: uuid)
    }
    
    fileprivate func setupUI() {
        title = "result.title".localized

        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubview(dismissButton)
        scrollView.addSubview(globalDepthLabel)
        scrollView.addSubview(minimumDepthLabel)
        
        let stackView = UIStackView(arrangedSubviews: [
            localDepth1Label, localDepth2Label, localDepth3Label
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        scrollView.addSubview(heatmapImageView)
        scrollView.addSubview(resultTextLabel)

        scrollView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        heatmapHeightConstraint = heatmapImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            
            heatmapHeightConstraint,
            
            dismissButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            dismissButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            dismissButton.heightAnchor.constraint(equalToConstant: 36),
            dismissButton.widthAnchor.constraint(equalToConstant: 200),
            
            globalDepthLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 20),
            globalDepthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            minimumDepthLabel.topAnchor.constraint(equalTo: globalDepthLabel.bottomAnchor, constant: 20),
            minimumDepthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: minimumDepthLabel.bottomAnchor, constant: 10),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            heatmapImageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            heatmapImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            heatmapImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            resultTextLabel.topAnchor.constraint(equalTo: heatmapImageView.bottomAnchor, constant: 10),
            resultTextLabel.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor, constant: 10),
            
            resultTextLabel.leadingAnchor.constraint(equalTo: heatmapImageView.leadingAnchor),
            resultTextLabel.trailingAnchor.constraint(equalTo:heatmapImageView.trailingAnchor),
            resultTextLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: resultTextLabel.bottomAnchor, constant: 20),
            retryButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            retryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    fileprivate func processResult(_ treadDepthResult: TreadDepthResult) {
        let globalThreadResult = treadDepthResult.global
        let localThreadResult = treadDepthResult.regions
        globalDepthLabel.text = String(format: "%.2f\nmm", globalThreadResult.valueMm)
        if let minimumValue = treadDepthResult.minimumValueMm?.doubleValue {
            minimumDepthLabel.text = String(format: "%.2f\nmm", minimumValue)
        }
        localDepth1Label.text = String(format: "%.2f\nmm", localThreadResult[0].valueMm)
        localDepth2Label.text = String(format: "%.2f\nmm", localThreadResult[1].valueMm)
        localDepth3Label.text = String(format: "%.2f\nmm", localThreadResult[2].valueMm)
        writeResult(treadDepthResult.toJson(), isJSON: true)
    }

    fileprivate func fetchHeatmapImage() async {
        let heatmap = await SDKUtilities.fetchHeatMap(uuid: uuid)
        switch heatmap {
        case .success(let heatmap):
            loadImage(url: heatmap.url)
        case .failure(let error):
            var errorMessage = ""
            switch error {
            case let .responseError(message): errorMessage = message
            case let .responseException(message): errorMessage = message
            }
            writeResult("heat map image fetch failed: \(errorMessage)", isError: true)
        }
    }
    
    fileprivate func fetchTreadDepthResult() async -> Bool {
        let result = await SDKUtilities.fetchTreadDepthResult(uuid: uuid)
        if case let .success(value) = result {
            processResult(value)
            return true
        } else if case let .failure(error) = result {
            var errorMessage = ""
            switch error {
            case let .responseError(message): errorMessage = message
            case let .responseException(message): errorMessage = message
            }
            writeResult("tread depth result fetch failed: \(errorMessage)", isError: true)
        }
        return false
    }
    
    fileprivate func fetchResults(uuid: String) {
        Task {
            if await fetchTreadDepthResult() {
                Task {
                    await fetchHeatmapImage()
                }
            }
        }

        print("fetch tire tread depth result and heat map image for uuid: \(uuid)")

        heatmapImageView.image = nil
        heatmapHeightConstraint.constant = 0

        retryButton.isEnabled = false
        resultTextLabel.attributedText = NSAttributedString(string: "Fetching results for UUID:\n\n\(uuid)\n\n...",
                                                         attributes: [
                                                            .foregroundColor: UIColor.label,
                                                            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
                                                        ])
    }

    fileprivate func loadImage(url: String) {
        guard let url = URL(string: url) else {
            writeResult("Invalid image URL", isError: true)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.heatmapImageView.image = image
                        UIView.animate(withDuration: 0.15) {
                            self.heatmapHeightConstraint.constant = 280
                            self.view.layoutIfNeeded()
                        }
                    }
                } else {
                    self.writeResult("Failed to load image", isError: true)
                }
            } catch {
                self.writeResult("Error loading image for \(url): \(error.localizedDescription)", isError: true)
            }
        }
    }
    
    func writeResult(_ text: String, isJSON: Bool = false, isError: Bool = false) {

        var mutAttrStr: NSMutableAttributedString!
        var attrTxt: NSAttributedString!
        if isError {
            attrTxt = NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
            ])
        } else {
            attrTxt = isJSON ? prettifiedJSONAttributedString(text) : NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.label,
                .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
            ])
        }

        DispatchQueue.main.async {
            if let contents = self.resultTextLabel.attributedText, !contents.string.isEmpty {
                mutAttrStr = NSMutableAttributedString(attributedString: contents)
                mutAttrStr.append(.init(string: "\n\n"))
                mutAttrStr.append(attrTxt)
            } else {
                mutAttrStr = NSMutableAttributedString(attributedString: attrTxt)
            }
            self.resultTextLabel.attributedText = mutAttrStr

            if isJSON || isError {
                self.retryButton.isEnabled = true
            }
        }
    }
    
    func prettifiedJSONAttributedString(_ jsonString: String) -> NSAttributedString {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
        ]
        let errorAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .light)
        ]
        guard let data = jsonString.data(using: .utf8) else {
            return NSAttributedString(string: "Error: Could not convert string to Data", attributes: errorAttributes)
        }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                let attributedString = NSMutableAttributedString(string: prettyString)
                attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: prettyString.utf16.count))
                return attributedString
            } else {
                return NSAttributedString(string: "Error: Could not convert pretty Data to String", attributes: errorAttributes)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return NSAttributedString(string: "Error: \(error.localizedDescription)", attributes: errorAttributes)
        }
    }
}
