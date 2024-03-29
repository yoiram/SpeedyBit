//
//  GameScene.swift
//  SpeedyBit
//
//  Created by Mario Youssef on 2016-05-05.
//  Copyright (c) 2016 Mario Youssef. All rights reserved.
//

import SpriteKit

struct scoreKey { //struct for stored values
    static let highScore = "highScore"
}

struct lanes { //struct to store lane x positions
    static let firstLane = UIScreen.mainScreen().bounds.width / 6
    static let secondLane = UIScreen.mainScreen().bounds.width / 2
    static let thirdLane = UIScreen.mainScreen().bounds.width / 6 * 5
}

struct gameOverMessages { //struct containing different messages
    static let zero = "Oh no!"
    static let one = "Smooth..."
    static let two = "You crashed!"
    static let three = "Try again!"
    static let four = "Wow."
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //init constants and variables
    var viewController: GameViewController!
    var car = SKSpriteNode()
    var currCarColour = -1
    var obstacles = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = false
    var crashed = false
    var score:CGFloat = 0
    var scoreBar = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    let scoreLabelGO = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    var mileStoneLabel = SKLabelNode()
    var youCrashedLabel = SKLabelNode()
    var tryAgainLabel = SKLabelNode()
    var leaderboardButton = SKLabelNode()
    var gameOverNode = SKNode()
    var Logo = SKSpriteNode()
    var textureArray = [SKTexture]()
    let tapToStartLabel = SKLabelNode(text: "Tap to Start")
    let tapToMoveLabel = SKLabelNode(text: "Tap to move")
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
        
        //init logo
        for i in 0 ..< 6  {
            let name = "Logo\(i)"
            textureArray.append(SKTexture(imageNamed: name))
        }
        
