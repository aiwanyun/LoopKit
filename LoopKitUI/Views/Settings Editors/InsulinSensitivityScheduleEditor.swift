//
//  InsulinSensitivityScheduleEditor.swift
//  LoopKitUI
//
//  Created by Michael Pangburn on 4/20/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import HealthKit
import LoopKit


public struct InsulinSensitivityScheduleEditor: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    @Environment(\.appName) private var appName

    let mode: SettingsPresentationMode
    let viewModel: InsulinSensitivityScheduleEditorViewModel

    var displayGlucoseUnit: HKUnit {
        displayGlucosePreference.unit
    }

    public init(
        mode: SettingsPresentationMode,
        therapySettingsViewModel: TherapySettingsViewModel,
        didSave: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.viewModel = InsulinSensitivityScheduleEditorViewModel(
            therapySettingsViewModel: therapySettingsViewModel,
            didSave: didSave)
    }

    public var body: some View {
        QuantityScheduleEditor(
            title: Text(TherapySetting.insulinSensitivity.title),
            description: description,
            schedule: viewModel.insulinSensitivitySchedule?.schedule(for: displayGlucoseUnit),
            unit: sensitivityUnit,
            guardrail: .insulinSensitivity,
            defaultFirstScheduleItemValue: Guardrail.insulinSensitivity.startingSuggestion ?? Guardrail.insulinSensitivity.recommendedBounds.upperBound,
            confirmationAlertContent: confirmationAlertContent,
            guardrailWarning: InsulinSensitivityGuardrailWarning.init(crossedThresholds:),
            onSave: { insulinSensitivitySchedulePerU in
                // the sensitivity units are passed as the units to display `/U`
                // need to go back to displayGlucoseUnit. This does not affect the value
                // force unwrapping since dailyItems are already validated
                let insulinSensitivitySchedule = InsulinSensitivitySchedule(unit: displayGlucoseUnit,
                                                                            dailyItems: insulinSensitivitySchedulePerU.items,
                                                                            timeZone: insulinSensitivitySchedulePerU.timeZone)!
                viewModel.saveInsulinSensitivitySchedule(insulinSensitivitySchedule)
            },
            mode: mode,
            settingType: .insulinSensitivity
        )
    }

    private var description: Text {
        Text(TherapySetting.insulinSensitivity.descriptiveText(appName: appName))
    }

    private var sensitivityUnit: HKUnit {
        displayGlucoseUnit.unitDivided(by: .internationalUnit())
    }

    private var confirmationAlertContent: AlertContent {
        AlertContent(
            title: Text(LocalizedString("保存胰岛素敏感性？", comment: "Alert title for confirming insulin sensitivities outside the recommended range")),
            message: Text(TherapySetting.insulinSensitivity.guardrailSaveWarningCaption)
        )
    }
}

private struct InsulinSensitivityGuardrailWarning: View {
    var crossedThresholds: [SafetyClassification.Threshold]

    var body: some View {
        assert(!crossedThresholds.isEmpty)
        return GuardrailWarning(
            therapySetting: .insulinSensitivity,
            title: crossedThresholds.count == 1 ? singularWarningTitle(for: crossedThresholds.first!) : multipleWarningTitle,
            thresholds: crossedThresholds
        )
    }

    private func singularWarningTitle(for threshold: SafetyClassification.Threshold) -> Text {
        switch threshold {
        case .minimum, .belowRecommended:
            return Text(LocalizedString("低胰岛素灵敏度", comment: "Title text for the low insulin sensitivity warning"))
        case .aboveRecommended, .maximum:
            return Text(LocalizedString("高胰岛素灵敏度", comment: "Title text for the high insulin sensitivity warning"))
        }
    }

    private var multipleWarningTitle: Text {
        Text(LocalizedString("胰岛素敏感性", comment: "Title text for multi-value insulin sensitivity warning"))
    }
}
