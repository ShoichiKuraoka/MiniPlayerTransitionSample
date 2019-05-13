//
//  PanDismissInteractiveTransition.swift
//  MiniPlayerTransitionSample
//
//  Created by Shoichi Kuraoka on 2019/05/13.
//  Copyright © 2019 ShoichiKuraoka. All rights reserved.
//

import UIKit

enum DismissGestureDirection {
    case down, right, up, left
}

class PanDismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Property
    var isInProgress = false
    let gesture = UIPanGestureRecognizer(target: nil, action: nil)
    // private
    private var shouldCompleteTransition = false
    private let panDirection: DismissGestureDirection
    private weak var viewController: UIViewController?
    
    // MARK: Initializer
    init(panDirection aPanDirection: DismissGestureDirection = .down) {
        panDirection = aPanDirection
        super.init()
    }
    
    func setTarget(_ aViewController: UIViewController) {
        gesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        viewController = aViewController
        aViewController.view.addGestureRecognizer(gesture)
    }
    
    // MARK: Private function
    @objc
    private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isInProgress = true
            viewController?.dismiss(animated: true)
        case .changed:
            let panChangeRate = self.panChangeRate(of: gestureRecognizer, containsVelocity: false)
            print("update: \(panChangeRate.description)")
            shouldCompleteTransition = panChangeRate > 0.5
            update(panChangeRate)
        case .cancelled:
            isInProgress = false
            cancel()
        case .ended:
            isInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
    private func panChangeRate(of gestureRecognizer: UIPanGestureRecognizer, containsVelocity: Bool) -> CGFloat {
        guard let view = gestureRecognizer.view else { return 0 }
        let changePanDistance: CGFloat = {
            let translation = gestureRecognizer.translation(in: view)
            let velocity = gestureRecognizer.velocity(in: view)
            switch panDirection {
            case .down: return translation.y + (containsVelocity ? velocity.y : 0)
            case .right: return translation.x + (containsVelocity ? velocity.x : 0)
            case .up: return -1 * (translation.y + (containsVelocity ? velocity.y : 0))
            case .left: return -1 * (translation.x + (containsVelocity ? velocity.x : 0))
            }
        }()
        let maxPanDistance: CGFloat = {
            switch panDirection {
            case .down, .up: return UIApplication.shared.keyWindow?.frame.height ?? 0
            case .right, .left: return UIApplication.shared.keyWindow?.frame.width ?? 0
            }
        }()
        return max(min(changePanDistance / maxPanDistance, 1), 0)
    }
}
