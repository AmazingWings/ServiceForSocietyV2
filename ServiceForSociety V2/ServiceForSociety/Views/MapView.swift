import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var favorites: Set<UUID>
    @Binding var selectedRadius: Double
    
    // Use the renamed service to avoid conflicts
    @StateObject private var donationService = DynamicDonationCenterService.shared
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Geographic center of USA
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 12.0) // More focused regional view
    )
    
    @State private var selectedCenter: DonationCenter?
    @State private var showingFilters = false
    @State private var selectedTypes: Set<CenterType> = Set(CenterType.allCases)
    
    private let radiusOptions: [Double] = [2, 5, 10, 15, 25, 50, 100]
    
    // Updated filtered centers to use dynamic data
    var filteredCenters: [DonationCenter] {
        let filtered = donationService.donationCenters.filter { center in
            // Filter by type
            return selectedTypes.contains(center.type)
        }
        
        // Additional radius filtering if needed (service already handles basic radius)
        if let userLocation = locationManager.location, selectedRadius < 25 {
            return filtered.filter { center in
                let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
                let distance = userLocation.distance(from: centerLocation) / 1609.34 // Convert to miles
                return distance <= selectedRadius
            }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: filteredCenters) { center in
                MapAnnotation(coordinate: center.coordinate) {
                    DonationCenterMarker(
                        center: center,
                        isFavorite: favorites.contains(center.id)
                    ) {
                        selectedCenter = center
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(locationManager.$location) { location in
                // Auto-center on user location when first obtained and load donation centers
                if let location = location {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        )
                    }
                    
                    // Load donation centers for new location
                    loadDonationCenters(for: location)
                }
            }
            
            // Top controls
            VStack {
                HStack {
                    // Radius selector
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Radius")
                            .font(.caption)
                            .foregroundColor(ColorTheme.primaryText)
                        
                        Menu {
                            ForEach(radiusOptions, id: \.self) { radius in
                                Button("\(Int(radius)) miles") {
                                    selectedRadius = radius
                                    // Reload centers with new radius
                                    if let location = locationManager.location {
                                        loadDonationCenters(for: location, radius: radius)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(Int(selectedRadius)) mi")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(ColorTheme.primaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ColorTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(ColorTheme.primaryGreen, lineWidth: 1)
                            )
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    // Filter button
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title2)
                            .foregroundColor(ColorTheme.primaryGreen)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    
                    // My location button
                    Button {
                        if let userLocation = locationManager.location {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                region = MKCoordinateRegion(
                                    center: userLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            }
                            // Reload centers for current location
                            loadDonationCenters(for: userLocation)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(ColorTheme.primaryBlue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .padding(8)
                    }
                    
                    // Refresh button
                    Button {
                        if let userLocation = locationManager.location {
                            loadDonationCenters(for: userLocation)
                        }
                    } label: {
                        Image(systemName: donationService.isLoading ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                            .font(.title2)
                            .foregroundColor(ColorTheme.accent)
                            .background(Color.white)
                            .clipShape(Circle())
                            .padding(8)
                            .rotationEffect(.degrees(donationService.isLoading ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: donationService.isLoading)
                    }
                }
                .padding()
                
                // Loading indicator
                if donationService.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Finding donation centers...")
                            .font(.caption)
                            .foregroundColor(ColorTheme.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: ColorTheme.shadow, radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                // Bottom controls
                HStack {
                    Spacer()
                    
                    // Zoom controls
                    VStack(spacing: 8) {
                        // Zoom In
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                let newSpan = MKCoordinateSpan(
                                    latitudeDelta: max(region.span.latitudeDelta * 0.5, 0.001),
                                    longitudeDelta: max(region.span.longitudeDelta * 0.5, 0.001)
                                )
                                region = MKCoordinateRegion(center: region.center, span: newSpan)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(ColorTheme.primaryText)
                                .frame(width: 44, height: 44)
                                .background(ColorTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: ColorTheme.shadow, radius: 2, x: 0, y: 2)
                        }
                        
                        // Zoom Out
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                let newSpan = MKCoordinateSpan(
                                    latitudeDelta: min(region.span.latitudeDelta * 2.0, 180.0),
                                    longitudeDelta: min(region.span.longitudeDelta * 2.0, 360.0)
                                )
                                region = MKCoordinateRegion(center: region.center, span: newSpan)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.title3)
                                .foregroundColor(ColorTheme.primaryText)
                                .frame(width: 44, height: 44)
                                .background(ColorTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: ColorTheme.shadow, radius: 2, x: 0, y: 2)
                        }
                        
                        // Show USA button
                        Button {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                                    span: MKCoordinateSpan(latitudeDelta: 25.0, longitudeDelta: 35.0)
                                )
                            }
                        } label: {
                            Image(systemName: "globe.americas.fill")
                                .font(.title3)
                                .foregroundColor(ColorTheme.accent)
                                .frame(width: 44, height: 44)
                                .background(ColorTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: ColorTheme.shadow, radius: 2, x: 0, y: 2)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 100) // Account for tab bar
                }
            }
            
            // Error message
            if let errorMessage = donationService.errorMessage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding()
                    Spacer()
                }
            }
        }
        .navigationTitle("Service for Society")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load donation centers when view appears
            if let location = locationManager.location {
                loadDonationCenters(for: location)
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(selectedTypes: $selectedTypes)
        }
        .sheet(item: $selectedCenter) { center in
            DonationCenterDetailView(
                center: center,
                isFavorite: favorites.contains(center.id)
            ) { isFav in
                if isFav {
                    favorites.insert(center.id)
                } else {
                    favorites.remove(center.id)
                }
            }
        }
    }
    
    // Helper function to load donation centers
    private func loadDonationCenters(for location: CLLocation, radius: Double? = nil) {
        Task {
            await donationService.findDonationCenters(
                near: location,
                radius: radius ?? selectedRadius
            )
        }
    }
}

