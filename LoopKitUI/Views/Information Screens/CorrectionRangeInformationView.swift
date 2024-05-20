//
//  CorrectionRangeInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct CorrectionRangeInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) var appName

    public init(onExit: (() -> Void)? = nil, mode: SettingsPresentationMode = .acceptanceFlow) {
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        GlucoseTherapySettingInformationView(
            therapySetting: .glucoseTargetRange,
            onExit: onExit,
            mode: mode,
            appName: appName,
            text: text
        )
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(LocalizedString("如果您以前使用过CGM，则您可能熟悉目标范围作为血糖通知警报所需的广泛值，例如70-180 mg/dl或90-200 mg/dl。", comment: "Information about target range"))
            Text(LocalizedString("校正范围不同。这将是一个较窄的范围。", comment: "Information about differences between target range and correction range"))
            .bold()
            Text(String(format: LocalizedString("For this range, choose the specific glucose value (or range of values) that you want %1$@ to aim for in adjusting your basal insulin.", comment: "Information about correction range format (1: app name)"), appName))
            Text(LocalizedString("您的医疗保健提供者可以帮助您选择适合您的更正范围。", comment: "Disclaimer"))
        }
    }
}

struct CorrectionRangeInformationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CorrectionRangeInformationView()
        }
        .colorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE 2"))
        .previewDisplayName("SE light")
        NavigationView {
            CorrectionRangeInformationView()
        }
        .preferredColorScheme(.dark)
        .colorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        .previewDisplayName("11 Pro dark")
    }
}
