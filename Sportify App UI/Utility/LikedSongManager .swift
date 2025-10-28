class LikedSongsManager {
    static let shared = LikedSongsManager()
    private init() {}

    private(set) var likedSongs: [Song] = []

    func addSong(_ song: Song) {
        if !likedSongs.contains(where: { $0.title == song.title }) {
            likedSongs.append(song)
        }
    }

    func removeSong(_ song: Song) {
        likedSongs.removeAll { $0.title == song.title }
    }

    func isLiked(_ song: Song) -> Bool {
        return likedSongs.contains(where: { $0.title == song.title })
    }
}
