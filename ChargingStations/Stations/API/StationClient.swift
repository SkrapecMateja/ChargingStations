//
//  ChargingStationFetchService.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import Combine

protocol StationFetching {
    func fetchStations(boundingBox: BoundingBox) -> AnyPublisher<[APIStation], StationError>
}

struct StationClient: StationFetching {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchStations(boundingBox: BoundingBox) -> AnyPublisher<[APIStation], StationError> {
        apiClient.fetch(APIStationsWrapper.self,
                        url: API.Endpoint.stationsInBoundingBox(bbox: boundingBox).fullURL
        ).map { wrapper -> [APIStation] in
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
