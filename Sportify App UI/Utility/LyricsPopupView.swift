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
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        textView.bounces = true
        textView.alwaysBounceVertical = true
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
        label.text = "0:00"
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
    
    private func setBackgroundColorFromSongImage(_ song: Song) {
        DispatchQueue.global(qos: .background).async {
            var dominantColor: UIColor = .darkGray
            if let image = UIImage(named: song.imageName) {
                if let color = image.dominantColor() ?? image.averageColor() {
                    dominantColor = color
                }
            } else if let url = URL(string: song.imageName),
                      let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) {
                if let color = image.dominantColor() ?? image.averageColor() {
                    dominantColor = color
                }
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0) {
                    self.backgroundView.backgroundColor = dominantColor
                }
            }
        }
    }

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
    private var totalSongDuration: TimeInterval = 0.0 
    private var lastScrollLineIndex = -1
    private var animationStartTime: TimeInterval = 0.0
    private var elapsedTime: TimeInterval = 0.0
    
    private var progressFillWidthConstraint: NSLayoutConstraint?
    private var progressDotCenterXConstraint: NSLayoutConstraint?
    
    var dismissHandler: (() -> Void)?
    weak var parentViewController: UIViewController?
    
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
        updateTimeLabels()
        loadLyrics(for: song)
        setBackgroundColorFromSongImage(song)
    }
    
    private func updateTimeLabels() {
        currentTimeLabel.text = formatTime(elapsedTime)
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
    
    // MARK: - Display and Prepare Lyrics
    private func displayLyricsWithLetterByLetterHighlighting(_ lyrics: String) {
        let formattedLyrics = lyrics.replacingOccurrences(of: "\r\n", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = formattedLyrics.components(separatedBy: "\n").filter { !$0.isEmpty }

        let totalLines = lines.count
        let totalDesiredDuration: TimeInterval = Double(totalLines) * 6.0
        let lineGap: TimeInterval = 0.2
        let baseLineDuration = (totalDesiredDuration / Double(totalLines)) - lineGap

        lyricsData = []
        var currentTime: TimeInterval = 0.9

        for line in lines {
            let letters = parseLettersFromLine(line, lineStartTime: currentTime, lineDuration: baseLineDuration)
            let lyricLine = LyricLine(time: currentTime, text: line, letters: letters)
            lyricsData.append(lyricLine)
            currentTime += baseLineDuration + lineGap
        }

        if let lastLine = lyricsData.last {
            totalSongDuration = lastLine.time + baseLineDuration + lineGap
        }


        DispatchQueue.main.async {
            self.progress = 0
            self.progressFillWidthConstraint?.constant = 0
            self.updateTimeLabels()
            if self.isPlaying {
                self.startProgressAnimation()
            }
        }
    }

    
    private func parseLettersFromLine(_ line: String, lineStartTime: TimeInterval, lineDuration: TimeInterval) -> [LyricLetter] {
        
        let cleanedLine = line.replacingOccurrences(of: " +", with: " ", options: .regularExpression)
        let characters = Array(cleanedLine)
        
        var lyricLetters: [LyricLetter] = []
        
        let baseLetterDuration: TimeInterval = 0.35
        _ = Double(characters.count) * baseLetterDuration
        
        let actualLetterDuration = min(baseLetterDuration, lineDuration / Double(characters.count))
        
        var currentTime = lineStartTime
        
        for character in characters {
            let charString = String(character)
            let lyricLetter = LyricLetter(character: charString, startTime: currentTime, duration: actualLetterDuration)
            lyricLetters.append(lyricLetter)
            currentTime += actualLetterDuration
        }
        
        return lyricLetters
    }
    
    private func updateLyricsHighlight() {
        guard !lyricsData.isEmpty else { return }

        let highlightDelay: TimeInterval = 2.5
        let adjustedTime = max(0, elapsedTime - highlightDelay)

        let attributedText = NSMutableAttributedString()
        var currentLineIndex = -1

        for (lineIndex, line) in lyricsData.enumerated() {
            let isLineActive = adjustedTime >= line.time
            let lineAttributedString = createHighlightedLineString(line: line, currentTime: adjustedTime)
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
        
        for letter in line.letters {
            let isLetterHighlighted = currentTime >= letter.startTime && currentTime <= letter.startTime + letter.duration
            let isLetterCompleted = currentTime > letter.startTime + letter.duration
            
            let letterAttributes: [NSAttributedString.Key: Any]
            
            let font = UIFont.systemFont(ofSize: 22, weight: .regular)

            if isLetterHighlighted {
                letterAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: font
                ]
            } else if isLetterCompleted {
                letterAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: font
                ]
            } else {
                letterAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.4),
                    .font: font
                ]
            }

            
            let letterString = NSAttributedString(string: letter.character, attributes: letterAttributes)
            lineAttributedString.append(letterString)
        }
        
        return lineAttributedString
    }
    
    // FIXED SCROLL METHOD - More precise and slower scrolling
    private func scrollToLine(_ lineIndex: Int) {
        guard lineIndex < lyricsData.count else { return }
        
        // Ensure the text view has laid out its content
        lyricsTextView.layoutIfNeeded()
        
        // Calculate the character position of the target line
        var characterPosition = 0
        for (index, line) in lyricsData.enumerated() {
            if index == lineIndex {
                break
            }
            characterPosition += line.text.count + 2 // +2 for the "\n\n"
        }
        
        // Get the text container and layout manager
        let layoutManager = lyricsTextView.layoutManager
        let textContainer = lyricsTextView.textContainer
        
        // Get the glyph range for the target line
        let characterRange = NSRange(location: characterPosition, length: lyricsData[lineIndex].text.count)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        
        // Get the bounding rect of the target line
        let lineRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // Calculate target offset to center the line in the visible area
        let targetOffset = max(0, lineRect.midY - lyricsTextView.bounds.height / 2)
        
        // Ensure we don't scroll beyond content
        let maxOffset = max(0, lyricsTextView.contentSize.height - lyricsTextView.bounds.height)
        let clampedOffset = min(targetOffset, maxOffset)
        
        // Use slower animation with better curve
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.lyricsTextView.contentOffset.y = clampedOffset
        }
    }

    // Alternative simpler method if you want even smoother scrolling
    private func scrollToLineSmooth(_ lineIndex: Int) {
        guard lineIndex < lyricsData.count else { return }
        
        lyricsTextView.layoutIfNeeded()
        
        // Use more realistic line height calculation
        let lineHeight: CGFloat = 45 // Increased for better spacing
        let lineSpacing: CGFloat = 25 // Increased spacing
        
        // Calculate target position with slower progression
        let targetOffset = CGFloat(lineIndex) * (lineHeight + lineSpacing)
        
        // Ensure we don't scroll beyond content
        let maxOffset = max(0, lyricsTextView.contentSize.height - lyricsTextView.bounds.height)
        let clampedOffset = min(max(0, targetOffset), maxOffset)
        
        // Slower animation with spring effect
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.lyricsTextView.contentOffset.y = clampedOffset
        }
    }

    // Even simpler method for very smooth scrolling
    private func scrollToLineSimple(_ lineIndex: Int) {
        guard lineIndex < lyricsData.count else { return }
        
        lyricsTextView.layoutIfNeeded()
        
        // Calculate based on actual content height divided by number of lines
        let averageLineHeight = lyricsTextView.contentSize.height / CGFloat(max(lyricsData.count, 1))
        let targetOffset = CGFloat(lineIndex) * averageLineHeight
        
        let maxOffset = max(0, lyricsTextView.contentSize.height - lyricsTextView.bounds.height)
        let clampedOffset = min(max(0, targetOffset), maxOffset)
        
        // Smooth linear animation
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveLinear, .allowUserInteraction]) {
            self.lyricsTextView.contentOffset.y = clampedOffset
        }
    }
    
    private func displayNoLyricsFound() {
        lyricsTextView.text = "Lyrics not available for this song.\n\nWe couldn't find lyrics for \"\(currentSong?.title ?? "")\" by \(currentSong?.artist ?? "")."
        lyricsTextView.textAlignment = .center
        lyricsTextView.textColor = .white
        lyricsTextView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Set a default duration when no lyrics are found
        totalSongDuration = 180.0
        updateTimeLabels()
    }
    
    // MARK: - Progress Animation
    private func resetProgress() {
        progress = 0.0
        elapsedTime = 0.0
        animationStartTime = Date().timeIntervalSinceReferenceDate
        progressFillWidthConstraint?.constant = 0
        updateTimeLabels()
    }
    
    private func startProgressAnimation() {
        displayLink?.invalidate()
        animationStartTime = Date().timeIntervalSinceReferenceDate - elapsedTime
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateProgress() {
        guard isPlaying else { return }

        // Calculate elapsed time based on actual time passed
        let currentTime = Date().timeIntervalSinceReferenceDate
        elapsedTime = currentTime - animationStartTime
        
        // Calculate progress based on elapsed time and total duration
        if totalSongDuration > 0 {
            progress = Float(elapsedTime / totalSongDuration)
        } else {
            progress = 0.0
        }

        // Check if we've reached the end
        if elapsedTime >= totalSongDuration {
            elapsedTime = totalSongDuration
            progress = 1.0
            displayLink?.invalidate()
            isPlaying = false
            playPauseButton.isSelected = true
        }

        // Update progress bar position
        progressFillWidthConstraint?.constant = progressContainer.frame.width * CGFloat(progress)
        progressDotCenterXConstraint?.isActive = true

        // Update time labels
        updateTimeLabels()

        // Update lyrics highlighting
        updateLyricsHighlight()
        
        self.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func closeTapped() { dismiss() }
    
    @objc private func playPauseTapped() {
        isPlaying.toggle()
        playPauseButton.isSelected = !isPlaying
        if isPlaying {
            startProgressAnimation()
        } else {
            displayLink?.invalidate()
        }
    }
    
}
