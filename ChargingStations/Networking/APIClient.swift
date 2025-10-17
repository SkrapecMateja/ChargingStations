//
//  APIClient.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, NetworkingError>
}

final class APIClient: APIClientProtocol {
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, NetworkingError> {
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { output -> Data in
                    guard let statusCode = (output.response as? HTTPURLResponse)?.statusCode else {
                        throw NetworkingError.invalidStatusCode(statusCode: -1)
                    }
                    guard (200...299).contains(statusCode) else {
                        throw NetworkingError.invalidStatusCode(statusCode: statusCode)
                    }
                    return output.data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError({ error -> NetworkingError in
                    if let urlError = error as? URLError {
                        if urlError.code == .notConnectedToInternet {
                            return .noNetworkConnection
                        } else {
                            return .requestFailed(error: urlError)
                        }
                    } else if let decodingError = error as? DecodingError {
                        return .decodingFailed(error: decodingError)
                    } else if let networkingError = error as? NetworkingError {
                        return networkingError
                    } else {
                        return .generalError(error: error)
                    }
                })
                .eraseToAnyPublisher()
        }
}
