import UIKit

class AlbumDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Searchbar: UIVisualEffectView!
    @IBOutlet weak var sortBar: UIVisualEffectView!
    @IBOutlet weak var albumHeaderContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var SearchHeight: NSLayoutConstraint!
    
    @IBOutlet weak var SortHeight: NSLayoutConstraint!
    var albumTitle: String?
    var albumImageName: String?
    var totalDuration: String?
    var songs: [Song] = []
    var selectedStation: Station?
    var albumSubtitle: String?
    var isStation: Bool = false
    private var currentSongPreviewUrl: String?
    private var isPlaying = false
    private var lyricsPopupView: LyricsPopupView?

    private let maxImageSize: CGFloat = 180
    private let minImageSize: CGFloat = 130
    private var initialHeaderY: CGFloat = 0
    
    // MARK: - Header Back Button (positioned on side of screen)
    private let headerBackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.alpha = 1
        return button
    }()

    // MARK: - Gradient Background
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        layer.locations = [0.0, 0.8]
        return layer
    }()

    private lazy var miniPlayer = MiniPlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially collapse
        SearchHeight.constant = 0
        SortHeight.constant = 0
        Searchbar.alpha = 0
        sortBar.alpha = 0
        
        view.backgroundColor = .clear
        setupGradientBackground()
        forceTransparentBackgrounds()
        
        albumTitleLabel.text = albumTitle
        setupNavigationBar()
        setupAlbumHeader()
        setupTableView()
        setupMiniPlayer()
        
        // Add back button to main view (not album header)
        setupHeaderBackButton()
        
        view.bringSubviewToFront(playButton)
        
        scrollView.delegate = self
        tableView.delegate = self

        self.navigationItem.title = nil
        
        if let totalDuration = totalDuration {
            durationLabel.text = "\(totalDuration)"
        }
        
        if let albumTitle = albumTitle {
            APIManager.shared.fetchSongs(for: albumTitle) { [weak self] songs in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.songs = songs
                    self.tableView.reloadData()
                    self.updateContentSize()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.updateContentSize()
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else { return }

        // Hide nav bar initially
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Make nav bar transparent
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.tintColor = .clear
        navBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialHeaderY == 0 {
            let centerX = view.frame.width / 2
            initialHeaderY = 0
            albumHeaderContainer.frame = CGRect(
                x: centerX - maxImageSize/2,
                y: 0,
                width: maxImageSize,
                height: maxImageSize
            )
            
            let initialTableY = albumHeaderContainer.frame.maxY + 20
            tableView.frame = CGRect(
                x: 0,
                y: initialTableY,
                width: view.frame.width,
                height: 0
            )
            
            scrollView.contentSize = CGSize(
                width: view.frame.width,
                height: scrollView.frame.height + 1
            )
        }
        
        gradientLayer.frame = view.bounds
        positionMiniPlayer()
        
        // Position back button in top-left corner of screen
        updateHeaderBackButtonPosition()
    }

    // MARK: - Back Button Setup (positioned on side)
    private func setupHeaderBackButton() {
        view.addSubview(headerBackButton)
        headerBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Position in top-left corner with safe area consideration
        let safeAreaTop = view.safeAreaInsets.top
        let buttonY = max(16, safeAreaTop) // At least 16 points from top, or safe area
        headerBackButton.frame = CGRect(x: 16, y: buttonY, width: 40, height: 40)
        headerBackButton.alpha = 1
        
        // Ensure it's above other views
        view.bringSubviewToFront(headerBackButton)
    }
    
    private func updateHeaderBackButtonPosition() {
        let safeAreaTop = view.safeAreaInsets.top
        let buttonY = max(16, safeAreaTop)
        headerBackButton.frame = CGRect(x: 16, y: buttonY, width: 40, height: 40)
        
        // Always keep it on top
        view.bringSubviewToFront(headerBackButton)
    }

    // MARK: - Gradient Background Setup
    private func setupGradientBackground() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.locations = [0.0, 0.7]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        if let albumImageName = albumImageName,
           let image = UIImage(named: albumImageName),
           let dominantColor = image.dominantColor() {
            // Use dominant color from album image
            gradientLayer.colors = [
                dominantColor.withAlphaComponent(1.0).cgColor,
                UIColor.black.cgColor
            ]
            self.updateNavigationBarColor(with: dominantColor)
        } else {
            // Fallback to neutral dark gradient
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.0).cgColor,
                UIColor.black.cgColor
            ]
            self.updateNavigationBarColor(with: UIColor.black)
        }

        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = view.bounds
    }

    
    private func forceTransparentBackgrounds() {
        scrollView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        albumHeaderContainer.backgroundColor = .clear
        Searchbar.alpha = 0.7
        sortBar.alpha = 0.7
        
        for subview in scrollView.subviews {
            if subview != tableView && subview != albumHeaderContainer {
                subview.backgroundColor = .clear
            }
        }
    }

    // MARK: - Fix: Update navigation bar color
    private func updateNavigationBarColor(with color: UIColor) {
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.backgroundColor = color
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }

    // MARK: - Lyrics Popup
    private func showLyricsPopup(for song: Song) {
        headerBackButton.isHidden = true
        // Create popup if it doesn't exist
        if lyricsPopupView == nil {
            lyricsPopupView = LyricsPopupView()
            lyricsPopupView?.dismissHandler = { [weak self] in
                self?.lyricsPopupView = nil
            }
        }
        
        // Show the popup; it will handle its own background color
        lyricsPopupView?.show(in: self.view, with: song, from: self)
    }

    
    // MARK: - Mini Player Setup
    private func setupMiniPlayer() {
        miniPlayer.delegate = self
        miniPlayer.alpha = 0
        miniPlayer.transform = CGAffineTransform(translationX: 0, y: 100)
        view.addSubview(miniPlayer)
        positionMiniPlayer()
    }
    
    private func positionMiniPlayer() {
        let safeArea = view.safeAreaInsets
        let playerHeight: CGFloat = 64
        let bottomInset: CGFloat = safeArea.bottom > 0 ? safeArea.bottom : 16
        
        miniPlayer.frame = CGRect(
            x: 8,
            y: view.bounds.height - playerHeight - bottomInset,
            width: view.bounds.width - 16,
            height: playerHeight
        )
    }

    private func setupAlbumHeader() {
        albumHeaderContainer.backgroundColor = .clear

        if let station = selectedStation,
           let cell = Bundle.main.loadNibNamed("StationCell", owner: nil, options: nil)?.first as? StationCell {

            // Set up cell
            cell.frame = albumHeaderContainer.bounds
            cell.configure(with: station)
            cell.backgroundColor = .clear
            cell.subtitleLabel.isHidden = true
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            albumHeaderContainer.addSubview(cell)

            // Delay gradient update until image is ready
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let image = cell.singerImageView.image,
                      let dominantColor = image.dominantColor() else { return }

                // Update gradient
                self.gradientLayer.colors = [
                    dominantColor.withAlphaComponent(1.0).cgColor,
                    UIColor.black.cgColor
                ]

                // Update nav bar color
                self.updateNavigationBarColor(with: dominantColor)
            }

        } else if let albumImageName = albumImageName {
            let imageView = UIImageView(frame: albumHeaderContainer.bounds)
            imageView.image = UIImage(named: albumImageName)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            albumHeaderContainer.addSubview(imageView)

            // Delay gradient update for album image
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let image = imageView.image,
                      let dominantColor = image.dominantColor() else { return }

                self.gradientLayer.colors = [
                    dominantColor.withAlphaComponent(1.0).cgColor,
                    UIColor.black.cgColor
                ]
                self.updateNavigationBarColor(with: dominantColor)
            }
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        navigationItem.title = albumTitle
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = 70
    }
    
    private func updateContentSize() {
        guard !songs.isEmpty else {
            scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.frame.height + 1)
            return
        }
        let rowHeight: CGFloat = 70
        let tableHeight = CGFloat(songs.count) * rowHeight
        let tableY = albumHeaderContainer.frame.maxY + 20
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.width, height: tableHeight)
        
        let headerHeight = albumHeaderContainer.frame.height
        let totalContentHeight = initialHeaderY + headerHeight + tableHeight + 120
        scrollView.contentSize = CGSize(width: view.frame.width, height: max(totalContentHeight, scrollView.frame.height + 1))
        
        self.view.layoutIfNeeded()
    }
}

