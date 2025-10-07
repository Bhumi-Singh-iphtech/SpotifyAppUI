import UIKit

class StationCell: UICollectionViewCell {
    @IBOutlet weak var backgroundCardView: UIView!       // colored background
    @IBOutlet weak var spotifyImageView: UIImageView!    // top left icon
    @IBOutlet weak var radioLabel: UILabel!              // top right label
    @IBOutlet weak var singerImageView: UIImageView!     // center image
    @IBOutlet weak var nameLabel: UILabel!               // inside colored card (middle below image)
    @IBOutlet weak var subtitleLabel: UILabel!           // outside card
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
        backgroundCardView.layer.cornerRadius = 10
        backgroundCardView.clipsToBounds = true
        
        radioLabel.text = "RADIO"
        radioLabel.font = .boldSystemFont(ofSize: 12)
        radioLabel.textColor = .black
        
        singerImageView.contentMode = .scaleAspectFill
       
        singerImageView.clipsToBounds = true
        
        nameLabel.textColor = .black
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2
    }
    
    
    func configure(with station: Station) {
        nameLabel.text = station.name
        subtitleLabel.text = station.subtitle
        singerImageView.image = UIImage(named: station.imageName)
        backgroundCardView.backgroundColor = UIColor(hex: station.hexColor)
        spotifyImageView.image = UIImage(named: "Spotify_icon") // your asset
    }
}
