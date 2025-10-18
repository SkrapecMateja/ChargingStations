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
            ForEach(viewModel.tabItems) { item in
                item.view
                .tabItem {
                    Label(item.title, systemImage: item.icon)
                }.id(item.id)
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
