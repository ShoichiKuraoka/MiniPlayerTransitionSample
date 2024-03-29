//
//  WipePlayerView.swift
//  MiniPlayerTransitionSample
//
//  Created by Shoichi Kuraoka on 2019/05/13.
//  Copyright © 2019 ShoichiKuraoka. All rights reserved.
//

import AVKit
import SnapKit
import UIKit

class WipePlayerView: UIView {
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
    private let closeButton = UIButton(type: .system)
    private let playerBaseView = UIView()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4
        
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.setTitle("close", for: .normal)
        closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let `self` = self, let superview = self.superview else { return }
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: UIView.AnimationOptions.curveEaseOut,
                    animations: {
                        self.frame.origin.y = superview.frame.height + self.layer.shadowRadius
                },
                    completion: { _ in
                        self.removeFromSuperview()
                })
            })
            .disposed(by: rx.disposeBag)
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
        
        addSubview(playerBaseView)
        playerBaseView.snp.makeConstraints() { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(100)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError()
    }
}
