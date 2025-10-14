

struct MusicDataManager {
    
    static let libraryItems: [LibraryItem] = [
        LibraryItem(title: "English Songs", imageName: "english song", totalDuration: "• 35 min"),
        LibraryItem(title: "Hindi Songs", imageName: "Top hindi songs", totalDuration: "• 35 min"),
        LibraryItem(title: "Workout", imageName: "Workout", totalDuration: "• 35 min"),
        LibraryItem(title: "Chill Vibes", imageName: "Chill Vibes", totalDuration: "• 35 min"),
        LibraryItem(title: "Focus Beats", imageName: "Focus music", totalDuration: "• 35 min"),
        LibraryItem(title: "Liked Songs", imageName: "liked-songs", totalDuration: "• 35 min")
    ]
    
    static let stations: [Station] = [
        Station(name: "Neha Kakkar",
                subtitle: "Neha Kakkar, Tony Kakkar, Guru Randhawa, Badshah, Meet Bros and more",
                imageName: "Neha Kakar",
                hexColor: "#F19AD2",
                totalDuration: "• 35 min"),
        
        Station(name: "Vishal Mishra",
                subtitle: "Vishal Mishra, Sachin-Jigar, Atif Aslam, Anuv Jain and more",
                imageName: "Vishal Mishra Radio",
                hexColor: "#FBD97D",
                totalDuration: "• 35 min"),
        
        Station(name: "Darshan Raval",
                subtitle: "Darshan Raval, Atif Aslam, Rochak Kohli and more",
                imageName: "Darshal Raval",
                hexColor: "#CFF66A",
                totalDuration: "• 35 min"),
        
        Station(name: "Atif Aslam",
                subtitle: "Atif Aslam, Pritam, Mithoon and more",
                imageName: "Atif Aslam",
                hexColor: "#95EFB5",
                totalDuration: "• 35 min"),
        
        Station(name: "Pritam Radio",
                subtitle: "Pritam, Mithoon",
                imageName: "Pritham Radio",
                hexColor: "#95EFB5",
                totalDuration: "• 35 min")
    ]
    
    static let topArtists: [Artist] = [
        Artist(name: "Arijit Singh", imageName: "arjit singh", totalDuration: "• 35 min"),
        Artist(name: "Neha Kakkar", imageName: "neha kakkar", totalDuration: "• 35 min"),
        Artist(name: "Badshah", imageName: "badshah", totalDuration: "• 35 min"),
        Artist(name: "Darshal Raval", imageName: "Darshal Raval-1", totalDuration: "• 35 min")
    ]
}
