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
    let scoreLabelGO = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let defaults = NSUserDefaults.standardUserDefaults()
    var bgSpeed:CGFloat = 0
    let carCategory:UInt32 = 0x1 << 0
    let obstacleCategory:UInt32 = 0x1 << 1
    var delayBetweenObstacles = 2.0
    var speedOfMovement = 0.008
    var gameOverView = SKSpriteNode()
    
    var updated1000 = false
    var updated5000 = false
    var updated10000 = false
    var updated50000 = false
    var updated100000 = false
    var updated1000000 = false
    
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
        scoreBar.zPosition = 10
        
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "Verdana-Bold"
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 20)
        scoreLabel.text = "Score: 0"
        self.addChild(scoreLabel)
        scoreLabel.zPosition = 11
        
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
    }
    
    func spawn() {
        self.removeAllActions()
        let spawn = SKAction.runBlock({
            () in self.createObstacles()
        })
        let delay = SKAction.waitForDuration(delayBetweenObstacles)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
        let spawnAction = SKAction.sequence([SKAction.waitForDuration(delayBetweenObstacles), spawnDelayForever])
        self.runAction(spawnAction)
        let distance = CGFloat(self.frame.height + obstacles.frame.height)
        let moveObstacles = SKAction.moveByX(0, y: -distance - 50, duration: NSTimeInterval(CGFloat(speedOfMovement) * distance))
        let removeObstacles = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([moveObstacles,removeObstacles])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted && !crashed {
            gameStarted = true
            spawn()
        }
        else if crashed {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            crashed = false
            if gameOverView.containsPoint(touchLocation) {
                gameOverView.removeFromParent()
                highScoreLabel.removeFromParent()
                scoreLabelGO.removeFromParent()
            }
            self.removeAllChildren()
            self.removeAllActions()
            score = 0
            delayBetweenObstacles = 2.0
            speedOfMovement = 0.008
            updated1000 = false
            updated5000 = false
            updated10000 = false
            updated50000 = false
            updated100000 = false
            updated1000000 = false
            createScene()
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
            
            if touchLocation.x <= car.position.x && touchLocation.x > 0 && car.position.x - differenceBetweenLanes > 0 {
                car.runAction(leftSeq)
            } else if touchLocation.x >= car.position.x && touchLocation.x < self.frame.width && car.position.x + differenceBetweenLanes < self.frame.width {
                car.runAction(rightSeq)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == carCategory && secondBody.categoryBitMask == obstacleCategory || firstBody.categoryBitMask == obstacleCategory && secondBody.categoryBitMask == carCategory {
            self.removeAllActions()
            enumerateChildNodesWithName("obstacles", usingBlock: ({
               (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            gameOver()
        }
    }
    
    func gameOver() {
        gameStarted = false
        crashed = true
        
        if defaults.integerForKey(scoreKey.highScore) < Int(score) {
            defaults.setValue(Int(score), forKey: scoreKey.highScore)
        }
        
        gameOverView = SKSpriteNode(color: UIColor.yellowColor(), size: CGSize(width: self.frame.width/2 + self.frame.width/3, height: self.frame.height/3))
        gameOverView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        scoreLabelGO.fontSize = 25
        scoreLabelGO.fontName = "Verdana-Bold"
        scoreLabelGO.position = CGPointMake(gameOverView.position.x, gameOverView.position.y + 30)
        scoreLabelGO.fontColor = UIColor.blackColor()
        scoreLabelGO.text = "Current score: \(Int(score))"
        scoreLabelGO.setScale(0)

        highScoreLabel.fontSize = 25
        highScoreLabel.fontName = "Verdana-Bold"
        highScoreLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - 30)
        highScoreLabel.fontColor = UIColor.blackColor()
        highScoreLabel.text = "Highest: \(defaults.integerForKey(scoreKey.highScore))"
        gameOverView.setScale(0)
        highScoreLabel.setScale(0)
        self.addChild(gameOverView)
        gameOverView.runAction(SKAction.scaleTo(1.0, duration: 0.2))
        self.addChild(highScoreLabel)
        highScoreLabel.runAction(SKAction.scaleTo(1.0, duration: 0.2))
        self.addChild(scoreLabelGO)
        scoreLabelGO.runAction(SKAction.scaleTo(1.0, duration: 0.2))
    }
    
    func createObstacles() {
        obstacles = SKNode()
        obstacles.name = "obstacles"
        
        let car1 = SKSpriteNode(imageNamed:"Car")
        let car2 = SKSpriteNode(imageNamed: "Car")
        
        let numObstacles = CGFloat.random(2)
        
        let randomPos = CGFloat.random(3)
        var randomPos2 = CGFloat.random(3)
        
        repeat {
            randomPos2 = CGFloat.random(3)
        } while randomPos2 == randomPos
        
        if numObstacles == 0 { //only one obstacle
            switch randomPos {
            case 0: car1.position = CGPoint(x: lanes.firstLane, y: self.frame.height + 25)
            case 1: car1.position = CGPoint(x: lanes.secondLane, y: self.frame.height + 25)
            case 2: car1.position = CGPoint(x: lanes.thirdLane, y: self.frame.height + 25)
            default: break
            }
            car1.size = CGSizeMake(80, 80)
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: car1.size)
            car1.physicsBody?.affectedByGravity = false
            car1.physicsBody?.dynamic = false
            car1.physicsBody?.categoryBitMask = obstacleCategory
            car1.physicsBody?.collisionBitMask = carCategory
            car1.physicsBody?.contactTestBitMask = carCategory
            obstacles.addChild(car1)
        } else if numObstacles == 1 { //two obstacles
            switch randomPos {
            case 0: car1.position = CGPoint(x: lanes.firstLane, y: self.frame.height + 25)
            case 1: car1.position = CGPoint(x: lanes.secondLane, y: self.frame.height + 25)
            case 2: car1.position = CGPoint(x: lanes.thirdLane, y: self.frame.height + 25)
            default: break
            }
            car1.size = CGSizeMake(80, 80)
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: car1.size)
            car1.physicsBody?.affectedByGravity = false
            car1.physicsBody?.dynamic = false
            car1.physicsBody?.categoryBitMask = obstacleCategory
            car1.physicsBody?.collisionBitMask = carCategory
            car1.physicsBody?.contactTestBitMask = carCategory
            switch randomPos2 {
            case 0: car2.position = CGPoint(x: lanes.firstLane, y: self.frame.height + 25)
            case 1: car2.position = CGPoint(x: lanes.secondLane, y: self.frame.height + 25)
            case 2: car2.position = CGPoint(x: lanes.thirdLane, y: self.frame.height + 25)
            default: break
            }
            car2.size = CGSizeMake(80, 80)
            car2.physicsBody = SKPhysicsBody(rectangleOfSize: car2.size)
            car2.physicsBody?.affectedByGravity = false
            car2.physicsBody?.dynamic = false
            car2.physicsBody?.categoryBitMask = obstacleCategory
            car2.physicsBody?.collisionBitMask = carCategory
            car2.physicsBody?.contactTestBitMask = carCategory
            obstacles.addChild(car1)
            obstacles.addChild(car2)
        }
        
        obstacles.runAction(moveAndRemove)
        
        self.addChild(obstacles)
    }
    
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
                    if !updated1000000 {
                        updated1000000 = true
                        speedOfMovement = 0.0005
                        delayBetweenObstacles = 1.0
                        spawn()
                    }
                }
            } else if score > 100000 {
                if bgSpeed < 29.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 30
                    if !updated100000 {
                        updated100000 = true
                        speedOfMovement = 0.001
                        delayBetweenObstacles = 1.5
                        spawn()
                    }
                }
            } else if score > 50000 {
                if bgSpeed < 24.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 25
                    if !updated50000 {
                        updated50000 = true
                        speedOfMovement = 0.002
                        delayBetweenObstacles = 1.6
                        spawn()
                    }
                }
            } else if score > 10000 {
                if bgSpeed < 24.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 25
                    if !updated10000 {
                        updated10000 = true
                        speedOfMovement = 0.003
                        delayBetweenObstacles = 1.7
                        spawn()
                    }
                }
            } else if score > 5000 {
                if bgSpeed < 19.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 20
                    if !updated5000 {
                        updated5000 = true
                        speedOfMovement = 0.004
                        delayBetweenObstacles = 1.8
                        spawn()
                    }
                }
            } else if score > 1000 {
                if bgSpeed < 14.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 15
                    if !updated1000 {
                        updated1000 = true
                        speedOfMovement = 0.005
                        delayBetweenObstacles = 1.9
                        spawn()
                    }
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

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}