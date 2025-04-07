### Project Overview  
A dream journal app where users can log dreams, visions, and aspirations in a visual gallery powered by Vertex AI or Replicate AI. The app offers a seamless, intuitive interface for capturing and organizing dream entries with AI-generated imagery.  

### Tech Stack
- **Framework: SwiftUI
- **Language: Swift 6
- **Navigation: NavigationStack
- **UI Library: Native SwiftUI Components
- **Backend/Auth: Apple Sign In & CloudKit 
- **Image storage: Firebase

Deployment: TestFlight / App Store

### Feature List  

#### **Dream Entry Creation**  
- Form for text input (title, description, tags, user uploaded image) 
- Date picker for dream logging.  
- Save drafts locally for offline use.  

#### **AI Image Generation**  
- Integration with Vertex AI/Replicate AI for dream visualization.  
- Fetch and display AI-generated images based on dream text.  
- Option to regenerate or refine images.  

#### **Visual Gallery**  
- Grid/list view of dream entries with thumbnails.  
- Infinite scroll for pagination.  
- Swipe gestures to delete/archive entries.  

#### **Dream Details & Editing**  
- Full-screen view with dream text and AI-generated image.  
- Edit/update existing entries with version history.  
- Share option (text/image) via native sharing dialog.  

#### **Search & Filtering**  
- Full-text search across dream entries.  
- Filter by tags, dates, or moods.  
- Bookmark favorite entries.  

#### **Offline Support**  
- Local SQLite storage for offline access.  
- Sync with Firebase when online.  
- Conflict resolution for edited entries.  

#### **Settings & Preferences**  
- Toggle dark/light mode.  
- Adjust AI image generation settings.  
- Export data (JSON/PDF).  

#### **Push Notifications**  
- Daily reminders to log dreams.  
- Notify about new AI-generated visuals.  
- Configure notification preferences.  

#### **Deployment**  
- Test Flight

Each feature is optimized for mobile UX, including touch gestures, smooth navigation, and offline resilience.