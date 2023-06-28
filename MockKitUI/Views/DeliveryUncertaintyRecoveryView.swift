//
//  DeliveryUncertaintyRecoveryView.swift
//  MockKitUI
//
//  Created by Pete Schwamb on 8/17/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI

struct DeliveryUncertaintyRecoveryView: View, HorizontalSizeClassOverride {
    @Environment(\.dismissAction) private var dismiss

    let appName: String
    let uncertaintyStartedAt: Date
    let recoverCommsTapped: () -> Void
    
    var body: some View {
        NavigationView {
            GuidePage(content: {
                Text("\(self.appName) 自此以来一直无法与模拟器泵通信 \(self.uncertaintyDateLocalizedString).\n\n如果没有通信，应用程序无法继续发送胰岛素输送命令或显示有关您的活性胰岛素或正在输送的胰岛素的准确的最新信息。")
            }) {
                Button(action: {
                    self.recoverCommsTapped()
                    self.dismiss()
                }) {
                    Text(LocalizedString("恢复模拟器", comment: "Button title recovering comms"))
                    .actionButtonStyle()
                    .padding()
                }
            }
            .environment(\.horizontalSizeClass, horizontalOverride)
            .navigationBarTitle(Text("通讯恢复"), displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        }
    }
    
    private var uncertaintyDateLocalizedString: String {
        DateFormatter.localizedString(from: uncertaintyStartedAt, dateStyle: .none, timeStyle: .short)
    }
    
    private var backButton: some View {
        Button(LocalizedString("后退", comment: "Back button text on DeliveryUncertaintyRecoveryView"), action: {
            self.dismiss()
        })
    }
}

struct DeliveryUncertaintyRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DeliveryUncertaintyRecoveryView(appName: "Test App", uncertaintyStartedAt: Date()) {
            print("Recover Comms")
        }
    }
}


// Wrapper to provide a CompletionNotifying ViewController
class DeliveryUncertaintyRecoveryViewController: UIHostingController<AnyView>, CompletionNotifying {
    
    public weak var completionDelegate: CompletionDelegate?
    
    init(appName: String, uncertaintyStartedAt: Date, recoverCommsTapped: @escaping () -> Void) {
        
        var dismiss = {}
        
        let view = DeliveryUncertaintyRecoveryView(appName: appName, uncertaintyStartedAt: uncertaintyStartedAt) {
            recoverCommsTapped()
            dismiss()
        }
        .environment(\.dismissAction, { dismiss() })
        
        super.init(rootView: AnyView(view))
        
        dismiss = {
            self.completionDelegate?.completionNotifyingDidComplete(self)
        }
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
