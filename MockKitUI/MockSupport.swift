//
//  MockSupport.swift
//  MockKitUI
//
//  Created by Rick Pasetto on 10/13/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit
import LoopKitUI
import SwiftUI

public class MockSupport: SupportUI {

    public static let supportIdentifier = "MockSupport"
    
    var versionUpdate: VersionUpdate?
    var alertIssuer: AlertIssuer? {
        return self.delegate
    }
    var lastVersionCheckAlertDate: Date?

    public init() { }

    public required init?(rawState: RawStateValue) {
        lastVersionCheckAlertDate = rawState["lastVersionCheckAlertDate"] as? Date
    }
    
    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["lastVersionCheckAlertDate"] = lastVersionCheckAlertDate
        return rawValue
    }

    public func initializationComplete(for services: [LoopKit.Service]) { }
   
    public func checkVersion(bundleIdentifier: String, currentVersion: String) async -> VersionUpdate? {
        maybeIssueAlert(versionUpdate ?? .noUpdateNeeded)
        return versionUpdate
    }
    
    public weak var delegate: SupportUIDelegate?

    public func configurationMenuItems() -> [LoopKitUI.CustomMenuItem] {
        return []
    }

    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        return AnyView(SupportMenuItem(mockSupport: self))
    }
    
    public func softwareUpdateView(bundleIdentifier: String, currentVersion: String, guidanceColors: GuidanceColors, openAppStore: (() -> Void)?) -> AnyView? {
        return AnyView(
            Button("versionUpdate: \(versionUpdate!.localizedDescription)\n\nbundleIdentifier: \(bundleIdentifier)\n\ncurrentVersion: \(currentVersion)") {
                openAppStore?()
            }
        )
    }
    
    public func getScenarios(from scenarioURLs: [URL]) -> [LoopScenario] {
        scenarioURLs.map { LoopScenario(name: $0.lastPathComponent, url: $0) }
    }
    
    public func loopWillReset() {}
    
    public func loopDidReset() {}
}

extension MockSupport {
    
    var alertCadence: TimeInterval {
        return TimeInterval.minutes(1)
    }
    
    private var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }

    private func maybeIssueAlert(_ versionUpdate: VersionUpdate) {
        guard versionUpdate >= .recommended else {
            noAlertNecessary()
            return
        }
        
        let alertIdentifier = Alert.Identifier(managerIdentifier: MockSupport.supportIdentifier, alertIdentifier: versionUpdate.rawValue)
        let alertContent: LoopKit.Alert.Content
        if firstAlert {
            alertContent = Alert.Content(title: versionUpdate.localizedDescription,
                                         body: String(format: LocalizedString("""
                                                     您的 %1$@ 应用程序已过时。 它将继续工作，但我们建议更新到最新版本。
                                                    
                                                     转至 %2$@ 设置 > 软件更新以完成。
                                                    """, comment: "Alert content body for first software update alert (1: app name)(2: app name)"), appName, appName),
                                         acknowledgeActionButtonLabel: LocalizedString("好的", comment: "Default acknowledgement"))
        } else if let lastVersionCheckAlertDate = lastVersionCheckAlertDate,
                  abs(lastVersionCheckAlertDate.timeIntervalSinceNow) > alertCadence {
            alertContent = Alert.Content(title: LocalizedString("更新提醒", comment: "Recurring software update alert title"),
                                         body: String(format: LocalizedString("""
                                                     建议进行软件更新以继续使用 %1$@ 应用程序。
                                                    
                                                     转至 %2$@ 设置 > 软件更新以安装最新版本。
                                                    """, comment: "Alert content body for recurring software update alert"), appName, appName),
                                         acknowledgeActionButtonLabel: LocalizedString("好的", comment: "Default acknowledgement"))
        } else {
            return
        }
        let interruptionLevel: LoopKit.Alert.InterruptionLevel = versionUpdate == .required ? .critical : .active
        alertIssuer?.issueAlert(Alert(identifier: alertIdentifier, foregroundContent: alertContent, backgroundContent: alertContent, trigger: .immediate, interruptionLevel: interruptionLevel))
        recordLastAlertDate()
    }
    
    private func noAlertNecessary() {
        lastVersionCheckAlertDate = nil
    }
    
    private var firstAlert: Bool {
        return lastVersionCheckAlertDate == nil
    }
    
    private func recordLastAlertDate() {
        lastVersionCheckAlertDate = Date()
    }
    
}

struct SupportMenuItem : View {
    
    let mockSupport: MockSupport
    
    @State var showActionSheet: Bool = false
    
    private var buttons: [ActionSheet.Button] {
        VersionUpdate.allCases.map { versionUpdate in
            let setter = { mockSupport.versionUpdate = versionUpdate }
            switch versionUpdate {
            case .required:
                return ActionSheet.Button.destructive(Text(versionUpdate.localizedDescription), action: setter)
            default:
                return ActionSheet.Button.default(Text(versionUpdate.localizedDescription), action: setter)
            }
        } +
        [.cancel(Text("取消"))]
    }

    private var actionSheet: ActionSheet {
        ActionSheet(title: Text("版本检查响应"), message: Text("模拟器应该如何响应版本检查？"), buttons: buttons)
    }

    var body: some View {
        Button(action: {
            self.showActionSheet.toggle()
        }) {
            Text("模拟版本检查 \(currentVersionUpdate)")
        }
        .actionSheet(isPresented: $showActionSheet, content: {
            self.actionSheet
        })
        
        Button(action: { mockSupport.lastVersionCheckAlertDate = nil } ) {
            Text("清除最后版本检查警报日期")
        }
    }
    
    var currentVersionUpdate: String {
        return mockSupport.versionUpdate.map { "(\($0.rawValue))" } ?? ""
    }
}
