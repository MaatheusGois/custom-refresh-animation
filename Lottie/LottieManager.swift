//
//  LottieManager.swift
//  SSCustomPullToRefresh
//
//  Created by Matheus Gois on 04/12/21.
//

import Foundation
import Lottie

// MARK: - Class

public class LottieManager {

    // Shared

    public static let shared = LottieManager()
    private init() {}

    // Resource

    public enum Resource: String {
        case loading
    }

    // Static Methods

    public func animationView(_ resource: Resource, loopMode: LottieLoopMode = .loop, color: UIColor? = nil) -> AnimationView {
        let animationView = AnimationView(
            animation: .named(
                resource.rawValue,
                bundle: Bundle(for: type(of: self))
            )
        )

        return setupAnimationView(animationView, loopMode: loopMode, color: color)
    }

    public func animationView(_ url: URL, loopMode: LottieLoopMode = .loop, color: UIColor? = nil) -> AnimationView {
        let animationView = AnimationView(url: url, closure: { _ in }, animationCache: LRUAnimationCache.sharedCache)
        return setupAnimationView(animationView, loopMode: loopMode, color: color)
    }

    private func setupAnimationView(_ animationView: AnimationView, loopMode: LottieLoopMode, color: UIColor?) -> AnimationView {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        if let tintColor = color {
            setColorValueProvider(animationView, uiColor: tintColor)
        }

        return animationView
    }

    private func setColorValueProvider(_ animationView: AnimationView, uiColor: UIColor) {
//        let keypath = AnimationKeypath(keypath: "**.Fill 1.Color")
        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        let colorProvider = ColorValueProvider(uiColor.lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
    }
}
