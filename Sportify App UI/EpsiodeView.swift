import UIKit

class EpisodeCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(episodeImageView)
        episodeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            episodeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            episodeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            episodeImageView.heightAnchor.constraint(equalToConstant: 200) // adjust height
        ])
        
        // Add buttons ON TOP of image
        episodeImageView.addSubview(playButton)
        episodeImageView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            // Play button bottom-right
            playButton.trailingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: -8),
            playButton.bottomAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: -8),
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Plus button left of play button
            plusButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -8),
            plusButton.bottomAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: -8),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
