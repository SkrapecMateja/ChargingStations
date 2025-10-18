//
//  Tab.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import SwiftUI

enum TabType: Int, Identifiable, Hashable {
    case map = 0
    case list
    
    var id: Int { rawValue }
}

struct TabItem: Identifiable {
    let tab: TabType
    let title: String
    let icon: String
    let view: AnyView
    
    var id: Int { tab.id }
}
