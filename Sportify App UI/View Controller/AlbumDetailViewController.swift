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
    private var isTableViewScrolling = false
    private let maxImageSize: CGFloat = 180
    private let minImageSize: CGFloat = 130
    private var initialHeaderY: CGFloat = 0 // ✅ ADD THIS

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        albumTitleLabel.text = albumTitle
        setupNavigationBar()
        setupAlbumHeader()
        setupTableView()
        
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
        
        // ✅ SET INITIAL HEADER POSITION (only once)
        if initialHeaderY == 0 {
            let centerX = view.frame.width / 2
            initialHeaderY = 120 // Adjust this based on your design
            
            albumHeaderContainer.frame = CGRect(
                x: centerX - maxImageSize/2,
                y: initialHeaderY,
                width: maxImageSize,
                height: maxImageSize
            )
        }
        
        // Set scroll view content size
        let headerHeight = albumHeaderContainer.frame.height
        scrollView.contentSize = CGSize(width: view.frame.width, height: headerHeight + tableView.contentSize.height)
        tableView.frame.size.height = tableView.contentSize.height
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
        return cell
    }

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        let headerHeight = albumHeaderContainer.frame.height
        
        if scrollView == self.scrollView {
            // ✅ ONLY SHRINK WHEN SCROLLING UP, STAY MAX SIZE WHEN SCROLLING DOWN
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
            
            // ✅ FIX: UPDATE STATION CELL CONTENT PROPERLY
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
            
            // Scroll handoff to table view
            if scrollOffset >= headerHeight - minImageSize && !isTableViewScrolling {
                isTableViewScrolling = true
                tableView.isScrollEnabled = true
                let remainingOffset = scrollOffset - (headerHeight - minImageSize)
                tableView.contentOffset.y = remainingOffset
            }
        }
        
        else if scrollView == tableView {
            if tableView.contentOffset.y <= 0 && isTableViewScrolling {
                isTableViewScrolling = false
                tableView.isScrollEnabled = false
                let scrollViewOffset = headerHeight - minImageSize + tableView.contentOffset.y
                self.scrollView.contentOffset.y = scrollViewOffset
            }
        }
    }
    // ✅ ADD THIS METHOD FOR STATUS BAR HEIGHT
    private func getStatusBarHeight() -> CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tableView && tableView.contentOffset.y <= 0 {
            isTableViewScrolling = false
            tableView.isScrollEnabled = false
        }
    }
}
