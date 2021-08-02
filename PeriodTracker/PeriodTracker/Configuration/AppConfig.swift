//
//  AppConfig.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    /// Test Native ID: ca-app-pub-3940256099942544/3986624511
    static let nativeAdId: String = "ca-app-pub-4998868944035881/1038440570"
    static let adMobAdId: String = "ca-app-pub-4998868944035881/3748364391"
    static let showNativeAds: Bool = true
    
    // MARK: - UI Styles
    static let darkGrayColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let lightGrayColor: Color = Color(#colorLiteral(red: 0.9715679288, green: 0.9767021537, blue: 0.9764299989, alpha: 1))
    static let bottomViewGradient: [Color] = [Color(#colorLiteral(red: 0.8470588235, green: 0.5450980392, blue: 0.6, alpha: 1)), Color(#colorLiteral(red: 0.7843137255, green: 0.3529411765, blue: 0.4235294118, alpha: 1))]
    static let dashboardGradient: [Color] = [Color(#colorLiteral(red: 0.8470588235, green: 0.5450980392, blue: 0.6, alpha: 1)), Color(#colorLiteral(red: 0.7843137255, green: 0.3529411765, blue: 0.4235294118, alpha: 1))]
    
    // MARK: - Ovulation
    static let ovulationDay = 14 /// an esimated/average day when a woman ovulates based on the first day of the period
}
