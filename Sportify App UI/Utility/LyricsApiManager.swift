import Foundation
// MARK: - Lyrics API Manager
class LyricsAPIManager {
    static let shared = LyricsAPIManager()
    
    private let geniusToken = "4bSmrqYy4di5NL1CvCmJ8In9jet92ODlyeGba_HOAUru-8t_Wb4g5W17bUIUnt4-"
    private let baseURL = "https://api.genius.com"
    
    // Main method to fetch lyrics with fallback
    func fetchLyrics(artist: String, title: String, completion: @escaping (String?) -> Void) {
        // Try Genius first, then fallback to lyrics.ovh
        fetchFromGenius(artist: artist, title: title) { geniusLyrics in
            if let geniusLyrics = geniusLyrics, !geniusLyrics.isEmpty {
                completion(geniusLyrics)
            } else {
                self.fetchFromLyricsOvh(artist: artist, title: title, completion: completion)
            }
        }
    }
    
    // Fetch from Genius API
    private func fetchFromGenius(artist: String, title: String, completion: @escaping (String?) -> Void) {
        let searchQuery = "\(artist) \(title)"
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "feat.", with: "")
            .replacingOccurrences(of: "ft.", with: "")
        
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let urlString = "\(baseURL)/search?q=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(geniusToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(nil)
                    return
                }
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(GeniusSearchResponse.self, from: data)
                
                guard let hits = searchResponse.response?.hits, !hits.isEmpty else {
                    completion(nil)
                    return
                }
                
                if let bestHit = self.findBestMatch(hits: hits, artist: artist, title: title) {
                    self.fetchLyricsFromGeniusPage(path: bestHit.result.path, completion: completion)
                } else {
                    completion(nil)
                }
                
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    // Find the best matching song from search results
    private func findBestMatch(hits: [GeniusHit], artist: String, title: String) -> GeniusHit? {
        let artistLower = artist.lowercased()
        let titleLower = title.lowercased()
        
        for hit in hits {
            let hitArtist = hit.result.primary_artist.name.lowercased()
            let hitTitle = hit.result.title.lowercased()
            
            // Exact match
            if hitArtist.contains(artistLower) && hitTitle.contains(titleLower) {
                return hit
            }
        }
        
        // Return first result if no exact match
        return hits.first
    }
    
    // Fetch lyrics from Genius web page
    private func fetchLyricsFromGeniusPage(path: String, completion: @escaping (String?) -> Void) {
        let fullURL = "https://genius.com\(path)"
        
        guard let url = URL(string: fullURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            let lyrics = self.extractLyricsFromHTML(html)
            
            if let lyrics = lyrics, !lyrics.isEmpty {
                completion(lyrics)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    // Extract lyrics from Genius HTML (cleaned)
    private func extractLyricsFromHTML(_ html: String) -> String? {
        let patterns = [
            #"<div[^>]*data-lyrics-container="true"[^>]*>(.*?)</div>"#,
            #"<div[^>]*class="[^"]*Lyrics__Container[^"]*"[^>]*>(.*?)</div>"#
        ]
        
        var extractedLyrics = ""
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
                let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
                
                for match in matches {
                    guard match.numberOfRanges > 1,
                          let range = Range(match.range(at: 1), in: html) else { continue }
                    
                    var lyricChunk = String(html[range])
                    
                    // Replace <br> with newlines
                    lyricChunk = lyricChunk.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
                    
                    // Remove all other HTML tags
                    lyricChunk = lyricChunk.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    
                    // Decode HTML entities
                    lyricChunk = lyricChunk
                        .replacingOccurrences(of: "&amp;", with: "&")
                        .replacingOccurrences(of: "&quot;", with: "\"")
                        .replacingOccurrences(of: "&#x27;", with: "'")
                        .replacingOccurrences(of: "&nbsp;", with: " ")
                    
                    // Remove annotations in brackets []
                    lyricChunk = lyricChunk.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
                    
                    // Split lines, filter empty or unwanted lines
                    let lines = lyricChunk
                        .components(separatedBy: "\n")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty && !$0.lowercased().contains("contributor") && !$0.lowercased().contains("embed") }
                    
                    if !lines.isEmpty {
                        extractedLyrics += lines.joined(separator: "\n") + "\n\n"
                    }
                }
                
            } catch {
                continue
            }
        }
        
        // Trim any leading/trailing whitespace/newlines
        return extractedLyrics.isEmpty ? nil : extractedLyrics.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Fallback: Fetch from lyrics.ovh
    private func fetchFromLyricsOvh(artist: String, title: String, completion: @escaping (String?) -> Void) {
        guard let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let urlString = "https://api.lyrics.ovh/v1/\(encodedArtist)/\(encodedTitle)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let lyricsResponse = try JSONDecoder().decode(LyricsOvhResponse.self, from: data)
                if let lyrics = lyricsResponse.lyrics, !lyrics.isEmpty {
                    completion(lyrics)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    // Convenience method for Song object
    func fetchLyricsForSong(_ song: Song, completion: @escaping (String?) -> Void) {
        fetchLyrics(artist: song.artist, title: song.title, completion: completion)
    }
}
