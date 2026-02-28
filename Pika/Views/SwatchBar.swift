import SwiftUI

struct Swatch: Identifiable, Equatable {
    let id: String
    let hex: String
    let hoverText: String
}

struct SwatchBar: View {
    let title: String
    let swatches: [Swatch]
    let onTap: (Swatch) -> Void

    @State private var hoveredSwatch: Swatch?
    @State private var isHoveringBar = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                Text(hoveredSwatch?.hoverText ?? " ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isHoveringBar ? 1 : 0)
                    .animation(.easeInOut(duration: 0.15), value: isHoveringBar)
            }
            .padding(.horizontal, 12.0)

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(swatches) { swatch in
                        Rectangle()
                            .fill(Color(NSColor(hex: swatch.hex)))
                            .frame(width: geometry.size.width / CGFloat(swatches.count))
                            .onHover { hovering in
                                if hovering { hoveredSwatch = swatch }
                            }
                            .onTapGesture {
                                onTap(swatch)
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4.0))
                .onHover { hovering in
                    isHoveringBar = hovering
                    if !hovering { hoveredSwatch = nil }
                }
            }
            .frame(height: 16)
            .padding(.horizontal, 12.0)
        }
    }
}
