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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.stations) { stationVM in
                    StationListItem(viewModel: stationVM)
                }
            }.padding()
        }.background(Color(.systemGroupedBackground))
    }
}

//#Preview {
//    StationsListView(viewModel: StationsViewModel(stationsProvider: <#any StationsProviderType#>))
//}
