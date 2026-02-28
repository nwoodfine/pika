import Defaults
import SwiftUI

struct ColorHistory: View {
    @Default(.colorHistory) var colorHistory
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
        if !colorHistory.isEmpty {
            Divider()
            VStack(alignment: .leading, spacing: 4.0) {
                Text(PikaText.textColorHistory)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12.0)

                GeometryReader { geometry in
                    let colors = Array(colorHistory.prefix(20))
                    HStack(spacing: 0) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { _, hex in
                            Rectangle()
                                .fill(Color(NSColor(hex: hex)))
                                .frame(width: geometry.size.width / CGFloat(colors.count))
                                .help(hex)
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
                }
                .frame(height: 16)
            }
            .padding(.top, 6.0)
            .padding(.bottom, 10.0)
            .background(VisualEffect(
                material: NSVisualEffectView.Material.underWindowBackground,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            ))
        }
    }
}
