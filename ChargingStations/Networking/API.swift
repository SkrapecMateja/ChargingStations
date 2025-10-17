//
//  Endpoint.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//
import Foundation

enum API {
    static var baseUrl: URL = URL(string: "https://data.geo.admin.ch")!

    enum Endpoint {
        case stationsInBoundingBox(x1:Int, y1:Int, x2:Int, y2:Int)

        var fullURL: URL {
            switch self {
            case let .stationsInBoundingBox(x1,y1,x2,y2):
                return URL(string: "http://ich-tanke-strom.switzerlandnorth.cloudapp.azure.com:8080/geoserver/ich-tanke-strom/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=ich-tanke-strom%3Aevse&maxFeatures=50&outputFormat=application%2Fjson&cql_filter=bbox(geometry,11,48,12,59)")!
            }
        }
    }

}

