//
//  AddEditOverrideTableViewController.swift
//  Loop
//
//  Created by Michael Pangburn on 1/2/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import UIKit
import HealthKit
import LoopKit


public protocol AddEditOverrideTableViewControllerDelegate: AnyObject {
    func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didSavePreset preset: TemporaryScheduleOverridePreset)
    func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didSaveOverride override: TemporaryScheduleOverride)
    func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didCancelOverride override: TemporaryScheduleOverride)
}

// MARK: - Default Implementations
extension AddEditOverrideTableViewControllerDelegate {
    public func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didSavePreset preset: TemporaryScheduleOverridePreset) { }
    public func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didSaveOverride override: TemporaryScheduleOverride) { }
    public func addEditOverrideTableViewController(_ vc: AddEditOverrideTableViewController, didCancelOverride override: TemporaryScheduleOverride) { }
}


private extension TimeInterval {
    static let defaultOverrideDuration: TimeInterval = .hours(1)
}

public final class AddEditOverrideTableViewController: UITableViewController {

    // MARK: - Public configuration API

    public enum InputMode {
        case newPreset                                                  // Creating a new preset
        case editPreset(TemporaryScheduleOverridePreset)                // Editing an existing preset
        case customizePresetOverride(TemporaryScheduleOverridePreset)   // Defining an override relative to an existing preset
        case customOverride                                             // Defining a one-off custom override
        case editOverride(TemporaryScheduleOverride)                    // Editing an active override
        case viewOverride(TemporaryScheduleOverride)                    // Viewing an override
    }

    public enum DismissalMode {
        case dismissModal
        case popViewController
    }

    public var inputMode: InputMode = .newPreset {
        didSet {
            switch inputMode {
            case .newPreset:
                symbol = nil
                name = nil
                targetRange = nil
                insulinNeedsScaleFactor = 1.0
                duration = .finite(.defaultOverrideDuration)
            case .editPreset(let preset), .customizePresetOverride(let preset):
                symbol = preset.symbol
                name = preset.name
                configure(with: preset.settings)
                duration = preset.duration
            case .customOverride:
                symbol = nil
                name = nil
                targetRange = nil
                insulinNeedsScaleFactor = 1.0
                startDate = Date()
                duration = .finite(.defaultOverrideDuration)
            case .editOverride(let override):
                if case .preset(let preset) = override.context {
                    symbol = preset.symbol
                    name = preset.name
                } else {
                    symbol = nil
                    name = nil
                }
                configure(with: override.settings)
                startDate = override.startDate
                duration = override.duration
                enactTrigger = override.enactTrigger
                syncIdentifier = override.syncIdentifier
            case .viewOverride(let override):
                if case .preset(let preset) = override.context {
                    symbol = preset.symbol
                    name = preset.name
                } else {
                    symbol = nil
                    name = nil
                }
                configure(with: override.settings)
                startDate = override.startDate
                duration = override.duration
                syncIdentifier = override.syncIdentifier
            }
        }
    }

    public var customDismissalMode: DismissalMode?

    public weak var delegate: AddEditOverrideTableViewControllerDelegate?

    // MARK: - Override properties

    private let glucoseUnit: HKUnit

    private var symbol: String? { didSet { updateSaveButtonEnabled() } }

    private var name: String? { didSet { updateSaveButtonEnabled() } }

    private var targetRange: DoubleRange? { didSet { updateSaveButtonEnabled() } }

    private var insulinNeedsScaleFactor = 1.0 { didSet { updateSaveButtonEnabled() }}

    private var startDate = Date()

    private var duration: TemporaryScheduleOverride.Duration = .finite(.defaultOverrideDuration)
    
    private var enactTrigger: TemporaryScheduleOverride.EnactTrigger = .local

    private var syncIdentifier = UUID()
    
    private var isConfiguringPreset: Bool {
        switch inputMode {
        case .newPreset, .editPreset:
            return true
        case .customizePresetOverride, .customOverride, .editOverride, .viewOverride:
            return false
        }
    }

    private func configure(with settings: TemporaryScheduleOverrideSettings) {
        if let targetRange = settings.targetRange {
            self.targetRange = DoubleRange(minValue: targetRange.lowerBound.doubleValue(for: glucoseUnit), maxValue: targetRange.upperBound.doubleValue(for: glucoseUnit))
        } else {
            self.targetRange = nil
        }
        insulinNeedsScaleFactor = settings.effectiveInsulinNeedsScaleFactor
    }

