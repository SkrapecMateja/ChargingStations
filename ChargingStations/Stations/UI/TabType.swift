//
//  Tab.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import SwiftUI

enum TabType: Int, Identifiable, Hashable, CaseIterable {
    case map = 0
    case list
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .map:
            return "Map"
        case .list:
            return "List"
        }
    }
    
    var icon: String {
        switch self {
        case .map:
            return "map"
        case .list:
            return "list.bullet"
        }
    }
}
