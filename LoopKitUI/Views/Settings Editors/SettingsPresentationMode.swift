//
//  SettingsPresentationMode.swift
//  LoopKitUI
//
//  Created by Anna Quinlan on 7/21/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

/// Represents the different modes that settings screens might be represented in
public enum SettingsPresentationMode {
    /// Presentation is in the onboarding acceptance flow
    case acceptanceFlow
    /// Presentation is under the settings ("gear icon") screen
    case settings
}

extension SettingsPresentationMode {
    /// Text for the button at the bottom of the settings screen
    func buttonText(isSaving: Bool = false) -> String {
        switch self {
        case .acceptanceFlow:
            return LocalizedString("确认设置", comment: "The button text for confirming the setting")
        case .settings:
            if isSaving {
                return LocalizedString("保存...", comment: "The button text during saving on a configuration page")
            } else {
                return LocalizedString("保存", comment: "The button text for saving on a configuration page")
            }
        }
    }
}
