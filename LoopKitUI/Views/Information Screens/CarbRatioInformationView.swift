//
//  CarbRatioInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/28/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct CarbRatioInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) private var appName

    public init(
        onExit: (() -> Void)?,
        mode: SettingsPresentationMode = .acceptanceFlow
    ){
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        InformationView(
            title: Text(TherapySetting.carbRatio.title),
            informationalContent: {text},
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(TherapySetting.carbRatio.descriptiveText(appName: appName))
            Text(LocalizedString("您可以通过使用➕在一天中的不同时间添加不同的碳水化合物比率。", comment: "Description of how to add a ratio"))
        }
        .accentColor(.secondary)
    }
}
