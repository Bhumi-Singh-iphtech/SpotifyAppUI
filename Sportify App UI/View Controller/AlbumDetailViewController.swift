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

    // MARK: - Data
    var albumTitle: String?
    var albumImageName: String?
    var totalDuration: String?
    var songs: [Song] = []
    var selectedStation: Station?
    var albumSubtitle: String?
    var isStation: Bool = false
    
    // MARK: - State
    private let maxImageSize: CGFloat = 180
    private let minImageSize: CGFloat = 130
    private var initialHeaderY: CGFloat = 0
    
    // MARK: - Mini Player
    private lazy var miniPlayer = MiniPlayerView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        albumTitleLabel.text = albumTitle
        setupNavigationBar()
        setupAlbumHeader()
        setupTableView()
        setupMiniPlayer()
        
        // Initially hide search, sort and title
        sortBar.alpha = 0
        Searchbar.alpha = 0
        view.bringSubviewToFront(playButton)
        
        scrollView.delegate = self
        tableView.delegate = self

        // Initially hide the navigation title
        self.navigationItem.title = nil
        
        if let totalDuration = totalDuration {
            durationLabel.text = "\(totalDuration)"
            
        
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
            
            // Update scroll view content size
            updateScrollViewContentSize()
        }
        
        // Position mini player
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
            x: 5,
            y: view.bounds.height - playerHeight - bottomInset,
            width: view.bounds.width - 10,
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
        
      
    }
    
    private func updateScrollViewContentSize() {
        let headerHeight = albumHeaderContainer.frame.height
        let tableHeight = tableView.contentSize.height
        
        // Calculate total content height
        let totalContentHeight = initialHeaderY + headerHeight + tableHeight + 50
        
        // Make sure content size is at least the scroll view's height
        let minContentHeight = scrollView.frame.height + 1
        
        scrollView.contentSize = CGSize(
            width: view.frame.width,
            height: max(totalContentHeight, minContentHeight)
        )
        
        // Update table view frame to fit all content
        tableView.frame.size.height = tableView.contentSize.height
    }
}

extension AlbumDetailViewController: MiniPlayerViewDelegate {
    func miniPlayerDidTapPlayPause() {
        // Do nothing or add basic functionality
    }
    
    func miniPlayerDidTapClose() {
        miniPlayer.hide()
    }
    
    func miniPlayerDidTapExpand() {
        // Do nothing
    }
    
    func miniPlayerDidTapDevice() {
        // Do nothing
    }
    
    func miniPlayerDidTapCreate() {
        // Do nothing
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
        let image = UIImage(named: song.imageName)
        
        miniPlayer.configure(with: image, title: song.title, subtitle: song.artist)
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
        
        // ✅ SHRINK/GROW HEADER BASED ON SCROLL
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
            x: centerX - newSize/2, // Always centered horizontally
            y: initialHeaderY,      // Same Y position
            width: newSize,
            height: newSize
        )
        
        // ✅ UPDATE STATION CELL CONTENT PROPERLY
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
    
    // ✅ UPDATE TABLE VIEW HEIGHT WHEN DATA CHANGES
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure table view height is updated after data is loaded
        DispatchQueue.main.async {
            self.updateScrollViewContentSize()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Update content size when all cells are about to be displayed
        if indexPath.row == songs.count - 1 {
            DispatchQueue.main.async {
                self.updateScrollViewContentSize()
            }
        }
    }
}