// MARK: - Supporting Views
struct DonationCenterMarker: View {
    let center: DonationCenter
    let isFavorite: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(ColorTheme.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(getColorForType(center.type), lineWidth: 3)
                    )
                
                Image(systemName: center.type.icon)
                    .foregroundColor(getColorForType(center.type))
                    .font(.system(size: 16, weight: .bold))
                
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(ColorTheme.success)
                        .font(.system(size: 12))
                        .offset(x: 15, y: -15)
                }
            }
        }
        .shadow(color: ColorTheme.shadow, radius: 3, x: 0, y: 2)
    }
    
    private func getColorForType(_ type: CenterType) -> Color {
        switch type {
        case .foodBank:
            return ColorTheme.primaryGreen
        case .homelessShelter:
            return ColorTheme.primaryBlue
        case .recyclingCenter:
            return ColorTheme.accent
        case .compostFacility:
            return ColorTheme.success
        }
    }
}

struct FilterView: View {
    @Binding var selectedTypes: Set<CenterType>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Filter by Type")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.primaryText)
                    .padding(.top)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(CenterType.allCases, id: \.self) { type in
                        FilterTypeCard(
                            type: type,
                            isSelected: selectedTypes.contains(type)
                        ) {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(ColorTheme.primaryGreen)
                .cornerRadius(12)
                .padding()
            }
            .background(ColorTheme.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FilterTypeCard: View {
    let type: CenterType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : getColorForType(type))
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ColorTheme.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? getColorForType(type) : ColorTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getColorForType(type), lineWidth: isSelected ? 0 : 2)
            )
            .cornerRadius(12)
            .shadow(color: ColorTheme.shadow, radius: isSelected ? 5 : 2, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
    
    private func getColorForType(_ type: CenterType) -> Color {
        switch type {
        case .foodBank:
            return ColorTheme.primaryGreen
        case .homelessShelter:
            return ColorTheme.primaryBlue
        case .recyclingCenter:
            return ColorTheme.accent
        case .compostFacility:
            return ColorTheme.success
        }
    }
}

struct DonationCenterDetailView: View {
    let center: DonationCenter
    let isFavorite: Bool
    let onFavoriteToggle: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: center.type.icon)
                                .font(.title)
                                .foregroundColor(getColorForType(center.type))
                            
                            VStack(alignment: .leading) {
                                Text(center.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(ColorTheme.primaryText)
                                
                                Text(center.type.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(ColorTheme.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button {
                                onFavoriteToggle(!isFavorite)
                            } label: {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(isFavorite ? ColorTheme.success : ColorTheme.secondaryText)
                            }
                        }
                        
                        Text(center.description)
                            .font(.body)
                            .foregroundColor(ColorTheme.secondaryText)
                    }
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(12)
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Information")
                            .font(.headline)
                            .foregroundColor(ColorTheme.primaryText)
                        
                        Label(center.address, systemImage: "location.fill")
                            .foregroundColor(ColorTheme.secondaryText)
                        
                        if let phone = center.phone {
                            Label(phone, systemImage: "phone.fill")
                                .foregroundColor(ColorTheme.secondaryText)
                        }
                        
                        if let website = center.website {
                            Label(website, systemImage: "globe")
                                .foregroundColor(ColorTheme.accent)
                        }
                        
                        Label(center.hours, systemImage: "clock.fill")
                            .foregroundColor(ColorTheme.secondaryText)
                    }
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(12)
                    
                    // Accepted Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Accepted Items")
                            .font(.headline)
                            .foregroundColor(ColorTheme.primaryText)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(center.acceptedItems, id: \.self) { item in
                                Text(item)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ColorTheme.lightGreen.opacity(0.3))
                                    .foregroundColor(ColorTheme.primaryText)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(ColorTheme.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.primaryGreen)
                }
            }
        }
    }
    
    private func getColorForType(_ type: CenterType) -> Color {
        switch type {
        case .foodBank:
            return ColorTheme.primaryGreen
        case .homelessShelter:
            return ColorTheme.primaryBlue
        case .recyclingCenter:
            return ColorTheme.accent
        case .compostFacility:
            return ColorTheme.success
        }
    }
}

#Preview {
    MapView(
        locationManager: LocationManager(),
        favorites: .constant(Set<UUID>()),
        selectedRadius: .constant(5.0)
    )
}
