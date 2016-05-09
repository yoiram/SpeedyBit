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
    var currCarColour = -1
    var obstacles = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = false
    var crashed = false
    var score:CGFloat = 0
    let scoreBar = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    let scoreLabelGO = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    var mileStoneLabel = SKLabelNode()
    
    let tapToStartLabel = SKLabelNode(text: "Tap to Start")
    let tapToMoveLabel = SKLabelNode(text: "Tap on either side to move")
    
    
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

        //init car
        currCarColour = Int(CGFloat.random(6))
        car = SKSpriteNode(imageNamed: "Car\(currCarColour)")
        car.size = CGSizeMake(80, 80)
        car.position = CGPointMake(lanes.secondLane, car.size.height/2 + 20)
        car.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 53, height: 80))
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.categoryBitMask = carCategory
        car.physicsBody?.collisionBitMask = obstacleCategory
        car.physicsBody?.contactTestBitMask = obstacleCategory
        self.addChild(car)
        
        tapToStartLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 40)
        tapToStartLabel.fontSize = 40
        tapToStartLabel.fontName = "MarkerFelt-Thin"
        tapToStartLabel.setScale(0)
        tapToStartLabel.fontColor = UIColor.whiteColor()
        self.addChild(tapToStartLabel)
        let scaleUp = SKAction.scaleTo(1.0, duration: 0.5)
        let scaleDown = SKAction.scaleTo(0.9, duration: 0.5)
        let seq = SKAction.sequence([scaleUp, scaleDown])
        tapToStartLabel.runAction(SKAction.repeatActionForever(seq))
    }
    
    func spawn() {
        self.removeAllActions()
        let spawn = SKAction.runBlock({
            () in self.createObstacles()
        })
        let delay = SKAction.waitForDuration(delayBetweenObstacles)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
        let spawnAction = SKAction.sequence([SKAction.waitForDuration(delayBetweenObstacles+0.4), spawnDelayForever])
        self.runAction(spawnAction)
        let distance = CGFloat(self.frame.height + obstacles.frame.height)
        let moveObstacles = SKAction.moveByX(0, y: -distance - 100, duration: NSTimeInterval(CGFloat(speedOfMovement) * distance))
        let removeObstacles = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([moveObstacles,removeObstacles])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted && !crashed {
            gameStarted = true
            tapToStartLabel.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
            
            tapToMoveLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 40)
            tapToMoveLabel.fontSize = 32
            tapToMoveLabel.fontName = "MarkerFelt-Thin"
            tapToMoveLabel.setScale(0)
            tapToMoveLabel.fontColor = UIColor.whiteColor()
            self.addChild(tapToMoveLabel)
            let scaleUp = SKAction.scaleTo(1.0, duration: 0.5)
            let scaleDown = SKAction.scaleTo(0.9, duration: 0.5)
            let seq = SKAction.sequence([scaleUp, scaleDown])
            tapToMoveLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.repeatAction(seq, count: 3), SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
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
            crashed = true
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
        
        gameOverView = SKSpriteNode(color: UIColor.grayColor(), size: CGSize(width: self.frame.width/2 + self.frame.width/3, height: self.frame.height/3))
        gameOverView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        scoreLabelGO.fontSize = 21
        scoreLabelGO.fontName = "Verdana-Bold"
        scoreLabelGO.position = CGPointMake(gameOverView.position.x, gameOverView.position.y + 30)
        scoreLabelGO.fontColor = UIColor.blackColor()
        scoreLabelGO.text = "Current score: \(Int(score))"

        highScoreLabel.fontSize = 21
        highScoreLabel.fontName = "Verdana-Bold"
        highScoreLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - 30)
        highScoreLabel.fontColor = UIColor.blackColor()
        highScoreLabel.text = "Highest: \(defaults.integerForKey(scoreKey.highScore))"
        
        gameOverView.setScale(0)
        highScoreLabel.setScale(0)
        scoreLabelGO.setScale(0)
        
        gameOverView.removeFromParent()
        self.addChild(gameOverView)
        gameOverView.runAction(SKAction.scaleTo(1.0, duration: 0.2))
        highScoreLabel.removeFromParent()
        self.addChild(highScoreLabel)
        highScoreLabel.runAction(SKAction.scaleTo(1.0, duration: 0.2))
        scoreLabelGO.removeFromParent()
        self.addChild(scoreLabelGO)
        scoreLabelGO.runAction(SKAction.scaleTo(1.0, duration: 0.2))
    }
    
    func mileStone() {
        mileStoneLabel = SKLabelNode()
        mileStoneLabel.text = "CHECKPOINT!"
        mileStoneLabel.fontSize = 40
        mileStoneLabel.fontName = "MarkerFelt-Thin"
        mileStoneLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/5 * 4)
        mileStoneLabel.setScale(0)
        mileStoneLabel.fontColor = UIColor.redColor()
        mileStoneLabel.zPosition = 20
        let scaleUp = SKAction.scaleTo(1.0, duration: 0.3)
        let rotateRight = SKAction.rotateByAngle(CGFloat(M_PI/12), duration: 0.1)
        let rotateLeft = rotateRight.reversedAction()
        let rotate = SKAction.rotateByAngle(CGFloat(2*M_PI), duration: 1.0)
        let scaleDown = SKAction.scaleTo(0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let seq = SKAction.sequence([scaleUp, rotateRight, rotateLeft, rotateLeft, rotateRight, rotate, rotate, scaleDown, remove])
        self.addChild(mileStoneLabel)
        mileStoneLabel.runAction(seq)
    }
    
    func createObstacles() {
        obstacles = SKNode()
        obstacles.name = "obstacles"
        
        var randCol1 = Int(CGFloat.random(6))
        var randCol2 = Int(CGFloat.random(6))
        
        repeat {
            randCol1 = Int(CGFloat.random(6))
            randCol2 = Int(CGFloat.random(6))
        } while (randCol1 == currCarColour || randCol2 == currCarColour)
        
        let car1 = SKSpriteNode(imageNamed: "Car\(randCol1)")
        let car2 = SKSpriteNode(imageNamed: "Car\(randCol2)")
        
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
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 53, height: 80))
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
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 53, height: 80))
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
            car2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 53, height: 80))
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
                        delayBetweenObstacles = 0.2
                        mileStone()
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
                        delayBetweenObstacles = 0.4
                        mileStone()
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
                        delayBetweenObstacles = 0.6
                        mileStone()
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
                        delayBetweenObstacles = 0.8
                        mileStone()
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
                        delayBetweenObstacles = 1.2
                        mileStone()

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
                        delayBetweenObstacles = 1.6
                        mileStone()
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