//
//  BasalRatesInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/3/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct BasalRatesInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    var maximumScheduleEntryCount: Int
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) var appName
    
    public init(onExit: (() -> Void)?, mode: SettingsPresentationMode = .acceptanceFlow, maximumScheduleEntryCount: Int? = nil) {
        self.onExit = onExit
        self.mode = mode
        self.maximumScheduleEntryCount = maximumScheduleEntryCount ?? 48
    }
    
    public var body: some View {
        InformationView(
            title: Text(TherapySetting.basalRate.title),
            informationalContent: {text},
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(LocalizedString("您的基础胰岛素速率是您要使用的单位数量来满足背景胰岛素需求。", comment: "Information about basal rates"))
            Text(String(format: LocalizedString("%1$@ supports 1 to %2$@ rates per day.", comment: "Information about max number of basal rates (1: app name) (2: maximum schedule entry count)"), appName, String(describing: maximumScheduleEntryCount)))
            Text(LocalizedString("时间表从午夜开始，不能包含0 u/hr的速率。", comment: "Information about basal rate scheduling"))
        }
    }
}

struct BasalRatesInformationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BasalRatesInformationView(onExit: nil)
        }
        .colorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPod touch (7th generation)"))
        .previewDisplayName("SE light")
        
        NavigationView {
            BasalRatesInformationView(onExit: nil)
        }
        .preferredColorScheme(.dark)
        .colorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
        .previewDisplayName("12 Pro dark")
    }
}

