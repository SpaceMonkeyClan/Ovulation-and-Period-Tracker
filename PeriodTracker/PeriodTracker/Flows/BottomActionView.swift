//
//  BottomActionView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import SwiftUI

// MARK: - Selected date steps
enum SelectedDateStep {
    case startEnd   /// ask the user to choose if the selected date is a Start, End or Another date of the period
    case flowType   /// ask the user to choose a period flow type
    case comeBack   /// ask the user to come back again tomorrow
    case completed  /// show the user the completed flow
    
    /// Title and Subtitle for each step
    var titleSubtitle: (title: String, subtitle: String) {
        switch self {
        case .startEnd:
            return ("Choose an option", "Is this day the START or the END of your period?")
        case .flowType:
            return ("Menstrual Flow", "How is your menstrual flow for this day?")
        case .comeBack:
            return ("Well Done!", "Come back tomorrow to track your period and flow again.")
        case .completed:
            return ("Congratulations!", "Your period has ended, you can now see the fertile and ovulation days above.")
        }
    }
}

/// Bottom action view to handle selected dates
struct BottomActionView: View {
    
    @ObservedObject var manager: PeriodManager
    @State private var currentStep: SelectedDateStep?
    @State private var selectedDateTimeline: PeriodTimeline?
    @State private var selectedDateFlowType: FlowType?
    
    // MARK: - Main rendering function
    var body: some View {
        updateCurrentStep()
        return ZStack {
            LinearGradient(gradient: Gradient(colors: AppConfig.bottomViewGradient), startPoint: .top, endPoint: .bottom)
                .mask(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
                .edgesIgnoringSafeArea(.bottom)
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: -3)
            VStack {
                if currentStep == nil {
                    SelectDateContinueView
                } else {
                    SelectedDateStepDetails
                }
            }
        }
    }
    
    /// Update current step based on selected date
    private func updateCurrentStep() {
        DispatchQueue.main.async {
            /// Set the initial start/end step when a date is selected
            if manager.currentSelectedDate != nil && currentStep == nil {
                self.currentStep = .startEnd
            }
        }
    }
    
