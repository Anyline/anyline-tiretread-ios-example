import Foundation

protocol ScanViewModelDelegate: AnyObject {
    func displayError(uuid: String)
}

class ScanViewModel {
    
    // MARK: - Private properties
    private weak var scanViewModelDelegate: ScanViewModelDelegate?
    
    // MARK: - Public properties
    var didTimeElapse = false
    var uploadStep: Int = 0
        
    // MARK: - Init
    init(delegate: ScanViewModelDelegate) {
        self.scanViewModelDelegate = delegate
    }
    
    // MARK: - Actions
}
