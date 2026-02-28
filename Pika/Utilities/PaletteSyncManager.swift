import Cocoa
import Defaults
import Security

class PaletteSyncManager {
    private var store: NSUbiquitousKeyValueStore?
    private let key = "paletteText"
    private var lastCloudAppliedValue: String?

    private static var hasKVSEntitlement: Bool {
        guard let task = SecTaskCreateFromSelf(nil) else { return false }
        let value = SecTaskCopyValueForEntitlement(
            task, "com.apple.developer.ubiquity-kvstore-identifier" as CFString, nil
        )
        return value != nil
    }

    init() {
        if Self.hasKVSEntitlement {
            let kvStore = NSUbiquitousKeyValueStore.default
            store = kvStore

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(cloudDidChange(_:)),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: kvStore
            )

            kvStore.synchronize()

            if let cloudValue = kvStore.string(forKey: key), Defaults[.paletteText].isEmpty {
                lastCloudAppliedValue = cloudValue
                Defaults[.paletteText] = cloudValue
            }
        }

        Defaults.observe(.paletteText) { [weak self] change in
            guard let self = self else { return }
            if change.newValue == self.lastCloudAppliedValue {
                self.lastCloudAppliedValue = nil
                return
            }
            self.store?.set(change.newValue, forKey: self.key)
        }.tieToLifetime(of: self)
    }

    @objc private func cloudDidChange(_ notification: Notification) {
        guard let store = store,
              let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
        else { return }

        switch reason {
        case NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange,
             NSUbiquitousKeyValueStoreAccountChange:
            if let cloudValue = store.string(forKey: key) {
                if cloudValue != Defaults[.paletteText] {
                    lastCloudAppliedValue = cloudValue
                }
                Defaults[.paletteText] = cloudValue
            }
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            NSLog("PaletteSyncManager: iCloud KVS quota exceeded")
        default:
            break
        }
    }
}
