//
//  DeliveryLimits.swift
//  LoopKit
//
//  Created by Rick Pasetto on 7/15/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import HealthKit

public struct DeliveryLimits: Equatable {
    public enum Setting: Equatable {
        case maximumBasalRate
        case maximumBolus
    }

    private var settings: [Setting: HKQuantity]

    public init(maximumBasalRate: HKQuantity?, maximumBolus: HKQuantity?) {
        settings = [:]
        settings[.maximumBasalRate] = maximumBasalRate
        settings[.maximumBolus] = maximumBolus
    }

    public var maximumBasalRate: HKQuantity? {
        get { settings[.maximumBasalRate] }
        set { settings[.maximumBasalRate] = newValue }
    }

    public var maximumBolus: HKQuantity? {
        get { settings[.maximumBolus] }
        set { settings[.maximumBolus] = newValue }
    }
}

public extension DeliveryLimits.Setting {
    // The following comes from https://tidepool.atlassian.net/browse/IFU-24
    var title: String {
        switch self {
        case .maximumBasalRate:
            return LocalizedString("最大基础速率", comment: "Title text for maximum basal rate configuration")
        case .maximumBolus:
            return LocalizedString("最大推注", comment: "Title text for maximum bolus configuration")
        }
    }
    
    func localizedDescriptiveText(appName: String) -> String {
        switch self {
        case .maximumBasalRate:
            return String(format: LocalizedString("Maximum Basal Rate is the highest temporary basal rate %1$@ is allowed to set.", comment: "Descriptive text for maximum basal rate (1: app name)"), appName)
        case .maximumBolus:
            return LocalizedString("最大推注是您一次可以输送的最高推注，以覆盖碳水化合物或降低高血糖。", comment: "Descriptive text for maximum bolus")
        }
    }
}

