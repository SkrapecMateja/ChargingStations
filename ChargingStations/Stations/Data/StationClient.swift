//
//  ChargingStationFetchService.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import Combine

protocol StationFetching {
    func fetchStations(boundingBox: BoundingBox) -> AnyPublisher<[Station], StationError>
}

struct BoundingBox {
    let x1: Int
    let y1: Int
    let x2: Int
    let y2: Int
}

struct StationClient: StationFetching {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchStations(boundingBox: BoundingBox) -> AnyPublisher<[Station], StationError> {
        apiClient.fetch(StationsWrapper.self,
                        url: API.Endpoint.stationsInBoundingBox(x1: boundingBox.x1, y1: boundingBox.y1, x2: boundingBox.x2, y2: boundingBox.y2).fullURL
        ).map { wrapper -> [Station] in
            return wrapper.stations
        }.mapError { networkError -> StationError in
            switch networkError {
            case .noNetworkConnection:
                return .networkUnavailable
            case .decodingFailed, .invalidStatusCode, .requestFailed, .generalError:
                return .serviceUnavailable
            }
        }.eraseToAnyPublisher()
    }
}
