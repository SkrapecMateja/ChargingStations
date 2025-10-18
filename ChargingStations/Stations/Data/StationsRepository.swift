//
//  StationCache.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import Foundation

protocol StationsRepositoryType {
    func saveStations(_ stations: [Station], completion: @escaping (Result<Void, StationError>) -> Void)
    func loadStations(completion: @escaping (Result<[Station],StationError>) -> Void)
    func saveLastUpdated(date: Date)
    var lastUpdated: Date? { get }
}

struct StationsRepository: StationsRepositoryType {
    
    private(set) var cacheFileName: String
    private(set) var  lastUpdatedKey: String
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private var cacheURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(cacheFileName)
    }
    
    init(cacheFileName: String = "stationsCache.json", lastUpdatedKey: String = "stations.lastUpdated") {
        self.cacheFileName = cacheFileName
        self.lastUpdatedKey = lastUpdatedKey
    }
    
    func saveStations(_ stations: [Station], completion: @escaping (Result<Void, StationError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.jsonEncoder.encode(stations).write(to: self.cacheURL)
                completion(.success(()))
            } catch {
                completion(.failure(StationError.saveToCacheFailed))
            }
        }
    }
    
    func loadStations(completion: @escaping (Result<[Station],StationError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: self.cacheURL)
                let stations = try self.jsonDecoder.decode([Station].self, from: data)
                completion(.success(stations))
            } catch {
                completion(.failure(.readingFromCacheFailed))
            }
        }
    }
    
    
    func saveLastUpdated(date: Date) {
        UserDefaults.standard.set(date, forKey: lastUpdatedKey)
    }
    
    var lastUpdated: Date? {
        UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date
    }
}
