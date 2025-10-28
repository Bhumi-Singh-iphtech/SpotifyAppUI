# Spotify App UI

## Introduction  
A modern and elegant Spotify-style Music App interface built using **Swift** and **Xcode**, demonstrating a clean music experience with synchronized lyrics, smooth animations, and dynamic color theming.  

This project replicates key features of Spotify’s interface including a **Landing screen**, **Home screen**, **Album details**, **Lyrics view**, **Mini Player**, and **Liked Songs** section.

---

## Screens Included  
- **Landing Screen**: Welcome interface before the user enters the app.  
- **Home Screen**: Displays playlists, albums, and quick access buttons.  
- **Album Detail Screen**: Shows album artwork, song list, and song options.  
- **Lyrics Screen**: Displays real-time synced lyrics with dynamic colors.  
- **Mini Player View**: Floating music control adapting to song colors.  
- **Liked Songs Screen**: Lists all user-liked songs with total count.

---

## Features  

### Landing Screen  
- Acts as the entry point of the app.  
- Displays the Spotify logo and smooth transition animation.  
- Leads to the Home Screen via navigation controller.  

---

### Home Screen  
- Buttons for **All Music**, **Podcasts**, and **User Profile**  
- Displays recent albums and trending playlists  
- Integrated **Search bar** and navigation functionality  
- **Tab Bar** with Home, Item, Library, Liked Songs, and Create  

---

### Album Detail Screen  
- Dynamic header animation with album artwork and title  
- Scrollable list of songs with smooth transition effects  
- **Song Options Bottom Sheet** displaying:  
  - Play Song  
  - Like / Unlike  
  - Add to Playlist  
  - Share Song  
- Songs fetched dynamically using the **iTunes API** and **Genius API** for metadata  

---

### Lyrics Screen  
- Lyrics fetched dynamically from the **Lyrics.ovh API** and **Genius API**  
- Real-time line-by-line highlighting synced with playback  
- Dynamic background color generated from the current song’s album artwork  
- Auto-scroll animation and smooth fading between lines  
- Optimized performance for seamless lyric updates  

---

### Liked Songs Feature  
- Allows users to like songs from the Album or Mini Player view  
- All liked songs are displayed in a dedicated **LikedSongsViewController**  
- Shows total liked songs count at the top  
- Provides quick access to play or remove songs from favorites  
- Uses local persistence to retain liked songs between app sessions  

---

### Mini Player View  
- Floating bottom player visible across all main screens  
- Displays current song name and artist with Play/Pause and Next/Previous buttons  
- Dynamic color theme automatically changes based on the album artwork  
- Tapping the Mini Player expands it to a full-screen player or lyrics view  

---

### API Integration  
- **iTunes API** → Fetches song details, album info, and media preview  
- **Genius API** → Fetches song metadata and lyrics when available  
- **Lyrics.ovh API** → Fetches synchronized lyrics for playback  
- Includes proper error handling and fallback behavior for missing data  

---

### Navigation  
- **UINavigationController** for managing screen transitions  
- **UITabBarController** for main app navigation  
- Custom modal transition for the Song Options Bottom Sheet  

---


## Prerequisites  
- Xcode 12.0 or later  
- iOS 14.0 or later  
- Swift 5.0 or later  

---

## License  
This project is open source.

---

## Contributing  
Contributions are welcome.  
If you find any issues or have suggestions for improvement, please submit an issue or create a pull request.

---

## Support  
If you encounter any problems or have questions, please contact the project maintainer at **[email protected]**.

---

## Acknowledgements  
Thanks to the **Apple Developer Community** for their frameworks and documentation,  
which greatly facilitated the development of this project.

---

## Screenshots
<div style="display: flex; gap: 10px;">

  <img src="https://github.com/user-attachments/assets/6547914a-1b25-487b-9b8b-6f11e5d9ea08" width="250" alt="Home Screen">
  <img src="https://github.com/user-attachments/assets/e8be1a3e-4e46-4009-bac2-abb74553e017" width="250" alt="Album Detail Screen">
  <img src="https://github.com/user-attachments/assets/1493a6e7-4d37-47ed-8eba-ec002ac84674" width="250" alt="Lyrics Screen">

</div>


---

## Demo Video  

[🎬 Watch Full Demo on ScreenPal](https://go.screenpal.com/watch/cT6u1InFcxM)

---
