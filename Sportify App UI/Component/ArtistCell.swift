import UIKit

class ArtistCell: UICollectionViewCell {
    
 
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(artistImageView)
        contentView.addSubview(artistNameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Artist Image
            artistImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artistImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            artistImageView.widthAnchor.constraint(equalToConstant: 120),
            artistImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Artist Name Label
            artistNameLabel.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 8),
            artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            artistNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
   
    func configure(with artist: Artist) {
        artistNameLabel.text = artist.name
        
        if let image = UIImage(named: artist.imageName) {
            artistImageView.image = image
        } else {
            // Fallback image
            artistImageView.image = UIImage(systemName: "person.circle.fill")
            artistImageView.tintColor = .lightGray
        }
        artistImageView.load(urlString: artist.imageName)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artistImageView.image = nil
        artistNameLabel.text = nil
    }
}
