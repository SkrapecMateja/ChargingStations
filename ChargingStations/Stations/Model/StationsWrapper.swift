//
//  StationsWrapper.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

struct StationsWrapper: Decodable {
    let stations: [Station]

    enum CodingKeys: String, CodingKey {
        case features
    }

    struct Feature: Decodable {
        let properties: Station
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let features = try container.decode([Feature].self, forKey: .features)
        self.stations = features.map { $0.properties }
    }
}
