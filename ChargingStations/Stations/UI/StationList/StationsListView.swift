//
//  StationsListView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI
import Combine

struct StationsListView: View {
    @ObservedObject var viewModel: StationsViewModel
    
    init(viewModel: StationsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.stations.isEmpty {
                // Empty, loading view
                VStack {
                    Spacer()
                    ContentUnavailableView("No stations found", systemImage: "ev.charger")
                    Spacer()
                }
            } else {
                ScrollView {
                    // Last updated label
                    if let lastUpdate = viewModel.lastUpdate {
                        HStack {
                            LastUpdateView(lastUpdateDate: lastUpdate)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.leading, 32)
                    }
 
                    // Stations list
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.stations) { stationVM in
                            StationListItem(viewModel: stationVM)
                        }
                    }.padding([.bottom, .leading, .trailing], 12)
                }
            }
        }.background(Color(.systemGroupedBackground))
    }
}

//#Preview {
//    StationsListView(viewModel: StationsViewModel(stationsProvider: <#any StationsProviderType#>))
//}