        Logo = SKSpriteNode(imageNamed: "Logo5")
        Logo.size = CGSize(width: self.frame.width/4 * 3, height: self.frame.width/4 * 3 / 2)
        Logo.position = CGPoint(x: self.frame.width/2, y: self.frame.height/5 * 4)
        self.addChild(Logo)
        Logo.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.2)))
        let scaleUp1 = SKAction.scaleTo(1.0, duration: 0.6)
        let scaleDown1 = SKAction.scaleTo(0.9, duration: 0.6)
        let sequ = SKAction.sequence([scaleUp1, scaleDown1])
        Logo.runAction(SKAction.repeatActionForever(sequ))
        
        //init score display
        scoreBar.size = CGSizeMake(self.frame.size.width - lanes.firstLane/2 + 2, 30)
        scoreBar.color = UIColor.init(hue: 0, saturation: 0, brightness: 0.40, alpha: 0.75)
        scoreBar.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 15)
        self.addChild(scoreBar)
        scoreBar.zPosition = 10
        
        scoreLabel.fontSize = 13
        scoreLabel.fontName = "PressStart2P-Regular"
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 20)
        scoreLabel.text = "Score: 0"
        self.addChild(scoreLabel)
        scoreLabel.zPosition = 11

        //init car
        currCarColour = Int(CGFloat.random(6))
        car = SKSpriteNode(imageNamed: "Car\(currCarColour)")
        car.size = CGSizeMake(self.frame.width/3 - lanes.firstLane/2 - 10, self.frame.width/3 - lanes.firstLane/2 - 10)
        car.position = CGPointMake(lanes.secondLane, car.size.height/2 + 20)
        car.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: car.size.width*0.67, height: car.size.height - 1))
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.categoryBitMask = carCategory
        car.physicsBody?.collisionBitMask = obstacleCategory
        car.physicsBody?.contactTestBitMask = obstacleCategory
        self.addChild(car)
        
        tapToStartLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 40)
        tapToStartLabel.fontSize = 25
        tapToStartLabel.fontName = "PressStart2P-Regular"
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
        let spawnAction = SKAction.sequence([SKAction.waitForDuration(delayBetweenObstacles+1), spawnDelayForever])
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
            Logo.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.5),SKAction.removeFromParent()]))
            tapToMoveLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 40)
            tapToMoveLabel.fontSize = 25
            tapToMoveLabel.fontName = "PressStart2P-Regular"
            tapToMoveLabel.setScale(0)
            tapToMoveLabel.fontColor = UIColor.whiteColor()
            self.addChild(tapToMoveLabel)
            let scaleUp = SKAction.scaleTo(1.0, duration: 0.5)
            let scaleDown = SKAction.scaleTo(0.9, duration: 0.5)
            let seq = SKAction.sequence([scaleUp, scaleDown])
            tapToMoveLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.repeatAction(seq, count: 2), scaleUp, SKAction.scaleTo(0, duration: 0.8),SKAction.removeFromParent()]))
            spawn()
        }
        else if crashed {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            if touchLocation.x <= self.frame.width/2 + leaderboardButton.frame.width/2 && touchLocation.x >= self.frame.width/2 - leaderboardButton.frame.width/2 && touchLocation.y <= leaderboardButton.position.y + leaderboardButton.frame.height && touchLocation.y >= leaderboardButton.position.y {
                viewController.showLeaderboard()
            } else if touchLocation.x <= self.frame.width/2 + gameOverView.frame.width/2 && touchLocation.x >= self.frame.width/2 - gameOverView.frame.width/2 && touchLocation.y <= gameOverView.position.y + gameOverView.frame.height/2 && touchLocation.y >= gameOverView.position.y - gameOverView.frame.height/2 {
                crashed = false
                self.removeAllChildren()
                self.removeAllActions()
                score = 0
                delayBetweenObstacles = 2.0
                speedOfMovement = 0.008
                bgSpeed = 0
                updated1000 = false
                updated5000 = false
                updated10000 = false
                updated50000 = false
                updated100000 = false
                updated1000000 = false
                createScene()
            }
        }
        else {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            
            let turnLeft = SKAction.rotateByAngle(CGFloat(M_PI/12), duration: 0.0 )
            let turnRight = turnLeft.reversedAction()
            let reset = SKAction.rotateToAngle(0, duration: 0.05)
            
            if touchLocation.x <= car.position.x && touchLocation.x > 0 {// && car.position.x - differenceBetweenLanes > 0 {
                var moveLeft = SKAction()
                if car.position.x > self.frame.width/3 {
                    if car.position.x > ((self.frame.width/3) * 2) {
                        moveLeft = SKAction.moveToX(lanes.secondLane, duration: 0.1)
                        
                    } else {
                        moveLeft = SKAction.moveToX(lanes.firstLane, duration: 0.1)
                    }
                    let leftSeq = SKAction.sequence([turnLeft,moveLeft,reset])
                    car.runAction(leftSeq)
                }
                
            } else if touchLocation.x >= car.position.x && touchLocation.x < self.frame.width { //&& car.position.x + differenceBetweenLanes < self.frame.width {
                var moveRight = SKAction()
                if car.position.x < self.frame.width/3 * 2 {
                    if car.position.x < self.frame.width/3 {
                        moveRight = SKAction.moveToX(lanes.secondLane, duration: 0.1)
                    } else {
                        moveRight = SKAction.moveToX(lanes.thirdLane, duration: 0.1)
                    }
                    let rightSeq = SKAction.sequence([turnRight,moveRight,reset])
                    car.runAction(rightSeq)
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == carCategory && secondBody.categoryBitMask == obstacleCategory || firstBody.categoryBitMask == obstacleCategory && secondBody.categoryBitMask == carCategory && !crashed {
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
        
        gameOverNode = SKNode()
        
        if defaults.integerForKey(scoreKey.highScore) < Int(score) {
            defaults.setValue(Int(score), forKey: scoreKey.highScore)
            viewController.saveHighScoreToGC(Int(score))
        }
        
        gameOverView = SKSpriteNode(color: UIColor.init(hue: 0, saturation: 0, brightness: 0.40, alpha: 0.75), size: CGSize(width: self.frame.width - lanes.firstLane/2 + 2, height: self.frame.height/3))
        gameOverView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        
        youCrashedLabel.fontSize = 18
        youCrashedLabel.fontName = "PressStart2P-Regular"
        youCrashedLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - gameOverView.frame.height/2 + gameOverView.frame.height/5 * 4)
        youCrashedLabel.fontColor = UIColor.whiteColor()
        
        var youCrashedText = "That was fun."
        let randomMessageNum = CGFloat.random(6)
        
        switch randomMessageNum {
        case 0 : youCrashedText = gameOverMessages.zero
        case 1 : youCrashedText = gameOverMessages.one
        case 2 : youCrashedText = gameOverMessages.two
        case 3 : youCrashedText = gameOverMessages.three
        case 4 : youCrashedText = gameOverMessages.four
        default : break
        }
        
        youCrashedLabel.text = (youCrashedText)
        
        scoreLabelGO.fontSize = 13
        scoreLabelGO.fontName = "PressStart2P-Regular"
        scoreLabelGO.position = CGPointMake(gameOverView.position.x, gameOverView.position.y)
        scoreLabelGO.fontColor = UIColor.whiteColor()
        scoreLabelGO.text = "Current score: \(Int(score))"
        
        highScoreLabel.fontSize = 13
        highScoreLabel.fontName = "PressStart2P-Regular"
        highScoreLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - gameOverView.frame.height/2 + gameOverView.frame.height/3)
        highScoreLabel.fontColor = UIColor.whiteColor()
        highScoreLabel.text = "Highest: \(defaults.integerForKey(scoreKey.highScore))"
        
        tryAgainLabel.fontSize = 11
        tryAgainLabel.fontName = "PressStart2P-Regular"
        tryAgainLabel.position = CGPointMake(gameOverView.position.x, gameOverView.position.y - gameOverView.frame.height/2 + gameOverView.frame.height/8)
        tryAgainLabel.fontColor = UIColor.whiteColor()
        tryAgainLabel.text = "Tap here to try again"
        
        leaderboardButton.name = "button"
        //leaderboardButton.position = CGPoint(x: gameOverView.position.x, y: gameOverView.position.y - (gameOverView.frame.height/3 * 2))
        leaderboardButton.text = "Leaderboard"
        leaderboardButton.fontSize = 18
        leaderboardButton.fontName = "PressStart2P-Regular"
        leaderboardButton.fontColor = UIColor.whiteColor()
        leaderboardButton.position = CGPointMake(self.frame.width/2, gameOverView.position.y - (gameOverView.frame.height/3 * 2))

        
        gameOverNode.removeFromParent()
        gameOverNode.setScale(0)
        gameOverNode.addChild(gameOverView)
        gameOverNode.addChild(highScoreLabel)
        gameOverNode.addChild(scoreLabelGO)
        gameOverNode.addChild(youCrashedLabel)
        gameOverNode.addChild(tryAgainLabel)
        gameOverNode.addChild(leaderboardButton)
        gameOverNode.runAction(SKAction.scaleTo(1.0, duration: 0.2))
        self.addChild(gameOverNode)
        
        //leaderboardButton.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: gameOverView.frame.width/3 * 2, height: gameOverView.frame.height/2), center: CGPoint(x: leaderboardButton.position.x + self.frame.width/2, y: leaderboardButton.position.y))
//        leaderboardButton.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: gameOverView.frame.width/3 * 2, height: gameOverView.frame.height/2))
//        leaderboardButton.physicsBody?.affectedByGravity = false
//        leaderboardButton.physicsBody?.dynamic = false
//        leaderboardButton.physicsBody?.pinned = true
    }
    
    func mileStone() {
        mileStoneLabel = SKLabelNode()
        mileStoneLabel.text = "CHECKPOINT!"
        mileStoneLabel.fontSize = 25
        mileStoneLabel.fontName = "PressStart2P-Regular"
        mileStoneLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/6 * 5)
        mileStoneLabel.setScale(0)
        mileStoneLabel.fontColor = UIColor.redColor()
        mileStoneLabel.zPosition = 20
        self.addChild(mileStoneLabel)
        let scaleUp = SKAction.scaleTo(1.0, duration: 0.5)
        let scaleDown = SKAction.scaleTo(0.6, duration: 0.5)
        let seq = SKAction.sequence([scaleUp, scaleDown])
        mileStoneLabel.runAction(SKAction.sequence([SKAction.repeatAction(seq, count: 1), scaleUp, SKAction.scaleTo(0, duration: 0.8),SKAction.removeFromParent()]))
        mileStoneLabel = SKLabelNode()
        mileStoneLabel.text = "Speeding up!"
        mileStoneLabel.fontSize = 25
        mileStoneLabel.fontName = "PressStart2P-Regular"
        mileStoneLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/6 * 5)
        mileStoneLabel.setScale(0)
        mileStoneLabel.fontColor = UIColor.redColor()
        mileStoneLabel.zPosition = 20
        self.addChild(mileStoneLabel)
        mileStoneLabel.runAction(SKAction.sequence([SKAction.waitForDuration(2.5),SKAction.repeatAction(seq, count: 1), scaleUp, SKAction.scaleTo(0, duration: 0.8),SKAction.removeFromParent()]))
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
            car1.size = CGSizeMake(self.frame.width/3 - lanes.firstLane/2 - 10, self.frame.width/3 - lanes.firstLane/2 - 10)
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: car1.size.width*0.67, height: car1.size.height - 1))
            car1.physicsBody?.affectedByGravity = false
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
            car1.size = CGSizeMake(self.frame.width/3 - lanes.firstLane/2 - 10, self.frame.width/3 - lanes.firstLane/2 - 10)
            car1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: car1.size.width*0.67, height: car1.size.height - 1))
            car1.physicsBody?.affectedByGravity = false
            car1.physicsBody?.categoryBitMask = obstacleCategory
            car1.physicsBody?.collisionBitMask = carCategory
            car1.physicsBody?.contactTestBitMask = carCategory
            switch randomPos2 {
            case 0: car2.position = CGPoint(x: lanes.firstLane, y: self.frame.height + 25)
            case 1: car2.position = CGPoint(x: lanes.secondLane, y: self.frame.height + 25)
            case 2: car2.position = CGPoint(x: lanes.thirdLane, y: self.frame.height + 25)
            default: break
            }
            car2.size = CGSizeMake(self.frame.width/3 - lanes.firstLane/2 - 10, self.frame.width/3 - lanes.firstLane/2 - 10)
            car2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: car2.size.width*0.67, height: car2.size.height - 1))
            car2.physicsBody?.affectedByGravity = false
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
                if bgSpeed < 34.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 35
                    if !updated1000000 {
                        updated1000000 = true
                        speedOfMovement = 0.0005
                        delayBetweenObstacles = 0.2
                        mileStone()
                        spawn()
                    }
                }
            } else if score > 500000 {
                if bgSpeed < 29.9 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 30
                    if !updated1000000 {
                        updated1000000 = true
                        speedOfMovement = 0.0005
                        delayBetweenObstacles = 0.2
                        mileStone()
                        spawn()
                    }
                }
            } else if score > 100000 {
                if bgSpeed < 27.4 {
                    bgSpeed += 0.1
                } else {
                    bgSpeed = 27.5
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