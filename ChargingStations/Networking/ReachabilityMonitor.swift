//
//  ReachabilityMonitor.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//
import Combine
import Network

protocol ReachabilityMonitoring {
    var networkAvailablePublisher: AnyPublisher<Void, Never> { get }
}

final class ReachabilityMonitor: ReachabilityMonitoring {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "ReachabilityMonitorQueue")

    private let networkAvailableSubject = PassthroughSubject<Void, Never>()
    var networkAvailablePublisher: AnyPublisher<Void, Never> {
        networkAvailableSubject.eraseToAnyPublisher()
    }

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            if isConnected {
                DefaultLogger.shared.info("Sending network is available")
                self?.networkAvailableSubject.send(())
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
