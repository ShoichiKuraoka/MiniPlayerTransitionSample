//
//  PlayerView.swift
//  MiniPlayerTransitionSample
//
//  Created by Shoichi Kuraoka on 2019/05/13.
//  Copyright © 2019 ShoichiKuraoka. All rights reserved.
//

import AVKit

class PlayerView: UIView {
    // MARK: Property
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
