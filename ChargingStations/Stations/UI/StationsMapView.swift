//
//  MapView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI
import MapKit

struct StationsMapView: View {
    @ObservedObject var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Map(bounds: viewModel.mapCameraBounds) {
                ForEach(viewModel.chargingPoints) { point in
                        Marker(
                            "",
                            coordinate: CLLocationCoordinate2D(
                                latitude: point.latitude,
                                longitude: point.longitude
                            )
                        ).tint(point.bestAvailability.color)
                    }
                Marker(
                    "You are here",
                    coordinate: viewModel.currentLocation
                ).tint(.blue)
            }
            
            if let lastUpdate = viewModel.lastUpdate {
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
