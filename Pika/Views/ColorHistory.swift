import Defaults
import SwiftUI

struct ColorHistory: View {
    @Default(.colorHistory) var colorHistory
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
        let colors = Array(colorHistory.prefix(20))
        if !colors.isEmpty {
            Divider()
            SwatchBar(
                title: PikaText.textColorHistory,
                swatches: colors.map { Swatch(id: $0, hex: $0, hoverText: $0) },
                onTap: { swatch in
                    eyedroppers.foreground.set(
                        NSColor(hex: swatch.hex),
                        recordToHistory: false
                    )
                    eyedroppers.foreground.colorHistoryManager?.moveToFront(hex: swatch.hex)
                    NSApp.sendAction(
                        #selector(AppDelegate.triggerCopyForeground),
                        to: nil,
                        from: nil
                    )
                }
            )
            .padding(.top, 10.0)
            .padding(.bottom, 12.0)
            .background(VisualEffect(
                material: NSVisualEffectView.Material.underWindowBackground,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            ))
        }
    }
}
