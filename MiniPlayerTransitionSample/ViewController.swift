//
//  ViewController.swift
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

class ViewController: UIViewController {
    
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("open movie", for: .normal)
        button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let moviePlayVC = MoviePlayViewController()
                moviePlayVC.playerView = {
                    let playerView = PlayerView()
                    let movieURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Chelsea", ofType: "mp4")!)
                    playerView.player = AVPlayer(url: movieURL)
                    playerView.player?.volume = 0
                    playerView.player?.play()
                    return playerView
                }()
                self?.present(moviePlayVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        view.addSubview(button)
        button.snp.makeConstraints() { make in
            make.center.equalToSuperview()
        }
    }
}
