//
//  InsulinType.swift
//  LoopKit
//
//  Created by Anna Quinlan on 12/8/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation

public enum InsulinType: Int, Codable, CaseIterable {
    case novolog
    case humalog
    case apidra
    case fiasp
    case lyumjev
    case afrezza
    
    public var title: String {
        switch self {
        case .novolog:
            return LocalizedString("Novolog（胰岛素阿斯帕特）", comment: "Title for Novolog insulin type")
        case .humalog:
            return LocalizedString("Humalog（胰岛素lispro）", comment: "Title for Humalog insulin type")
        case .apidra:
            return LocalizedString("阿皮德拉（胰岛素胰岛素）", comment: "Title for Apidra insulin type")
        case .fiasp:
            return LocalizedString("fiasp", comment: "Title for Fiasp insulin type")
        case .lyumjev:
            return LocalizedString("Lyumjev", comment: "Title for Lyumjev insulin type")
        case .afrezza:
            return LocalizedString("afrezza", comment: "Title for Afrezza insulin type")
        }
    }
    
    public var brandName: String {
        switch self {
        case .novolog:
            return LocalizedString("Novolog", comment: "Brand name for novolog insulin type")
        case .humalog:
            return LocalizedString("Humalog", comment: "Brand name for humalog insulin type")
        case .apidra:
            return LocalizedString("阿皮德拉", comment: "Brand name for apidra insulin type")
        case .fiasp:
            return LocalizedString("fiasp", comment: "Brand name for fiasp insulin type")
        case .lyumjev:
            return LocalizedString("Lyumjev", comment: "Brand name for lyumjev insulin type")
        case .afrezza:
            return LocalizedString("afrezza", comment: "Brand name for afrezza insulin type")
        }
    }
    
    public var description: String {
        switch self {
        case .novolog:
            return LocalizedString("Novolog（胰岛素Aspart）是Novo Nordisk制造的快速作用胰岛素", comment: "Description for novolog insulin type")
        case .humalog:
            return LocalizedString("Humalog（胰岛素lispro）是Eli Lilly制造的快速作用胰岛素", comment: "Description for humalog insulin type")
        case .apidra:
            return LocalizedString("阿皮德拉（胰岛素纤维素）是由sanofi-aventis制造的快速作用胰岛素", comment: "Description for apidra insulin type")
        case .fiasp:
            return LocalizedString("FIASP是一种用餐时间胰岛素阿斯帕特配方", comment: "Description for fiasp insulin type")
        case .lyumjev:
            return LocalizedString("lyumjev是一种用餐时间胰岛素lispro配方", comment: "Description for lyumjev insulin type")
        case .afrezza:
            return LocalizedString("Afrezza是一种超快速作用的进餐时间胰岛素，使用口服吸入器并由Mannkind制成", comment: "Description for afrezza insulin type")
        }
    }
    
    public var pumpAdministerable: Bool {
        switch self {
        case .afrezza:
            return false
        default:
            return true
        }
    }
}
