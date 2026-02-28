import Cocoa
import Defaults

class ColorHistoryManager {
    private var debounceWorkItem: DispatchWorkItem?

    func recordImmediate(_ color: NSColor) {
        addColor(color)
    }

    func recordDebounced(_ color: NSColor) {
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.addColor(color)
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }

    private func addColor(_ color: NSColor) {
        let hex = color.toHexString()
        var history = Defaults[.colorHistory]
        if let index = history.firstIndex(of: hex) {
            history.remove(at: index)
        }
        history.insert(hex, at: 0)
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        Defaults[.colorHistory] = history
    }
}
