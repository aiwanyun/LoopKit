//
//  PumpManagerError.swift
//  LoopKit
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import Foundation

public enum PumpManagerError: Error {
    /// The manager isn't configured correctly
    case configuration(LocalizedError?)

    /// The device connection failed
    case connection(LocalizedError?)

    /// The device is connected, but communication failed
    case communication(LocalizedError?)

    /// The device is in an error state
    case deviceState(LocalizedError?)
    
    /// A command issued to the pump was sent, but we do not know if the pump received it
    case uncertainDelivery
}


extension PumpManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .communication(let error):
            return error?.errorDescription ?? LocalizedString("沟通失败", comment: "Generic pump error description")
        case .configuration(let error):
            return error?.errorDescription ?? LocalizedString("无效的配置", comment: "Generic pump error description")
        case .connection(let error):
            return error?.errorDescription ?? LocalizedString("连接故障", comment: "Generic pump error description")
        case .deviceState(let error):
            return error?.errorDescription ?? LocalizedString("设备拒绝", comment: "Generic pump error description")
        case .uncertainDelivery:
            return LocalizedString("交付不确定", comment: "Error description for uncertain delivery")
        }
    }

    public var failureReason: String? {
        switch self {
        case .communication(let error):
            return error?.failureReason
        case .configuration(let error):
            return error?.failureReason
        case .connection(let error):
            return error?.failureReason
        case .deviceState(let error):
            return error?.failureReason
        case .uncertainDelivery:
            return LocalizedString("胰岛素输送命令期间中断通信。", comment: "Failure reason for uncertain delivery")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .communication(let error):
            return error?.recoverySuggestion
        case .configuration(let error):
            return error?.recoverySuggestion
        case .connection(let error):
            return error?.recoverySuggestion
        case .deviceState(let error):
            return error?.recoverySuggestion
        case .uncertainDelivery:
            return LocalizedString("确保您的泵在手机的通信范围内。", comment: "Recovery suggestion for uncertain delivery")
        }
    }

    public var helpAnchor: String? {
        switch self {
        case .communication(let error):
            return error?.helpAnchor
        case .configuration(let error):
            return error?.helpAnchor
        case .connection(let error):
            return error?.helpAnchor
        case .deviceState(let error):
            return error?.helpAnchor
        case .uncertainDelivery:
            return nil
        }
    }
}
