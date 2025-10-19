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
    @State private var selectedMarkerId: String?
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if viewModel.mapCameraBounds == nil || viewModel.chargingPoints.isEmpty {
                VStack {
                    Spacer()
                    ContentUnavailableView("No locations found", systemImage: "map")
                    Spacer()
                }
            } else {
                Map(bounds: viewModel.mapCameraBounds, selection: $selectedMarkerId) {
                    if let currentLocation = viewModel.currentLocation {
                        MapCircle(center: currentLocation, radius: CLLocationDistance(1200))
                            .foregroundStyle(.orange.opacity(0.5))
                            .mapOverlayLevel(level: .aboveLabels)
                    }
                    
                    ForEach(viewModel.chargingPoints) { point in
                        Marker(
                            "",
                            coordinate: CLLocationCoordinate2D(
                                latitude: point.latitude,
                                longitude: point.longitude
                            )
                        ).tint(point.bestAvailability.color)
                    }
                    
                    if let currentLocation = viewModel.currentLocation {
                        Marker(
                            "You are here",
                            coordinate: currentLocation
                        ).tint(.blue)
                    }
                }.onChange(of: selectedMarkerId) {
                    if let selectedMarkerId = selectedMarkerId {
                        viewModel.showStations(for: selectedMarkerId)
                    } else {
                        viewModel.hideStations()
                    }
                }
                
                
                if let selectedStations = viewModel.selectedStationsText {
                    VStack {
                        Spacer()
                        HStack {
                            Text(selectedStations)
                                .font(.caption)
                                .padding([.leading, .trailing], 16)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                                .padding(.leading, 16)
                                .padding(.bottom, 24)
                            Spacer()
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
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
}
