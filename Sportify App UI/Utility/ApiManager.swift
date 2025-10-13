import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}

    func fetchSongs(for artist: String, completion: @escaping ([Song]) -> Void) {
        let searchTerm = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
        let urlString = "https://itunes.apple.com/search?term=\(searchTerm)&entity=song&limit=50"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(ITunesResponse.self, from: data)
                
                // Map to Song model
                var songs = response.results.map {
                    Song(
                        title: $0.trackName,
                        artist: $0.artistName,
                        imageName: $0.artworkUrl100,
                        previewUrl: $0.previewUrl ?? ""
                    )
                }
                
                // Remove duplicates by imageName
                var uniqueImages = Set<String>()
                songs = songs.filter { song in
                    guard !uniqueImages.contains(song.imageName) else { return false }
                    uniqueImages.insert(song.imageName)
                    return true
                }
                
                // Limit to first 5 unique songs
                songs = Array(songs.prefix(8))
                
                DispatchQueue.main.async {
                    completion(songs)
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}
