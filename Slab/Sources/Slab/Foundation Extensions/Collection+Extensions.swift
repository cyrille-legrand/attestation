import Foundation

extension Collection {
    public func grouped(_ where: (Element) -> Bool) -> [[Element]] {
        guard !isEmpty else { return [] }
        var ret: [[Element]] = []
        var subret: [Element] = []
        for i in self {
            if `where`(i), !subret.isEmpty {
                ret.append(subret)
                subret = []
            }
            subret.append(i)
        }
        ret.append(subret)
        return ret
    }

    public var isNotEmpty: Bool {
        !isEmpty
    }
    
    public var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Sequence {
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, reversed r: Bool = false) -> [Element] {
        sorted { a, b in
            r ? a[keyPath: keyPath] > b[keyPath: keyPath]
                : a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension Array {
    public func removing(at index: Index) -> Array {
        var new = self
        new.remove(at: index)
        return new
    }

    public func appending(_ newElement: Element) -> Array {
        var ret = self
        ret.append(newElement)
        return ret
    }
}

extension Collection where Element: Equatable {
    public func replacing(_ old: Element, with new: Element) -> [Element] {
        map { $0 == old ? new : $0 }
    }
}

extension Optional where Wrapped: Collection {
    public var isEmpty: Bool {
        map(\.isEmpty) ?? true
    }

    public var isNotEmpty: Bool {
        map { !$0.isEmpty } ?? false
    }
}

extension Set {
    public mutating func toggle(_ member: Element) {
        if contains(member) { remove(member) }
        else { insert(member) }
    }
}