    // MARK: - Initialization & view life cycle

    public init(glucoseUnit: HKUnit) {
        self.glucoseUnit = glucoseUnit
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        setupBarButtonItems()

        tableView.register(LabeledTextFieldTableViewCell.nib(), forCellReuseIdentifier: LabeledTextFieldTableViewCell.className)
        tableView.register(DoubleRangeTableViewCell.nib(), forCellReuseIdentifier: DoubleRangeTableViewCell.className)
        tableView.register(DecimalTextFieldTableViewCell.nib(), forCellReuseIdentifier: DecimalTextFieldTableViewCell.className)
        tableView.register(InsulinSensitivityScalingTableViewCell.nib(), forCellReuseIdentifier: InsulinSensitivityScalingTableViewCell.className)
        tableView.register(DateAndDurationTableViewCell.nib(), forCellReuseIdentifier: DateAndDurationTableViewCell.className)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.className)
        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: TextButtonTableViewCell.className)
    }

    // MARK: - UITableViewDataSource

    private enum Section: Int, CaseIterable {
        case properties = 0
        case cancel
    }

    private enum PropertyRow: Int, CaseIterable {
        case symbol
        case name
        case insulinNeeds
        case targetRange
        case startDate
        case endDate
        case durationFiniteness
        case duration
    }

    private var propertyRows: [PropertyRow] {
        var rows: [PropertyRow] = {
            if isConfiguringPreset {
                return [.symbol, .name, .insulinNeeds, .targetRange, .durationFiniteness]
            } else if case let .viewOverride(override) = inputMode, override.hasFinished() {
                return [.insulinNeeds, .targetRange, .startDate, .endDate]
            } else {
                return [.insulinNeeds, .targetRange, .startDate, .durationFiniteness]
            }
        }()

        if duration.isFinite {
            rows.append(.duration)
        }

        rows.sort(by: { $0.rawValue < $1.rawValue })
        return rows
    }

    private func propertyRow(for indexPath: IndexPath) -> PropertyRow {
        return propertyRows[indexPath.row]
    }

    private func indexPath(for row: PropertyRow) -> IndexPath? {
        guard let rowIndex = propertyRows.firstIndex(of: row) else {
            return nil
        }
        return IndexPath(row: rowIndex, section: 0)
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        if case .editOverride = inputMode {
            return Section.allCases.count
        } else {
            // No cancel button available unless override is already set
            return Section.allCases.count - 1
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .properties:
            return propertyRows.count
        case .cancel:
            return 1
        }
    }

    private lazy var quantityFormatter: QuantityFormatter = {
        let formatter = QuantityFormatter(for: glucoseUnit)
        return formatter
    }()

    private lazy var overrideSymbolKeyboard: EmojiInputController = {
        let keyboard = OverrideSymbolInputController()
        keyboard.delegate = self
        return keyboard
    }()

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .properties:
            switch propertyRow(for: indexPath) {
            case .symbol:
                let cell = tableView.dequeueReusableCell(withIdentifier: LabeledTextFieldTableViewCell.className, for: indexPath) as! LabeledTextFieldTableViewCell
                cell.titleLabel.text = LocalizedString("标识", comment: "The text for the custom preset symbol setting")
                cell.textField.text = symbol
                cell.textField.placeholder = SettingsTableViewCell.NoValueString
                cell.maximumTextLength = 2
                cell.customInput = overrideSymbolKeyboard
                cell.delegate = self
                return cell
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: LabeledTextFieldTableViewCell.className, for: indexPath) as! LabeledTextFieldTableViewCell
                cell.titleLabel.text = LocalizedString("姓名", comment: "The text for the custom preset name setting")
                cell.textField.text = name
                cell.textField.placeholder = LocalizedString("运行", comment: "The text for the custom preset name field placeholder")
                cell.delegate = self
                return cell
            case .insulinNeeds:
                let cell = tableView.dequeueReusableCell(withIdentifier: InsulinSensitivityScalingTableViewCell.className, for: indexPath) as! InsulinSensitivityScalingTableViewCell
                cell.scaleFactor = insulinNeedsScaleFactor
                cell.delegate = self
                return cell
            case .targetRange:
                let cell = tableView.dequeueReusableCell(withIdentifier: DoubleRangeTableViewCell.className, for: indexPath) as! DoubleRangeTableViewCell
                cell.numberFormatter = quantityFormatter.numberFormatter
                cell.titleLabel.text = LocalizedString("目标范围", comment: "The text for the custom preset target range setting")
                cell.range = targetRange
                cell.unitLabel.text = quantityFormatter.localizedUnitStringWithPlurality()
                cell.delegate = self
                return cell
            case .startDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: DateAndDurationTableViewCell.className, for: indexPath) as! DateAndDurationTableViewCell
                cell.titleLabel.text = LocalizedString("开始时间", comment: "The text for the custom preset start time")
                cell.datePicker.datePickerMode = .dateAndTime
                cell.datePicker.preferredDatePickerStyle = .wheels
                cell.datePicker.minimumDate = min(startDate, Date())
                cell.date = startDate
                cell.delegate = self
                return cell
            case .endDate:
                guard case let .viewOverride(override) = inputMode else {
                    fatalError("endDate should only be used when viewing override history")
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: DateAndDurationTableViewCell.className, for: indexPath) as! DateAndDurationTableViewCell
                cell.titleLabel.text = LocalizedString("时间结束", comment: "The text for the override start time")
                cell.datePicker.datePickerMode = .dateAndTime
                cell.date = override.actualEndDate
                return cell
            case .durationFiniteness:
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className, for: indexPath) as! SwitchTableViewCell
                cell.selectionStyle = .none
                cell.textLabel?.text = LocalizedString("无限期启用", comment: "The text for the indefinite custom preset duration setting")
                cell.switch?.isOn = !duration.isFinite
                cell.switch?.addTarget(self, action: #selector(durationFinitenessChanged), for: .valueChanged)
                return cell
            case .duration:
                let cell = tableView.dequeueReusableCell(withIdentifier: DateAndDurationTableViewCell.className, for: indexPath) as! DateAndDurationTableViewCell
                cell.titleLabel.text = LocalizedString("期间", comment: "The text for the custom preset duration setting")
                cell.datePicker.datePickerMode = .countDownTimer
                guard case .finite(let duration) = duration else {
                    preconditionFailure("Duration should only be selectable when duration is finite")
                }
                // Use the actual duration if we're retrospectively viewing overrides
                if case let .viewOverride(override) = inputMode {
                    cell.titleLabel.text = LocalizedString("活动持续时间", comment: "The text for the override history duration")
                    cell.datePicker.minuteInterval = 1
                    cell.duration = override.actualEndDate.timeIntervalSince(override.startDate)
                } else {
                    cell.titleLabel.text = LocalizedString("期间", comment: "The text for the override duration setting")
                    cell.datePicker.minuteInterval = 15
                    cell.duration = duration
                }
                cell.maximumDuration = .hours(24)
                cell.delegate = self
                return cell
            }
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextButtonTableViewCell.className, for: indexPath) as! TextButtonTableViewCell
            if startDate > Date() {
                cell.textLabel?.text = LocalizedString("取消", comment: "The text for the scheduled custom preset cancel button")
            } else {
                cell.textLabel?.text = LocalizedString("禁用预设", comment: "The text for the custom preset disable button")
            }
            cell.textLabel?.textAlignment = .center
            cell.tintColor = .defaultButtonTextColor
            return cell
        }
    }

    @objc private func durationFinitenessChanged(_ sender: UISwitch) {
        if sender.isOn {
            setDurationIndefinite()
        } else {
            setDurationFinite()
        }
    }

    private func setDurationIndefinite() {
        guard let durationIndexPath = indexPath(for: .duration) else {
            assertionFailure("Unable to locate duration row")
            return
        }
        duration = .indefinite
        tableView.deleteRows(at: [durationIndexPath], with: .automatic)
    }

    private func setDurationFinite() {
        switch inputMode {
        case .newPreset, .customOverride:
            duration = .finite(.defaultOverrideDuration)
        case .editPreset(let preset), .customizePresetOverride(let preset):
            switch preset.duration {
            case .finite(let interval):
                duration = .finite(interval)
            case .indefinite:
                duration = .finite(.defaultOverrideDuration)
            }
        case .editOverride(let override), .viewOverride(let override):
            if case .preset(let preset) = override.context,
                case .finite(let interval) = preset.duration {
                duration = .finite(interval)
            } else {
                switch override.duration {
                case .finite(let interval):
                    duration = .finite(interval)
                case .indefinite:
                    duration = .finite(.defaultOverrideDuration)
                }
            }
        }

        guard let durationIndexPath = indexPath(for: .duration) else {
            assertionFailure("Unable to locate duration row")
            return
        }
        tableView.insertRows(at: [durationIndexPath], with: .automatic)
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else {
            return nil
        }

        switch inputMode {
        case .customizePresetOverride(let preset):
            return String(format: LocalizedString("Changes will only apply this time you enable the preset. The default settings of %@ will not be affected.", comment: "Footer text for customizing from a preset (1: preset name)"), preset.name)
        case .editOverride(let override):
            guard case .preset(let preset) = override.context else {
                return nil
            }
            return String(format: LocalizedString("Edits persist only until the preset is disabled. The default settings of %@ will not be affected.", comment: "Footer text for editing an enabled custom preset (1: preset name)"), preset.name)
        default:
            return nil
        }
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch Section(rawValue: indexPath.section)! {
        case .properties:
            tableView.endEditing(false)
            tableView.beginUpdates()
            collapseExpandableCells(excluding: indexPath)
        case .cancel:
            break
        }

        return indexPath
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .properties:
            tableView.endUpdates()
            tableView.deselectRow(at: indexPath, animated: true)

            if let cell = tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell, !cell.isFirstResponder {
                cell.textField.becomeFirstResponder()
            }
        case .cancel:
            guard case .editOverride(let override) = inputMode else {
                assertionFailure("Only an already-set override can be canceled")
                return
            }
            delegate?.addEditOverrideTableViewController(self, didCancelOverride: override)
            dismiss()
        }
    }

    private func collapseExpandableCells(excluding indexPath: IndexPath? = nil) {
        tableView.beginUpdates()
        hideDatePickerCells(excluding: indexPath)
        collapseInsulinSensitivityScalingCells(excluding: indexPath)
        tableView.endUpdates()
    }
}

