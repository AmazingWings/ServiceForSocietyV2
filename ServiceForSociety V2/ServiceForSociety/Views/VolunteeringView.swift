import SwiftUI
import CoreLocation
import MapKit

struct VolunteeringView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedRadius: Double = 25.0
    @State private var selectedTypes: Set<OpportunityType> = Set(OpportunityType.allCases)
    @State private var selectedOpportunity: VolunteeringOpportunity?
    @State private var showingFilters = false
    @State private var showingAddOpportunity = false
    @State private var searchText: String = ""
    
    private let radiusOptions: [Double] = [5, 10, 15, 25, 50, 100]
    
    var filteredOpportunities: [VolunteeringOpportunity] {
        let typeFiltered = filterByType()
        let searchFiltered = applySearchFilter(to: typeFiltered)
        let distanceFiltered = applyDistanceFilter(to: searchFiltered)
        let sortedResults = applySorting(to: distanceFiltered)
        return sortedResults
    }
    
    private func filterByType() -> [VolunteeringOpportunity] {
        return VolunteeringOpportunity.sampleData.filter { opportunity in
            selectedTypes.contains(opportunity.type)
        }
    }
    
    private func applySearchFilter(to opportunities: [VolunteeringOpportunity]) -> [VolunteeringOpportunity] {
        guard !searchText.isEmpty else { return opportunities }
        
        let searchLower = searchText.lowercased()
        return opportunities.filter { opportunity in
            matchesSearchTerm(opportunity: opportunity, searchTerm: searchLower)
        }
    }
    
    private func matchesSearchTerm(opportunity: VolunteeringOpportunity, searchTerm: String) -> Bool {
        let titleMatch = opportunity.title.lowercased().contains(searchTerm)
        let orgMatch = opportunity.organization.lowercased().contains(searchTerm)
        let descMatch = opportunity.description.lowercased().contains(searchTerm)
        let typeMatch = opportunity.type.rawValue.lowercased().contains(searchTerm)
        return titleMatch || orgMatch || descMatch || typeMatch
    }
    
    private func applyDistanceFilter(to opportunities: [VolunteeringOpportunity]) -> [VolunteeringOpportunity] {
        let shouldApplyDistanceFilter = searchText.isEmpty && selectedRadius < 100
        guard shouldApplyDistanceFilter else { return opportunities }
        
        return opportunities.filter { opportunity in
            let distance = opportunity.distanceInMiles(from: locationManager.location)
            return distance <= selectedRadius
        }
    }
    
    private func applySorting(to opportunities: [VolunteeringOpportunity]) -> [VolunteeringOpportunity] {
        let hasLocationAndNotSearching = locationManager.location != nil && searchText.isEmpty
        
        if hasLocationAndNotSearching {
            return sortByDistance(opportunities, from: locationManager.location!)
        } else {
            return opportunities.sorted { $0.title < $1.title }
        }
    }
    
    private func sortByDistance(_ opportunities: [VolunteeringOpportunity], from userLocation: CLLocation) -> [VolunteeringOpportunity] {
        return opportunities.sorted { first, second in
            let firstDistance = first.distanceInMiles(from: userLocation)
            let secondDistance = second.distanceInMiles(from: userLocation)
            return firstDistance < secondDistance
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBarView
                mainContentView
            }
            .navigationTitle("Volunteer")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                locationManager.requestLocationPermission()
            }
            .sheet(item: $selectedOpportunity) { opportunity in
                VolunteeringDetailView(opportunity: opportunity)
            }
            .sheet(isPresented: $showingFilters) {
                VolunteeringFiltersView(selectedTypes: $selectedTypes)
            }
            .sheet(isPresented: $showingAddOpportunity) {
                AddOpportunityView()
            }
        }
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            searchTextField
            searchButton
            clearButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var searchTextField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField("Search events (e.g., food drive)", text: $searchText)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var searchButton: some View {
        Button("Search") {
            print("Search tapped: \(searchText)")
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.green)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if !searchText.isEmpty {
            Button("Clear") {
                searchText = ""
            }
            .font(.system(size: 14))
            .foregroundColor(.blue)
        }
    }
    
    private var mainContentView: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            if filteredOpportunities.isEmpty {
                EmptyVolunteeringView()
            } else {
                opportunitiesScrollView
            }
            
            floatingActionButton
        }
    }
    
    private var opportunitiesScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                controlsAndStatsView
                opportunityCards
            }
            .padding(.bottom, 100)
        }
    }
    
    private var controlsAndStatsView: some View {
        VStack(spacing: 16) {
            controlsRow
            statsRow
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var controlsRow: some View {
        HStack {
            radiusSelector
            Spacer()
            filtersButton
        }
    }
    
    private var radiusSelector: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Search Radius")
                .font(.caption)
                .foregroundColor(ColorTheme.primaryText)
            
            radiusMenu
        }
    }
    
    private var radiusMenu: some View {
        Menu {
            ForEach(radiusOptions, id: \.self) { radius in
                Button("\(Int(radius)) miles") {
                    selectedRadius = radius
                }
            }
        } label: {
            radiusLabel
        }
        .opacity(searchText.isEmpty ? 1.0 : 0.5)
        .disabled(!searchText.isEmpty)
    }
    
    private var radiusLabel: some View {
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
    
    private var filtersButton: some View {
        Button {
            showingFilters.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title2)
                .foregroundColor(ColorTheme.primaryGreen)
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 20) {
            StatBox(title: "Available", value: "\(filteredOpportunities.count)", icon: "hands.sparkles.fill")
            StatBox(title: "Ongoing", value: "\(getOngoingCount())", icon: "clock.fill")
            additionalStatBox
        }
    }
    
    private func getOngoingCount() -> String {
        let count = filteredOpportunities.filter { $0.isOngoing }.count
        return "\(count)"
    }
    
    @ViewBuilder
    private var additionalStatBox: some View {
        if let userLocation = locationManager.location, searchText.isEmpty {
            let nearbyCount = getNearbyCount(userLocation: userLocation)
            StatBox(title: "Nearby", value: "\(nearbyCount)", icon: "location.fill")
        } else if !searchText.isEmpty {
            StatBox(title: "Found", value: "\(filteredOpportunities.count)", icon: "magnifyingglass")
        }
    }
    
    private func getNearbyCount(userLocation: CLLocation) -> Int {
        return filteredOpportunities.filter { opportunity in
            opportunity.distanceInMiles(from: userLocation) <= 10
        }.count
    }
    
    private var opportunityCards: some View {
        ForEach(filteredOpportunities) { opportunity in
            VolunteeringCard(opportunity: opportunity, userLocation: locationManager.location) {
                selectedOpportunity = opportunity
            }
        }
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button {
                    showingAddOpportunity = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(ColorTheme.primaryGreen)
                        .clipShape(Circle())
                        .shadow(color: ColorTheme.shadow.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Address Search Helper
class AddressSearchManager: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var selectedAddress: String = ""
    
    private let completer = MKLocalSearchCompleter()
    private let localSearchRequest = MKLocalSearch.Request()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func searchAddress(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        completer.queryFragment = query
    }
    
    func selectAddress(_ completion: MKLocalSearchCompletion) {
        localSearchRequest.naturalLanguageQuery = completion.title + " " + completion.subtitle
        let search = MKLocalSearch(request: localSearchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response,
                  let firstResult = response.mapItems.first else {
                return
            }
            
            DispatchQueue.main.async {
                self.selectedCoordinate = firstResult.placemark.coordinate
                self.selectedAddress = completion.title + " " + completion.subtitle
                self.searchResults = []
            }
        }
    }
    
    func clearSearch() {
        searchResults = []
        selectedCoordinate = nil
        selectedAddress = ""
    }
}

extension AddressSearchManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Address search error: \(error.localizedDescription)")
    }
}

