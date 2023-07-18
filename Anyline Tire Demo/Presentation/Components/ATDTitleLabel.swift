import UIKit

final class ATDTitleLabel: UILabel {
    
    // MARK: - Init
    init(textColor: UIColor, text: String) {
        super.init(frame: .zero)
        setup(textColor: textColor, text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Private func
private extension ATDTitleLabel {
    func setup(textColor: UIColor, text: String) {
        self.textColor = textColor
        self.text = text
        font = FontStruct.proximaNovaBold20
    }
}
