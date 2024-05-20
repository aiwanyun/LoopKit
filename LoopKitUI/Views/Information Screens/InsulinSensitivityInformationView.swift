//
//  InsulinSensitivityInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/28/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct InsulinSensitivityInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        onExit: (() -> Void)?,
        mode: SettingsPresentationMode = .acceptanceFlow
    ){
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        InformationView(
            title: Text(TherapySetting.insulinSensitivity.title),
            informationalContent: {text},
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(LocalizedString("您的胰岛素敏感性因子（ISF）是一种胰岛素单位预期的血糖下降。", comment: "Description of insulin sensitivity factor"))
            Text(LocalizedString("您可以通过使用➕在一天中的不同时间添加不同的胰岛素敏感性。", comment: "Description of how to add a ratio"))
        }
        .accentColor(.secondary)
    }
}

