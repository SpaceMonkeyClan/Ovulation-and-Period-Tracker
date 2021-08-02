//
//  PeriodTrackerApp.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import UIKit
import SwiftUI
import GoogleMobileAds

@main
struct PeriodTrackerApp: App {
    
    @State private var didConfigureProject: Bool = false
    
    // MARK: - Main rendering function
    var body: some Scene {
        configureProject()
        return WindowGroup {
            DashboardContentView()
        }
    }
    
    /// One time configuration when the app launches
    private func configureProject() {
        DispatchQueue.main.async {
            if didConfigureProject == false {
                didConfigureProject = true
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
    }
}

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject {
    private var interstitial: GADInterstitialAd?
    
    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }
    
    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdId, request: request, completionHandler: { [self] ad, error in
            if ad != nil { interstitial = ad }
        })
    }
    
    func showInterstitialAds() {
        if self.interstitial != nil {
            var root = UIApplication.shared.windows.first?.rootViewController
            if let presenter = root?.presentedViewController { root = presenter }
            self.interstitial?.present(fromRootViewController: root!)
        }
    }
}

/// Present auth error alert
func presentAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController {
        root = presenter
    }
    root?.present(alert, animated: true, completion: nil)
}
