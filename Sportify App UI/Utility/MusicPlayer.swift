import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    private var player: AVPlayer?
    private var currentUrl: String?

    private init() {}

    var isPlaying: Bool {
        player?.rate != 0
    }

    func play(urlString: String) {
     
        if currentUrl != urlString {
            guard let url = URL(string: urlString) else { return }
            player = AVPlayer(url: url)
            currentUrl = urlString
        }
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.pause()
        player = nil
        currentUrl = nil
    }
}
