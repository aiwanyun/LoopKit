//
//  DeliveryLimitsInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/3/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct DeliveryLimitsInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) var appName

    public init(onExit: (() -> Void)?, mode: SettingsPresentationMode = .acceptanceFlow) {
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        InformationView(
            title: Text(TherapySetting.deliveryLimits.title),
            informationalContent: {
                VStack (alignment: .leading, spacing: 20) {
                    deliveryLimitDescription
                    maxBasalDescription
                    maxBolusDescription
                }
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
            },
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var deliveryLimitDescription: some View {
        Text(LocalizedString("交付限制是您的胰岛素输送的安全护栏。", comment: "Information about delivery limits"))
        .foregroundColor(.secondary)
    }
    
    private var maxBasalDescription: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(DeliveryLimits.Setting.maximumBasalRate.title)
            .font(.headline)
            VStack(alignment: .leading, spacing: 20) {
                Text(String(format: LocalizedString("最大基础率是允许 %1$@ 制定的最大自动调整基础率，以帮助达到您的校正范围。", comment: "Information about maximum basal rate (1: app name)"), appName))
                Text(LocalizedString("一些用户选择一个值2、3或4倍的基础速率。", comment: "Information about typical maximum basal rates"))
                Text(LocalizedString("与您的医疗保健提供商合作，选择一个高于您计划的最高基础价格的价值，但是您感到舒适，但保守或积极进取。", comment: "Disclaimer"))
            }
            .foregroundColor(.secondary)
        }
    }
    
    private var maxBolusDescription: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(DeliveryLimits.Setting.maximumBolus.title)
            .font(.headline)
            VStack(alignment: .leading, spacing: 20) {
                    Text(String(format: LocalizedString("最大推注量是您允许 %1$@ 一次性推荐的最高推注量，用于补充碳水化合物或降低高血糖。", comment: "Information about maximum bolus (1: app name)"), appName))
                    Text(String(format: LocalizedString("该设置还将确定自动给药的安全限值。 %1$@ 将限制自动输送，以将活性胰岛素的量保持在最大推注量的两倍以下。", comment: "Information about maximum automated insulin on board (1: app name)"), appName))
            }
           .foregroundColor(.secondary)
        }
    }
}