    /// Selected date title and subtitle for each step
    private var SelectedDateStepDetails: some View {
        VStack(alignment: .center) {
            /// Header image based on the current step
            if currentStep == .completed {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).padding(5)
            } else if currentStep == .comeBack {
                Image(systemName: "calendar.badge.clock").font(.system(size: 40)).padding(5)
            }
            
            /// Title and Subtitle for each step
            Text(currentStep!.titleSubtitle.title).bold().font(.system(size: 30))
                .fixedSize(horizontal: false, vertical: true)
            Text(currentStep!.titleSubtitle.subtitle).font(.system(size: 22))
                .fixedSize(horizontal: false, vertical: true)
            
            /// Show the START/END of the period or just ANOTHER day
            if currentStep == .startEnd {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        PeriodTimelineButton(type: .start)
                        PeriodTimelineButton(type: .end)
                    }.font(.system(size: 30)).frame(height: 45)
                    PeriodTimelineButton(type: .another).frame(height: 45).font(.system(size: 25))
                }
            }
            
            /// Show the flow type options
            if currentStep == .flowType {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        FlowTypeButton(type: .light)
                        FlowTypeButton(type: .medium)
                    }.frame(height: 45)
                    FlowTypeButton(type: .heavy).frame(height: 45)
                }.font(.system(size: 20))
            }
        }.foregroundColor(.white).font(.system(size: 30)).multilineTextAlignment(.center).padding(30)
    }
    
    /// Select a date to continue view
    private var SelectDateContinueView: some View {
        VStack(alignment: .center) {
            Image(systemName: "calendar").font(.system(size: 40)).padding(5)
            Text("Select a date").bold().font(.system(size: 32))
            Text("You must select a date to track").font(.system(size: 25))
        }.foregroundColor(.white).font(.system(size: 30)).multilineTextAlignment(.center).padding(20)
    }
    
    // MARK: - Create Start/End button
    private func PeriodTimelineButton(type: PeriodTimeline) -> some View {
        var isEnabled = false
        let periodEntries = manager.selectedEntries.filter({ $0.dateType == .period })
        
        switch type {
        case .start:
            /// Start period is enabled only when there is no period in progress
            isEnabled = !manager.hasInProgressPeriod
        case .end:
            /// End period is enabled only when there is a period in progress
            if let date = manager.currentSelectedDate {
                let selectedDates = periodEntries.compactMap({ $0.date }).sorted(by: { $0 > $1 })
                isEnabled = manager.hasInProgressPeriod && date > selectedDates.last! && date <= Date()
            }
        case .another:
            /// Any other day for the period is enabled when there is a period in progress and date is greater than start date
            if let date = manager.currentSelectedDate,
               let startDate = periodEntries.first(where: { $0.timeline == .start })?.date {
                isEnabled = manager.hasInProgressPeriod && date > startDate && date <= Date()
            }
        }
        
        /// If the selected date is in the past compared to the last selected date OR is in the future compare to today's date
        if let date = manager.currentSelectedDate,
           let lastDate = periodEntries.compactMap({ $0.date }).sorted(by: { $0 < $1 }).last {
            if date < lastDate || date.fullDay == lastDate.fullDay || date > Date() { isEnabled = false }
        }
        
        /// If the selected date is an ovulation or fertile day OR the date is a start day before fertile/ovulation date
        if let date = manager.currentSelectedDate {
            let nonPeriodDays = manager.selectedEntries.filter({ $0.dateType != .period })
            nonPeriodDays.compactMap({ $0.date }).forEach { nonPeriodDate in
                if date.fullDay == nonPeriodDate.fullDay { isEnabled = false }
                if type == .start && date < nonPeriodDate { isEnabled = false }
            }
        }
        
        return Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            withAnimation {
                selectedDateTimeline = type
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    currentStep = .flowType
                }
            }
        }, label: {
            ZStack {
                if selectedDateTimeline == type { RoundedRectangle(cornerRadius: 30) } else {
                    RoundedRectangle(cornerRadius: 30).strokeBorder(Color.white, lineWidth: 4)
                }
                HStack {
                    if type != .another {
                        Image(systemName: type == .start ? "play.fill" : "stop.fill")
                    }
                    Text(type.rawValue)
                }.foregroundColor(selectedDateTimeline == type ? AppConfig.darkGrayColor : .white)
            }
        }).disabled(!isEnabled).opacity(isEnabled ? 1 : 0.4)
    }
    
    // MARK: - Create flow type button
    private func FlowTypeButton(type: FlowType) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            withAnimation {
                selectedDateFlowType = type
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    if let date = manager.currentSelectedDate {
                        let model = DateEntryModel(date: date, dateType: .period, timeline: selectedDateTimeline, flowType: type)
                        manager.saveDateEntry(entry: model)
                        currentStep = manager.hasInProgressPeriod ? .comeBack : .completed
                    } else {
                        currentStep = nil
                    }
                }
            }
        }, label: {
            ZStack {
                if selectedDateFlowType == type { RoundedRectangle(cornerRadius: 30) } else {
                    RoundedRectangle(cornerRadius: 30).strokeBorder(Color.white, lineWidth: 4)
                }
                VStack(spacing: 0) {
                    HStack {
                        ForEach(0...FlowType.allCases.firstIndex(of: type)!, id: \.self, content: { _ in
                            Image(systemName: "drop.fill")
                        })
                        Text(type.rawValue.capitalized)
                    }
                }.foregroundColor(selectedDateFlowType == type ? AppConfig.darkGrayColor : .white)
            }
        })
    }
}

// MARK: - Preview UI
struct BottomActionView_Previews: PreviewProvider {
    /// The height here is just for debugging purposes
    static var previews: some View {
        VStack {
            Spacer()
            BottomActionView(manager: PeriodManager())
                .frame(height: UIScreen.main.bounds.height/2.5)
        }
    }
}
