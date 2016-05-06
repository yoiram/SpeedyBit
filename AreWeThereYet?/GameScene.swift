//
//  GameScene.swift
//  AreWeThereYet?
//
//  Created by Mario Youssef on 2016-05-05.
//  Copyright (c) 2016 Mario Youssef. All rights reserved.
//

import SpriteKit
import GameKit

struct scoreKey { //struct for stored values
    static let highScore = "highScore"
}

struct lanes { //struct to store lane x positions
    static let firstLane = UIScreen.mainScreen().bounds.width / 6
    static let secondLane = UIScreen.mainScreen().bounds.width / 2
    static let thirdLane = UIScreen.mainScreen().bounds.width / 6 * 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //init constants and variables
    var car = SKSpriteNode()
    var obstacles = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = false
    var crashed = false
    var score:CGFloat = 0
    let scoreBar = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let defaults = NSUserDefaults.standardUserDefaults()
    var bgSpeed:CGFloat = 0
    let carCategory:UInt32 = 0x1 << 0
    let obstacleCategory:UInt32 = 0x1 << 1
    
    override init(size: CGSize) {
        super.init(size: size)
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 { //init backgrounds
            let background = SKSpriteNode(imageNamed: "background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(0, CGFloat(i) * self.frame.height)
            background.name = "background"
            background.size = self.frame.size
            self.addChild(background)
        }
        
        //init score display
        scoreBar.size = CGSizeMake(self.frame.size.width, 30)
        scoreBar.color = SKColor.grayColor()
        scoreBar.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 15)
        self.addChild(scoreBar)
        
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 20)
        scoreLabel.text = "Score: 0"
        self.addChild(scoreLabel)
        
        //        highScoreLabel.fontSize = 20
        //        highScoreLabel.position = CGPointMake((self.frame.size.width/6)*5, self.frame.size.height - 20)
        //        highScoreLabel.fontColor = UIColor.blackColor()
        //        highScoreLabel.text = "Highest: \(defaults.integerForKey(scoreKey.highScore))"
        //        self.addChild(highScoreLabel)
        //
        //init car
        car = SKSpriteNode(imageNamed: "Car")
        car.size = CGSizeMake(80, 80)
        car.position = CGPointMake(lanes.secondLane, car.size.height/2 + 20)
        car.physicsBody = SKPhysicsBody(rectangleOfSize: car.size)
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.categoryBitMask = carCategory
        car.physicsBody?.collisionBitMask = obstacleCategory
        car.physicsBody?.contactTestBitMask = obstacleCategory
        self.addChild(car)
        
        //init obstacles
        //makeObstacles()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted {
            gameStarted = true
        }
        else {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            
            let differenceBetweenLanes = lanes.secondLane - lanes.firstLane
            let moveRight = SKAction.moveByX(differenceBetweenLanes, y: 0, duration: 0.1)
            let moveLeft = moveRight.reversedAction()
            let turnLeft = SKAction.rotateByAngle(CGFloat(M_PI/12), duration: 0.05)
            let turnRight = turnLeft.reversedAction()
            let leftSeq = SKAction.sequence([turnLeft,moveLeft,turnRight])
            let rightSeq = SKAction.sequence([turnRight,moveRight,turnLeft])
            
            if touchLocation.x <= self.frame.width/3 && touchLocation.x > 0 && car.position.x - differenceBetweenLanes > 0 {
                car.runAction(leftSeq)
            } else if touchLocation.x >= self.frame.width/3*2 && touchLocation.x < self.frame.width && car.position.x + differenceBetweenLanes < self.frame.width {
                car.runAction(rightSeq)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    }
    
//    func gameOver() {
//        if CGFloat(defaults.floatForKey(scoreKey.highScore)) < score {
//            defaults.setValue(score, forKey: scoreKey.highScore)
//        }
//        
//        let gameOverView = SKSpriteNode(color: UIColor.yellowColor(), size: CGSize(width: self.frame.width/2 + self.frame.width/3, height: self.frame.height/3))
//        gameOverView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
//        
//        highScoreLabel.fontSize = 20
//        highScoreLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - 10)
//        highScoreLabel.fontColor = UIColor.blackColor()
//        highScoreLabel.text = "Highest: \(defaults.integerForKey(scoreKey.highScore))"
//        gameOverView.setScale(0)
//        self.addChild(gameOverView)
//        gameOverView.runAction(SKAction.scaleTo(1.0, duration: 0.2))
//        self.addChild(highScoreLabel)
//    }
    
    override func update(currentTime: CFTimeInterval) {
        //init movement of background
        if gameStarted {
            
            if bgSpeed < 9.9 { //to allow slow start
                bgSpeed += 0.1
            } else if score > 1000000 {
                if bgSpeed < 49 {
                    bgSpeed += 1
                } else {
                    bgSpeed = 50
                }
            } else if score > 100000 {
                if bgSpeed < 29.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 30
                }
            } else if score > 10000 {
                if bgSpeed < 24.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 25
                }
            } else if score > 5000 {
                if bgSpeed < 19.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 20
                }
            } else if score > 1000 {
                if bgSpeed < 14.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 15
                }
            } else {
                bgSpeed = 10
            }
            
            enumerateChildNodesWithName("background", usingBlock: ({
                (node, error) in
                let bg = node as! SKSpriteNode
                
                bg.position = CGPoint(x: bg.position.x, y: bg.position.y - self.bgSpeed)
                
                if bg.position.y <= -bg.size.height {
                    bg.position = CGPointMake(bg.position.x, bg.position.y + bg.size.height*2)
                }
            }))
            
            if (bgSpeed > 10) {
                score += bgSpeed/5
            } else {
                score += 1
            }
            scoreLabel.text = "Score: \(Int(score))"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