struct AddOpportunityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var addressSearchManager = AddressSearchManager()
    
    @State private var title: String = ""
    @State private var organization: String = ""
    @State private var selectedType: OpportunityType = .communityOutreach
    @State private var addressSearchText: String = ""
    @State private var description: String = ""
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var hoursNeeded: String = ""
    @State private var contactPhone: String = ""
    @State private var contactEmail: String = ""
    @State private var requirements: [String] = [""]
    @State private var showingDatePicker = false
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    @State private var showingMapPreview = false
    @State private var showingAddressAlert = false
    
    private var isFormValid: Bool {
        let hasTitle = !title.isEmpty
        let hasOrganization = !organization.isEmpty
        let hasValidAddress = addressSearchManager.selectedCoordinate != nil
        let hasDescription = !description.isEmpty
        let hasHours = !hoursNeeded.isEmpty
        
        return hasTitle && hasOrganization && hasValidAddress && hasDescription && hasHours
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                formScrollView
            }
            .navigationTitle("New Opportunity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
            }
            .sheet(isPresented: $showingStartTimePicker) {
                startTimePickerSheet
            }
            .sheet(isPresented: $showingEndTimePicker) {
                endTimePickerSheet
            }
            .sheet(isPresented: $showingMapPreview) {
                mapPreviewSheet
            }
            .alert("Invalid Address", isPresented: $showingAddressAlert) {
                Button("OK") { }
            } message: {
                Text("Please select a valid address from the search results.")
            }
        }
    }
    
    private var formScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                basicInformationSection
                addressSection
                dateTimeSection
                descriptionSection
                contactSection
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(ColorTheme.secondaryText)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                if isFormValid {
                    saveOpportunity()
                } else if addressSearchManager.selectedCoordinate == nil {
                    showingAddressAlert = true
                }
            }
            .foregroundColor(isFormValid ? ColorTheme.primaryGreen : ColorTheme.secondaryText)
            .disabled(!isFormValid)
        }
    }
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            VStack(spacing: 12) {
                CustomTextField(title: "Event Name", text: $title, placeholder: "Enter event name")
                CustomTextField(title: "Organization", text: $organization, placeholder: "Enter organization name")
                eventTypeSelector
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            VStack(spacing: 12) {
                addressSearchField
                
                if !addressSearchManager.searchResults.isEmpty {
                    addressSearchResults
                }
                
                if addressSearchManager.selectedCoordinate != nil {
                    selectedAddressView
                }
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var addressSearchField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Address")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(ColorTheme.primaryGreen)
                
                TextField("Search for address...", text: $addressSearchText)
                    .onChange(of: addressSearchText) { newValue in
                        addressSearchManager.searchAddress(newValue)
                    }
                
                if !addressSearchText.isEmpty {
                    Button(action: {
                        addressSearchText = ""
                        addressSearchManager.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var addressSearchResults: some View {
        VStack(spacing: 0) {
            ForEach(addressSearchManager.searchResults.prefix(5), id: \.self) { result in
                Button(action: {
                    addressSearchManager.selectAddress(result)
                    addressSearchText = result.title
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title)
                            .font(.body)
                            .foregroundColor(ColorTheme.primaryText)
                            .multilineTextAlignment(.leading)
                        
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundColor(ColorTheme.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(ColorTheme.cardBackground)
                }
                .buttonStyle(PlainButtonStyle())
                
                if result != addressSearchManager.searchResults.prefix(5).last {
                    Divider()
                }
            }
        }
        .background(ColorTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var selectedAddressView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ColorTheme.success)
                
                Text("Address Selected")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.success)
                
                Spacer()
                
                Button("Preview") {
                    showingMapPreview = true
                }
                .font(.caption)
                .foregroundColor(ColorTheme.primaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(ColorTheme.primaryGreen.opacity(0.1))
                .cornerRadius(6)
            }
            
            Text(addressSearchManager.selectedAddress)
                .font(.caption)
                .foregroundColor(ColorTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
        }
        .padding()
        .background(ColorTheme.success.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var mapPreviewSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let coordinate = addressSearchManager.selectedCoordinate {
                    Map(coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ), annotationItems: [MapAnnotation(coordinate: coordinate)]) { annotation in
                        MapPin(coordinate: annotation.coordinate, tint: .red)
                    }
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Location")
                            .font(.headline)
                            .foregroundColor(ColorTheme.primaryText)
                        
                        Text(addressSearchManager.selectedAddress)
                            .font(.body)
                            .foregroundColor(ColorTheme.secondaryText)
                        
                        Text("Latitude: \(coordinate.latitude, specifier: "%.6f")")
                            .font(.caption)
                            .foregroundColor(ColorTheme.secondaryText)
                        
                        Text("Longitude: \(coordinate.longitude, specifier: "%.6f")")
                            .font(.caption)
                            .foregroundColor(ColorTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(ColorTheme.cardBackground)
                    
                    Spacer()
                }
            }
            .navigationTitle("Location Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingMapPreview = false
                    }
                    .foregroundColor(ColorTheme.primaryGreen)
                }
            }
        }
    }
    
    struct MapAnnotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
    
    private var eventTypeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Type")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            Menu {
                ForEach(OpportunityType.allCases, id: \.self) { type in
                    Button(type.rawValue) {
                        selectedType = type
                    }
                }
            } label: {
                eventTypeLabel
            }
        }
    }
    
    private var eventTypeLabel: some View {
        HStack {
            Text(selectedType.rawValue)
                .foregroundColor(ColorTheme.primaryText)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(ColorTheme.secondaryText)
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date & Time")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            VStack(spacing: 12) {
                dateSelector
                timeSelectors
                CustomTextField(title: "Hours Needed", text: $hoursNeeded, placeholder: "e.g., 2-4 hours")
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            Button {
                showingDatePicker.toggle()
            } label: {
                dateSelectorLabel
            }
        }
    }
    
    private var dateSelectorLabel: some View {
        HStack {
            Text(selectedDate, style: .date)
                .foregroundColor(ColorTheme.primaryText)
            Spacer()
            Image(systemName: "calendar")
                .foregroundColor(ColorTheme.primaryGreen)
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var timeSelectors: some View {
        HStack(spacing: 12) {
            startTimeSelector
            endTimeSelector
        }
    }
    
    private var startTimeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Start Time")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            Button {
                showingStartTimePicker.toggle()
            } label: {
                timeSelectorLabel(time: startTime)
            }
        }
    }
    
    private var endTimeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("End Time")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            Button {
                showingEndTimePicker.toggle()
            } label: {
                timeSelectorLabel(time: endTime)
            }
        }
    }
    
    private func timeSelectorLabel(time: Date) -> some View {
        HStack {
            Text(time, style: .time)
                .foregroundColor(ColorTheme.primaryText)
            Spacer()
            Image(systemName: "clock")
                .foregroundColor(ColorTheme.primaryGreen)
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Description & Details")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            descriptionEditor
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var descriptionEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            TextEditor(text: $description)
                .frame(minHeight: 100)
                .padding(8)
                .background(ColorTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                )
            
            if description.isEmpty {
                Text("Describe what volunteers will be doing...")
                    .font(.caption)
                    .foregroundColor(ColorTheme.secondaryText)
                    .padding(.leading, 8)
            }
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            VStack(spacing: 12) {
                CustomTextField(title: "Phone Number", text: $contactPhone, placeholder: "Enter phone number")
                CustomTextField(title: "Email", text: $contactEmail, placeholder: "Enter email address")
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                        .foregroundColor(ColorTheme.primaryGreen)
                    }
                }
        }
    }
    
    private var startTimePickerSheet: some View {
        NavigationView {
            DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                .navigationTitle("Start Time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingStartTimePicker = false
                        }
                        .foregroundColor(ColorTheme.primaryGreen)
                    }
                }
        }
    }
    
    private var endTimePickerSheet: some View {
        NavigationView {
            DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                .navigationTitle("End Time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingEndTimePicker = false
                        }
                        .foregroundColor(ColorTheme.primaryGreen)
                    }
                }
        }
    }
    
    private func saveOpportunity() {
        guard let coordinate = addressSearchManager.selectedCoordinate else {
            showingAddressAlert = true
            return
        }
        
        let newOpportunity = VolunteeringOpportunity.create(
            title: title,
            organization: organization,
            description: description,
            type: selectedType,
            address: addressSearchManager.selectedAddress,
            coordinate: coordinate,
            timeCommitment: hoursNeeded,
            requirements: requirements.filter { !$0.isEmpty },
            contactEmail: contactEmail.isEmpty ? nil : contactEmail,
            contactPhone: contactPhone.isEmpty ? nil : contactPhone,
            isOngoing: true,
            startDate: selectedDate,
            endDate: endTime > startTime ? endTime : nil
        )
        
        print("Saving opportunity:")
        print("Title: \(newOpportunity.title)")
        print("Organization: \(newOpportunity.organization)")
        print("Address: \(newOpportunity.address)")
        print("Coordinates: \(coordinate.latitude), \(coordinate.longitude)")
        print("Type: \(newOpportunity.type.rawValue)")
        
        // Here you would typically save to your data store
        // For now, we'll just dismiss
        dismiss()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryText)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(ColorTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct EmptyVolunteeringView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hands.sparkles")
                .font(.system(size: 80))
                .foregroundColor(ColorTheme.secondaryText)
            
            emptyStateText
            featureIcons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateText: some View {
        VStack(spacing: 12) {
            Text("No Opportunities Found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.primaryText)
            
            Text("Try expanding your search radius or changing your location filters to find volunteer opportunities near you.")
                .font(.body)
                .foregroundColor(ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var featureIcons: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FeatureIcon(icon: "hands.sparkles.fill", color: ColorTheme.primaryGreen, text: "Food Service")
                FeatureIcon(icon: "heart.circle.fill", color: ColorTheme.primaryBlue, text: "Shelter Support")
            }
            
            HStack(spacing: 16) {
                FeatureIcon(icon: "leaf.arrow.circlepath", color: ColorTheme.success, text: "Environmental")
                FeatureIcon(icon: "person.3.fill", color: ColorTheme.accent, text: "Community")
            }
        }
        .padding(.horizontal, 20)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(ColorTheme.primaryGreen)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.primaryText)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(ColorTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(ColorTheme.cardBackground)
        .cornerRadius(8)
    }
}

struct VolunteeringCard: View {
    let opportunity: VolunteeringOpportunity
    let userLocation: CLLocation?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                cardHeader
                organizationInfo
                descriptionText
                footerInfo
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: ColorTheme.shadow, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var cardHeader: some View {
        HStack {
            HStack(spacing: 12) {
                opportunityIcon
                opportunityTitleInfo
                Spacer()
            }
            
            if opportunity.isOngoing {
                ongoingIndicator
            }
        }
    }
    
    private var opportunityIcon: some View {
        Image(systemName: opportunity.type.icon)
            .font(.title2)
            .foregroundColor(getColorForOpportunityType(opportunity.type))
            .frame(width: 40, height: 40)
            .background(getColorForOpportunityType(opportunity.type).opacity(0.1))
            .clipShape(Circle())
    }
    
    private var opportunityTitleInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(opportunity.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.primaryText)
                .multilineTextAlignment(.leading)
            
            Text(opportunity.type.rawValue)
                .font(.caption)
                .foregroundColor(ColorTheme.secondaryText)
        }
    }
    
    private var ongoingIndicator: some View {
        Image(systemName: "clock.fill")
            .font(.caption)
            .foregroundColor(ColorTheme.success)
            .padding(4)
            .background(ColorTheme.success.opacity(0.1))
            .clipShape(Circle())
    }
    
    private var organizationInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(opportunity.organization)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.primaryGreen)
            
            HStack {
                Label(opportunity.address, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundColor(ColorTheme.secondaryText)
                    .lineLimit(2)
                
                Spacer()
                
                distanceLabel
            }
        }
    }
    
    @ViewBuilder
    private var distanceLabel: some View {
        if let userLocation = userLocation {
            let distance = opportunity.distanceInMiles(from: userLocation)
            if distance != .infinity {
                Text("\(distance, specifier: "%.1f") mi")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(ColorTheme.accent.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
    
    private var descriptionText: some View {
        Text(opportunity.description)
            .font(.caption)
            .foregroundColor(ColorTheme.primaryText)
            .lineLimit(2)
    }
    
    private var footerInfo: some View {
        HStack {
            Label(opportunity.timeCommitment, systemImage: "clock")
                .font(.caption)
                .foregroundColor(ColorTheme.secondaryText)
            
            Spacer()
            
            if opportunity.requirements.count > 0 {
                Text("\(opportunity.requirements.count) requirements")
                    .font(.caption2)
                    .foregroundColor(ColorTheme.secondaryText)
            }
        }
    }
    
    private func getColorForOpportunityType(_ type: OpportunityType) -> Color {
        switch type {
        case .foodService:
            return ColorTheme.primaryGreen
        case .shelterSupport:
            return ColorTheme.primaryBlue
        case .environmentalCleanup:
            return ColorTheme.success
        case .communityOutreach:
            return ColorTheme.accent
        case .education:
            return .orange
        case .elderCare:
            return ColorTheme.lightGreen
        }
    }
}

struct VolunteeringDetailView: View {
    let opportunity: VolunteeringOpportunity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    detailsSection
                    requirementsSection
                    mapSection
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: opportunity.type.icon)
                    .font(.title)
                    .foregroundColor(getColorForOpportunityType(opportunity.type))
                
                VStack(alignment: .leading) {
                    Text(opportunity.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.primaryText)
                    
                    Text(opportunity.organization)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.primaryGreen)
                }
                
                Spacer()
                
                if opportunity.isOngoing {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(ColorTheme.success)
                }
            }
            
            Text(opportunity.description)
                .font(.body)
                .foregroundColor(ColorTheme.secondaryText)
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            Label(opportunity.address, systemImage: "location.fill")
                .foregroundColor(ColorTheme.secondaryText)
            
            Label(opportunity.timeCommitment, systemImage: "clock.fill")
                .foregroundColor(ColorTheme.secondaryText)
            
            if let contactPhone = opportunity.contactPhone {
                Label(contactPhone, systemImage: "phone.fill")
                    .foregroundColor(ColorTheme.secondaryText)
            }
            
            if let contactEmail = opportunity.contactEmail {
                Label(contactEmail, systemImage: "envelope.fill")
                    .foregroundColor(ColorTheme.accent)
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var requirementsSection: some View {
        if !opportunity.requirements.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Requirements")
                    .font(.headline)
                    .foregroundColor(ColorTheme.primaryText)
                
                ForEach(opportunity.requirements, id: \.self) { requirement in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorTheme.success)
                        Text(requirement)
                            .foregroundColor(ColorTheme.primaryText)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .foregroundColor(ColorTheme.primaryText)
            
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: opportunity.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            ), annotationItems: [DetailMapAnnotation(coordinate: opportunity.coordinate)]) { annotation in
                MapPin(coordinate: annotation.coordinate, tint: .red)
            }
            .frame(height: 200)
            .cornerRadius(8)
            .disabled(true)
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    struct DetailMapAnnotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
    
    private func getColorForOpportunityType(_ type: OpportunityType) -> Color {
        switch type {
        case .foodService:
            return ColorTheme.primaryGreen
        case .shelterSupport:
            return ColorTheme.primaryBlue
        case .environmentalCleanup:
            return ColorTheme.success
        case .communityOutreach:
            return ColorTheme.accent
        case .education:
            return .orange
        case .elderCare:
            return ColorTheme.lightGreen
        }
    }
}

