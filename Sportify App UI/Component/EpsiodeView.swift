import UIKit

class EpisodeView: UIView {

    // MARK: - UI Components
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .redraw
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        addSubview(episodeImageView)
        addSubview(playButton)
        addSubview(addButton)

        NSLayoutConstraint.activate([
            // Episode Image
            episodeImageView.topAnchor.constraint(equalTo: topAnchor),
            episodeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            episodeImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            episodeImageView.heightAnchor.constraint(equalToConstant: 200),

            // Play button - bottom right
            playButton.trailingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: -16),
            playButton.bottomAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            // + button - left of play button
            addButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -12),
            addButton.bottomAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
