import UIKit

class SongOptions: UIViewController {
    let options: [(iconName: String, title: String, isPremium: Bool, spotifyText: String?)] = [
            ("share (1)", "Share", false, nil),
            ("liked-songs", "Add to liked Songs", false, nil),
            ("circle", "Add to other playlist", false, nil),
            ("diamond (2)", "Listen to music ad-free", true, "Spotify"),
            ("minus", "Remove from this playlist", false, nil),
            ("dot-inside-a-circle", "Go to album", false, nil),
            ("artist", "Go to artist", false, nil),
            ("user", "Start a Jam", true, "Spotify"),
            ("antenna", "Go to song radio", false, nil),
            ("music-notes", "View song credits", false, nil),
            ("sound (1)", "Show Spotify Code", false, nil)
        ]

    private let song: Song
    private let containerView = UIView()
    private let contentStack = UIStackView()
    private let accessibilityIndicator = UIView()

    private var containerBottomConstraint: NSLayoutConstraint?
    private let minHeight: CGFloat = 300
    private var maxHeight: CGFloat { view.frame.height - 40 }

    private var panGesture: UIPanGestureRecognizer!
    private var initialBottomConstant: CGFloat = 0

    // MARK: - Init
    init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupContainer()
        setupAccessibilityIndicator()
        setupContent()
        setupPanGesture() // This method is now included
        animateUp()
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
       
    }

    // MARK: - Container
    private func setupContainer() {
        containerView.backgroundColor = UIColor(hex: "#292929")
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Start with container partially visible (minHeight)
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: minHeight)
        containerBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: maxHeight)
        ])
    }

    // MARK: - Accessibility Indicator
    private func setupAccessibilityIndicator() {
        accessibilityIndicator.backgroundColor = .lightGray
        accessibilityIndicator.layer.cornerRadius = 2
        containerView.addSubview(accessibilityIndicator)
        accessibilityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            accessibilityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            accessibilityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            accessibilityIndicator.widthAnchor.constraint(equalToConstant: 20),
            accessibilityIndicator.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    // MARK: - Content
    private func setupContent() {
        containerView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])

        // Song Image
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true

        if let url = URL(string: song.imageName) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { imageView.image = UIImage(data: data) }
                }
            }.resume()
        } else {
            imageView.image = UIImage(named: song.imageName)
        }

        // Title & Artist
        let titleLabel = UILabel()
        titleLabel.text = song.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white

        let artistLabel = UILabel()
        artistLabel.text = song.artist
        artistLabel.font = .systemFont(ofSize: 14)
        artistLabel.textColor = .lightGray

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4

        let headerStack = UIStackView(arrangedSubviews: [imageView, labelStack])
        headerStack.axis = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .center

        contentStack.addArrangedSubview(headerStack)

       
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.tintColor = .white
            button.contentHorizontalAlignment = .left
            button.tag = index
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            
            // Create the icon
            let iconImageView = UIImageView()
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.contentMode = .scaleAspectFit
            
    
            if option.title == "Add to liked Songs" {
                if LikedSongsManager.shared.isLiked(song) {
                    iconImageView.image = UIImage(systemName: "heart.fill")
                    iconImageView.tintColor = .systemGreen
                } else {
                    iconImageView.image = UIImage(systemName: "heart")
                    iconImageView.tintColor = .white
                }
            } else {
               
                iconImageView.image = UIImage(named: option.iconName)
            }
            
            button.addSubview(iconImageView)
            
            // Icon constraints
            NSLayoutConstraint.activate([
                iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 5),
                iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            // Title setup
            button.setTitle(option.title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
            
            // Premium badge (if needed)
            if option.isPremium {
                let premiumLabel = UILabel()
                premiumLabel.text = "Premium"
                premiumLabel.font = UIFont.boldSystemFont(ofSize: 12)
                premiumLabel.textColor = .systemGreen
                premiumLabel.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(premiumLabel)
                
                let spotifyImageView = UIImageView(image: UIImage(named: "spotify"))
                spotifyImageView.translatesAutoresizingMaskIntoConstraints = false
                spotifyImageView.contentMode = .scaleAspectFit
                button.addSubview(spotifyImageView)
                
                NSLayoutConstraint.activate([
                    premiumLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
                    premiumLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    
                    spotifyImageView.trailingAnchor.constraint(equalTo: premiumLabel.leadingAnchor, constant: -4),
                    spotifyImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    spotifyImageView.widthAnchor.constraint(equalToConstant: 16),
                    spotifyImageView.heightAnchor.constraint(equalToConstant: 16)
                ])
            }
            
            contentStack.addArrangedSubview(button)
        }
    }
        @objc private func optionTapped(_ sender: UIButton) {
            guard sender.tag < options.count else { return }
            let selectedOption = options[sender.tag]
            
            if selectedOption.title == "Add to liked Songs" {
                toggleLikedSong(for: sender)
            } else {
                dismissSheet()
            }
        }
    private func toggleLikedSong(for sender: UIButton) {
        guard let iconImageView = sender.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        
        if LikedSongsManager.shared.isLiked(song) {
            // Unlike
            LikedSongsManager.shared.removeSong(song)
            iconImageView.image = UIImage(systemName: "heart")
            iconImageView.tintColor = .white
        } else {
            // Like
            LikedSongsManager.shared.addSong(song)
            iconImageView.image = UIImage(systemName: "heart.fill")
            iconImageView.tintColor = .systemGreen
        }
        
        // Notify LikedSongsViewController to update count
        NotificationCenter.default.post(name: .likedSongsUpdated, object: nil)
    }

    // MARK: - Pan Gesture (ADD THIS MISSING METHOD)
    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            // Store the current bottom constraint value when gesture starts
            initialBottomConstant = containerBottomConstraint?.constant ?? minHeight
            
        case .changed:
            // Calculate new bottom constraint based on translation from initial position
            let newBottomConstant = initialBottomConstant + translation.y
            
            // Clamp the value between fully expanded (0) and fully hidden (maxHeight)
            let clampedConstant = max(0, min(maxHeight, newBottomConstant))
            
            // Update the constraint
            containerBottomConstraint?.constant = clampedConstant
            
            // Update background alpha based on position
            let progress = 1 - (clampedConstant / maxHeight)
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5 * progress)
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            let currentConstant = containerBottomConstraint?.constant ?? minHeight
            
            // Determine action based on current position and velocity
            if currentConstant > maxHeight * 0.7 || velocity.y > 800 {
                // Dismiss if pulled down enough or fast swipe down
                dismissSheet()
            } else if currentConstant < maxHeight * 0.3 || velocity.y < -800 {
                // Expand to full screen
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.containerBottomConstraint?.constant = 0
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    self.view.layoutIfNeeded()
                }
            } else {
                // Return to initial minHeight position
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.containerBottomConstraint?.constant = self.minHeight
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }

    private func animateUp() {
        containerBottomConstraint?.constant = minHeight
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.containerBottomConstraint?.constant = self.minHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerBottomConstraint?.constant = self.maxHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    

    

}
extension Notification.Name {
    static let likedSongsUpdated = Notification.Name("likedSongsUpdated")
}
