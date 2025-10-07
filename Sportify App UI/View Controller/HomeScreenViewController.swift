
import UIKit
class HomeScreenViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var epsiodeLabel: UILabel!
    // MARK: - Outlets
    
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
        Artist(name: "Taylor Swift", imageName: "taylor swift",totalDuration: "• 35 min")
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
           // Hide navigation bar when returning to home
           navigationController?.setNavigationBarHidden(true, animated: animated)
       }
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           // Show navigation bar when going to detail screen
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
            detailVC.songs = [
                Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london_thumakda"),
                Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
            ]
            
        } else if collectionView == artistsCollectionView {
            let artist = topArtists[indexPath.item]
            detailVC.albumTitle = artist.name
            detailVC.albumImageName = artist.imageName
            detailVC.totalDuration = artist.totalDuration
            
            // Specific artist songs
            switch artist.name {
            case "Arijit Singh":
                detailVC.songs = [
                    Song(title: "Desh Mere", artist: "Arijit Singh", imageName: "Desh mere"),
                    Song(title: "Hamari Adhuri Khani", artist: "Arijit Singh", imageName: "Hamari Adhuri Khani"),
                    Song(title: "Maan Mera", artist: "Arijit Singh", imageName: "maan mera"),
                    Song(title: "Solumate", artist: "Arijit Singh", imageName: "Solumate"),
                    Song(title: "Tera Yar Hoon Main", artist: "Arijit Singh", imageName: "Tera Yaar Hoon Main")
                ]
            case "Neha Kakkar":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
                ]
            
            default:
                detailVC.songs = [
                    Song(title: "Hit 1", artist: artist.name, imageName: "hit1"),
                    Song(title: "Hit 2", artist: artist.name, imageName: "hit2")
                ]
            }

        }else if collectionView == stationCollectionView {
            let station = stations[indexPath.item]
            detailVC.albumTitle = station.subtitle
            detailVC.isStation = true
            detailVC.albumTitle = station.name      // navigation bar title
            detailVC.albumSubtitle = station.subtitle
            detailVC.selectedStation = station
            detailVC.totalDuration = station.totalDuration
            switch station.name {
            case "Neha Kakkar":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
                ]
            case "Vishal Mishra":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Vishal Mishra", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Vishal Mishra", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Vishal Mishra", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Vishal Mishra", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Vishal Mishra", imageName: "Badri ki dulhaniya")
                ]
            case "Darshan Raval":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Darshal Raval", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Darshal Raval", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Darshal Raval", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Darshal Raval", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Darshal Raval", imageName: "Badri ki dulhaniya")
                ]

            case "Atif Aslam":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Atif Aslam", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Atif Aslam", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Atif Aslam", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Atif Aslam", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Atif Aslam", imageName: "Badri ki dulhaniya")
                ]

            case "Pritam Radio":
                detailVC.songs = [
                    Song(title: "Lambargini", artist: "Pritam", imageName: "Lambargini"),
                    Song(title: "Dilbar", artist: "Pritam", imageName: "dilbar"),
                    Song(title: "Tera Yar Hoon Main", artist: "Pritam", imageName: "Tera Yaar Hoon Main"),
                    Song(title: "London Thumakda", artist: "Pritam", imageName: "london thumka"),
                    Song(title: "Badri Ki Dulhania", artist: "Pritam", imageName: "Badri ki dulhaniya")
                ]

            default:
                detailVC.songs = [
                    Song(title: "Hit 1", artist: station.name, imageName: "hit1"),
                    Song(title: "Hit 2", artist: station.name, imageName: "hit2")
                ]
        }
        }
        else if collectionView == recentCollectionView {
            let item = recentItems[indexPath.item]
            detailVC.albumTitle = item.title
            detailVC.albumImageName = item.imageName
            detailVC.totalDuration = item.totalDuration

            // Specific songs for each recent item
            switch item.title {
            case "English Songs":
                detailVC.songs = [
                    Song(title: "wanted", artist: "Hunter Hayes", imageName: "wanted"),
                    Song(title: "Life is", artist: "Hunter Hayes", imageName: "Life is"),
                    Song(title: "Imagination", artist: "Hunter Hayes", imageName: "imagination"),
                    Song(title: "Apt", artist: "Hunter Hayes", imageName: "Apt"),
                    Song(title: "just like you", artist: "Hunter Hayes", imageName: "just like you"),
                    Song(title: "castle on hill", artist: "Hunter Hayes", imageName: "castle on hill")
                ]
            case "Hindi Songs":
                detailVC.songs = [
                Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london thumka"),
                Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
            ]
            case "Workout":
                detailVC.songs = [
                Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london thumka"),
                Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
            ]
            case "Chill Vibes":
                detailVC.songs = [
                Song(title: "Lambargini", artist: "Neha Kakkar", imageName: "Lambargini"),
                Song(title: "Dilbar", artist: "Neha Kakkar", imageName: "dilbar"),
                Song(title: "Tera Yar Hoon Main", artist: "Neha Kakkar", imageName: "Tera Yaar Hoon Main"),
                Song(title: "London Thumakda", artist: "Neha Kakkar", imageName: "london thumka"),
                Song(title: "Badri Ki Dulhania", artist: "Neha Kakkar", imageName: "Badri ki dulhaniya")
            ]
            default:
                detailVC.songs = [
                    Song(title: "Hit 1", artist: "Unknown", imageName: "hit1"),
                    Song(title: "Hit 2", artist: "Unknown", imageName: "hit2")
                ]
            }
        }


        navigationController?.pushViewController(detailVC, animated: true)
    }


}
