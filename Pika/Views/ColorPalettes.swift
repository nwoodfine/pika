import SwiftUI

struct ColorPalettes: View {
    let palettes: [ColorPalette]
    @EnvironmentObject var eyedroppers: Eyedroppers

    var body: some View {
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
