
struct GeniusSearchResponse: Codable {
    let response: GeniusResponse?
}

struct GeniusResponse: Codable {
    let hits: [GeniusHit]?
}

struct GeniusHit: Codable {
    let result: GeniusSongResult
}

struct GeniusSongResult: Codable {
    let title: String
    let primary_artist: GeniusArtist
    let path: String
    
    struct GeniusArtist: Codable {
        let name: String
    }
}

struct LyricsOvhResponse: Codable {
    let lyrics: String?
}
