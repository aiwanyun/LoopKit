//
//  CorrectionRangeOverrideInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import SwiftUI

public struct CorrectionRangeOverrideInformationView: View {
    let preset: CorrectionRangeOverrides.Preset
    var onExit: (() -> Void)?
    let mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.carbTintColor) var carbTintColor
    @Environment(\.glucoseTintColor) var glucoseTintColor
    @Environment(\.appName) var appName

    public init(
        preset: CorrectionRangeOverrides.Preset,
        onExit: (() -> Void)? = nil,
        mode: SettingsPresentationMode = .acceptanceFlow
    ) {
        self.preset = preset
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        GlucoseTherapySettingInformationView(
            therapySetting: preset.therapySetting,
            onExit: onExit,
            mode: mode,
            appName: appName,
            text: AnyView(section(for: preset))
        )
    }
    
    private func section(for preset: CorrectionRangeOverrides.Preset) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            description(for: preset)
                .foregroundColor(.secondary)
        }
    }
        
    private func description(for preset: CorrectionRangeOverrides.Preset) -> some View {
        switch preset {
        case .preMeal:
            return VStack(alignment: .leading, spacing: 20) {
                Text(String(format: LocalizedString("您的餐前范围应该是您在吃第一口饭时希望 %1$@ 达到的目标血糖值（或值范围）。 当您激活餐前预设按钮时，该范围将生效。", comment: "Information about pre-meal range format (1: app name)"), appName))
                Text(LocalizedString("这通常是", comment: "Information about pre-meal range relative to correction range")) + Text(LocalizedString("降低", comment: "Information about pre-meal range relative to correction range")).bold().italic() + Text(LocalizedString("比您的更正范围。", comment: "Information about pre-meal range relative to correction range"))
            }
            .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
        case .workout:
            return VStack(alignment: .leading, spacing: 20) {
                Text(String(format: LocalizedString("锻炼范围是您希望 %1$@ 在活动期间达到的目标葡萄糖值或值范围。 当您激活“锻炼预设”按钮时，该范围将生效。", comment: "Information about workout range format (1: app name)"), appName))
                Text(LocalizedString("这通常是", comment: "Information about workout range relative to correction range")) + Text(LocalizedString("更高", comment: "Information about workout range relative to correction range")).bold().italic() + Text(LocalizedString("比您的更正范围。", comment: "Information about workout range relative to correction range"))
            }
            .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
        }
    }
}

struct CorrectionRangeOverrideInformationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CorrectionRangeOverrideInformationView(preset: .preMeal)
        }
        .colorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE 2"))
        .previewDisplayName("Pre-Meal SE light")
        NavigationView {
            CorrectionRangeOverrideInformationView(preset: .workout)
        }
        .colorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE 2"))
        .previewDisplayName("Workout SE light")
        NavigationView {
            CorrectionRangeOverrideInformationView(preset: .preMeal)
        }
        .preferredColorScheme(.dark)
        .colorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        .previewDisplayName("Pre-Meal 11 Pro dark")
        NavigationView {
            CorrectionRangeOverrideInformationView(preset: .workout)
        }
        .preferredColorScheme(.dark)
        .colorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        .previewDisplayName("Workout 11 Pro dark")
    }
}
