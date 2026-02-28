import Cocoa
import Foundation

struct PaletteColor: Equatable {
    /// Full-precision color for rendering and format conversion.
    let color: NSColor
    /// Hex string used as an identifier (e.g. for color history lookups).
    let hex: String
    let name: String?

    static func == (lhs: PaletteColor, rhs: PaletteColor) -> Bool {
        lhs.hex == rhs.hex && lhs.name == rhs.name
    }
}

struct ColorPalette: Identifiable, Equatable {
    let id: String
    let name: String
    let colors: [PaletteColor]
}

/// Parses palette text format: `[Name]` header followed by comma-separated colors
/// with optional `(label)` names. Supports all color formats: hex, rgb(), hsl(),
/// hsb(), lab(), oklch(), rgba(). Example: `#FF6B35(Tangerine), oklch(80% 0.15 90)`
enum PaletteParser {
    /// Splits a color line on commas that are outside parentheses, so that
    /// values like `rgb(255, 0, 0)` are kept intact.
    static func splitColorEntries(_ line: String) -> [String] {
        var entries: [String] = []
        var current = ""
        var parenDepth = 0

        for char in line {
            switch char {
            case "(":
                parenDepth += 1
                current.append(char)
            case ")":
                parenDepth = max(0, parenDepth - 1)
                current.append(char)
            case "," where parenDepth == 0:
                entries.append(current)
                current = ""
            default:
                current.append(char)
            }
        }
        if !current.trimmingCharacters(in: .whitespaces).isEmpty {
            entries.append(current)
        }
        return entries
    }

    /// Extracts an optional trailing `(label)` name from a color entry.
    /// For function-style colors like `rgb(255, 0, 0)(Red)`, identifies the
    /// label as the parenthesized group that follows the function's closing paren.
    /// Distinguishes labels from function arguments by checking whether what
    /// precedes the trailing `(...)` is itself a valid color string.
    private static func extractNameAndColorString(_ entry: String) -> (colorString: String, name: String?) {
        let trimmed = entry.trimmingCharacters(in: .whitespaces)

        // Walk backward: if the entry ends with `)`, check whether it's a trailing label.
        guard trimmed.hasSuffix(")") else {
            return (trimmed, nil)
        }

        // Find the matching `(` for the final `)`.
        var depth = 0
        var labelOpenIndex: String.Index?
        for index in trimmed.indices.reversed() {
            if trimmed[index] == ")" { depth += 1 }
            else if trimmed[index] == "(" {
                depth -= 1
                if depth == 0 {
                    labelOpenIndex = index
                    break
                }
            }
        }

        guard let openIdx = labelOpenIndex else {
            return (trimmed, nil)
        }

        let beforeLabel = trimmed[trimmed.startIndex ..< openIdx]
            .trimmingCharacters(in: .whitespaces)

        guard !beforeLabel.isEmpty else {
            return (trimmed, nil)
        }

        // Only treat the trailing (...) as a name label if what precedes it
        // is a valid color. Otherwise the parens are the color function's own
        // arguments (e.g. `oklch(...)` with no label).
        guard NSColor.fromColorString(beforeLabel) != nil else {
            return (trimmed, nil)
        }

        let nameContent = String(trimmed[trimmed.index(after: openIdx) ..< trimmed.index(before: trimmed.endIndex)])
            .trimmingCharacters(in: .whitespaces)

        let name = nameContent.isEmpty ? nil : nameContent
        return (beforeLabel, name)
    }

    static func parseColorEntry(_ entry: String) -> PaletteColor? {
        let (colorString, name) = extractNameAndColorString(entry)

        guard let color = NSColor.fromColorString(colorString) else { return nil }
        return PaletteColor(color: color, hex: color.toHexString(), name: name)
    }

    /// Walks palette text line-by-line, yielding each `[Name]` + colors-line pair.
    /// Handler returns `true` to stop early (used by parse() to cap at 5 palettes).
    private static func enumerateSections(
        _ text: String,
        handler: (_ name: String, _ colorsLine: String) -> Bool
    ) {
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
                currentName = nil
                let shouldStop = handler(name, trimmed)
                if shouldStop { return }
            }
        }
    }

    static func parse(_ text: String) -> [ColorPalette] {
        var palettes: [ColorPalette] = []

        enumerateSections(text) { name, colorsLine in
            let colors = splitColorEntries(colorsLine)
                .compactMap { parseColorEntry($0) }
                .prefix(20)

            if !colors.isEmpty {
                // Index prefix ensures unique IDs when multiple palettes share a name.
                palettes.append(ColorPalette(
                    id: "\(palettes.count):\(name)",
                    name: name,
                    colors: Array(colors)
                ))
            }
            return palettes.count >= 5
        }

        return palettes
    }

    static func validate(_ text: String) -> String? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        var paletteCount = 0
        var maxColorsExceeded = false

        enumerateSections(text) { _, colorsLine in
            paletteCount += 1
            let colorCount = splitColorEntries(colorsLine)
                .compactMap { parseColorEntry($0) }.count
            if colorCount > 20 {
                maxColorsExceeded = true
            }
            return false
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
