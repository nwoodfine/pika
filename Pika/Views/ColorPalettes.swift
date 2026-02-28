import Defaults
import SwiftUI

struct ColorPalettes: View {
    @Default(.paletteText) var paletteText
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
        let palettes = PaletteParser.parse(paletteText).filter { !$0.colors.isEmpty }
        if !palettes.isEmpty {
            Divider()
            VStack(alignment: .leading, spacing: 6.0) {
                ForEach(palettes) { palette in
                    ColorPaletteBar(palette: palette)
                        .environmentObject(eyedroppers)
                }
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
