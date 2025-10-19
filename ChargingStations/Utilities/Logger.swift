//
//  Logger.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 19.10.2025.
//
import Foundation

protocol Logging {
    func info(_ message: String, file: String, line: Int)
    func error(_ message: String, file: String, line: Int)
}

final class DefaultLogger: Logging {
    static let shared = DefaultLogger()
    private init() {}
    
    
    func info(_ message: String,
              file: String = #file,
              line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("ℹ️ Info  - [\(fileName):\(line)]: \(message)")
    }
    
    func error(_ message: String,
               file: String = #file,
               line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("❌ Error - [\(fileName):\(line)]: \(message)")
    }
}
