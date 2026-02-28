import Defaults
import SwiftUI

struct ColorHistory: View {
    @Default(.colorHistory) var colorHistory
    @EnvironmentObject var eyedroppers: Eyedroppers
    @State private var hoveredHex: String?
    @State private var isHoveringBar = false

    var body: some View {
        if !colorHistory.isEmpty {
            Divider()
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Text(PikaText.textColorHistory)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(hoveredHex ?? " ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(isHoveringBar ? 1 : 0)
                        .animation(.easeInOut(duration: 0.15), value: isHoveringBar)
                }
                .padding(.horizontal, 12.0)

                GeometryReader { geometry in
                    let colors = Array(colorHistory.prefix(20))
                    HStack(spacing: 0) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { _, hex in
                            Rectangle()
                                .fill(Color(NSColor(hex: hex)))
                                .frame(width: geometry.size.width / CGFloat(colors.count))
                                .onHover { hovering in
                                    if hovering { hoveredHex = hex }
                                }
                                .onTapGesture {
                                    eyedroppers.foreground.set(
                                        NSColor(hex: hex),
                                        recordToHistory: false
                                    )
                                    // Move this exact hex to front of history
                                    var history = Defaults[.colorHistory]
                                    if let index = history.firstIndex(of: hex) {
                                        history.remove(at: index)
                                    }
                                    history.insert(hex, at: 0)
                                    Defaults[.colorHistory] = history

                                    NSApp.sendAction(
                                        #selector(AppDelegate.triggerCopyForeground),
                                        to: nil,
                                        from: nil
                                    )
                                }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    .onHover { hovering in
                        isHoveringBar = hovering
                    }
                }
                .frame(height: 16)
                .padding(.horizontal, 12.0)
            }
            .padding(.top, 10.0)
            .padding(.bottom, 12.0)
            .background(VisualEffect(
                material: NSVisualEffectView.Material.underWindowBackground,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            ))
        }
    }
}
