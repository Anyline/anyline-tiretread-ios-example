import UIKit
import AnylineTireTreadSdk

class CaptureSpeedView: UIView {

    var delegate: CaptureSpeedViewDelegate?

    var scanSpeed: ScanSpeed = UserDefaultsManager.shared.scanSpeed {
        didSet {
            let attrStr = attributedString(scanSpeed: scanSpeed)
            buttonText.setAttributedTitle(attrStr, for: .normal)
        }
    }

    private func attributedString(scanSpeed: ScanSpeed) -> NSAttributedString {
        let presetValue = scanSpeed.name
        let fullText = "\(presetValue) (Tap to change)"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: presetValue)
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: FontStruct.proximaNovaBold16!
        ]
        attributedString.addAttributes(boldAttributes, range: range)
        return attributedString
    }

    private lazy var headerLabel: ATDTextLabel = {
        let label = ATDTextLabel(text: "settings.label.capture_speed".localized())
        return label
    }()

    private lazy var buttonText: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(ColorStruct.anylineBlue, for: .normal)
        button.titleLabel?.font = FontStruct.proximaNovaRegular14
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        return button
    }()

    @objc func didPressButton(btn: UIButton) {
        delegate?.buttonTapped(sender: btn)
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorStruct.snowWhite
        configureView()
        addSubviews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

private extension CaptureSpeedView {

    // MARK: - Setup UI
    func configureView() {
        let attrStr = attributedString(scanSpeed: scanSpeed)
        buttonText.setAttributedTitle(attrStr, for: .normal)
    }

    func addSubviews() {
        self.addSubview(headerLabel)
        self.addSubview(buttonText)
    }

    func setupLayout() {
        headerLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }

        buttonText.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(headerLabel.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
