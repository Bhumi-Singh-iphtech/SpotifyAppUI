
import UIKit
class HomeScreenViewController: UIViewController {
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
    
    // MARK: - Data
    let libraryItems: [LibraryItem] = [
        LibraryItem(title: "English Songs", imageName: "english song",totalDuration: "• 35 min"),
        LibraryItem(title: "Hindi Songs", imageName: "Top hindi songs",totalDuration: "• 35 min"),
        LibraryItem(title: "Workout", imageName: "Workout",totalDuration: "• 35 min"),
        LibraryItem(title: "Chill Vibes", imageName: "Chill Vibes",totalDuration: "• 35 min"),
        LibraryItem(title: "Focus Beats", imageName: "Focus music",totalDuration: "• 35 min"),
        LibraryItem(title: "Liked Songs", imageName: "liked-songs",totalDuration: "• 35 min"),
    ]
    
    let stations: [Station] = [
        Station(
            name: "Neha Kakkar",
            subtitle: "Neha Kakkar, Tony Kakkar, Guru Randhawa, Badshah, Meet Bros and more",
            imageName: "Neha Kakar",
            hexColor: "#F19AD2",
            totalDuration: "• 35 min"
        ),
        Station(
            name: "Vishal Mishra",
            subtitle: "Vishal Mishra, Sachin-Jigar, Atif Aslam, Anuv Jain and more",
            imageName: "Vishal Mishra Radio",
            hexColor: "#FBD97D",
            totalDuration: "• 35 min"
        ),
        Station(
            name: "Darshan Raval",
            subtitle: "Darshan Raval, Atif Aslam, Rochak Kohli and more",
            imageName: "Darshal Raval",
            hexColor: "#CFF66A",
            totalDuration: "• 35 min"
        ),
        Station(
            name: "Atif Aslam",
            subtitle: "Atif Aslam, Pritam, Mithoon and more",
            imageName: "Atif Aslam",
            hexColor: "#95EFB5",
            totalDuration: "• 35 min"
        ),
        Station(
            name: "Pritam Radio",
            subtitle: "Pritam, Mithoon",
            imageName: "Pritham Radio",
            hexColor: "#95EFB5",totalDuration: "• 35 min"
        )
    ]

    // Add top artists data
    let topArtists: [Artist] = [
        Artist(name: "Arijit Singh", imageName: "arjit singh",totalDuration: "• 35 min"),
        Artist(name: "Neha Kakkar", imageName: "neha kakkar",totalDuration: "• 35 min"),
        Artist(name: "Badshah", imageName: "badshah",totalDuration: "• 35 min"),
        Artist(name: "Darshal Raval", imageName: "Darshal Raval-1",totalDuration: "• 35 min")
    ]

    var recentItems: [LibraryItem] {
        return Array(libraryItems.prefix(4)) //
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupButtons()
        setupLibraryCollectionView()
        setupStationsCollectionView()
        setupRecentCollectionView()
        selectButton(allButton)
        setupEpisodeSection()
        setupTopArtistsSection()
            // Left arrow back button
                let backButton = UIBarButtonItem(
                    image: UIImage(systemName: "arrow.left"),
                    style: .plain,
                    target: self,
                    action: #selector(backButtonTapped)
                )
                backButton.tintColor = .white
                navigationItem.leftBarButtonItem = backButton
            }

            @objc func backButtonTapped() {
                navigationController?.popViewController(animated: true)
            }
   
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
         
           navigationController?.setNavigationBarHidden(true, animated: animated)
       }
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
          
           navigationController?.setNavigationBarHidden(false, animated: animated)
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

    // MARK: - Setup Methods
    private func setupButtons() {
        let buttons = [allButton, musicButton, podcastButton]
        for btn in buttons {
            let darkGrayColor = UIColor(hex: "292929")
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
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        stationCollectionView.backgroundColor = .clear
        stationCollectionView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: "StationCell", bundle: nil)
        stationCollectionView.register(nib, forCellWithReuseIdentifier: "StationCell")
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
        layout.minimumInteritemSpacing = 10
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
            // Artists Label - below the episode image view
            artistsLabel.topAnchor.constraint(equalTo: recentCollectionView.bottomAnchor, constant: 300),
            artistsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Artists Collection View
            artistsCollectionView.topAnchor.constraint(equalTo: artistsLabel.bottomAnchor, constant: 15),
            artistsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            artistsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            artistsCollectionView.heightAnchor.constraint(equalToConstant: 180), artistsCollectionView.bottomAnchor.constraint(equalTo:contentView.bottomAnchor, constant: 0)
        ])
    }
    
    @IBAction func allTapped(_ sender: UIButton) {
        selectButton(allButton)
    }
    
    @IBAction func podcastsTapped(_ sender: UIButton) {
        selectButton(podcastButton)
    }
    
    @IBAction func musicTapped(_ sender: UIButton) {
        selectButton(musicButton)
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
}

extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == libraryCollectionView {
            return libraryItems.count
        } else if collectionView == stationCollectionView {
            return stations.count
        } else if collectionView == recentCollectionView {
            return recentItems.count
        } else if collectionView == artistsCollectionView {
            return topArtists.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == libraryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryGridCell", for: indexPath) as! LibraryGridCell
            let item = libraryItems[indexPath.item]
            cell.titleLabel.text = item.title
            
            if let image = UIImage(named: item.imageName) {
                cell.coverImageView.image = image
            } else {
                cell.coverImageView.image = UIImage(systemName: "music.note")
            }
            
            return cell
        } else if collectionView == stationCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationCell", for: indexPath) as! StationCell
            let station = stations[indexPath.item]
            cell.configure(with: station)
            return cell
        } else if collectionView == recentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCollectionViewCell", for: indexPath) as! RecentCollectionViewCell
            let item = recentItems[indexPath.item]
            cell.configure(with: item)
            return cell
        } else if collectionView == artistsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCell
            let artist = topArtists[indexPath.item]
            cell.configure(with: artist)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == libraryCollectionView {
            let totalSpacing: CGFloat = 2
            let width = (collectionView.bounds.width - totalSpacing) / 2
            return CGSize(width: width, height: 50)
        } else if collectionView == stationCollectionView {
       
            return CGSize(width: 173, height:370)
        } else if collectionView == recentCollectionView {
            return CGSize(width: 140, height: 200)
        } else if collectionView == artistsCollectionView {
            return CGSize(width: 150, height: 180)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailViewController") as! AlbumDetailViewController

        if collectionView == libraryCollectionView {
            let item = libraryItems[indexPath.item]
            detailVC.albumTitle = item.title
            detailVC.albumImageName = item.imageName
            detailVC.totalDuration = item.totalDuration

            switch item.title {
            case "English Songs":
                APIManager.shared.fetchSongs(for: "english pop") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Hindi Songs":
                APIManager.shared.fetchSongs(for: "hindi songs") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Workout":
                APIManager.shared.fetchSongs(for: "workout music") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Chill Vibes":
                APIManager.shared.fetchSongs(for: "chill music") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            default:
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini", previewUrl: ""),
                    Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar", previewUrl: "")
                ]
            }
        } else if collectionView == artistsCollectionView {
            let artist = topArtists[indexPath.item]
            detailVC.albumTitle = artist.name
            detailVC.albumImageName = artist.imageName
            detailVC.totalDuration = artist.totalDuration

            APIManager.shared.fetchSongs(for: artist.name) { songs in
                DispatchQueue.main.async {
                    detailVC.songs = songs
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
            return
        } else if collectionView == stationCollectionView {
            let station = stations[indexPath.item]
            detailVC.albumTitle = station.name
            detailVC.albumSubtitle = station.subtitle
            detailVC.isStation = true
            detailVC.selectedStation = station
            detailVC.totalDuration = station.totalDuration

            APIManager.shared.fetchSongs(for: station.name) { songs in
                DispatchQueue.main.async {
                    detailVC.songs = songs
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
            return
        } else if collectionView == recentCollectionView {
            let item = recentItems[indexPath.item]
            detailVC.albumTitle = item.title
            detailVC.albumImageName = item.imageName
            detailVC.totalDuration = item.totalDuration

            switch item.title {
            case "English Songs":
                APIManager.shared.fetchSongs(for: "english pop") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Hindi Songs":
                APIManager.shared.fetchSongs(for: "bollywood songs") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Workout":
                APIManager.shared.fetchSongs(for: "workout edm") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            case "Chill Vibes":
                APIManager.shared.fetchSongs(for: "chill lofi") { songs in
                    DispatchQueue.main.async {
                        detailVC.songs = songs
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                return
            default:
                detailVC.songs = [
                    Song(title: "Hit 1", artist: "Unknown", imageName: "hit1", previewUrl: ""),
                    Song(title: "Hit 2", artist: "Unknown", imageName: "hit2", previewUrl: "")
                ]
            }
        }

        // Fallback push if not returned early
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func showLoadingIndicator() {
        
        print("Loading songs from iTunes...")
    }


    private func handleAPIError(_ error: Error) {
        print("API Error: \(error)")
     
        let alert = UIAlertController(title: "Error", message: "Failed to load songs. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}
