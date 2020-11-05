import Foundation

extension Date {
    public func progress(between start: Date, and end: Date) -> Double {
        guard start < end else { return 0 }
        return min(1, max(0, Date().timeIntervalSince(start) / end.timeIntervalSince(start)))
    }

    public func progress(in interval: ClosedRange<Date>) -> Double {
        progress(between: interval.lowerBound, and: interval.upperBound)
    }

    public var dmy: DateComponents {
        Calendar.current.dateComponents([.day, .month, .year], from: self)
    }

    public var isPast: Bool { timeIntervalSinceNow < 0 }
    public var isFuture: Bool { timeIntervalSinceNow > 0 }
    public var isToday: Bool { midnight == Date().midnight }
    public var isTomorrow: Bool { midnight == Date.tomorrow.midnight }

    public var midnight: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    public var timeIntervalSinceMidnight: TimeInterval {
        timeIntervalSince(midnight)
    }

    public static var midnight: Date {
        Date().midnight
    }

    public static var timeIntervalSinceMidnight: TimeInterval {
        Date().timeIntervalSinceMidnight
    }

    public static var tomorrow: Date {
        Date().midnight >> 1.day
    }

    public static var yesterday: Date {
        Date().midnight >> (-1).day
    }
}

public func >> (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(rhs)
}

public func << (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(-rhs)
}

public func >> (lhs: Date, rhs: DateComponents) -> Date {
    Calendar.current.date(byAdding: rhs, to: lhs)!
}

extension ClosedRange where Bound == Date {
    public var isPresent: Bool { contains(Date()) }
    public var isPast: Bool { upperBound.isPast }
    public var isFuture: Bool { lowerBound.isFuture }
}

extension Int {
    public var hours: DateComponents { var ret = DateComponents(); ret.hour = self; return ret }
    public var days: DateComponents { var ret = DateComponents(); ret.day = self; return ret }
    public var weeks: DateComponents { var ret = DateComponents(); ret.day = 7 * self; return ret }
    public var months: DateComponents { var ret = DateComponents(); ret.month = self; return ret }
    public var years: DateComponents { var ret = DateComponents(); ret.year = self; return ret }

    public var hour: DateComponents { var ret = DateComponents(); ret.hour = self; return ret }
    public var day: DateComponents { var ret = DateComponents(); ret.day = self; return ret }
    public var week: DateComponents { var ret = DateComponents(); ret.day = 7 * self; return ret }
    public var month: DateComponents { var ret = DateComponents(); ret.month = self; return ret }
    public var year: DateComponents { var ret = DateComponents(); ret.year = self; return ret }
}

extension DateComponents {
    public init?(day: Int, month: Int, year: Int) {
        self = DateComponents()
        self.day = day
        self.month = month
        self.year = year
    }

    public func and(_ other: DateComponents) -> DateComponents {
        var ret = self
        if let d = other.day { ret.day = (ret.day ?? 0) + d }
        if let m = other.month { ret.month = (ret.month ?? 0) + m }
        if let y = other.year { ret.year = (ret.year ?? 0) + y }
        if let h = other.hour { ret.hour = (ret.hour ?? 0) + h }
        if let m = other.minute { ret.minute = (ret.minute ?? 0) + m }
        if let s = other.second { ret.second = (ret.second ?? 0) + s }
        return ret
    }

    public var negated: DateComponents {
        var ret = DateComponents()
        if let d = day { ret.day = -d }
        if let m = month { ret.month = -m }
        if let y = year { ret.year = -y }
        if let h = hour { ret.hour = -h }
        if let m = minute { ret.minute = -m }
        if let s = second { ret.second = -s }
        return ret
    }

    public var ago: Date { Calendar.current.date(byAdding: negated, to: Date())! }
    public var fromNow: Date { Calendar.current.date(byAdding: self, to: Date())! }
    public var date: Date { Calendar.current.date(from: self)! }

    public static var today: DateComponents { Calendar.current.dateComponents([.day, .month, .year], from: Date())
    }
}

extension DateFormatter {
    public convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }

    public convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool = false) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        self.doesRelativeDateFormatting = relative
    }

    public static var shortDate = DateFormatter(dateStyle: .short, timeStyle: .none)
    
    public static var shortTime = DateFormatter(dateStyle: .none, timeStyle: .short)
    
    public static var relativeDate = DateFormatter(dateStyle: .short, timeStyle: .none, relative: true)
    
    public static var relativeDateTime = DateFormatter(dateStyle: .short, timeStyle: .short, relative: true)
}

public protocol Dated {
    var date: Date { get }
}

public extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Date, using formatter: DateFormatter) {
        appendLiteral(formatter.string(from: value))
    }
}