struct VolunteeringFiltersView: View {
    @Binding var selectedTypes: Set<OpportunityType>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Filter by Type")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.primaryText)
                    .padding(.top)
                
                filterGrid
                
                Spacer()
                
                doneButton
            }
            .background(ColorTheme.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var filterGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(OpportunityType.allCases, id: \.self) { type in
                VolunteeringFilterCard(
                    type: type,
                    isSelected: selectedTypes.contains(type)
                ) {
                    toggleTypeSelection(type)
                }
            }
        }
        .padding()
    }
    
    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorTheme.primaryGreen)
        .cornerRadius(12)
        .padding()
    }
    
    private func toggleTypeSelection(_ type: OpportunityType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
}

struct VolunteeringFilterCard: View {
    let type: OpportunityType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : getColorForOpportunityType(type))
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ColorTheme.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? getColorForOpportunityType(type) : ColorTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getColorForOpportunityType(type), lineWidth: isSelected ? 0 : 2)
            )
            .cornerRadius(12)
            .shadow(color: ColorTheme.shadow, radius: isSelected ? 5 : 2, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
    
    private func getColorForOpportunityType(_ type: OpportunityType) -> Color {
        switch type {
        case .foodService:
            return ColorTheme.primaryGreen
        case .shelterSupport:
            return ColorTheme.primaryBlue
        case .environmentalCleanup:
            return ColorTheme.success
        case .communityOutreach:
            return ColorTheme.accent
        case .education:
            return .orange
        case .elderCare:
            return ColorTheme.lightGreen
        }
    }
}



#Preview {
    VolunteeringView()
}