// MARK: - Navigation item configuration

extension AddEditOverrideTableViewController {
    private func setupTitle() {
        if let symbol = symbol, let name = name {
            let format = LocalizedString("%1$@ %2$@", comment: "The format for a preset symbol and name (1: symbol)(2: name)")
            title = String(format: format, symbol, name)
        } else {
            switch inputMode {
            case .newPreset:
                title = LocalizedString("新预设", comment: "The title for the new custom preset entry screen")
            case .editPreset, .customizePresetOverride:
                assertionFailure("Editing or customizing a preset means we'll have a symbol and a name")
            case .customOverride:
                title = LocalizedString("自定义预设", comment: "The title for the custom preset entry screen")
            case .editOverride:
                title = LocalizedString("编辑", comment: "The title for the enabled custom preset editing screen")
            case .viewOverride:
                title = LocalizedString("查看覆盖", comment: "The title for the override editing screen")
            }
        }
    }

    private func setupBarButtonItems() {
        switch inputMode {
        case .newPreset, .editPreset, .editOverride:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        case .customizePresetOverride, .customOverride:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString("开启", comment: "The button text for enabling a temporary override"), style: .done, target: self, action: #selector(save))
        case .viewOverride: break
        }

        updateSaveButtonEnabled()

        switch inputMode {
        case .newPreset:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        default:
            break
        }
    }

