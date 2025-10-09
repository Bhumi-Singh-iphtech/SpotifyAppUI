import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}

    func fetchSongs(for artist: String, completion: @escaping ([Song]) -> Void) {
        let searchTerm = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
        let urlString = "https://itunes.apple.com/search?term=\(searchTerm)&entity=song&limit=10"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(ITunesResponse.self, from: data)
                let songs = response.results.map {
                    Song(title: $0.trackName, artist: $0.artistName, imageName: $0.artworkUrl100)
                }
                DispatchQueue.main.async {
                    completion(songs)
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}
