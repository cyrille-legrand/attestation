import Foundation

public func wait(_ Δ: TimeInterval, then: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Δ, execute: then)
}

prefix operator ^

public prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    { root in root[keyPath: keyPath] }
}

prefix operator ↑
prefix operator ↓

public prefix func ↑ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
}

public prefix func ↓ <Root, Value: Comparable>(keyPath: KeyPath<Root, Value>) -> (Root, Root) -> Bool {
    { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
}

// https://twitter.com/cyrillusmaximus/status/1139519511021981696?s=20
// Twitter is the new Stack Overflow.
public protocol Withable {}
extension NSObject: Withable {}
extension Withable where Self: NSObject {
    @discardableResult
    public func with<T>(_ kp: WritableKeyPath<Self, T>, _ value: T) -> Self {
        var mutableSelf = self
        mutableSelf[keyPath: kp] = value
        return self
    }

    @discardableResult
    public func with<T>(_ kp: ReferenceWritableKeyPath<Self, T>, _ value: T) -> Self {
        self[keyPath: kp] = value
        return self
    }
}
