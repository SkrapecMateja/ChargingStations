//
//  MapView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI
import MapKit

struct StationsMapView: View {
    @ObservedObject var stationsViewModel: StationsViewModel
    @ObservedObject var mapViewModel: MapViewModel
    
    init(viewModel: StationsViewModel) {
        self.stationsViewModel = viewModel
        self.mapViewModel = viewModel.mapViewModel
    }
    
    var body: some View {
        ZStack {
            Map(bounds: mapViewModel.mapCameraBounds) {
                ForEach(stationsViewModel.stations) { station in
                        Marker(
                            station.id,
                            coordinate: CLLocationCoordinate2D(
                                latitude: station.latitude,
                                longitude: station.longitude
                            )
                        ).tint(station.availability.color)
                    }
                Marker(
                    "You are here",
                    coordinate: mapViewModel.currentLocation
                ).tint(.blue)
            }
            
            if let lastUpdate = stationsViewModel.lastUpdate {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LastUpdateView(lastUpdateDate: lastUpdate)
                    }
                }
            }
        }
    }
}

//#Preview {
//    StationsMapView(viewModel: StationsViewModel())
//}
