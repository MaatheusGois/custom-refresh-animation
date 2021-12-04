//
//  SpinnerAnimationView.swift
//  PullToRefreshDemo
//
//  Created by Mansi Vadodariya on 06/04/21.
//

import UIKit
import Lottie

// Protocols

public protocol RefreshDelegate: NSObject {
    func startRefresh()
    func endRefresh()
}

// Structs

public extension SpinnerAnimationView {
    struct ViewData {
        let resource: Resource
        let background: UIColor

        public init(
            resource: SpinnerAnimationView.Resource,
            background: UIColor = .clear
        ) {
            self.resource = resource
            self.background = background
        }
    }
}

// Resource

public extension SpinnerAnimationView {
    enum Resource {
        case loading(tintColor: UIColor)

        // Helpers

        var keys: [String] {
            switch self {
            case .loading:
                return ["part2", "part3"]
            }
        }

        var description: String {
            switch self {
            case .loading:
                return "loading"
            }
        }
    }
}

// Class

public class SpinnerAnimationView: UIView {

    // Views

    private var parentView: UIScrollView!
    private var refreshBaseView : UIView!
    private var backgroundColorView : UIView!
    private var animationView : AnimationView!
    private var refreshControl: UIRefreshControl!

    // Variables

    private var viewData: ViewData!
    private var isRefreshAnimating = false
    private var pullDistance: CGFloat = .zero

    // Delegate

    private weak var delegate: RefreshDelegate?

    // Computed propertie

    public var isRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    // Life cycle

    public required convenience init(
        viewData: ViewData,
        parentView: UIScrollView,
        delegate: RefreshDelegate?
    ) {
        self.init()
        self.viewData = viewData
        self.parentView = parentView
        self.delegate = delegate
    }
    
    // Setup

    public func setupRefreshControl() {

        // UIRefreshControl

        refreshControl = UIRefreshControl(frame: .init(x: 0, y: 0, width: parentView.frame.size.width, height: 60))

        // Setup the base view, which will hold the moving graphics

        refreshBaseView = UIView(frame: refreshControl.bounds)
        refreshBaseView.backgroundColor = viewData.background
        
        // Setup the color view, which will display the background color

        backgroundColorView = UIView(frame: refreshControl.bounds)
        backgroundColorView.backgroundColor = .clear

        // Create the graphic image views


        animationView = .init(
            name: viewData.resource.description,
            bundle: .init(for: type(of: self))
        )
        animationView.setColor(resource: viewData.resource)

        // Add the graphics to the base view
        refreshBaseView.addSubview(self.animationView)
        
        // Clip so the graphics don't stick out
        refreshBaseView.clipsToBounds = true
        
        // Hide the original spinner icon
        refreshControl.tintColor = .clear
        
        // Add the base and colors views to our refresh control
        refreshControl.addSubview(self.backgroundColorView)
        refreshControl.addSubview(self.refreshBaseView)
        
        // Initalize flags
        isRefreshAnimating = false
        
        // When activated, invoke our refresh function
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        parentView.delegate = self

        parentView.refreshControl = refreshControl
    }

    public func setupData(viewData: ViewData) {
        self.viewData = viewData
        refreshBaseView.backgroundColor = viewData.background
        animationView.setColor(resource: viewData.resource)
    }
    
    @objc private func refresh(){
        self.delegate?.startRefresh()
    }
    
    // MARK: - Methods

    private func animateRefreshView() {

        self.isRefreshAnimating = true
        
        UIView.animate(
            withDuration: Double(0.3),
            delay: .zero,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                self.animationView.contentMode = .scaleAspectFit
                self.animationView.loopMode = .loop
                self.animationView.play()

                self.backgroundColorView.backgroundColor = self.tintColor
            },
            completion: { finished in
                if self.refreshControl.isRefreshing {
                    self.animateRefreshView()
                } else {
                    self.resetAnimation()
                }
            }
        )
    }
    
    private func resetAnimation() {
        self.isRefreshAnimating = false
        self.animationView.stop()
        self.backgroundColorView.backgroundColor = .clear
    }
}

// MARK: - UIScrollViewDelegate

extension SpinnerAnimationView: UIScrollViewDelegate {

    public func scrollDidImageAnimation() {
        // Get the current size of the refresh controller
        var refreshBounds = self.refreshControl.bounds

        let heightHalf = animationView.bounds.size.height / 2
        let widthHalf = animationView.bounds.size.width / 2

        // Set the Y coord of the graphics, based on pull distance
        let spinnerY = pullDistance / 2 - heightHalf

        var spinnerFrame = self.animationView.frame
        spinnerFrame.origin.x = (parentView.frame.size.width / 2) - widthHalf
        spinnerFrame.origin.y = spinnerY

        self.animationView.frame = .init(
            origin: spinnerFrame.origin,
            size: animationView.bounds.size
        )

        // Set the refreshBounds view's frames
        refreshBounds.size.height = pullDistance

        self.backgroundColorView.frame = refreshBounds
        self.refreshBaseView.frame = refreshBounds

        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
            self.animateRefreshView()
        }

    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Distance the table has been pulled >= 0
        pullDistance = max(.zero, -refreshControl.frame.origin.y)
        if pullDistance == 0.0 {
            return
        }
        scrollDidImageAnimation()
    }

    public func endRefreshing() {
        self.refreshControl.endRefreshing()
        self.delegate?.endRefresh()
    }
}

extension AnimationView {
    func setColor(resource: SpinnerAnimationView.Resource) {
        switch resource {
        case let .loading(tintColor):
            setColor(keys: resource.keys, color: tintColor)
        }
    }

    func setColor(keys: [String], color: UIColor) {
        for key in keys {
            setColor(key: key, color: color)
        }
    }

    func setColor(key: String, color: UIColor) {
        setValueProvider(
            ColorValueProvider(color.lottieColorValue),
            keypath: .init(keys: ["**", key, "**", "Color"])
        )
    }
}
