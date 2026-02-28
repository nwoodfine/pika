import SwiftUI

struct ColorPaletteBar: View {
    let palette: ColorPalette
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
        SwatchBar(
            title: palette.name,
            swatches: palette.colors.enumerated().map { index, color in
                Swatch(
                    id: "\(palette.id):\(index)",
                    hex: color.hex,
                    hoverText: color.name.map { "\($0) (\(color.hex))" } ?? color.hex
                )
            },
            onTap: { swatch in
                eyedroppers.foreground.set(
                    NSColor(hex: swatch.hex),
                    recordToHistory: false
                )
                NSApp.sendAction(
                    #selector(AppDelegate.triggerCopyForeground),
                    to: nil,
                    from: nil
                )
            }
        )
    }
}
