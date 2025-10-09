struct ITunesResponse: Codable {
    let results: [ITunesSong]
}

struct ITunesSong: Codable {
    let trackName: String
    let artistName: String
    let artworkUrl100: String
}
