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
    
    private let cacheFileName: String
    private let lastUpdatedKey: String
    private let lastLatitudeKey: String
    private let lastLongitudeKey: String
    private var cacheDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory

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
        let dir = FileManager.default.urls(for: cacheDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(cacheFileName)
    }
    
    init(cacheDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
         cacheFileName: String = "stationsCache.json",
         lastUpdatedKey: String = "stations.lastUpdated",
         lastLatitudeKey: String = "stations.lastLatitude",
         lastLongitudeKey: String = "stations.lastLongitude"
    ) {
        self.cacheDirectory = cacheDirectory
        self.cacheFileName = cacheFileName
        self.lastUpdatedKey = lastUpdatedKey
        self.lastLatitudeKey = lastLatitudeKey
        self.lastLongitudeKey = lastLongitudeKey
    }
    
    func saveStations(_ stations: [Station], completion: @escaping (Result<Void, StationError>) -> Void) {
        DefaultLogger.shared.info("Saving stations to cache: \(stations.count)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.jsonEncoder.encode(stations).write(to: self.cacheURL)
                DefaultLogger.shared.info("Saved stations to cache.")
                completion(.success(()))
            } catch {
                DefaultLogger.shared.error("Failed to save stations to cache: \(error.localizedDescription)")
                completion(.failure(StationError.saveToCacheFailed))
            }
        }
    }
    
    func loadStations(completion: @escaping (Result<[Station],StationError>) -> Void) {
        DefaultLogger.shared.info("Loading stations from cache...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: self.cacheURL)
                let stations = try self.jsonDecoder.decode([Station].self, from: data)
                
                DefaultLogger.shared.info("Loaded stations from cache \(stations.count)")
                completion(.success(stations))
            } catch {
                DefaultLogger.shared.error("Failed to log stations from cache:\(error.localizedDescription)")
                completion(.failure(.readingFromCacheFailed))
            }
        }
    }
    
    
    func saveLastUpdated(date: Date) {
        DefaultLogger.shared.info("Saving last updated date to cache.")
        UserDefaults.standard.set(date, forKey: lastUpdatedKey)
    }
    
    var lastUpdated: Date? {
        DefaultLogger.shared.info("Fetching last updated date from cache.")
        return UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date
    }
}
