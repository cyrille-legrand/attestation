import Foundation

// Cross † is done as alt+T on a US (QWERTY) or FR (AZERTY) keyboard
// and as shift+alt+5 on my SuperQWERTY2 keyboard (Cyrille)
postfix operator †
public postfix func † (left: String) -> String {
    NSLocalizedString(left, comment: "?⃤ " + left + " ?⃤")
}

extension String {
    public var initials: String {
        components(separatedBy: .whitespacesAndNewlines).compactMap { String($0.first ?? Character("")) }.joined()
    }

    public var forSort: String {
        localizedLowercase.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    public var cleanedUp: String {
        String(self
                .folding(options: .diacriticInsensitive, locale: nil)
                .uppercased()
                .unicodeScalars.filter({ CharacterSet.alphanumerics.contains($0) })
        )
    }
}

extension Optional where Wrapped == String {
    public var forSort: String {
        self?.forSort ?? ""
    }
}

extension Collection where Element == String {
    public var noneIsEmpty: Bool {
        for i in self where i.isEmpty { return false }
        return true
    }
}

extension Collection where Element == String? {
    public func compactJoined(separator: String = "\n") -> String? {
        let mapped = compactMap { $0 }
        return mapped.isEmpty ? nil : mapped.joined(separator: separator)
    }
}
