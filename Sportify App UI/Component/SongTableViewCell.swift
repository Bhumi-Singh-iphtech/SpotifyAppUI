    import UIKit

    class SongTableViewCell: UITableViewCell {
        @IBOutlet weak var songImageView: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var artistLabel: UILabel!
        @IBOutlet weak var moreImageView: UIImageView!
        
        var moreTapAction: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            songImageView.contentMode = .scaleAspectFill
            songImageView.clipsToBounds = true
            songImageView.layer.cornerRadius = 6
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moreTapped))
            moreImageView.isUserInteractionEnabled = true
            moreImageView.addGestureRecognizer(tapGesture)
        }
        
        @objc private func moreTapped() {
            moreTapAction?()
        }
        
        func configure(with song: Song, action: @escaping () -> Void) {
            songImageView.image = UIImage(named: song.imageName)
            titleLabel.text = song.title
            artistLabel.text = song.artist
            moreTapAction = action
            songImageView.load(urlString: song.imageName)
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            songImageView.image = nil
            titleLabel.text = nil
            artistLabel.text = nil
            moreTapAction = nil
        }
    }
   
  




