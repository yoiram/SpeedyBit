//
//  GameViewController.swift
//  SpeedyBit
//
//  Created by Mario Youssef on 2016-05-05.
//  Copyright (c) 2016 Mario Youssef. All rights reserved.
//

import UIKit
import GameKit
//import iAd


class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.canDisplayBannerAds = true
    }
    override func viewDidAppear(animated: Bool) {
        authPlayer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //let skView = self.originalContentView as! SKView
        let skView = self.view as! SKView

        if skView.scene == nil {
//            skView.showsFPS = true
//            skView.showsNodeCount = true
            
            let gameScene = GameScene(size: skView.bounds.size)
            gameScene.viewController = self
            gameScene.scaleMode = .Fill
            
            skView.presentScene(gameScene)
        }
    }
    
    func authPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view, error) in
            if view != nil {
                self.presentViewController(view!,animated: true, completion: nil)
            } else {
                print("Local Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
    }
    
    func playerAuthenticated() -> Bool {
        return GKLocalPlayer.localPlayer().authenticated
    }
    
    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        
        gcViewController.leaderboardIdentifier = "myLeaderboard"
        
        self.showViewController(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
    }
    
    func gameCenterViewControllerDidFinish(gcViewController: GKGameCenterViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveHighScoreToGC(score: Int) {
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "myLeaderboard")
            
            scoreReporter.value = Int64(score)
            let scoreArray : [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
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
