//
//  DateEntryModel.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/10/21.
//

import SwiftUI
import Foundation

/// A simple model to encapsulate the entry for a selected date
struct DateEntryModel {
    let date: Date
    let dateType: CycleDateType
    let timeline: PeriodTimeline?
    let flowType: FlowType?
    
    /// Date entry color
    var color: Color {
        flowType?.flowColor ?? dateType.color
    }
    
    /// Dictionary representation
    var dictionary: [String: Any] {
        var data = [String: Any]()
        data["date"] = "\(date.timeIntervalSince1970)"
        data["dateType"] = dateType.rawValue
        if let timelineType = timeline {
            data["timeline"] = timelineType.rawValue
        }
        if let flow = flowType {
            data["flowType"] = flow.rawValue
        }
        return data
    }
    
    /// Create a date entry model from dictionary
    /// NOTE: Force-unwrapping here `as! String` since we know for sure how the data is saved
    static func build(withData data: [String: Any]) -> DateEntryModel {
        DateEntryModel(date: Date(timeIntervalSince1970: Double(data["date"] as! String)!),
                       dateType: CycleDateType(rawValue: data["dateType"] as! String)!,
                       timeline: PeriodTimeline(rawValue: data["timeline"] as? String ?? ""),
                       flowType: FlowType(rawValue: data["flowType"] as? String ?? ""))
    }
}

// MARK: - Period timeline
enum PeriodTimeline: String {
    case start = "Start"
    case another = "Just another day"
    case end = "End"
}

// MARK: - Period blood flow type
enum FlowType: String, CaseIterable {
    case light, medium, heavy
    var flowColor: Color {
        switch self {
        case .light:
            return CycleDateType.period.color.opacity(0.4)
        case .medium:
            return CycleDateType.period.color.opacity(0.7)
        case .heavy:
            return CycleDateType.period.color
        }
    }
}

// MARK: - Time interval type
enum CycleDateType: String, CaseIterable {
    case period, fertile, ovulation
    /// Color for a specifi time interval
    var color: Color {
        switch self {
        case .period:
            return Color(#colorLiteral(red: 0.9019325972, green: 0.4388501048, blue: 0.3665972948, alpha: 1))
        case .fertile:
            return Color(#colorLiteral(red: 0.9234351516, green: 0.6777120829, blue: 0.34554106, alpha: 1))
        case .ovulation:
            return Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        }
    }
}

// MARK: - Date formatter
extension Date {
    var month: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var monthAndYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    var fullDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d, MMMM yyyy"
        return formatter.string(from: self)
    }
    
    var day: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
}

// MARK: - Generate arrays of dates
extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}
