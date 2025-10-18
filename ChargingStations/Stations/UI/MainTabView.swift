//
//  ContainerView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.tabItems) { tabType in
                switch tabType {
                case .map:
                    StationsMapView(viewModel: viewModel.stationsViewModel).tabItem {
                        Label(tabType.title, systemImage: tabType.icon)
                    }.tag(tabType)
                case .list:
                    StationsListView(viewModel: viewModel.stationsViewModel).tabItem {
                        Label(tabType.title, systemImage: tabType.icon)
                    }.tag(tabType)
                }
            }
        }.onAppear {
            viewModel.viewAppeared()
        }.onDisappear {
            viewModel.viewDisappeared()
        }
    }
}

//#Preview {
//    MainTabView(viewModel: MainTabViewModel(stationsListViewModel: StationsListViewModel()))
//}
