//
//  DashboardContentView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import SwiftUI
import AppTrackingTransparency

/// Main dashboard/view of the app
struct DashboardContentView: View {
    
    @ObservedObject private var manager = PeriodManager()
    @State private var showCalendarFlow: Bool = false
    @State private var showTipsFlow: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CalendarContentView(manager: manager),
                               isActive: $showCalendarFlow, label: { EmptyView() })
                HeaderGradientView
                BottomMainActionButtons
            }.navigationBarHidden(true).navigationBarBackButtonHidden(true)
        }.onAppear(perform: {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in }
            }
        }).sheet(isPresented: $showTipsFlow) {
            TipsContentView(manager: manager)
        }
    }
    
    /// Dashboard header view
    private var HeaderGradientView: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: AppConfig.dashboardGradient), startPoint: .topLeading, endPoint: .bottomTrailing).mask(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                .edgesIgnoringSafeArea(.top).shadow(color: Color.black.opacity(0.2), radius: 10, y: 3)
            VStack {
                Text("Period") + Text("Tracker").bold()
                Spacer()
                if manager.untilFertileDays != nil {
                    Text(manager.untilFertileDays! <= 0 ? "YOU MAY BE FERTILE" : "FERTILE IN").font(.system(size: 15))
                    Text("\(manager.untilFertileDays!) days".formattedDays).bold().font(.system(size: 20))
                }
            }.foregroundColor(.white).font(.system(size: 30)).padding([.top, .bottom], 35)
            LinearGradient(gradient: Gradient(colors: AppConfig.dashboardGradient), startPoint: .bottomTrailing, endPoint: .topTrailing)
                .mask(Circle())
                .frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.width/1.5)
                .shadow(color: Color.white.opacity(0.4), radius: 15, y: 5)
                .overlay(CircleProgressView)
        }.frame(height: UIScreen.main.bounds.height/1.4)
    }
    
    /// Circular progress view
    private var CircleProgressView: some View {
        ZStack {
            Circle().strokeBorder(Color.white, lineWidth: 10).padding(-5).opacity(0.4)
            if manager.untilOvulationDays != nil {
                Circle()
                    .trim(from: 0.0, to: manager.ovulationProgress)
                    .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .foregroundColor(.white)
                VStack(spacing: 10) {
                    Text("OVULATION\(manager.untilOvulationDays! <= 0 ? "" : " IN")").font(.system(size: 12))
                    Text("\(manager.untilOvulationDays!) DAYS".formattedDays).bold().font(.system(size: 40, design: .rounded))
                    Rectangle().frame(height: 1).padding([.leading, .trailing], 20).padding()
                    Text("\(manager.pregnancyChance) chance\nof getting pregnant").font(.system(size: 14)).multilineTextAlignment(.center)
                }.foregroundColor(.white)
            } else {
                VStack(spacing: 15) {
                    HStack {
                        Text("Tap the")
                        Image(systemName: "calendar.badge.plus")
                        Text("icon")
                    }
                    Text("Track Your Period").font(.system(size: 22)).bold()
                    Text("See your progress")
                }.foregroundColor(.white)
            }
        }
    }
    
    /// Dashboard bottom action buttons view
    private var BottomMainActionButtons: some View {
        VStack {
            Spacer()
            HStack(spacing: 45) {
                CreateButton(image: "calendar.badge.plus", title: "Calendar") {
                    showCalendarFlow = true
                }
                CreateButton(image: "lightbulb", title: "Tips") {
                    showTipsFlow = true
                }
            }
            Spacer()
        }
    }
    
    /// Create bottom action button
    private func CreateButton(image: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            VStack(alignment: .center) {
                Image(systemName: image).font(.system(size: 30))
                Text(title)
            }
            .foregroundColor(AppConfig.darkGrayColor)
            .frame(width: 70, height: 70, alignment: .center)
            .padding(12).background(
                RoundedRectangle(cornerRadius: 20).foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
        })
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView()
    }
}
