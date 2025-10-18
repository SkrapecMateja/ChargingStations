//
//  MapView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI

struct StationsMapView: View {
    @ObservedObject var viewModel: StationsViewModel
    
    init(viewModel: StationsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("Map")
    }
}

//#Preview {
//    StationsMapView(viewModel: StationsViewModel())
//}