    private var configuredSettings: TemporaryScheduleOverrideSettings? {
        if let targetRange = targetRange {
            guard targetRange.maxValue >= targetRange.minValue else {
                return nil
            }
        } else {
            guard insulinNeedsScaleFactor != 1.0 else {
                return nil
            }
        }

        return TemporaryScheduleOverrideSettings(
            unit: glucoseUnit,
            targetRange: targetRange,
            insulinNeedsScaleFactor: insulinNeedsScaleFactor == 1.0 ? nil : insulinNeedsScaleFactor
        )
    }

    private var configuredPreset: TemporaryScheduleOverridePreset? {
        guard
            let symbol = symbol, !symbol.isEmpty,
            let name = name, !name.isEmpty,
            let settings = configuredSettings
        else {
            return nil
        }

        let id: UUID
        if case .editPreset(let preset) = inputMode {
            id = preset.id
        } else {
            id = UUID()
        }

        return TemporaryScheduleOverridePreset(id: id, symbol: symbol, name: name, settings: settings, duration: duration)
    }

    private var configuredOverride: TemporaryScheduleOverride? {
        guard let settings = configuredSettings else {
            return nil
        }

        let context: TemporaryScheduleOverride.Context
        switch inputMode {
        case .customizePresetOverride(let preset):
            let customizedPreset = TemporaryScheduleOverridePreset(
                symbol: preset.symbol,
                name: preset.name,
                settings: settings,
                duration: duration
            )
            context = .preset(customizedPreset)
        case .editOverride(let override), .viewOverride(let override):
            context = override.context
        case .customOverride:
            context = .custom
        case .newPreset, .editPreset:
            assertionFailure()
            return nil
        }

        return TemporaryScheduleOverride(context: context, settings: settings, startDate: startDate, duration: duration, enactTrigger: enactTrigger, syncIdentifier: syncIdentifier)
    }

