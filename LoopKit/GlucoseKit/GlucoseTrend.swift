//
//  GlucoseTrend.swift
//  Loop
//
//  Created by Nate Racklyeft on 8/2/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation


public enum GlucoseTrend: Int, CaseIterable {
    case upUpUp       = 1
    case upUp         = 2
    case up           = 3
    case flat         = 4
    case down         = 5
    case downDown     = 6
    case downDownDown = 7

    public var symbol: String {
        switch self {
        case .upUpUp:
            return "⇈"
        case .upUp:
            return "↑"
        case .up:
            return "↗︎"
        case .flat:
            return "→"
        case .down:
            return "↘︎"
        case .downDown:
            return "↓"
        case .downDownDown:
            return "⇊"
        }
    }
    
    public var arrows: String {
        switch self {
        case .upUpUp:
            return "↑↑"
        case .upUp:
            return "↑"
        case .up:
            return "↗︎"
        case .flat:
            return "→"
        case .down:
            return "↘︎"
        case .downDown:
            return "↓"
        case .downDownDown:
            return "↓↓"
        }
    }

    public var localizedDescription: String {
        switch self {
        case .upUpUp:
            return LocalizedString("快速上升", comment: "Glucose trend up-up-up")
        case .upUp:
            return LocalizedString("快速上升", comment: "Glucose trend up-up")
        case .up:
            return LocalizedString("上升", comment: "Glucose trend up")
        case .flat:
            return LocalizedString("平坦的", comment: "Glucose trend flat")
        case .down:
            return LocalizedString("跌倒", comment: "Glucose trend down")
        case .downDown:
            return LocalizedString("迅速下降", comment: "Glucose trend down-down")
        case .downDownDown:
            return LocalizedString("跌倒很快", comment: "Glucose trend down-down-down")
        }
    }
}

extension GlucoseTrend {
    public init?(symbol: String) {
        switch symbol {
        case "↑↑":
            self = .upUpUp
        case "↑":
            self = .upUp
        case "↗︎":
            self = .up
        case "→":
            self = .flat
        case "↘︎":
            self = .down
        case "↓":
            self = .downDown
        case "↓↓":
            self = .downDownDown
        default:
            return nil
        }
    }
}
