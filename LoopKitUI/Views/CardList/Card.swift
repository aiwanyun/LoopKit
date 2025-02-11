//
//  Card.swift
//  LoopKitUI
//
//  Created by Michael Pangburn on 4/14/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI


/// A platter displaying a number of components over a rounded background tile.
///
/// In a `CardStackBuilder`, a single-component `Card` is implicitly created from any expression conforming to `View`.
/// A multi-component `Card` can be constructed using one of `Card`'s initializers.
///
/// A multi-component card may consist of purely static components:
/// ```
/// Card {
///     Text("顶部")
///     Text("中间")
///     Text("底部")
/// }
/// ```
///
/// Cards of a dynamic number of components can be constructed from identifiable data:
/// ```
/// Card(of: 1...5, id: \.self) { value in
///     Text("\(value)")
/// }
/// ```
///
/// Finally, dynamic components can be unrolled to intermix with static components via `Splat`:
/// ```
/// Card {
///     Text("上述动态数据")
///     Splat(1...5, id: \.self) { value in
///         Text("Dynamic data \(value)")
///     }
///     Text("以下动态数据")
/// }
/// ```
public struct Card: View {
    var parts: [AnyView?]
    var backgroundColor: Color = Color(.secondarySystemGroupedBackground)

    public var body: some View {
        VStack {
            ForEach(parts.indices, id: \.self) { index in
                Group {
                    if self.parts[index] != nil {
                        VStack {
                            self.parts[index]!
                                .padding(.top, 4)

                            if index != self.parts.indices.last! {
                                CardSectionDivider()
                            }
                        }
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(CardBackground(color: backgroundColor))
        .padding(.horizontal)
    }
}

extension Card {
    init(_ other: Self, backgroundColor: Color? = nil) {
        self.parts = other.parts
        self.backgroundColor = backgroundColor ?? other.backgroundColor
    }

    func backgroundColor(_ color: Color?) -> Self { Self(self, backgroundColor: color) }
}

extension Card {
    public enum Component {
        case `static`(AnyView)
        case dynamic([(view: AnyView, id: AnyHashable)])
    }

    public init(@CardBuilder card: () -> Card) {
        self = card()
    }

    public init<Data: RandomAccessCollection, ID: Hashable, Content: View>(
        of data: Data,
        id: KeyPath<Data.Element, ID>,
        rowContent: (Data.Element) -> Content
    ) {
        self.init(components: [.dynamic(Splat(data, id: id, rowContent: rowContent).identifiedViews)])
    }

    public init<Data: RandomAccessCollection, Content: View>(
        of data: Data,
        @ViewBuilder rowContent:  (Data.Element) -> Content
    ) where Data.Element: Identifiable {
        self.init(of: data, id: \.id, rowContent: rowContent)
    }

    init(reducing cards: [Card]) {
        self.parts = cards.flatMap { $0.parts }
    }

    /// `nil` values denote placeholder positions where a view may become visible upon state change.
    init(components: [Component?]) {
        self.parts = components.map { component in
            switch component {
            case .static(let view):
                return view
            case .dynamic(let identifiedViews):
                return AnyView(
                    ForEach(identifiedViews, id: \.id) { view, id in
                        VStack {
                            view
                            if id != identifiedViews.last?.id {
                                CardSectionDivider()
                            }
                        }
                    }
                )
            case nil:
                return nil
            }
        }
    }
}

public struct CardBackground: View {
    var color: Color
    
    public init(color: Color = Color(.secondarySystemGroupedBackground)) {
        self.color = color
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .foregroundColor(color)
    }
}

public struct CardSectionDivider: View {
    public init() {}
    
    public var body: some View {
        Divider()
            .padding(.trailing, -16)
    }
}
