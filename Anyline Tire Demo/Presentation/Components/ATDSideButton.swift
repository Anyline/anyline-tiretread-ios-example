import UIKit

final class ATDSideButton: UIButton {
    
    // MARK: - Private Properties
    private let cornerRadius: CGFloat = 15
    
    // MARK: - Init
    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private func
private extension ATDSideButton {
    func setup(title: String) {
        setTitle(title, for: .normal)
        setTitleColor(ColorStruct.snowWhite, for: .normal)
        backgroundColor = ColorStruct.anylineBlue
        contentHorizontalAlignment = .center
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        titleLabel?.font = FontStruct.proximaNovaBold16
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
