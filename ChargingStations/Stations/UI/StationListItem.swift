//
//  StationListItem.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI

struct StationListItem: View {
    let viewModel: StationViewModel
    
    init(viewModel: StationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text(viewModel.id)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                
                Text(viewModel.maxPowerText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Circle()
                    .fill(viewModel.availability.color)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.availability.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }.padding(.bottom, 8)
            
            if !viewModel.chargingFacilities.isEmpty {
                Divider()
            }
            
            VStack {
                ForEach(viewModel.chargingFacilities) { facility in
                    HStack {
                        Image(systemName: "powerplug.portrait.fill")
                            .font(.subheadline)
                        
                        Text(facility.powerText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding([.top, .bottom], 8)
                        
                       Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}
