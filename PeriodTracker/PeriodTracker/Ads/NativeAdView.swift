//
//  NativeAdView.swift
//  PeriodTracker
//
//  Created by Rene B. Dena on 7/9/21.
//

import UIKit
import SwiftUI
import GoogleMobileAds

/// Native ad wrapper
class NativeAdView: UIView {
    /// Add the native add to the view
    /// - Parameter ad: native ad view
    func configure(ad: GADNativeAdView) {
        addModalSubview(ad)
    }
}

// MARK: - SwiftUI Native Ad view
struct NativeAd: UIViewRepresentable {
    let adView: GADNativeAdView
    func makeUIView(context: Context) -> some UIView {
        let view = NativeAdView()
        view.configure(ad: adView)
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

// MARK: - Add a view as subview
extension UIView {
    func addModalSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leftAnchor.constraint(equalTo: leftAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
