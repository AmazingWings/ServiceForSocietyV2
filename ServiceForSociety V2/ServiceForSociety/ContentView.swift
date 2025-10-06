import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var favorites: Set<UUID> = []
    @State private var selectedRadius: Double = 100.0
    
    var body: some View {
        TabView {
            MapView(
                locationManager: locationManager,
                favorites: $favorites,
                selectedRadius: $selectedRadius
            )
            .tabItem {
                Image(systemName: "map.fill")
                Text("Map")
            }
            
            FavoritesView(favorites: $favorites)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
            
            // Volunteering opportunities
            VolunteeringView()
                .tabItem {
                    Image(systemName: "hands.sparkles.fill")
                    Text("Volunteer")
                }
            // Account
            Account()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Account")
                }
        }
        .accentColor(ColorTheme.primaryGreen)
        .background(ColorTheme.backgroundGradient)
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}

#Preview {
    ContentView()
}
