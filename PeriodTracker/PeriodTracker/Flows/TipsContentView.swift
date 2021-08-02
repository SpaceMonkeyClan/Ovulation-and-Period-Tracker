//
//  TipsContentView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/11/21.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Tips for helping with the period cramps
enum PeriodCrampTip: String, CaseIterable {
    case hotCompress = "Put a hot compress on your abdominal area."
    case stretching = "Go for some light stretching and exercise."
    case hotTea = "Drink hot tea."
    case noCaffeine = "Cut down your caffeine fix!"
    case massage = "Get a massage."
    case otcMeds = "Take over-the-counter medications."
    case birthControlPills = "Consider taking birth control pills."
    case goodFood = "Have a healthier diet."
    case acupuncture = "Try Acupuncture!"
    case sleep = "Get more sleep!"
    
    /// Details
    var details: String {
        switch self {
        case .hotCompress:
            return "Heating up your abdominal area during cramps can help relax the muscles, effectively reducing the pain it causes."
        case .stretching:
            return "Lay flat on your belly, and push your body upwards in a reverse C position. This stretches your abdominal muscles and ideally helps lessen the pain."
        case .hotTea:
            return "Drinking tea (ginger tea and not milk tea, sweetie) is known to help relieve muscle tension. It’s also known to be a natural remedy to relieve menstrual cramps."
        case .noCaffeine:
            return "Caffeinated food and drinks, such as sodas, energy drinks, ancd choolate, may contribute more to period pain."
        case .massage:
            return "The most popular spot to massage would be the lower back, as it directly supports the pelvic area where the uterus is."
        case .otcMeds:
            return "Medicine like ibuprofen, such as Advil, can really help relieve menstrual cramps."
        case .birthControlPills:
            return "For more extreme cases where chronic pain becomes too much and nothing else seems to work, taking regular birth control medication might be a solution."
        case .goodFood:
            return "Another way on how to relieve menstrual cramps, in the long run, is by reducing the intake of fats, sugar, and salty foods during your period."
        case .acupuncture:
            return "Meant for easing nerves and relaxing muscles, acupuncture is a widely recommended solution to relieve intense menstrual cramps."
        case .sleep:
            return "Sleeping better can help prevent the cramps from getting worse. Stress and in some cases, insomnia can contribute to getting worse menstrual cramps."
        }
    }
}

/// Shows a list of tips
struct TipsContentView: View {
    
    @ObservedObject var manager: PeriodManager
    @Environment(\.presentationMode) var presentation
    @State private var adViewTips = [PeriodCrampTip: GADNativeAdView]()
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            AppConfig.lightGrayColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                HeaderTitleView
                Spacer()
                TipsListView
            }
        }.navigationBarTitle(Text("")).navigationBarHidden(true).navigationBarBackButtonHidden(true).onAppear(perform: {
            fetchNativeAds()
        })
    }
    
    /// Header title and back button
    private var HeaderTitleView: some View {
        ZStack {
            Text("TIPS").font(.system(size: 20, weight: .bold))
            HStack {
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                }).font(.system(size: 22, weight: .bold, design: .rounded))
            }
        }.foregroundColor(AppConfig.darkGrayColor).padding().frame(height: 60)
    }
    
    /// List of tips
    private var TipsListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                ForEach(0..<PeriodCrampTip.allCases.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(PeriodCrampTip.allCases[index].rawValue)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                        Image(uiImage: UIImage(named: "period-cramps\(index+1)")!)
                            .resizable().aspectRatio(contentMode: .fit).cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.15), radius: 10)
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .frame(height: (UIScreen.main.bounds.width - 40) * 0.53)
                        Text(PeriodCrampTip.allCases[index].details).italic().opacity(0.6)
                        if adViewTips[PeriodCrampTip.allCases[index]] != nil {
                            Divider().padding([.top, .bottom], 30)
                            NativeAd(adView: adViewTips[PeriodCrampTip.allCases[index]]!)
                                .frame(height: 200).cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 10)
                        }
                    }.fixedSize(horizontal: false, vertical: true)
                    Divider()
                }.padding([.leading, .trailing], 20)
                Spacer(minLength: 20)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    /// Fetch and insert native ads
    private func fetchNativeAds() {
        manager.loadNativeAds { ad in
            DispatchQueue.main.async {
                if let adView = ad {
                    for index in 0..<PeriodCrampTip.allCases.count {
                        if adViewTips[PeriodCrampTip.allCases[index]] == nil {
                            adViewTips[PeriodCrampTip.allCases[index]] = adView
                            break
                        }
                    }
                    /// Fetch another set of 5 ads
                    if adViewTips.count == 5 {
                        fetchNativeAds()
                    }
                }
            }
        }
    }
}

// MARK: - Preview UI
struct TipsContentView_Previews: PreviewProvider {
    static var previews: some View {
        TipsContentView(manager: PeriodManager())
    }
}
