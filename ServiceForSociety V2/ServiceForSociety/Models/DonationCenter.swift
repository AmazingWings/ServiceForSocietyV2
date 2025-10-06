import Foundation
import CoreLocation
import MapKit

enum CenterType: String, CaseIterable, Codable {
    case foodBank = "Food Bank"
    case homelessShelter = "Homeless Shelter"
    case recyclingCenter = "Recycling Center"
    case compostFacility = "Compost Facility"
    
    var icon: String {
        switch self {
        case .foodBank:
            return "basket.fill"
        case .homelessShelter:
            return "house.fill"
        case .recyclingCenter:
            return "arrow.3.trianglepath"
        case .compostFacility:
            return "leaf.fill"
        }
    }
    
    var color: String {
        switch self {
        case .foodBank:
            return "primaryGreen"
        case .homelessShelter:
            return "primaryBlue"
        case .recyclingCenter:
            return "accent"
        case .compostFacility:
            return "success"
        }
    }
}

struct DonationCenter: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let type: CenterType
    let phone: String?
    let website: String?
    let hours: String
    let acceptedItems: [String]
    let latitude: Double
    let longitude: Double
    let description: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func distance(from userLocation: CLLocation) -> CLLocationDistance {
        let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: centerLocation)
    }
    
    func distanceInMiles(from userLocation: CLLocation) -> Double {
        let distanceInMeters = distance(from: userLocation)
        return distanceInMeters / 1609.34 // Convert meters to miles
    }
}

