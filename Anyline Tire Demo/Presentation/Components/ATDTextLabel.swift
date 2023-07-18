import UIKit

final class ATDTextLabel: UILabel {
    
    // MARK: - Private properties
    
    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        setup(text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Private func
private extension ATDTextLabel {
    func setup(text: String) {
        self.textColor = ColorStruct.stoneGrey
        self.text = text
        font = FontStruct.proximaNovaBold16
    }
}
