import UIKit

final class ATDSideTitleLabel: UILabel {
    
    // MARK: - Private Properties
    private var textPadding = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 20
    )
    
    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        setup(text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions
    override func drawText(in rect: CGRect) {
        let insets = textPadding
        super.drawText(in: rect.inset(by: insets))
    }
}

// MARK: - Private func
private extension ATDSideTitleLabel {
    func setup(text: String) {
        self.textColor = ColorStruct.snowWhite
        self.backgroundColor = ColorStruct.stoneGrey
        self.textAlignment = .right
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        self.font = FontStruct.proximaNovaBold16
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.text = text
        
    }
}
