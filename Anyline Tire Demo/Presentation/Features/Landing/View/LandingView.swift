import UIKit
import WebKit

class LandingView: UIView {
    
    // MARK: - UI properties
    lazy var startButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.start".localized())
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.settings".localized())
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.cancel".localized())
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tutorialButton: ATDSideButton = {
        let button = ATDSideButton(title: "landing.button.tutorial".localized())
        button.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: TextLandingView = {
        let view = TextLandingView()
        view.delegate = self
        return view
    }()
    
    // you need the PRO account to embed using video rather than an iframe: https://stackoverflow.com/a/36042672
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        let vimeoVideoID = 774805672
        
        // can't get autoplay or playsinline to work at least on iOS / Safari
        // the docs say that for autoplay to work on Safari, muted should be 1. But that
        // doesn't appear to be the case still
        let vimeoVideoURL = "https://player.vimeo.com/video/\(vimeoVideoID)?background=0&autoplay=1&muted=0&playsinline=1"
        
        let htmlCode = """
    <iframe src="\(vimeoVideoURL)" style="position:absolute;top:0;left:0;width:100%;height:100%;" frameborder="0" allow="autoplay"></iframe>
<script src="https://player.vimeo.com/api/player.js"></script>
"""
        let htmlString = """
<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0 maximum-scale=1.0 user-scalable=no\" charset=\"utf-8\" />
</head><body>\(htmlCode)</body></html>
"""
        
        view.loadHTMLString(htmlString, baseURL: nil)
        view.scrollView.isScrollEnabled = false
        return view
    }()
    
    // MARK: - Private Properties
    
    // MARK: - Public properties
    weak var delegate: LandingButtonActionsDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
        setupLayout()
    }
    
    func setDisplayMode(_ displayMode: LandingViewDisplayMode) {        
        switch displayMode {
        case .default:
            startButton.isHidden = false
            textView.isHidden = false
            webView.isHidden = true
            settingsButton.isHidden = false
            cancelButton.isHidden = true
            tutorialButton.isHidden = false

        case .intro:
            startButton.isHidden = true
            webView.isHidden = false
            textView.isHidden = true
            settingsButton.isHidden = true
            cancelButton.isHidden = false
            tutorialButton.isHidden = true
        }

        let cancelBtnTitle = displayMode == .intro ? "landing.button.back".localized() :
            "landing.button.cancel".localized()

        cancelButton.setTitle(cancelBtnTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Private functions
private extension LandingView {
    
    // MARK: - Setup UI
    func configureView() {
        self.backgroundColor = ColorStruct.snowWhite
    }
    
    func addSubviews() {
        self.addSubview(startButton)
        self.addSubview(cancelButton)
        self.addSubview(settingsButton)
        self.addSubview(tutorialButton)
        self.addSubview(webView)
        self.addSubview(textView)
    }
    
    func setupLayout() {
        
        startButton.snp.makeConstraints({ make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        // slightly below start (but above settings by at least as much)
        tutorialButton.snp.makeConstraints({ make in
            make.top.equalTo(startButton.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(settingsButton.snp.top).offset(-10)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        settingsButton.snp.makeConstraints({ make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        // occupies same space as settings
        cancelButton.snp.makeConstraints({ make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(0)
            make.width.equalTo(150)
            make.height.equalTo(80)
        })
        
        webView.snp.makeConstraints { make in
            // make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            // make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.top.bottom.equalTo(self.safeAreaLayoutGuide).offset(25)
            make.leading.equalTo(40)
            make.trailing.equalTo(startButton.snp.leading).offset(-40)
        }
        
        textView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.equalTo(40)
            make.trailing.equalTo(startButton.snp.leading).offset(-40)
        }
    }
    
    // MARK: - Actions
    @objc
    func startButtonTapped() {
        delegate?.startButtonTapped()
    }
    
    @objc
    func settingsButtonTapped() {
        delegate?.settingsButtonTapped()
    }
    
    @objc
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
    
    @objc
    func tutorialButtonTapped() {
        delegate?.tutorialButtonTapped()
    }
}

extension LandingView: LandingTextViewDelegate {
    func startTapped() {
        delegate?.startButtonTapped()
    }
    
    func tutorialTapped() {
        delegate?.tutorialButtonTapped()
    }
}
