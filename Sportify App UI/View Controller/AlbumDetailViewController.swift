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

 
    var albumTitle: String?
    var albumImageName: String?
    var totalDuration: String?
    var songs: [Song] = []
    var selectedStation: Station?
    var albumSubtitle: String?
    var isStation: Bool = false
    
  
    private let maxImageSize: CGFloat = 180
    private let minImageSize: CGFloat = 130
    private var initialHeaderY: CGFloat = 0
    
    private lazy var miniPlayer = MiniPlayerView()

 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        albumTitleLabel.text = albumTitle
        setupNavigationBar()
        setupAlbumHeader()
        setupTableView()
        setupMiniPlayer()
        
       
        sortBar.alpha = 0
        Searchbar.alpha = 0
        view.bringSubviewToFront(playButton)
        
        scrollView.delegate = self
        tableView.delegate = self

       
        self.navigationItem.title = nil
        
        if let totalDuration = totalDuration {
            durationLabel.text = "\(totalDuration)"
        }
        
        // Fetch songs
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialHeaderY == 0 {
            let centerX = view.frame.width / 2
            initialHeaderY = 120
            
            // Update header frame
            albumHeaderContainer.frame = CGRect(
                x: centerX - maxImageSize/2,
                y: initialHeaderY,
                width: maxImageSize,
                height: maxImageSize
            )
            
            // Set initial table view frame
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
        
   
        positionMiniPlayer()
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

    // MARK: - Album Header
    private func setupAlbumHeader() {
        albumHeaderContainer.backgroundColor = .clear
        
        if let station = selectedStation,
           let cell = Bundle.main.loadNibNamed("StationCell", owner: nil, options: nil)?.first as? StationCell {
            cell.frame = albumHeaderContainer.bounds
            cell.configure(with: station)
            cell.backgroundColor = .clear
            cell.subtitleLabel.isHidden = true
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            albumHeaderContainer.addSubview(cell)
        } else if let albumImageName = albumImageName {
            let imageView = UIImageView(frame: albumHeaderContainer.bounds)
            imageView.image = UIImage(named: albumImageName)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            albumHeaderContainer.addSubview(imageView)
        }
    }

    // MARK: - Navigation
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = nil
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View
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
    
    // MARK: - Content Size Management
    private func updateContentSize() {
        guard !songs.isEmpty else {
            // If no songs, set minimal content size
            scrollView.contentSize = CGSize(
                width: view.frame.width,
                height: scrollView.frame.height + 1
            )
            return
        }
        
       
        let rowHeight: CGFloat = 70
        let tableHeight = CGFloat(songs.count) * rowHeight
        
      
        let tableY = albumHeaderContainer.frame.maxY + 20
        tableView.frame = CGRect(
            x: 0,
            y: tableY,
            width: view.frame.width,
            height: tableHeight
        )
        
        // Calculate total content height
        let headerHeight = albumHeaderContainer.frame.height
        let totalContentHeight = initialHeaderY + headerHeight + tableHeight + 120
        
        // Update scroll view content size
        scrollView.contentSize = CGSize(
            width: view.frame.width,
            height: max(totalContentHeight, scrollView.frame.height + 1)
        )
        
        print("Content Updated: \(songs.count) songs, Table Height: \(tableHeight), Total Height: \(totalContentHeight)")
        
        // Force layout update
        self.view.layoutIfNeeded()
    }
}

// MARK: - MiniPlayerViewDelegate
extension AlbumDetailViewController: MiniPlayerViewDelegate {
    func miniPlayerDidTapPlayPause() {
        
    }
    
    func miniPlayerDidTapClose() {
        miniPlayer.hide()
    }
    
    func miniPlayerDidTapExpand() {
    
    }
    
    func miniPlayerDidTapDevice() {
       
    }
    
    func miniPlayerDidTapCreate() {
       
    }
}

// MARK: - TableView Delegate & DataSource
extension AlbumDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        cell.configure(with: song) { print("More tapped for song: \(song.title)") }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        
        // Configure mini player with song data
        miniPlayer.configure(with: song.imageName, title: song.title, subtitle: song.artist)
        miniPlayer.setPlaybackState(isPlaying: true)
        miniPlayer.show()
        
        // Deselect row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only handle scroll view scrolling
        guard scrollView == self.scrollView else { return }
        
        let scrollOffset = scrollView.contentOffset.y
        
        // Shrink/grow header based on scroll
        let newSize: CGFloat
        if scrollOffset > 0 {
            // Scrolling up - shrink the image
            newSize = max(maxImageSize - scrollOffset, minImageSize)
        } else {
            // Scrolling down - stay at max size
            newSize = maxImageSize
        }
        
        let centerX = view.frame.width / 2
        
        // Update frame while keeping it centered
        albumHeaderContainer.frame = CGRect(
            x: centerX - newSize/2,
            y: initialHeaderY,
            width: newSize,
            height: newSize
        )
        
        // Update station cell content properly
        if let stationCell = albumHeaderContainer.subviews.first as? StationCell {
            stationCell.frame = albumHeaderContainer.bounds
            
            // Scale the content inside the station cell
            let scale = newSize / maxImageSize
            stationCell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Update corner radius to match scale
            stationCell.layer.cornerRadius = 12 * scale
            
        } else if let imageView = albumHeaderContainer.subviews.first as? UIImageView {
            // For regular image view
            imageView.frame = albumHeaderContainer.bounds
            imageView.layer.cornerRadius = 12 * (newSize / maxImageSize)
        }
        
        // Navigation Title
        if scrollOffset > 50 {
            UIView.animate(withDuration: 0.2) {
                self.navigationItem.title = self.albumTitle
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.navigationItem.title = nil
            }
        }

        // Search & Sort Bars
        if scrollOffset < -100 {
            UIView.animate(withDuration: 0.2) {
                self.Searchbar.alpha = 1
                self.sortBar.alpha = 1
            }
        } else if scrollOffset > 0 {
            UIView.animate(withDuration: 0.2) {
                self.Searchbar.alpha = 0
                self.sortBar.alpha = 0
            }
        }
    }
}
