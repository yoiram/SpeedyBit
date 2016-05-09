//
//  GameViewController.swift
//  AreWeThereYet?
//
//  Created by Mario Youssef on 2016-05-05.
//  Copyright (c) 2016 Mario Youssef. All rights reserved.
//

import UIKit
import SpriteKit
//import iAd


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.canDisplayBannerAds = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //let skView = self.originalContentView as! SKView
        let skView = self.view as! SKView

        if skView.scene == nil {
//            skView.showsFPS = true
//            skView.showsNodeCount = true
            
            let gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = .Fill
            
            skView.presentScene(gameScene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
