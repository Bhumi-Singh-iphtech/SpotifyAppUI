    // MARK: - Lyric Data Structure
    import Foundation
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
