//
//  NetworkingError.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import Foundation

enum NetworkingError: Error {
    case decodingFailed(error: DecodingError)
    case invalidStatusCode(statusCode: Int)
    case noNetworkConnection
    case requestFailed(error: URLError)
    case generalError(error: Error)
}