// MARK: - MiniPlayerViewDelegate
extension AlbumDetailViewController: MiniPlayerViewDelegate {
    func miniPlayerDidTapPlayPause() {
        guard let urlString = currentSongPreviewUrl, !urlString.isEmpty else { return }
        if isPlaying {
            MusicPlayer.shared.pause()
            miniPlayer.setPlaybackState(isPlaying: false)
            isPlaying = false
        } else {
            MusicPlayer.shared.play(urlString: urlString)
            miniPlayer.setPlaybackState(isPlaying: true)
            isPlaying = true
        }
    }
    func miniPlayerDidTapClose() {
        miniPlayer.hide()
        MusicPlayer.shared.pause()
    }
    func miniPlayerDidTapExpand() {}
    func miniPlayerDidTapDevice() {}
    func miniPlayerDidTapCreate() {}
}

// MARK: - TableView
extension AlbumDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { songs.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongTableViewCell else {
            return UITableViewCell()
        }
        let song = songs[indexPath.row]
        cell.configure(with: song) { [weak self] in
            self?.SongOptionsBottomSheet(for: song)
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    private func SongOptionsBottomSheet(for song: Song) {
        let bottomSheet = SongOptions(song: song)
        present(bottomSheet, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        showLyricsPopup(for: song)
        currentSongPreviewUrl = song.previewUrl
        
        miniPlayer.configure(with: song.imageName, title: song.title, subtitle: song.artist)
        miniPlayer.setPlaybackState(isPlaying: true)
        miniPlayer.show()
        
        MusicPlayer.shared.play(urlString: song.previewUrl)
        tableView.deselectRow(at: indexPath, animated: true)
        isPlaying = true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }
}

// MARK: - ScrollView Delegate
extension AlbumDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }

