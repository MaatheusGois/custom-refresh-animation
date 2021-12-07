//
//  SpinnerAnimationView.swift
//  PullToRefreshDemo
//
//  Created by Mansi Vadodariya on 06/04/21.
//

import UIKit
import Lottie

// MARK: - Protocols

public protocol RefreshDelegate: NSObject {
    func startRefresh()
    func endRefresh()
}

// MARK: - Structs

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

// MARK: - Resource

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

// MARK: - Class

public class SpinnerAnimationView: UIView {

    // Constants

    private enum Constants {
        static let height: CGFloat = 60
        static let animateDuration: CGFloat = 0.3
    }

    // Views

    private weak var parentView: UIScrollView?

    private lazy var refreshBaseView: UIView = .init(frame: refreshControl.bounds)
    private lazy var backgroundColorView: UIView = .init(frame: refreshControl.bounds)

    private lazy var animationView: AnimationView = .init(
        name: viewData.resource.description,
        bundle: .init(for: type(of: self))
    )

    private lazy var refreshControl: UIRefreshControl = .init(
        frame: .init(
            x: .zero,
            y: .zero,
            width: parentView?.frame.size.width ?? .zero,
            height: Constants.height
        )
    )

    // Variables

    private var viewData: ViewData

    private var isRefreshAnimating = false
    private var pullDistance: CGFloat = .zero

    // Delegate

    private weak var delegate: RefreshDelegate?

    // Computed propertie

    public var isRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    // Life cycle

    public required init(
        viewData: ViewData,
        parentView: UIScrollView,
        delegate: RefreshDelegate?
    ) {
        self.viewData = viewData
        self.parentView = parentView
        self.delegate = delegate
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Public methods

    /// Setup refresh control
    public func setup() {

        // Setup the base view, which will hold the moving graphics
        refreshBaseView.backgroundColor = viewData.background
        
        // Setup the color view, which will display the background color
        backgroundColorView.backgroundColor = .clear

        // Setup animation
        animationView.setColor(resource: viewData.resource)

        // Add the graphics to the base view
        refreshBaseView.addSubview(animationView)
        
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
        
        parentView?.delegate = self

        parentView?.refreshControl = refreshControl
    }

    public func resetColors(viewData: ViewData) {
        self.viewData = viewData
        refreshBaseView.backgroundColor = viewData.background
        animationView.setColor(resource: viewData.resource)
    }
}

// MARK: - Actions

fileprivate extension SpinnerAnimationView {
    @objc func refresh() {
        self.delegate?.startRefresh()
    }
}

// MARK: - Methods

fileprivate extension SpinnerAnimationView {
    func animateRefreshView() {
        isRefreshAnimating = true

        UIView.animate(
            withDuration: Constants.animateDuration,
            delay: .zero,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                self.animationView.contentMode = .scaleAspectFit
                self.animationView.loopMode = .loop
                self.animationView.play()

                self.backgroundColorView.backgroundColor = .clear
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

    func resetAnimation() {
        isRefreshAnimating = false
        animationView.stop()
        backgroundColorView.backgroundColor = .clear
    }
}

// MARK: - UIScrollViewDelegate

extension SpinnerAnimationView: UIScrollViewDelegate {
    public func scrollDidImageAnimation() {
        // Get the current size of the refresh controller
        var refreshBounds = refreshControl.bounds

        let heightHalf = animationView.bounds.size.height / 2
        let widthHalf = animationView.bounds.size.width / 2

        // Set the Y coord of the graphics, based on pull distance
        let spinnerY = pullDistance / 2 - heightHalf

        var spinnerFrame = animationView.frame
        spinnerFrame.origin.x = ((parentView?.frame.size.width ?? .zero) / 2) - widthHalf
        spinnerFrame.origin.y = spinnerY

        animationView.frame = .init(
            origin: spinnerFrame.origin,
            size: animationView.bounds.size
        )

        // Set the refreshBounds view's frames
        refreshBounds.size.height = pullDistance

        backgroundColorView.frame = refreshBounds
        refreshBaseView.frame = refreshBounds

        // If we're refreshing and the animation is not playing, then play the animation
        if refreshControl.isRefreshing && !isRefreshAnimating {
            self.animateRefreshView()
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Distance the table has been pulled >= 0
        pullDistance = max(.zero, -refreshControl.frame.origin.y)

        // Annimate when scroll
        if !refreshControl.isRefreshing || isRefreshAnimating && pullDistance < Constants.height {
            animationView.currentTime = pullDistance / Constants.height
        }

        guard pullDistance != .zero else { return }

        scrollDidImageAnimation()
    }

    public func endRefreshing() {
        refreshControl.endRefreshing()
        delegate?.endRefresh()
    }
}

// MARK: - Extensions

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
