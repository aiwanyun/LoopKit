//
//  DeviceStatusHighlight.swift
//  LoopKit
//
//  Created by Nathaniel Hamming on 2020-06-23.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

public protocol DeviceStatusHighlight: Codable {
    /// a localized message from the device
    var localizedMessage: String { get }

    /// the system name of the icon related to the message
    var imageName: String { get }
        
    /// the state of the status highlight (guides presentation)
    var state: DeviceStatusHighlightState { get }
}

public typealias DeviceStatusHighlightState = DeviceStatusElementState

public enum DeviceStatusElementState: String, Codable {
    case critical
    case normalCGM
    case normalPump
    case warning

    public var localizedDescription: String {
        switch self {
        case .critical:
            return LocalizedString("设备状态关键", comment: "Accessibility label for device status critical state")
        case .normalCGM, .normalPump:
            return LocalizedString("设备状态正常", comment: "Accessibility label for device status normal state")
        case .warning:
            return LocalizedString("设备状态警告", comment: "Accessibility label for device status warning state")
        }
    }
}
