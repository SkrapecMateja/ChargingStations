//
//  Endpoint.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//
import Foundation

enum API {
    enum Endpoint {
        case stationsInBoundingBox(bbox: BoundingBox)
        
        var fullURL: URL {
            switch self {
            case .stationsInBoundingBox(let bbox):
                let url = URL(string: "http://ich-tanke-strom.switzerlandnorth.cloudapp.azure.com:8080/geoserver/ich-tanke-strom/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=ich-tanke-strom%3Aevse&outputFormat=application%2Fjson&cql_filter=bbox(geometry,\(bbox.bboxString))")!
                return url
            }
        }
    }
}
