//
//  InsulinModelInformationView.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/6/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

public struct InsulinModelInformationView: View {
    var onExit: (() -> Void)?
    var mode: SettingsPresentationMode
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appName) private var appName
    
    public init(onExit: (() -> Void)?, mode: SettingsPresentationMode = .acceptanceFlow) {
        self.onExit = onExit
        self.mode = mode
    }
    
    public var body: some View {
        InformationView(
            title: Text(TherapySetting.insulinModel.title),
            informationalContent: {
                VStack (alignment: .leading, spacing: 20) {
                    diaInfo
                    modelPeakInfo
                }
                .foregroundColor(.secondary)
            },
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var diaInfo: Text {
        Text(String(format: LocalizedString("%1$@ 假设它所输送的胰岛素在 6 小时内积极地降低您的血糖。 该设置无法更改。", comment: "Information about insulin action duration (1: app name)"), appName))
    }
    
    private var modelPeakInfo: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text(String(format: LocalizedString("您可以根据这两种胰岛素模型之一选择 %1$@ 如何测量速效胰岛素的峰值活性。", comment: "Information about insulin model (1: app name)"), appName))
            HStack(spacing: 10) {
                bulletCircle
                Text(LocalizedString("快速作用的成人模型在75分钟时假设峰值活性。", comment: "Information about adult insulin model"))
            }
            HStack(spacing: 10) {
                bulletCircle
                Text(LocalizedString("快速作用的儿童模型在65分钟时假设峰值活性。", comment: "Information about child insulin model"))
            }
        }
    }
    
    private var bulletCircle: some View {
        Image(systemName: "circle.fill")
        .resizable()
        .frame(width: 10, height: 10)
    }
}
