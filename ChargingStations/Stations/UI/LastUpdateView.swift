//
//  LastUpdateView.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI

struct LastUpdateView: View {
    let lastUpdateDateString: String
    
    init(lastUpdateDate: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        self.lastUpdateDateString = formatter.string(from: lastUpdateDate)
    }
    
    var body: some View {
        Text("Last update: \(self.lastUpdateDateString)")
            .font(.footnote)
            .foregroundColor(.primary)
    }
}
