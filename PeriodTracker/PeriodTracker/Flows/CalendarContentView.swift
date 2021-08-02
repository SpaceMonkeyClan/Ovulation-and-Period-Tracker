//
//  CalendarContentView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import SwiftUI

/// Main view with the calendar view and the bottom view to log data
struct CalendarContentView: View {
    
    @ObservedObject var manager: PeriodManager
    @Environment(\.presentationMode) var presentation
    @State private var month: Date = Date()
    @State private var didShowAds: Bool = false
    private let adMobAds = Interstitial()
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            AppConfig.lightGrayColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                HeaderTitleView
                Spacer()
                ScrollView {
                    CalendarView(month: $month, currentSelectedDate: $manager.currentSelectedDate, selectedDates: manager.selectedEntries.compactMap({ $0.date }), selectedDatesColors: selectedDatesColors, headerView: AnyView(MonthHeaderSelectorView), footerView: AnyView(CalendarFooterColorKey))
                        .disabled(manager.didSaveDateEntry).onTapGesture {
                            if manager.didSaveDateEntry {
                                presentAlert(title: "Warning", message: "You can't add/delete/edit any of the tracked days")
                            }
                        }
                    Spacer(minLength: 30)
                }
                BottomActionView(manager: manager).frame(height: 270)
            }
        }.navigationBarTitle(Text("")).navigationBarHidden(true).navigationBarBackButtonHidden(true).onAppear {
            if didShowAds == false {
                didShowAds = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    adMobAds.showInterstitialAds()
                }
            }
        }
    }
    
    /// Selected dates colors
    private var selectedDatesColors: [Date: Color] {
        var dateColors = [Date: Color]()
        manager.selectedEntries.forEach({ dateColors[$0.date] = $0.color })
        return dateColors
    }
    
    /// Header title and back button
    private var HeaderTitleView: some View {
        ZStack {
            Text("CALENDAR").font(.system(size: 20, weight: .bold))
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    manager.didSaveDateEntry = false
                    manager.currentSelectedDate = nil
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                })
                .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
            }
        }.foregroundColor(AppConfig.darkGrayColor).padding().frame(height: 60)
    }
    
    // MARK: - Create month and next/previous button selector
    private var MonthHeaderSelectorView: some View {
        ZStack {
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    month = Calendar.current.date(byAdding: .month, value: -1, to: month)!
                }, label: {
                    Image(systemName: "chevron.backward.circle.fill")
                })
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    month = Calendar.current.date(byAdding: .month, value: 1, to: month)!
                }, label: {
                    Image(systemName: "chevron.forward.circle.fill")
                })
            }
            .foregroundColor(AppConfig.darkGrayColor)
            .font(.system(size: 30)).padding([.leading, .trailing], 50)
            HStack {
                Text(month.monthAndYear).bold().font(.system(size: 25))
            }
        }
    }
    
    // MARK: - Calendar key/color details
    private var CalendarFooterColorKey: some View {
        HStack(spacing: 30) {
            ForEach(CycleDateType.allCases, id: \.self, content: { type in
                HStack(spacing: 5) {
                    Circle().foregroundColor(type.color)
                        .frame(width: 15, height: 15)
                    Text(type.rawValue.uppercased())
                        .font(.system(size: 12, weight: .medium))
                }
            })
        }.padding(.top)
    }
}

// MARK: - Preview UI
struct CalendarContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarContentView(manager: PeriodManager())
    }
}

/// Create a shape with specific rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
