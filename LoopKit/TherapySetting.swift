//
//  TherapySetting.swift
//  LoopKit
//
//  Created by Rick Pasetto on 7/14/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//


public enum TherapySetting {
    case glucoseTargetRange
    case preMealCorrectionRangeOverride
    case workoutCorrectionRangeOverride
    case suspendThreshold
    case basalRate(Int?)
    case deliveryLimits
    case insulinModel
    case carbRatio
    case insulinSensitivity
    case none
}

public extension TherapySetting {
    static var basalRate: TherapySetting {
        .basalRate(nil)
    }
}

extension TherapySetting: Equatable { }

public extension TherapySetting {
    
    // The following comes from https://tidepool.atlassian.net/browse/IFU-24
    var title: String {
        switch self {
        case .glucoseTargetRange:
            return LocalizedString("更正范围", comment: "Title text for glucose target range")
        case .preMealCorrectionRangeOverride:
            return String(format: LocalizedString("%@ Range", comment: "Format for correction range override therapy setting card"), CorrectionRangeOverrides.Preset.preMeal.title)
        case .workoutCorrectionRangeOverride:
            return String(format: LocalizedString("%@ Range", comment: "Format for correction range override therapy setting card"), CorrectionRangeOverrides.Preset.workout.title)
        case .suspendThreshold:
            return LocalizedString("血糖安全限制", comment: "Title text for glucose safety limit")
        case .basalRate:
            return LocalizedString("基础率", comment: "Title text for basal rates")
        case .deliveryLimits:
            return LocalizedString("交互限制", comment: "Title text for delivery limits")
        case .insulinModel:
            return LocalizedString("胰岛素模型", comment: "Title text for fast acting insulin model")
        case .carbRatio:
            return LocalizedString("碳水化合物比率", comment: "Title text for carb ratios")
        case .insulinSensitivity:
            return LocalizedString("胰岛素敏感性", comment: "Title text for insulin sensitivity")
        case .none:
            return ""
        }
    }
    
    var smallTitle: String {
        switch self {
        default:
            return title
        }
    }
    
    func descriptiveText(appName: String) -> String {
        switch self {
        case .glucoseTargetRange:
            return String(format: LocalizedString("Correction Range is the glucose value (or range of values) that you want %1$@ to aim for in adjusting your basal insulin and helping you calculate your boluses.", comment: "Descriptive text for glucose target range (1: app name)"), appName)
        case .preMealCorrectionRangeOverride:
            return LocalizedString("进餐前会暂时降低血糖靶标，以撞击圆环后的血糖峰值。", comment: "Descriptive text for pre-meal correction range override")
        case .workoutCorrectionRangeOverride:
            return LocalizedString("在体育锻炼之前，期间或之后，暂时提高血糖靶标，以降低低血糖事件的风险。", comment: "Descriptive text for workout correction range override")
        case .suspendThreshold:
            return String(format: LocalizedString("%1$@ will deliver basal and recommend bolus insulin only if your glucose is predicted to be above this limit for the next three hours.", comment: "Descriptive format string for glucose safety limit (1: app name)"), appName)
        case .basalRate:
            return LocalizedString("您的基础胰岛素速率是您要使用的单位数量来满足背景胰岛素需求。", comment: "Descriptive text for basal rate")
        case .deliveryLimits:
            return "\(DeliveryLimits.Setting.maximumBasalRate.localizedDescriptiveText(appName: appName))\n\n\(DeliveryLimits.Setting.maximumBolus.localizedDescriptiveText(appName: appName))"
        case .insulinModel:
            return String(format: LocalizedString("For fast acting insulin, %1$@ assumes it is actively working for 6 hours. You can choose from different models for the peak activity.", comment: "Descriptive text for fast acting insulin model (1: app name)"), appName)
        case .carbRatio:
            return LocalizedString("您的碳水化合物比是一个单位胰岛素覆盖的碳水化合物的克数。", comment: "Descriptive text for carb ratio")
        case .insulinSensitivity:
            return LocalizedString("您的胰岛素敏感性是指一个单位胰岛素预期的血糖下降。", comment: "Descriptive text for insulin sensitivity")
        case .none:
            return ""
        }
    }
}

// MARK: Guardrails
public extension TherapySetting {
    var guardrailCaptionForLowValue: String {
        switch self {
        case .glucoseTargetRange, .preMealCorrectionRangeOverride, .workoutCorrectionRangeOverride:
            return LocalizedString("您输入的价值低于大多数人通常建议的价值。", comment: "Descriptive text for guardrail low value warning for schedule interface")
        default:
            return LocalizedString("您输入的价值低于大多数人通常建议的价值。", comment: "Descriptive text for guardrail low value warning")
        }
    }
    
    var guardrailCaptionForHighValue: String {
        switch self {
        case .glucoseTargetRange, .preMealCorrectionRangeOverride, .workoutCorrectionRangeOverride:
            return LocalizedString("您输入的价值高于大多数人通常建议的价值。", comment: "Descriptive text for guardrail high value warning for schedule interface")
        default:
            return LocalizedString("您输入的价值高于大多数人通常建议的价值。", comment: "Descriptive text for guardrail high value warning")
        }
    }
    
    var guardrailCaptionForOutsideValues: String {
        switch self {
        case .deliveryLimits:
            return LocalizedString("您输入的值不包括大多数人通常建议的值。", comment: "Descriptive text for guardrail high value warning")
        default:
            return LocalizedString("您输入的一些值不在大多数人通常建议的内容之外。", comment: "Descriptive text for guardrail high value warning for schedule interface")
        }
    }
    
    var guardrailSaveWarningCaption: String {
        switch self {
        default:
            return LocalizedString("您输入的一个或多个值不在大多数人通常推荐的值之外。", comment: "Descriptive text for saving settings outside the recommended range")
        }
    }
}
