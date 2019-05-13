//
//  NextFirstViewController.swift
//  MiniPlayerTransitionSample
//
//  Created by Shoichi Kuraoka on 2019/05/13.
//  Copyright © 2019 ShoichiKuraoka. All rights reserved.
//

import AVKit
import NSObject_Rx
import RxGesture
import SnapKit
import UIKit

class MoviePlayViewController: UIViewController {
    // MARK: Property
    var playerView: PlayerView? {
        get {
            return playerBaseView.subviews.compactMap{ $0 as? PlayerView }.first
        }
        set {
            playerBaseView.subviews.forEach { $0.removeFromSuperview() }
            guard let newPlayerView = newValue else { return }
            playerBaseView.addSubview(newPlayerView)
            newPlayerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    // private
    private let playerBaseView = UIView()
    private let textView = UITextView()
    private let interactiveTransion = PanDismissInteractiveTransition()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
        interactiveTransion.setTarget(self)
        
        view.backgroundColor = .black
        
        playerBaseView.addGestureRecognizer(interactiveTransion.gesture)
        view.addSubview(playerBaseView)
        playerBaseView.snp.makeConstraints() { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(210)
        }
        
        textView.text = Constant.longText
        view.addSubview(textView)
        textView.snp.makeConstraints() { make in
            make.top.equalTo(playerBaseView.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension MoviePlayViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // presentアクションdelegate
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // dismissアクションdelegate
        return (dismissed as? MoviePlayViewController)?.dismissTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // インタラクションdelegate
        return self.interactiveTransion
    }
}

// MARK: - UIViewControllerAnimatedTransitioning for dismiss
extension MoviePlayViewController {
    private var dismissTransition: UIViewControllerAnimatedTransitioning {
        return DismissTransiton()
    }
    
    private class DismissTransiton: NSObject, UIViewControllerAnimatedTransitioning {
        // 動作時間
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.6
        }
        
        // 動作定義
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let revealVC = transitionContext.viewController(forKey: .to),
                let dismissVC = transitionContext.viewController(forKey: .from) as? MoviePlayViewController else {
                    return
            }
            
            // ====== ①create views ======
            /// トランジションに用いるコンテナビュー
            let containerView = transitionContext.containerView
            /// トランジション背景の黒いビュー
            let backgroundView: UIView = {
                let backgroundView = UIView()
                backgroundView.backgroundColor = .black
                return backgroundView
            }()
            /// トランジションコンテンツビュー
            let contentView: UIView = {
                let contentView = UIView()
                contentView.clipsToBounds = true
                return contentView
            }()
            /// プレーヤービュー
            let playerView = dismissVC.playerView ?? PlayerView()
            /// テキストビューのスナップショット
            let textViewSnapshot = dismissVC.textView.snapshotView(afterScreenUpdates: false) ?? UIView()
            /// 最終的に出すワイプ
            let wipePlayerView: WipePlayerView = {
                let wipePlayerView = WipePlayerView()
                wipePlayerView.layer.opacity = 0
                return wipePlayerView
            }()
            
            // ======== ②configure view layout ========
            containerView.addSubview(revealVC.view)
            containerView.addSubview(wipePlayerView)
            containerView.addSubview(backgroundView)
            containerView.addSubview(contentView)
            contentView.addSubview(textViewSnapshot)
            contentView.addSubview(playerView)
            
            // ======== ③configure view frame ========
            /// original frame
            let viewFrame = dismissVC.view.frame
            /// original safeAreaInsets
            let safeAreaInsets = dismissVC.view.safeAreaInsets
            /// Frame第1段階
            let contentFrame1st: CGRect = {
                var contentFrame1st = viewFrame
                contentFrame1st.origin.y += safeAreaInsets.top
                contentFrame1st.size.height -= safeAreaInsets.top
                return contentFrame1st
            }()
            /// Frame第2段階
            let contentFrame2nd: CGRect = {
                let wipeMargin = CGFloat(10)
                let wipeBottom = CGFloat(100)
                let wipeHeight2nd = CGFloat(100)
                return CGRect(x: wipeMargin,
                              y: viewFrame.height - wipeBottom - wipeHeight2nd,
                              width: viewFrame.width - 2 * wipeMargin,
                              height: wipeHeight2nd)
            }()
            /// Frame第3段階(=最終段階)
            let contentFrame3rd: CGRect = {
                let wipeHeight3rd = CGFloat(50)
                var contentFrame3rd = contentFrame2nd
                contentFrame3rd.origin.y += (contentFrame2nd.height - wipeHeight3rd)
                contentFrame3rd.size.height = wipeHeight3rd
                return contentFrame3rd
            }()
            // configure
            wipePlayerView.frame = contentFrame2nd
            backgroundView.frame = containerView.bounds
            contentView.frame = contentFrame1st
            playerView.frame = playerView.bounds
            textViewSnapshot.frame = {
                var textViewSnapshotFrame = dismissVC.textView.frame
                textViewSnapshotFrame.origin.y -= safeAreaInsets.top
                return textViewSnapshotFrame
            }()
            
            // ======== ④animate ========
            UIView.animateKeyframes(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .layoutSubviews,
                animations: {
                    // アニメーション：0 ~ 2/6
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/6) {
                        contentView.frame = contentFrame2nd
                        playerView.frame.size = contentFrame2nd.size
                        textViewSnapshot.center.x = contentView.frame.width / 2
                        textViewSnapshot.center.y = contentView.frame.height / 2
                        textViewSnapshot.layer.opacity = 0
                    }
                    // アニメーション：2/6 ~ 3/6
                    UIView.addKeyframe(withRelativeStartTime: 2/6, relativeDuration: 1/6) {
                        contentView.frame = contentFrame3rd
                        playerView.frame.size = CGSize(width: 100, height: contentFrame3rd.height)
                        wipePlayerView.frame = contentFrame3rd
                        wipePlayerView.layer.opacity = 1
                    }
                    // アニメーション：0 ~ 4/6
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 4/6) {
                        backgroundView.layer.opacity = 0
                    }
                    
            },
                completion: { _ in
                    // 個別処理
                    if !transitionContext.transitionWasCancelled {
                        // 完了した場合
                        wipePlayerView.playerView = playerView
                        playerView.rx.tapGesture()
                            .when(.recognized)
                            .subscribe(onNext: { [weak wipePlayerView] _ in
                                guard let wipePlayerView = wipePlayerView else { return }
                                let nextVC = MoviePlayViewController()
                                nextVC.playerView = wipePlayerView.playerView
                                UIApplication.shared.keyWindow?.rootViewController?.present(nextVC, animated: true) {
                                    wipePlayerView.removeFromSuperview()
                                }
                            })
                            .disposed(by: wipePlayerView.rx.disposeBag)
                        revealVC.view.addSubview(wipePlayerView)
                        backgroundView.removeFromSuperview()
                        contentView.removeFromSuperview()
                    } else {
                        // キャンセルした場合
                        dismissVC.playerView = playerView
                        revealVC.view.removeFromSuperview()
                        wipePlayerView.removeFromSuperview()
                        backgroundView.removeFromSuperview()
                        contentView.removeFromSuperview()
                    }
                    // 共通処理
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
