//
//  ConfigurationPage.swift
//  LoopKitUI
//
//  Created by Michael Pangburn on 4/10/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI


public enum ConfigurationPageActionButtonState {
    case enabled
    case loading
    case disabled
}

public struct ConfigurationPage<ActionAreaContent: View>: View {
    public typealias ActionButtonState = ConfigurationPageActionButtonState

    var title: Text
    var actionButtonTitle: Text
    var actionButtonState: ActionButtonState
    var cardListStyle: CardListStyle
    var actionAreaContent: ActionAreaContent
    var action: () -> Void

    public var body: some View {
        VStack(spacing: 0) {
            CardList(title: title, style: cardListStyle)

            VStack(spacing: 0) {
                actionAreaContent
                    .padding([.top, .horizontal])
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))

                Button(
                    action: action,
                    label: {
                        HStack(spacing: 12) {
                            ActivityIndicator(isAnimating: .constant(false), style: .medium)
                                .opacity(0) // For layout only, to ensure the button text is centered

                            actionButtonTitle
                            .animation(nil)

                            ActivityIndicator(isAnimating: .constant(true), style: .medium, color: .white)
                                .opacity(actionButtonState == .loading ? 1 : 0)
                        }
                    }
                )
                .buttonStyle(ActionButtonStyle(.primary))
                .disabled(actionButtonState != .enabled)
                .padding()
            }
            .padding(.bottom) // FIXME: unnecessary on iPhone 8 size devices
            .background(Color(.secondarySystemGroupedBackground).shadow(radius: 5))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension ConfigurationPage {
    public init(
        title: Text,
        actionButtonTitle: Text,
        actionButtonState: ActionButtonState = .enabled,
        @CardStackBuilder cards: () -> CardStack,
        @ViewBuilder actionAreaContent: () -> ActionAreaContent,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.actionButtonTitle = actionButtonTitle
        self.actionButtonState = actionButtonState
        self.cardListStyle = .simple(cards())
        self.actionAreaContent = actionAreaContent()
        self.action = action
    }

    /// Convenience initializer for a page whose action is 'Save'
    public init(
        title: Text,
        saveButtonState: ActionButtonState = .enabled,
        @CardStackBuilder cards: () -> CardStack,
        @ViewBuilder actionAreaContent: () -> ActionAreaContent,
        onSave save: @escaping () -> Void
    ) {
        self.init(
            title: title,
            actionButtonTitle: Text(LocalizedString("保存", comment: "The button text for saving on a configuration page")),
            actionButtonState: saveButtonState,
            cards: cards,
            actionAreaContent: actionAreaContent,
            action: save
        )
    }

    /// Convenience initializer for a sectioned page whose action is 'Save'
    public init(
        title: Text,
        saveButtonState: ActionButtonState = .enabled,
        sections: [CardListSection],
        @ViewBuilder actionAreaContent: () -> ActionAreaContent,
        onSave save: @escaping () -> Void
    ) {
        self.init(
            title: title,
            actionButtonTitle: Text(LocalizedString("保存", comment: "The button text for saving on a configuration page")),
            actionButtonState: saveButtonState,
            cardListStyle: .sectioned(sections),
            actionAreaContent: actionAreaContent(),
            action: save
        )
    }
}

struct ConfigurationPage_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationPage(
            title: Text("例子"),
            cards: {
                Text("一张简单的卡")
                Text("如果我继续输入足够长的时间，其文字将包裹在多行上的卡片 - 该长度应该做")

                Card {
                    Text("顶部组件")
                    Text("底部组件")
                }

                Card(of: 1...3, id: \.self) { value in
                    Text("Dynamic component #\(value)")
                }
            },
            actionAreaContent: {
                Text("在保存按钮上方")
            },
            onSave: {}
        )
    }
}
