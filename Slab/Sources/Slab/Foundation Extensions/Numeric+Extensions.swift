import CoreGraphics
import Foundation

public protocol NiceStringable {
    var niceString: String { get }
}

extension CGFloat: NiceStringable {
    public var niceString: String {
        if ceil(self) == floor(self) {
            return String(Int(ceil(self)))
        }
        else {
            return "\(self)"
        }
    }
}

extension Double: NiceStringable {
    public var niceString: String {
        if ceil(self) == floor(self) {
            return String(Int(ceil(self)))
        }
        else {
            return "\(self)"
        }
    }
}

extension Float: NiceStringable {
    public var niceString: String {
        if ceil(self) == floor(self) {
            return String(Int(ceil(self)))
        }
        else {
            return "\(self)"
        }
    }
}
