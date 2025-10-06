# Service for Society
## Food Waste & Donation Connector iOS App

A beautiful, functional iOS app that connects people with local food banks, homeless shelters, and recycling centers to reduce waste and help the community.

### 🌟 Features

#### ✅ **Core MVP Features Implemented:**
- **📱 User-Friendly Interface**: Clean green-blue environmental color theme
- **🗺️ Interactive Map View**: Google Maps-style interface with custom markers
- **📍 Location Services**: Finds nearby donation centers based on user location
- **📏 Radius Filtering**: Adjustable search radius (2, 5, 10, 15, 25, 50, 100 miles)
- **🔍 Zoom Controls**: Zoom in/out buttons plus "Show USA" for nationwide view
- **🎯 Smart Sorting**: Centers automatically sorted by distance (closest first)
- **❤️ Favorites System**: Save and manage favorite donation centers
- **🏷️ Smart Filtering**: Filter by center type (Food Banks, Shelters, Recycling, Compost)
- **📋 Detailed Information**: Complete center details including hours, contact info, and accepted items
- **🎨 Beautiful UI**: Consistent green-blue theme throughout

#### 🚀 **Future-Ready Features:**
- **🤖 AI Assistant Tab**: Placeholder ready for AI bot integration
- **💾 Persistent Storage**: Favorites are saved locally
- **📱 Native iOS Design**: SwiftUI with modern iOS design patterns

### 🎯 Target Users
- **Donors**: Restaurants, stores, households with excess food
- **Recipients**: People looking for food assistance or recycling options
- **Community Members**: Anyone wanting to contribute to sustainability

### 📱 App Structure

```
ServiceForSociety/
├── ServiceForSocietyApp.swift          # Main app entry point
├── ContentView.swift                   # Main tab view
├── Views/
│   ├── MapView.swift                   # Interactive map with markers
│   └── FavoritesView.swift            # Saved locations
├── Models/
│   └── DonationCenter.swift          # Data models and sample data
├── Services/
│   └── LocationManager.swift         # Location services
├── Utilities/
│   └── ColorTheme.swift              # App color scheme
└── Assets.xcassets/                   # App assets and icons
```

### 🏗️ Technical Details

#### **Built With:**
- **SwiftUI**: Modern declarative UI framework
- **MapKit**: Native iOS maps with custom annotations
- **Core Location**: GPS and location services
- **Combine**: Reactive programming for data flow

#### **Key Components:**

1. **MapView**: 
   - Interactive map with custom markers
   - Real-time location tracking
   - Radius-based filtering
   - Type-based filtering
   - Detailed center information sheets

2. **FavoritesView**:
   - Clean list of saved centers
   - Quick access to center details
   - Distance calculation from user location
   - Empty state with helpful onboarding

3. **LocationManager**:
   - Handles location permissions
   - Real-time location updates
   - Distance calculations

4. **ColorTheme**:
   - Consistent green-blue environmental colors
   - Light/dark mode support
   - Accessible color combinations

### 🎨 Design System

**Color Palette:**
- **Primary Green**: Teal green for food-related features
- **Primary Blue**: Ocean blue for shelter-related features
- **Accent**: Bright teal for recycling centers
- **Success**: Bright green for compost facilities
- **Background**: Subtle green-blue gradient

### 📊 Nationwide Sample Data

The app now includes **30 donation centers** across major US cities:

**🌎 Geographic Coverage:**
- **California**: San Francisco, Los Angeles
- **New York**: New York City, Brooklyn
- **Texas**: Houston
- **Illinois**: Chicago
- **Arizona**: Phoenix
- **Florida**: Miami/South Florida
- **Washington**: Seattle
- **Massachusetts**: Boston
- **Georgia**: Atlanta
- **North Carolina**: Charlotte, Raleigh, Greensboro, Durham, Winston-Salem

**🏢 Center Types:**
- **11 Food Banks** - Major food banks in each region
- **9 Homeless Shelters** - Emergency shelters and missions
- **3 Recycling Centers** - Community recycling facilities
- **7 Compost Facilities** - Organic waste processing

Each location includes:
- Realistic addresses and contact information
- Actual operating hours
- Comprehensive accepted items lists
- Precise GPS coordinates
- Detailed descriptions of services

### 🚀 Getting Started

1. **Open in Xcode**: Open `ServiceForSociety.xcodeproj` in Xcode
2. **Build & Run**: Select your target device/simulator and run
3. **Location Permission**: Grant location permission when prompted
4. **Explore**: Use the map to find nearby centers, save favorites, and explore features

### 📍 Location Features

- **Automatic Location**: Finds user's current location with smooth animation
- **Manual Search**: Pan the map to explore areas nationwide
- **Radius Control**: Adjust search radius from 2-100 miles for nationwide coverage
- **Zoom Controls**: Dedicated +/- buttons and "Show USA" for easy navigation
- **Smart Sorting**: Results automatically sorted by distance from your location
- **Smart Filtering**: Show only relevant center types
- **Nationwide Coverage**: Find centers from coast to coast, including North Carolina

### 💡 Future Enhancements

The app is structured to easily add:
- **AI Assistant**: Tab ready for ChatBot integration
- **Push Notifications**: Center hours, special events
- **User Accounts**: Personal donation history
- **Photo Upload**: Share donation photos
- **Reviews & Ratings**: Community feedback
- **Real-time Inventory**: What centers need most

### 🔧 Configuration

The app includes:
- **Bundle ID**: `com.serviceforsociety.app`
- **Deployment Target**: iOS 15.0+
- **Location Permission**: "When in Use" for finding nearby centers
- **MapKit**: Native iOS mapping

### 🎯 Next Steps

1. **Add Real Data**: Replace sample data with real donation centers
2. **Integrate APIs**: Connect to food bank and recycling databases
3. **AI Features**: Implement the AI assistant for guidance
4. **User Testing**: Gather feedback from community organizations
5. **App Store**: Prepare for App Store submission

---

**Built with ❤️ for the community**