    private func updateSaveButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = {
            switch inputMode {
            case .newPreset, .editPreset:
                return configuredPreset != nil
            case .customizePresetOverride, .customOverride, .editOverride:
                return configuredOverride != nil
            case .viewOverride:
                return false
            }
        }()
    }

    @objc private func save() {
        switch inputMode {
        case .newPreset, .editPreset:
            guard let configuredPreset = configuredPreset else {
                assertionFailure("Save button cannot be tapped when preset is invalid")
                break
            }
            delegate?.addEditOverrideTableViewController(self, didSavePreset: configuredPreset)
        case .customizePresetOverride, .customOverride, .editOverride:
            guard let configuredOverride = configuredOverride else {
                assertionFailure("Save button cannot be tapped when override is invalid")
                break
            }
            delegate?.addEditOverrideTableViewController(self, didSaveOverride: configuredOverride)
        case .viewOverride: break
        }
        dismiss()
    }

    @objc private func cancel() {
        dismiss()
    }

    private func dismiss() {
        if let customDismissalMode = customDismissalMode {
            dismiss(with: customDismissalMode)
        } else {
            switch inputMode {
            case .newPreset, .customizePresetOverride, .customOverride:
                dismiss(with: .dismissModal)
            case .editPreset, .editOverride, .viewOverride:
                dismiss(with: .popViewController)
            }
        }
    }

    private func dismiss(with mode: DismissalMode) {
        switch mode {
        case .dismissModal:
            dismiss(animated: true)
        case .popViewController:
            assert(navigationController != nil)
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Delegation

extension AddEditOverrideTableViewController: TextFieldTableViewCellDelegate {
    public func textFieldTableViewCellDidBeginEditing(_ cell: TextFieldTableViewCell) {
        collapseExpandableCells()
    }

    public func textFieldTableViewCellDidEndEditing(_ cell: TextFieldTableViewCell) {
        updateWithText(from: cell)
    }

    public func textFieldTableViewCellDidChangeEditing(_ cell: TextFieldTableViewCell) {
        updateWithText(from: cell)
    }

    private func updateWithText(from cell: TextFieldTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        switch propertyRow(for: indexPath) {
        case .symbol:
            symbol = cell.textField.text
        case .name:
            name = cell.textField.text
        default:
            assertionFailure()
        }
    }
}

extension AddEditOverrideTableViewController: EmojiInputControllerDelegate {
    public func emojiInputControllerDidAdvanceToStandardInputMode(_ controller: EmojiInputController) {
        guard
            let indexPath = indexPath(for: .symbol),
            let cell = tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell,
            let textField = cell.textField as? CustomInputTextField
        else {
            return
        }

        let customInput = textField.customInput
        textField.customInput = nil
        textField.resignFirstResponder()
        textField.becomeFirstResponder()
        textField.customInput = customInput
    }
}

extension AddEditOverrideTableViewController: InsulinSensitivityScalingTableViewCellDelegate {
    func insulinSensitivityScalingTableViewCellDidUpdateScaleFactor(_ cell: InsulinSensitivityScalingTableViewCell) {
        insulinNeedsScaleFactor = cell.scaleFactor
    }
}

extension AddEditOverrideTableViewController: DatePickerTableViewCellDelegate {
    public func datePickerTableViewCellDidUpdateDate(_ cell: DatePickerTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        switch propertyRow(for: indexPath) {
        case .startDate:
            startDate = cell.date
        case .duration:
            duration = .finite(cell.duration)
        default:
            assertionFailure()
        }
    }
}

extension AddEditOverrideTableViewController: DoubleRangeTableViewCellDelegate {
    func doubleRangeTableViewCellDidBeginEditing(_ cell: DoubleRangeTableViewCell) {
        collapseExpandableCells()
    }

    func doubleRangeTableViewCellDidUpdateRange(_ cell: DoubleRangeTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        switch propertyRow(for: indexPath) {
        case .targetRange:
            targetRange = cell.range
        default:
            assertionFailure()
        }
    }
}

private extension UIColor {
    static let defaultButtonTextColor = UIButton(type: .system).titleColor(for: .normal)
}

private extension UIFont {
    func bold() -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return nil
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
