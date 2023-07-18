import UIKit

class ATDTextField: UITextField {
    
    // MARK: - Private properties
    private var textPadding = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
    
    // MARK: - Init
    init(backgroundColor: UIColor) {
        super.init(frame: .zero)
        setup(backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    var placeholderColor: UIColor = .lightGray
    let paragraphStyle = NSMutableParagraphStyle()

    override func drawPlaceholder(in rect: CGRect) {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderColor,
                                                         .font: FontStruct.proximaNovaRegular12!, .paragraphStyle: paragraphStyle]
        placeholder?.draw(in: rect, withAttributes: attributes)
    }
}

// MARK: - Private Func
/// Sets up the text field. For the color, choose either skyGrey or snowWhite
private extension ATDTextField {
    func setup(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.textColor = ColorStruct.stoneGrey
        self.layer.borderWidth = 1
        self.layer.borderColor = ColorStruct.stoneGrey.cgColor
        self.tag = 0
        self.textColor = ColorStruct.stoneGrey
        font = FontStruct.proximaNovaBold16
    }
}
