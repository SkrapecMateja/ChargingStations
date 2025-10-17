//
//  Station.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

struct Station: Codable {
    let id: String
    let latitude: Double
    let longitude: Double
    let availability: Availability
    
    
    // MARK:  Decoding
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case evseStatus = "EvseStatus"
        case geoCoordinates = "GeoCoordinates"
    }

    enum GeoCodingKeys: String, CodingKey {
        case decimalDegree = "DecimalDegree"
    }

    enum DecimalDegreeKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let evseStatus = try container.decode(String.self, forKey: .evseStatus)
        self.availability = Availability(rawValue: evseStatus) ?? .unknown

        
        let geoContainer = try container.nestedContainer(keyedBy: GeoCodingKeys.self, forKey: .geoCoordinates)
        let decimalContainer = try geoContainer.nestedContainer(keyedBy: DecimalDegreeKeys.self, forKey: .decimalDegree)
        let latString = try decimalContainer.decode(String.self, forKey: .latitude)
        let lonString = try decimalContainer.decode(String.self, forKey: .longitude)
        self.latitude = Double(latString) ?? 0
        self.longitude = Double(lonString) ?? 0
    }
    
    // MARK: Encoding
    
    enum CachingCodingKeys: String, CodingKey {
        case id, latitude, longitude, availability
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CachingCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(availability.rawValue, forKey: .availability)
    }
}
