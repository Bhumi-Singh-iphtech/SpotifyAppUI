import UIKit

class LyricsPopupView: UIView {
    
    // MARK: - UI Components
    private let backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        textView.textAlignment = .center
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 100, right: 20)
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    private let sideButton: UIButton = {
        let button = UIButton()
        if let customImage = UIImage(named: "down-chevron") {
            button.setImage(customImage, for: .normal)
        } else {
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.backgroundColor = .clear
        return button
    }()
    
    // Progress View
    private let progressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let progressBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let progressFill: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let progressDot: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "0:00"
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.text = "3:00"
        return label
    }()
    
    // Top Buttons
    private let shareButton: UIButton = {
        let button = UIButton()
        if let customImage = UIImage(named: "share (1)") {
            button.setImage(customImage, for: .normal)
        } else {
            button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        }
        button.tintColor = .white
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        if let customImage = UIImage(named: "icons8-three-dots-24") {
            button.setImage(customImage, for: .normal)
        } else {
            button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        }
        button.tintColor = .white
        return button
    }()
    
    private func setBackgroundColorFromSongImage(_ song: Song) { DispatchQueue.global(qos: .background).async {
        var dominantColor: UIColor = .darkGray
        if let image = UIImage(named: song.imageName) {
            if let color = image.dominantColor() ?? image.averageColor() {
                dominantColor = color }
            
        } else if let url = URL(string: song.imageName),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) {
            if let color = image.dominantColor() ?? image.averageColor() {
                dominantColor = color
            }
        }
        DispatchQueue.main.async
        {
            UIView.animate(withDuration: 0)
                { self.backgroundView.backgroundColor = dominantColor } } } }

    // Bottom Play Button
    private let playPauseButton: UIButton = {
        let button = UIButton()
        if let playImage = UIImage(named: "play_icon"), let pauseImage = UIImage(named: "pause_icon") {
            button.setImage(pauseImage, for: .normal)
            button.setImage(playImage, for: .selected)
        } else {
            button.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            button.setImage(UIImage(systemName: "play.circle.fill"), for: .selected)
        }
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    // MARK: - Properties
    private var currentSong: Song?
    private var isPlaying = true
    private var displayLink: CADisplayLink?
    private var progress: Float = 0.0
    private var lyricsData: [LyricLine] = []
    private var totalSongDuration: TimeInterval = 180.0 // default 3 min
    private var lastScrollLineIndex = -1
    
    private var progressFillWidthConstraint: NSLayoutConstraint?
    private var progressDotCenterXConstraint: NSLayoutConstraint?
    
    var dismissHandler: (() -> Void)?
    weak var parentViewController: UIViewController?
    
    // MARK: - Lyric Data Structure
    struct LyricLine {
        let time: TimeInterval
        let text: String
        let letters: [LyricLetter]
    }
    
    struct LyricLetter {
        let character: String
        let startTime: TimeInterval
        let duration: TimeInterval
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    deinit { displayLink?.invalidate() }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .black
        addSubview(backgroundView)
        addSubview(songTitleLabel)
        addSubview(artistLabel)
        addSubview(lyricsTextView)
        addSubview(sideButton)
        addSubview(progressContainer)
        progressContainer.addSubview(progressBackground)
        progressContainer.addSubview(progressFill)
        progressContainer.addSubview(progressDot)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(shareButton)
        addSubview(moreButton)
        addSubview(playPauseButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        sideButton.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressBackground.translatesAutoresizingMaskIntoConstraints = false
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressDot.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        progressFillWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidthConstraint?.isActive = true
        
        progressDotCenterXConstraint = progressDot.centerXAnchor.constraint(equalTo: progressFill.trailingAnchor)
        progressDotCenterXConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            sideButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            sideButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            sideButton.widthAnchor.constraint(equalToConstant: 40),
            sideButton.heightAnchor.constraint(equalToConstant: 40),
            
            songTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            songTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            songTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            lyricsTextView.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 30),
            lyricsTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lyricsTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lyricsTextView.bottomAnchor.constraint(equalTo: progressContainer.topAnchor, constant: -40),
            
            progressContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressContainer.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -40),
            progressContainer.heightAnchor.constraint(equalToConstant: 20),
            
            progressBackground.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBackground.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor),
            progressBackground.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressBackground.heightAnchor.constraint(equalToConstant: 4),
            
            progressFill.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressFill.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressFill.heightAnchor.constraint(equalToConstant: 4),
            
            progressDot.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressDot.widthAnchor.constraint(equalToConstant: 12),
            progressDot.heightAnchor.constraint(equalToConstant: 12),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 5),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            
            totalTimeLabel.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 5),
            totalTimeLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor),
            
            shareButton.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: progressContainer.topAnchor, constant: -12),
            shareButton.widthAnchor.constraint(equalToConstant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: 20),
            
            moreButton.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: progressContainer.topAnchor, constant: -12),
            moreButton.widthAnchor.constraint(equalToConstant: 20),
            moreButton.heightAnchor.constraint(equalToConstant: 20),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -110),
            playPauseButton.widthAnchor.constraint(equalToConstant: 70),
            playPauseButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupActions() {
        sideButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
    }
    
    // MARK: - Public Methods
    func show(in view: UIView, with song: Song, from viewController: UIViewController) {
        self.currentSong = song
        self.parentViewController = viewController
        frame = view.bounds
        viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(self)
        configure(with: song)
        
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
        
        startProgressAnimation()
    }
    
    func dismiss() {
        parentViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        displayLink?.invalidate()
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 50)
        }) { _ in
            self.removeFromSuperview()
            self.dismissHandler?()
        }
    }
    
    // MARK: - Configuration
    private func configure(with song: Song) {
        currentSong = song
        songTitleLabel.text = song.title
        artistLabel.text = song.artist
        totalSongDuration = 180.0
        updateTimeLabels()
        loadLyrics(for: song)
        setBackgroundColorFromSongImage(song)    }
    
    private func updateTimeLabels() {
        let currentTime = TimeInterval(progress) * totalSongDuration
        currentTimeLabel.text = formatTime(currentTime)
        totalTimeLabel.text = formatTime(totalSongDuration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func loadLyrics(for song: Song) {
        LyricsAPIManager.shared.fetchLyricsForSong(song) { [weak self] lyrics in
            DispatchQueue.main.async {
                if let lyrics = lyrics {
                    self?.displayLyricsWithLetterByLetterHighlighting(lyrics)
                } else {
                    self?.displayNoLyricsFound()
                }
            }
        }
    }
    
    private func displayLyricsWithLetterByLetterHighlighting(_ lyrics: String) {
        let formattedLyrics = lyrics.replacingOccurrences(of: "\r\n", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = formattedLyrics.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        // Calculate timing for each line and letter
        let lineDuration = totalSongDuration / Double(max(lines.count, 1))
        
        lyricsData = lines.enumerated().map { lineIndex, lineText in
            let lineStartTime = Double(lineIndex) * lineDuration
            let letters = parseLettersFromLine(lineText, lineStartTime: lineStartTime, lineDuration: lineDuration)
            return LyricLine(time: lineStartTime, text: lineText, letters: letters)
        }
        
        updateLyricsHighlight()
    }
    
    private func parseLettersFromLine(_ line: String, lineStartTime: TimeInterval, lineDuration: TimeInterval) -> [LyricLetter] {
        // Remove extra spaces and split into characters
        let cleanedLine = line.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
        let characters = Array(cleanedLine)
        
        var lyricLetters: [LyricLetter] = []
        let letterDuration = lineDuration / Double(max(characters.count, 1))
        var currentTime = lineStartTime
        
        for character in characters {
            let charString = String(character)
            let lyricLetter = LyricLetter(character: charString, startTime: currentTime, duration: letterDuration)
            lyricLetters.append(lyricLetter)
            currentTime += letterDuration
        }
        
        return lyricLetters
    }
    
    private func updateLyricsHighlight() {
        guard !lyricsData.isEmpty else { return }
        
        let currentTime = TimeInterval(progress) * totalSongDuration
        let attributedText = NSMutableAttributedString()
        var currentLineIndex = -1
        
        for (lineIndex, line) in lyricsData.enumerated() {
            let isLineActive = currentTime >= line.time
            
            // Build attributed string for the line with letter-by-letter highlighting
            let lineAttributedString = createHighlightedLineString(line: line, currentTime: currentTime)
            attributedText.append(lineAttributedString)
            attributedText.append(NSAttributedString(string: "\n\n"))
            
            if isLineActive {
                currentLineIndex = lineIndex
            }
        }
        
        lyricsTextView.attributedText = attributedText
        
        if currentLineIndex >= 0 && currentLineIndex != lastScrollLineIndex {
            lastScrollLineIndex = currentLineIndex
            scrollToLine(currentLineIndex)
        }
    }
    
    private func createHighlightedLineString(line: LyricLine, currentTime: TimeInterval) -> NSAttributedString {
        let lineAttributedString = NSMutableAttributedString()
        
        for (_, letter) in line.letters.enumerated() {
            let isLetterHighlighted = currentTime >= letter.startTime && currentTime <= letter.startTime + letter.duration
            let isLetterCompleted = currentTime > letter.startTime + letter.duration
            
            let letterAttributes: [NSAttributedString.Key: Any]
            
            if isLetterHighlighted {
                // Currently highlighting this letter
                letterAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 22, weight: .bold)
                ]
            } else if isLetterCompleted {
                // Letter has been completed
                letterAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 22, weight: .regular)
                ]
            } else {
                // Letter hasn't been reached yet
                letterAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                    .font: UIFont.systemFont(ofSize: 22, weight: .regular)
                ]
            }
            
            let letterString = NSAttributedString(string: letter.character, attributes: letterAttributes)
            lineAttributedString.append(letterString)
        }
        
        return lineAttributedString
    }
    
    private func scrollToLine(_ lineIndex: Int) {
        guard lineIndex < lyricsData.count else { return }
        let text = lyricsTextView.attributedText ?? NSAttributedString(string: "")
        let lines = text.string.components(separatedBy: "\n\n")
        var location = 0
        for i in 0..<lineIndex { location += lines[i].count + 2 }
        let range = NSRange(location: location, length: lines[lineIndex].count)
        let layoutManager = lyricsTextView.layoutManager
        let textContainer = lyricsTextView.textContainer
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let visibleHeight = lyricsTextView.bounds.height
        let targetOffset = max(min(rect.origin.y - visibleHeight * 0.3, lyricsTextView.contentSize.height - visibleHeight), 0)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.lyricsTextView.contentOffset.y = targetOffset
        }
    }
    
    private func displayNoLyricsFound() {
        lyricsTextView.text = "Lyrics not available for this song.\n\nWe couldn't find lyrics for \"\(currentSong?.title ?? "")\" by \(currentSong?.artist ?? "")."
        lyricsTextView.textAlignment = .center
        lyricsTextView.textColor = .white
        lyricsTextView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    // MARK: - Progress Animation
    private func startProgressAnimation() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateProgress() {
        guard isPlaying else { return }
        let incrementPerFrame = 1.0 / (60.0 * totalSongDuration) // 60 FPS
        progress += Float(incrementPerFrame)
        if progress > 1.0 { progress = 1.0; displayLink?.invalidate() }
        progressFillWidthConstraint?.constant = progressContainer.frame.width * CGFloat(progress)
        updateTimeLabels()
        updateLyricsHighlight()
        self.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func closeTapped() { dismiss() }
    @objc private func playPauseTapped() {
        isPlaying.toggle()
        playPauseButton.isSelected = !isPlaying
        if isPlaying { startProgressAnimation() } else { displayLink?.invalidate() }
    }
}
