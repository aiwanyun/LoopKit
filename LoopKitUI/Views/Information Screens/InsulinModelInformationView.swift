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
            },
            onExit: onExit ?? { self.presentationMode.wrappedValue.dismiss() },
            mode: mode
        )
    }
    
    private var diaInfo: Text {
        Text(String(format: LocalizedString("%1$@ assumes that the insulin it has delivered is actively working to lower your glucose for 6 hours. This setting cannot be changed.", comment: "Information about insulin action duration (1: app name)"), appName))
    }
    
    private var modelPeakInfo: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text(String(format: LocalizedString("You can choose how %1$@ measures rapid acting insulin's peak activity according to one of these two insulin models.", comment: "Information about insulin model (1: app name)"), appName))
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