// Comprehensive nationwide sample data
extension DonationCenter {
    static let sampleData: [DonationCenter] = [
        // CALIFORNIA - San Francisco Bay Area
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            name: "San Francisco Food Bank",
            address: "900 Pennsylvania Ave, San Francisco, CA 94107",
            type: .foodBank,
            phone: "(415) 282-1900",
            website: nil,
            hours: "Mon-Fri: 9AM-5PM, Sat: 9AM-3PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Canned goods", "Baby food"],
            latitude: 37.7749,
            longitude: -122.4194,
            description: "Serving the Bay Area community with fresh and nutritious food donations."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
            name: "Hamilton Family Center",
            address: "260 Golden Gate Ave, San Francisco, CA 94102",
            type: .homelessShelter,
            phone: "(415) 355-7100",
            website: "https://www.hamiltonfamilies.org",
            hours: "Daily: 8AM-8PM",
            acceptedItems: ["Family meals", "Children's food", "Snacks", "Drinks"],
            latitude: 37.7799,
            longitude: -122.4244,
            description: "Family-focused shelter providing meals and support services."
        ),
        
        // CALIFORNIA - Los Angeles
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
            name: "Los Angeles Regional Food Bank",
            address: "1734 E 41st St, Los Angeles, CA 90058",
            type: .foodBank,
            phone: "(323) 234-3030",
            website: "https://www.lafoodbank.org",
            hours: "Mon-Fri: 8AM-4:30PM",
            acceptedItems: ["Canned goods", "Fresh produce", "Dairy products", "Meat", "Prepared meals"],
            latitude: 34.0224,
            longitude: -118.2437,
            description: "The largest food bank in the US, serving LA County with nutritious food."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
            name: "Union Rescue Mission",
            address: "545 S San Pedro St, Los Angeles, CA 90013",
            type: .homelessShelter,
            phone: "(213) 347-6300",
            website: "https://www.urm.org",
            hours: "24/7 - Meals at 6AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Sandwiches", "Beverages", "Snacks"],
            latitude: 34.0430,
            longitude: -118.2472,
            description: "Downtown LA's largest homeless shelter serving over 1000 meals daily."
        ),
        
        // NEW YORK - New York City
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
            name: "Food Bank for New York City",
            address: "39 Broadway, New York, NY 10006",
            type: .foodBank,
            phone: "(212) 566-7855",
            website: "https://www.foodbanknyc.org",
            hours: "Mon-Fri: 9AM-5PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Prepared meals", "Baby food"],
            latitude: 40.7047,
            longitude: -74.0142,
            description: "NYC's major food bank serving all five boroughs with emergency food assistance."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
            name: "Bowery Mission",
            address: "227 Bowery, New York, NY 10002",
            type: .homelessShelter,
            phone: "(212) 674-3456",
            website: "https://www.bowery.org",
            hours: "Daily: 7AM-9PM - Meals at 8AM, 1PM, 7PM",
            acceptedItems: ["Hot meals", "Sandwiches", "Soup", "Coffee", "Snacks"],
            latitude: 40.7209,
            longitude: -73.9939,
            description: "Historic shelter in Manhattan providing meals and services to the homeless."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
            name: "Sure We Can Recycling",
            address: "219 McKibbin St, Brooklyn, NY 11206",
            type: .recyclingCenter,
            phone: "(718) 599-2012",
            website: "https://www.surewecan.org",
            hours: "Mon-Sat: 10AM-4PM",
            acceptedItems: ["Bottles", "Cans", "Electronics", "Metal", "Plastic containers"],
            latitude: 40.7081,
            longitude: -73.9442,
            description: "Community recycling center in Brooklyn supporting local canners and recyclers."
        ),
        
        // TEXAS - Houston
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440008")!,
            name: "Houston Food Bank",
            address: "535 Portwall St, Houston, TX 77029",
            type: .foodBank,
            phone: "(713) 547-3663",
            website: "https://www.houstonfoodbank.org",
            hours: "Mon-Fri: 8AM-4PM, Sat: 8AM-12PM",
            acceptedItems: ["Canned food", "Rice", "Beans", "Fresh produce", "Meat", "Dairy"],
            latitude: 29.7344,
            longitude: -95.3181,
            description: "Texas's largest food bank serving 18 counties in Southeast Texas."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440009")!,
            name: "Star of Hope Mission",
            address: "419 Dowling St, Houston, TX 77003",
            type: .homelessShelter,
            phone: "(713) 748-0700",
            website: "https://www.sohmission.org",
            hours: "24/7 - Meals at 7AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Prepared food", "Sandwiches", "Beverages"],
            latitude: 29.7398,
            longitude: -95.3594,
            description: "Houston's largest homeless shelter providing comprehensive services."
        ),
        
        // ILLINOIS - Chicago
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440010")!,
            name: "Greater Chicago Food Depository",
            address: "4100 W Ann Lurie Pl, Chicago, IL 60632",
            type: .foodBank,
            phone: "(773) 247-3663",
            website: "https://www.chicagosfoodbank.org",
            hours: "Mon-Fri: 8AM-4PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Frozen items", "Dairy"],
            latitude: 41.8243,
            longitude: -87.7280,
            description: "Chicago's food bank serving Cook County with nutritious food distribution."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
            name: "Pacific Garden Mission",
            address: "1458 S Canal St, Chicago, IL 60607",
            type: .homelessShelter,
            phone: "(312) 922-1462",
            website: "https://www.pgm.org",
            hours: "24/7 - Meals at 6:30AM, 12PM, 5:30PM",
            acceptedItems: ["Hot meals", "Soup", "Sandwiches", "Coffee"],
            latitude: 41.8567,
            longitude: -87.6394,
            description: "Chicago's oldest continuously operating rescue mission."
        ),
        
        // ARIZONA - Phoenix
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
            name: "St. Mary's Food Bank",
            address: "2831 N 31st Ave, Phoenix, AZ 85009",
            type: .foodBank,
            phone: "(602) 242-3663",
            website: "https://www.firstfoodbank.org",
            hours: "Mon-Fri: 8AM-4PM, Sat: 8AM-12PM",
            acceptedItems: ["Canned goods", "Dry goods", "Fresh produce", "Frozen food"],
            latitude: 33.4781,
            longitude: -112.1249,
            description: "The world's first food bank, serving Arizona since 1967."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440013")!,
            name: "Central Arizona Shelter Services",
            address: "230 S 12th Ave, Phoenix, AZ 85007",
            type: .homelessShelter,
            phone: "(602) 256-6945",
            website: "https://www.cassaz.org",
            hours: "24/7 - Meals at 7AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Prepared food", "Snacks", "Beverages"],
            latitude: 33.4461,
            longitude: -112.0892,
            description: "Phoenix's largest homeless shelter serving families and individuals."
        ),
        
        // FLORIDA - Miami
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440014")!,
            name: "Feeding South Florida",
            address: "2501 SW 32nd Terrace, Pembroke Park, FL 33023",
            type: .foodBank,
            phone: "(954) 518-1818",
            website: "https://www.feedingsouthflorida.org",
            hours: "Mon-Fri: 8AM-4PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Prepared meals", "Baby food"],
            latitude: 25.9878,
            longitude: -80.2089,
            description: "Serving Broward, Miami-Dade, Monroe and Palm Beach counties."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440015")!,
            name: "Miami Rescue Mission",
            address: "2020 NW 1st Ave, Miami, FL 33127",
            type: .homelessShelter,
            phone: "(305) 375-3733",
            website: "https://www.miamirescuemission.com",
            hours: "Daily: 6AM-8PM - Meals at 7AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Sandwiches", "Soup", "Beverages"],
            latitude: 25.7825,
            longitude: -80.2056,
            description: "Downtown Miami shelter providing meals and recovery programs."
        ),
        
        // WASHINGTON - Seattle
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440016")!,
            name: "Food Lifeline",
            address: "815 S 96th St, Seattle, WA 98108",
            type: .foodBank,
            phone: "(206) 545-6600",
            website: "https://www.foodlifeline.org",
            hours: "Mon-Fri: 8AM-4:30PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Dairy", "Frozen items"],
            latitude: 47.5231,
            longitude: -122.3147,
            description: "Western Washington's hub for food rescue and distribution."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440017")!,
            name: "Seattle Recycling Center",
            address: "2300 S Jackson St, Seattle, WA 98144",
            type: .recyclingCenter,
            phone: "(206) 684-3000",
            website: "https://www.seattle.gov/utilities",
            hours: "Mon-Sat: 8AM-5:30PM",
            acceptedItems: ["Paper", "Cardboard", "Plastic", "Glass", "Metal", "Electronics"],
            latitude: 47.5984,
            longitude: -122.3045,
            description: "City of Seattle's comprehensive recycling facility."
        ),
        
        // MASSACHUSETTS - Boston
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440018")!,
            name: "Greater Boston Food Bank",
            address: "70 S Bay Ave, Boston, MA 02118",
            type: .foodBank,
            phone: "(617) 427-5200",
            website: "https://www.gbfb.org",
            hours: "Mon-Fri: 8AM-4PM",
            acceptedItems: ["Canned goods", "Fresh produce", "Dairy products", "Prepared meals"],
            latitude: 42.3398,
            longitude: -71.0632,
            description: "New England's largest hunger-relief organization."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440019")!,
            name: "Boston Compost Collective",
            address: "18 Leyland St, Boston, MA 02124",
            type: .compostFacility,
            phone: "(617) 522-6300",
            website: "https://www.bostoncompost.org",
            hours: "Mon-Fri: 8AM-5PM, Sat: 9AM-3PM",
            acceptedItems: ["Food scraps", "Yard waste", "Coffee grounds", "Paper towels"],
            latitude: 42.2928,
            longitude: -71.0856,
            description: "Community-based composting program reducing food waste."
        ),
        
        // GEORGIA - Atlanta
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440020")!,
            name: "Atlanta Community Food Bank",
            address: "732 Joseph E Lowery Blvd NW, Atlanta, GA 30318",
            type: .foodBank,
            phone: "(404) 892-9822",
            website: "https://www.acfb.org",
            hours: "Mon-Fri: 8AM-5PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Meat", "Dairy"],
            latitude: 33.7676,
            longitude: -84.4204,
            description: "Georgia's largest food bank serving 29 counties."
        ),
        
        // NORTH CAROLINA - Charlotte
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440021")!,
            name: "Second Harvest Food Bank of Metrolina",
            address: "500 Spratt St, Charlotte, NC 28206",
            type: .foodBank,
            phone: "(704) 376-1785",
            website: "https://www.secondharvestmetrolina.org",
            hours: "Mon-Fri: 8AM-5PM, Sat: 9AM-1PM",
            acceptedItems: ["Canned goods", "Fresh produce", "Dairy products", "Frozen food", "Baby food"],
            latitude: 35.2504,
            longitude: -80.8414,
            description: "Serving 24 counties in North and South Carolina with nutritious food."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440022")!,
            name: "Charlotte Rescue Mission",
            address: "907 W 1st St, Charlotte, NC 28202",
            type: .homelessShelter,
            phone: "(704) 333-4142",
            website: "https://www.charlotterescuemission.org",
            hours: "24/7 - Meals at 7AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Prepared food", "Sandwiches", "Beverages", "Snacks"],
            latitude: 35.2220,
            longitude: -80.8526,
            description: "Charlotte's premier homeless shelter providing comprehensive services."
        ),
        
        // NORTH CAROLINA - Raleigh
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440023")!,
            name: "Food Bank of Central & Eastern North Carolina",
            address: "1924 Capital Blvd, Raleigh, NC 27604",
            type: .foodBank,
            phone: "(919) 865-3050",
            website: "https://www.foodbankcenc.org",
            hours: "Mon-Fri: 8AM-4:30PM",
            acceptedItems: ["Non-perishable food", "Fresh produce", "Meat", "Dairy", "Prepared meals"],
            latitude: 35.8302,
            longitude: -78.6414,
            description: "Serving 34 counties across central and eastern North Carolina."
        ),
        DonationCenter(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440024")!,
            name: "Raleigh Rescue Mission",
            address: "314 E Hargett St, Raleigh, NC 27601",
            type: .homelessShelter,
            phone: "(919) 828-9014",
            website: "https://www.raleighrescue.org",
            hours: "Daily: 6AM-8PM - Meals at 7AM, 12PM, 6PM",
            acceptedItems: ["Hot meals", "Soup", "Sandwiches", "Coffee", "Snacks"],
            latitude: 35.7756,
            longitude: -78.6344,
            description: "Downtown Raleigh shelter providing meals and recovery programs."
        ),
        
        // Continue with remaining entries following the same pattern...
    ]
}
