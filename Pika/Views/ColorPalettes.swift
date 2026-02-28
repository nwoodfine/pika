import SwiftUI

struct ColorPalettes: View {
    let palettes: [ColorPalette]
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
        ForEach(palettes) { palette in
            Divider()
            ColorPaletteBar(palette: palette)
                .environmentObject(eyedroppers)
                .padding(.top, 10.0)
                .padding(.bottom, 12.0)
                .background(VisualEffect(
                    material: NSVisualEffectView.Material.underWindowBackground,
                    blendingMode: NSVisualEffectView.BlendingMode.behindWindow
                ))
        }
    }
}
