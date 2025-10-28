import UIKit

class LikedSongViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Liked Songs"
        view.backgroundColor = .black
        
        updateLikedSongsCount()
        
       
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLikedSongsCount),
            name: .likedSongsUpdated,
            object: nil
        )
    }
    
    @objc private func updateLikedSongsCount() {
        let count = LikedSongsManager.shared.likedSongs.count
        countLabel.text = "Liked Songs Count : \(count)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
