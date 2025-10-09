import UIKit

protocol MiniPlayerViewDelegate: AnyObject {
    func miniPlayerDidTapPlayPause()
    func miniPlayerDidTapClose()
    func miniPlayerDidTapExpand()
    func miniPlayerDidTapDevice()
    func miniPlayerDidTapCreate()
}

class MiniPlayerView: UIView {
 
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deviceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "iphone"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    weak var delegate: MiniPlayerViewDelegate?
    private var isPlaying = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGestures()
        setupButtonActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGestures()
        setupButtonActions()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Add container view
        addSubview(containerView)
        
        // Add background view
        containerView.addSubview(backgroundView)
        
        // Add content
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(buttonsStackView)
        
        // Setup buttons stack
        buttonsStackView.addArrangedSubview(deviceButton)
        buttonsStackView.addArrangedSubview(createButton)
        buttonsStackView.addArrangedSubview(playButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Background view
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Image view
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonsStackView.leadingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            // Subtitle label
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonsStackView.leadingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            // Buttons stack
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonsStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Button sizes
            deviceButton.widthAnchor.constraint(equalToConstant: 24),
            deviceButton.heightAnchor.constraint(equalToConstant: 24),
            
            createButton.widthAnchor.constraint(equalToConstant: 24),
            createButton.heightAnchor.constraint(equalToConstant: 24),
            
            playButton.widthAnchor.constraint(equalToConstant: 24),
            playButton.heightAnchor.constraint(equalToConstant: 24)
        ])
     
    }
    
    private func setupGestures() {
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped))
        playButton.addGestureRecognizer(playTap)
        
        // Add tap gesture to expand when tapping on the mini player
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(expandTapped))
        containerView.addGestureRecognizer(expandTap)
    }
    
    private func setupButtonActions() {
        deviceButton.addTarget(self, action: #selector(deviceTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
  
    func configure(with imageUrl: String, title: String, subtitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        // Load image from URL
        imageView.load(urlString: imageUrl) { [weak self] loadedImage in
            guard let self = self, let image = loadedImage else {
                return
            }
            
            
            self.setBackgroundColor(from: image)
        }
    }

    func configure(with image: UIImage?, title: String, subtitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image
        
        // Set background color based on image
        if let image = image {
            setBackgroundColor(from: image)
        }
    }

    private func setBackgroundColor(from image: UIImage) {
   
        if let dominantColor = image.dominantColor() {
            backgroundView.backgroundColor = dominantColor
        } else if let averageColor = image.averageColor() {
            backgroundView.backgroundColor = averageColor
        }
      
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    func setPlaybackState(isPlaying: Bool) {
        self.isPlaying = isPlaying
        updatePlayButtonImage()
    }
    
    private func updatePlayButtonImage() {
        let playImage = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        playButton.setImage(playImage, for: .normal)
        playButton.tintColor = .white
    }
    
    // MARK: - Actions
    @objc private func playPauseTapped() {
        isPlaying.toggle()
        setPlaybackState(isPlaying: isPlaying)
        delegate?.miniPlayerDidTapPlayPause()
    }
    
    @objc private func deviceTapped() {
        delegate?.miniPlayerDidTapDevice()
    }
    
    @objc private func createTapped() {
        delegate?.miniPlayerDidTapCreate()
    }
    
    @objc private func expandTapped() {
        delegate?.miniPlayerDidTapExpand()
    }
}
