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
    
            // Id and Max power of station
            HStack {
                Image(systemName: "ev.charger")
                    .font(.headline)
                Text(viewModel.id)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Availability
            HStack {
                Circle()
                    .fill(viewModel.availability.color)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.availability.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(viewModel.maxPowerText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.padding(.bottom, 8)
            
            if !viewModel.chargingFacilities.isEmpty {
                Divider()
            }
            
            // Charging facilities
            VStack {
                ForEach(viewModel.chargingFacilities) { facility in
                    HStack {
                        Image(systemName: "powerplug.portrait")
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
