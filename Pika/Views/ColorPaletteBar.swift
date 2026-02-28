import Defaults
import SwiftUI

struct ColorPaletteBar: View {
    let palette: ColorPalette
    @EnvironmentObject var eyedroppers: Eyedroppers
    @State private var hoveredColor: PaletteColor?
    @State private var isHoveringBar = false

    private var hoverText: String {
        guard let color = hoveredColor else { return " " }
        return color.name.map { "\($0) (\(color.hex))" } ?? color.hex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text(palette.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                Text(hoverText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isHoveringBar ? 1 : 0)
                    .animation(.easeInOut(duration: 0.15), value: isHoveringBar)
            }
            .padding(.horizontal, 12.0)

            GeometryReader { geometry in
                let colors = palette.colors
                HStack(spacing: 0) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                        Rectangle()
                            .fill(Color(NSColor(hex: color.hex)))
                            .frame(width: geometry.size.width / CGFloat(colors.count))
                            .onHover { hovering in
                                if hovering { hoveredColor = color }
                            }
                            .onTapGesture {
                                eyedroppers.foreground.set(
                                    NSColor(hex: color.hex),
                                    recordToHistory: false
                                )
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
    }
}
