//
//  InsulinModelSettings+Loop.swift
//  LoopKitUI
//
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit

public extension ExponentialInsulinModelPreset {
    var title: String {
        switch self {
        case .rapidActingAdult:
            return LocalizedString("快速行动 - 成人", comment: "Title of insulin model preset - rapid acting adult")
        case .rapidActingChild:
            return LocalizedString("快速行动 - 孩子", comment: "Title of insulin model preset - rapid acting children")
        case .fiasp:
            return LocalizedString("fiasp", comment: "Title of insulin model preset - fiasp")
        case .lyumjev:
            return LocalizedString("Lyumjev", comment: "Title of insulin model preset - lyumjev")
        case .afrezza:
            return LocalizedString("afrezza", comment: "Title of insulin model preset - afrezza")
        }
    }

    var subtitle: String {
        switch self {
        case .rapidActingAdult:
            return LocalizedString("该模型假设在75分钟时峰值胰岛素活性。", comment: "Subtitle of Rapid-Acting – Adult preset")
        case .rapidActingChild:
            return LocalizedString("该模型假定在65分钟时峰值胰岛素活性。", comment: "Subtitle of Rapid-Acting – Children preset")
        case .fiasp:
            return LocalizedString("该模型假设在55分钟时峰值胰岛素活性。", comment: "Subtitle of Fiasp preset")
        case .lyumjev:
            return LocalizedString("该模型假设在55分钟时峰值胰岛素活性。", comment: "Subtitle of Lyumjev preset")
        case .afrezza:
            return LocalizedString("该模型假设在19分钟时峰值胰岛素活性。", comment: "Subtitle of afrezza preset")
        }
    }
}


public extension WalshInsulinModel {
    static var title: String {
        return LocalizedString("沃尔什", comment: "Title of insulin model setting")
    }
    
    var title: String {
        return Self.title
    }

    static var subtitle: String {
        return LocalizedString("闭环使用的旧模型，允许自定义动作持续时间。", comment: "Subtitle description of Walsh insulin model setting")
    }
    
    var subtitle: String {
        return Self.subtitle
    }
}
