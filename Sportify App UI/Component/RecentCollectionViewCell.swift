import UIKit

class RecentCollectionViewCell: UICollectionViewCell {
    
   
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    // MARK: - Configuration
    private func setupAppearance() {
        // Configure image view
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 8
        
        // Configure labels
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
      
    }
    
    func configure(with item: LibraryItem) {
        titleLabel.text = item.title
        subtitleLabel.text = "Playlist" // Fixed subtitle
        
        if let image = UIImage(named: item.imageName) {
            coverImageView.image = image
        } else {
            coverImageView.image = UIImage(systemName: "music.note")
        }
    }
}
