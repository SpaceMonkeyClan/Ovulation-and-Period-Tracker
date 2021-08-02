//
//  CalendarView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import SwiftUI

/// Shows the calendar with the date selections
struct CalendarView: View {
    
    @Binding var month: Date
    @Binding var currentSelectedDate: Date?

    /// Selected dates and the colors
    let selectedDates: [Date]
    let selectedDatesColors: [Date: Color]
    
    /// Header and Footer views for the calendar
    let headerView: AnyView
    let footerView: AnyView
    
    // MARK: - Main rendering function
    var body: some View {
        VStack(spacing: 15) {
            headerView
            CalendarMainView
            footerView
        }
    }
    
    // MARK: - Create the days of the week header view
    private var WeekdaysHeaderView: some View {
        HStack {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self, content: { day in
                ZStack {
                    Rectangle().hidden()
                    Text(day.uppercased()).bold()
                }.lineLimit(1).minimumScaleFactor(0.5)
            })
        }.frame(height: 50)
    }
    
    // MARK: - Calendar view
    private var CalendarMainView: some View {
        VStack(spacing: 0) {
            WeekdaysHeaderView
            Divider()
            ForEach(weeks, id: \.self) { week in
                WeekView(week: week)
            }.frame(height: 50)
        }.padding([.leading, .trailing], 20).padding([.top, .bottom], 10).background(
            RoundedRectangle(cornerRadius: 30).foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        ).padding([.leading, .trailing], 20)
    }
    
    // MARK: - Create the week view
    private func WeekView(week: Date) -> some View {
        HStack(spacing: 0) {
            ForEach(days(week: week), id: \.self) { date in
                HStack {
                    /// Date of the week button
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()
                        currentSelectedDate = date
                    }, label: {
                        WeekdayTextView(date: date, week: week)
                    }).foregroundColor(selectedDates.contains(date) ? .white : .black)
                }
            }
        }
    }
    
    /// Week day text
    private func WeekdayTextView(date: Date, week: Date) -> some View {
        ZStack {
            /// Background view for each day
            Rectangle().foregroundColor(.clear).background(
                ZStack {
                    /// Current selected date to be marked accordingly
                    if currentSelectedDate == date && date < Date() {
                        Circle().foregroundColor(Color(#colorLiteral(red: 0.9329922199, green: 0.9263274074, blue: 0.9380961061, alpha: 1))).overlay(
                            Circle().strokeBorder(Color(#colorLiteral(red: 0.8559404016, green: 0.8606798053, blue: 0.872363925, alpha: 1)), lineWidth: 1)
                        )
                    } else {
                        /// Marked selected day
                        if selectedDates.contains(date) {
                            Circle().foregroundColor(selectedDatesColors[date])
                        }
                    }
                }.padding(8)
            )
            if Calendar.current.isDate(week, equalTo: date, toGranularity: .month) && date < Date() {
                Text(date.day)
                    .font(.system(size: Calendar.current.isDateInToday(date) ? 22 : 20, weight: Calendar.current.isDateInToday(date) ? .bold : .regular))
            } else {
                Text(date.day).opacity(selectedDates.contains(date) ? 1 : 0.2)
            }
        }
    }

    /// Get all the weeks for the current selected month
    private var weeks: [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: month)
            else { return [] }
        return Calendar.current.generateDates(inside: monthInterval, matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: Calendar.current.firstWeekday))
    }
    
    /// Get all the days for a given week day
    private func days(week: Date) -> [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return Calendar.current.generateDates(inside: weekInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
}
