import UIKit

class HomeScreenViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var podcastButton: UIButton!
    @IBOutlet weak var libraryCollectionView: UICollectionView!
    @IBOutlet weak var stationCollectionView: UICollectionView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    
    // MARK: - Programmatic Views
    private var artistsCollectionView: UICollectionView!
    private var artistsLabel: UILabel!
    
    // MARK: - Helpers
    var navHelper: NavigationHelper?

    // MARK: - Computed Properties
    var recentItems: [LibraryItem] {
        return Array(MusicDataManager.libraryItems.prefix(4))
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let navController = navigationController {
            navHelper = NavigationHelper(navigationController: navController)
        }
        
        setupButtons()
        setupLibraryCollectionView()
        setupStationsCollectionView()
        setupRecentCollectionView()
        setupTopArtistsSection()
        setupEpisodeSection()
        selectButton(allButton)
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupButtons() {
        let buttons = [allButton, musicButton, podcastButton]
        let darkGrayColor = UIColor(hex: "292929")
        
        for btn in buttons {
            btn?.setTitleColor(.white, for: .normal)
            btn?.setTitleColor(.black, for: .selected)
            btn?.backgroundColor = darkGrayColor
            btn?.layer.cornerRadius = 15
            btn?.layer.masksToBounds = true
            btn?.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        allButton.setTitle("All", for: .normal)
        musicButton.setTitle("Music", for: .normal)
        podcastButton.setTitle("Podcast", for: .normal)
    }
    
    private func setupLibraryCollectionView() {
        libraryCollectionView.dataSource = self
        libraryCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 2
        libraryCollectionView.collectionViewLayout = layout
        libraryCollectionView.backgroundColor = .clear
    }
    
    private func setupStationsCollectionView() {
        stationCollectionView.dataSource = self
        stationCollectionView.delegate = self
        
        if let layout = stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 5
            layout.sectionInset = .zero
        }
        
        stationCollectionView.backgroundColor = .clear
        stationCollectionView.showsHorizontalScrollIndicator = false
        stationCollectionView.register(UINib(nibName: "StationCell", bundle: nil), forCellWithReuseIdentifier: "StationCell")
    }
    
    private func setupRecentCollectionView() {
        recentCollectionView.dataSource = self
        recentCollectionView.delegate = self
        
        if let layout = recentCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
        
        recentCollectionView.backgroundColor = .clear
        recentCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupTopArtistsSection() {
        createArtistsLabel()
        createArtistsCollectionView()
        setupArtistsConstraints()
    }
    
    private func createArtistsLabel() {
        artistsLabel = UILabel()
        artistsLabel.text = "Top Artists"
        artistsLabel.textColor = .white
        artistsLabel.font = UIFont.boldSystemFont(ofSize: 22)
        artistsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artistsLabel)
    }
    
    private func createArtistsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        artistsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        artistsCollectionView.backgroundColor = .clear
        artistsCollectionView.showsHorizontalScrollIndicator = false
        artistsCollectionView.dataSource = self
        artistsCollectionView.delegate = self
        artistsCollectionView.register(ArtistCell.self, forCellWithReuseIdentifier: "ArtistCell")
        artistsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artistsCollectionView)
    }
    
    private func setupArtistsConstraints() {
        NSLayoutConstraint.activate([
            artistsLabel.topAnchor.constraint(equalTo: recentCollectionView.bottomAnchor, constant: 300),
            artistsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            artistsCollectionView.topAnchor.constraint(equalTo: artistsLabel.bottomAnchor, constant: 15),
            artistsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            artistsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            artistsCollectionView.heightAnchor.constraint(equalToConstant: 180),
            artistsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupEpisodeSection() {
        let episodeView = EpisodeView()
        episodeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(episodeView)
        episodeView.episodeImageView.image = UIImage(named: "Harshvardan Jain")

        NSLayoutConstraint.activate([
            episodeView.topAnchor.constraint(equalTo: recentCollectionView.bottomAnchor, constant: 90),
            episodeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            episodeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            episodeView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - Button Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == allButton {
            selectButton(allButton)
        } else if sender == musicButton {
            selectButton(musicButton)
        } else if sender == podcastButton {
            selectButton(podcastButton)
        }
    }
    
    private func selectButton(_ selectedButton: UIButton) {
        let buttons = [allButton, musicButton, podcastButton]
        let darkGrayColor = UIColor(hex: "292929")
        
        for btn in buttons {
            if btn == selectedButton {
                UIView.animate(withDuration: 0.2) {
                    btn?.isSelected = true
                    btn?.backgroundColor = .systemGreen
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    btn?.isSelected = false
                    btn?.backgroundColor = darkGrayColor
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case libraryCollectionView: return MusicDataManager.libraryItems.count
            case stationCollectionView: return MusicDataManager.stations.count
            case recentCollectionView: return recentItems.count
            case artistsCollectionView: return MusicDataManager.topArtists.count
            default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
            case libraryCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryGridCell", for: indexPath) as! LibraryGridCell
                let item = MusicDataManager.libraryItems[indexPath.item]
                cell.titleLabel.text = item.title
                cell.coverImageView.image = UIImage(named: item.imageName) ?? UIImage(systemName: "music.note")
                return cell
            case stationCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationCell", for: indexPath) as! StationCell
                let station = MusicDataManager.stations[indexPath.item]
                cell.configure(with: station)
                return cell
            case recentCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCollectionViewCell", for: indexPath) as! RecentCollectionViewCell
                let item = recentItems[indexPath.item]
                cell.configure(with: item)
                return cell
            case artistsCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCell
                let artist = MusicDataManager.topArtists[indexPath.item]
                cell.configure(with: artist)
                return cell
            default:
                return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
            case libraryCollectionView:
                let totalSpacing: CGFloat = 2
                let width = (collectionView.bounds.width - totalSpacing) / 2
                return CGSize(width: width, height: 50)
            case stationCollectionView:
                return CGSize(width: 173, height: 370)
            case recentCollectionView:
                return CGSize(width: 140, height: 200)
            case artistsCollectionView:
                return CGSize(width: 150, height: 180)
            default:
                return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailViewController") as? AlbumDetailViewController else { return }

        var fetchQuery: String?

        switch collectionView {
            case libraryCollectionView:
                let item = MusicDataManager.libraryItems[indexPath.item]
                detailVC.albumTitle = item.title
                detailVC.albumImageName = item.imageName
                detailVC.totalDuration = item.totalDuration
                switch item.title {
                    case "English Songs": fetchQuery = "english pop"
                    case "Hindi Songs": fetchQuery = "hindi songs"
                    case "Workout": fetchQuery = "workout music"
                    case "Chill Vibes": fetchQuery = "chill music"
                    default: break
                }
            case artistsCollectionView:
                let artist = MusicDataManager.topArtists[indexPath.item]
                detailVC.albumTitle = artist.name
                detailVC.albumImageName = artist.imageName
                detailVC.totalDuration = artist.totalDuration
                fetchQuery = artist.name
            case stationCollectionView:
                let station = MusicDataManager.stations[indexPath.item]
                detailVC.albumTitle = station.name
                detailVC.albumSubtitle = station.subtitle
                detailVC.isStation = true
                detailVC.selectedStation = station
                detailVC.totalDuration = station.totalDuration
                fetchQuery = station.name
            case recentCollectionView:
                let item = recentItems[indexPath.item]
                detailVC.albumTitle = item.title
                detailVC.albumImageName = item.imageName
                detailVC.totalDuration = item.totalDuration
                switch item.title {
                    case "English Songs": fetchQuery = "english pop"
                    case "Hindi Songs": fetchQuery = "bollywood songs"
                    case "Workout": fetchQuery = "workout edm"
                    case "Chill Vibes": fetchQuery = "chill lofi"
                    default: break
                }
            default: break
        }

        if let query = fetchQuery {
            APIManager.shared.fetchSongs(for: query) { songs in
                DispatchQueue.main.async {
                    detailVC.songs = songs
                    self.navHelper?.push(detailVC)
                }
            }
        } else {
            // fallback
            detailVC.songs = [
                Song(title: "Hit 1", artist: "Unknown", imageName: "hit1", previewUrl: ""),
                Song(title: "Hit 2", artist: "Unknown", imageName: "hit2", previewUrl: "")
            ]
            self.navHelper?.push(detailVC)
        }
    }
}
