//
//  ServiceHelper.swift
//  Battery-Monitor
//
//  Created by Matt on 6/18/26.
//

import SwiftUI
import Foundation
import Combine

class ServiceHelper {
    private var updateTimer: AnyCancellable?
    
    @AppStorage("selectedUpdateInterval") var selectedUpdateInterval: UpdateInterval = .five


    func createTimer(action: @escaping () -> Void) {
        updateTimer?.cancel()
        updateTimer = Timer.publish(
            every: TimeInterval(selectedUpdateInterval.rawValue),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { _ in
            action()
        }
    
    
}

}
