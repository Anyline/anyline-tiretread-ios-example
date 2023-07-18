import AVFoundation

class VolumeButtonObserver {
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var observer: NSKeyValueObservation?
    private var previousVolume: Float
    
    var onVolumeButtonPressed: (() -> Void)?
    
    init() {
        do {
            try audioSession.setActive(true)
            previousVolume = audioSession.outputVolume
            observer = audioSession.observe(\.outputVolume) { [weak self] _, _ in
                self?.handleVolumeButtonPressed()
            }
        } catch {
            print("Error configuring audio session: \(error)")
            previousVolume = 0.0
        }
    }
    
    private func handleVolumeButtonPressed() {
        let currentVolume = audioSession.outputVolume
        if currentVolume < previousVolume {
            onVolumeButtonPressed?()
        }
        previousVolume = currentVolume
    }
    
    deinit {
        observer?.invalidate()
        try? audioSession.setActive(false)
    }
}
