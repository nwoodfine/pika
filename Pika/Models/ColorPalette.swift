import Foundation

struct PaletteColor: Equatable {
    let hex: String
    let name: String?
}

struct ColorPalette: Identifiable, Equatable {
    let id: String
    let name: String
    let colors: [PaletteColor]
}

enum PaletteParser {
    static func normalizeHex(_ input: String) -> String? {
        var hex = input.trimmingCharacters(in: .whitespaces)
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        guard hex.allSatisfy(\.isHexDigit) else { return nil }
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        guard hex.count == 6 else { return nil }
        return "#\(hex.lowercased())"
    }

    static func parseColorEntry(_ entry: String) -> PaletteColor? {
        var trimmed = entry.trimmingCharacters(in: .whitespaces)
        var name: String?

        if let openParen = trimmed.lastIndex(of: "("),
           let closeParen = trimmed.lastIndex(of: ")"),
           closeParen > openParen
        {
            let nameStr = String(trimmed[trimmed.index(after: openParen) ..< closeParen])
                .trimmingCharacters(in: .whitespaces)
            if !nameStr.isEmpty {
                name = nameStr
            }
            trimmed = String(trimmed[trimmed.startIndex ..< openParen])
                .trimmingCharacters(in: .whitespaces)
        }

        guard let hex = normalizeHex(trimmed) else { return nil }
        return PaletteColor(hex: hex, name: name)
    }

    static func parse(_ text: String) -> [ColorPalette] {
        var palettes: [ColorPalette] = []
        let lines = text.components(separatedBy: .newlines)
        var currentName: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("["), trimmed.hasSuffix("]") {
                let name = String(trimmed.dropFirst().dropLast())
                    .trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    currentName = name
                }
                continue
            }

            if let name = currentName, !trimmed.isEmpty {
                let colors = trimmed
                    .components(separatedBy: ",")
                    .compactMap { parseColorEntry($0) }
                    .prefix(20)

                if !colors.isEmpty {
                    palettes.append(ColorPalette(
                        id: name,
                        name: name,
                        colors: Array(colors)
                    ))
                }
                currentName = nil

                if palettes.count >= 5 { break }
            }
        }

        return palettes
    }

    static func validate(_ text: String) -> String? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let lines = text.components(separatedBy: .newlines)
        var paletteCount = 0
        var currentName: String?
        var maxColorsExceeded = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("["), trimmed.hasSuffix("]") {
                let name = String(trimmed.dropFirst().dropLast())
                    .trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    currentName = name
                }
                continue
            }
            if currentName != nil, !trimmed.isEmpty {
                paletteCount += 1
                let colorCount = trimmed.components(separatedBy: ",")
                    .compactMap { parseColorEntry($0) }.count
                if colorCount > 20 {
                    maxColorsExceeded = true
                }
                currentName = nil
            }
        }

        if paletteCount > 5 {
            return "Maximum 5 palettes"
        }
        if maxColorsExceeded {
            return "Maximum 20 colors per palette"
        }
        return nil
    }
}