        let scrollOffset = scrollView.contentOffset.y
        let newSize: CGFloat = scrollOffset > 0 ? max(maxImageSize - scrollOffset, minImageSize) : maxImageSize
        let centerX = view.frame.width / 2

        albumHeaderContainer.frame = CGRect(x: centerX - newSize/2, y: initialHeaderY, width: newSize, height: newSize)

        if let stationCell = albumHeaderContainer.subviews.first(where: { $0 is StationCell }) as? StationCell {
            stationCell.frame = albumHeaderContainer.bounds
            let scale = newSize / maxImageSize
            stationCell.transform = CGAffineTransform(scaleX: scale, y: scale)
            stationCell.layer.cornerRadius = 12 * scale
        } else if let imageView = albumHeaderContainer.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.frame = albumHeaderContainer.bounds
            imageView.layer.cornerRadius = 12 * (newSize / maxImageSize)
        }

        // Update header back button position (always stay in top-left corner)
        updateHeaderBackButtonPosition()

        if scrollOffset < -80 {
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationItem.title = nil
                self.headerBackButton.alpha = 0 // Hide custom back button when nav bar is visible
                self.navigationController?.navigationBar.backgroundColor = nil // Clear for search
            }
            UIView.animate(withDuration: 0.2) {
                self.Searchbar.alpha = 1
                self.sortBar.alpha = 1
                self.SearchHeight.constant = 32
                self.SortHeight.constant = 31
            }
        } else if scrollOffset <= 0 {
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.headerBackButton.alpha = 1 // Show custom back button when nav bar is hidden
            }
            UIView.animate(withDuration: 0.2) {
                self.Searchbar.alpha = 0
                self.sortBar.alpha = 0
                self.SearchHeight.constant = 0
                self.SortHeight.constant = 0
            }
        } else if scrollOffset > 20 {
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationItem.title = self.albumTitle
                self.headerBackButton.alpha = 0 // Hide custom back button when nav bar is visible
                
                // Set the navigation bar color to match your album/station
                if let albumImageName = self.albumImageName,
                   let image = UIImage(named: albumImageName),
                   let dominantColor = image.dominantColor() {
                    self.navigationController?.navigationBar.backgroundColor = dominantColor
                } else if let _ = self.selectedStation,
                          let cell = self.albumHeaderContainer.subviews.first(where: { $0 is StationCell }) as? StationCell,
                          let image = cell.singerImageView.image,
                          let dominantColor = image.dominantColor() {
                    self.navigationController?.navigationBar.backgroundColor = dominantColor
                } else {
                    // Fallback color
                    self.navigationController?.navigationBar.backgroundColor = .systemBackground
                }
            }
            UIView.animate(withDuration: 0.2) {
                self.Searchbar.alpha = 0
                self.sortBar.alpha = 0
            }
        }
    }
}
