//
//  GameScene.swift
//  ios_game_test
//
//  Created by Weiheng Ni on 2016-01-03.
//  Copyright (c) 2016 Weiheng Ni. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var levelArray: [LevelData?] = []
    var currentLevel: Int = 0
    var blockSprite: GameBlock? = nil
    var gameGround: SKSpriteNode? = nil
    var barrierSprite = [GameBarrier?]()
    var blockSpriteAngleLabel: SKLabelNode? = nil
    var blockRotateAngle: CGFloat = 0.0
    var levelString: String? = nil
    
    private func gameObjectInit() {
        blockSprite = nil
        gameGround = nil
        barrierSprite = []
        blockSprite = nil
        blockSpriteAngleLabel = nil
        blockRotateAngle = 0.0
        levelString = nil
    }
    
    private func gameObjectSanityCheck() -> Bool {
        if blockSprite == nil {return false}
        if gameGround == nil {return false}
        if blockSpriteAngleLabel == nil {return false}
        if levelString == nil {return false}
        for var idx = 0; idx < barrierSprite.count; idx++ {
            if barrierSprite[idx] == nil {return false}
        }
        
        return true
    }
    
    private func constructGameLevel(levelData: LevelData?) -> Bool {
        
        if levelData == nil {
            return false
        }
        
        self.gameObjectInit()
        
        // Game Scene Properties
        self.levelString = levelData?.levelInfoStr
        self.backgroundColor = (levelData?.bgColor)!
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = (levelData?.gravity)!

        // Game Ground Properties
        gameGround = SKSpriteNode(color: (levelData?.groundProperty?.color)!, size: self.size * (levelData?.groundProperty?.size)!)
        gameGround!.anchorPoint = CGPointMake(0.5, 0.0)
        gameGround!.position = self.position + CGPointMake(self.size.width, self.size.height) * (levelData?.groundProperty?.position)!
        gameGround!.physicsBody = SKPhysicsBody(rectangleOfSize: (gameGround!.size), center: CGPointMake(0, (gameGround!.size.height)/2))
        gameGround!.physicsBody?.dynamic = false
        gameGround!.physicsBody?.categoryBitMask = PhysicsCategory.ground
        gameGround?.physicsBody?.collisionBitMask = PhysicsCategory.block
        gameGround!.physicsBody?.restitution = 0.0
        gameGround!.physicsBody?.friction = 0.0
        addChild(gameGround!)
        
        // Block Properties
        let blockRealSize = self.size.width * (levelData?.blockProperty?.size)!
        let blockRealSpeed = (levelData?.blockProperty?.moveSpeed!.dx)! * blockRealSize.width
        blockSprite = GameBlock(color: (levelData?.blockProperty?.color)!, size: blockRealSize, moveSpeed: blockRealSpeed, jumpDuration: (levelData?.blockProperty?.jumpDuration)!, jumpScale: (levelData?.blockProperty?.jumpScale)!)
        blockSprite!.position = CGPointMake(-blockSprite!.size.width/2, gameGround!.size.height + blockSprite!.size.height/2)
        addChild(blockSprite!)
        
        // Barriers
        barrierSprite = [GameBarrier?](count: (levelData?.barrierProperty?.count)!, repeatedValue: nil)
        for var idx = 0; idx < levelData?.barrierProperty?.count; idx++ {
            barrierSprite[idx] = GameBarrier(color: (levelData?.barrierProperty![idx].color)!, size: blockSprite!.size * (levelData?.barrierProperty![idx].size)!)
            barrierSprite[idx]?.position = CGPointMake(self.size.width, blockSprite!.size.height) * (levelData?.barrierProperty![idx].position)! + 0.5 * (barrierSprite[idx]?.size)! + CGPointMake(0, gameGround!.position.y + gameGround!.size.height)
            let barrierMove = (levelData?.barrierProperty![idx].moveVector)!
            let barrierMoveDuration = Double((levelData?.barrierProperty![idx].moveDuration)!)
            if (abs(barrierMove) >= 0.25 && barrierMoveDuration >= 0.1) {
                barrierSprite[idx]?.addMoveAction(barrierMove * blockSprite!.size.width, moveDuration: barrierMoveDuration)
            }
            addChild(barrierSprite[idx]!)
        }
        
        let blockSpriteAngleText = NSString(format: "%@ -- Angle: %.02f\u{00B0}", levelString!, blockSprite!.zRotation)
        blockSpriteAngleLabel = SKLabelNode(fontNamed: "Helvetica")
        blockSpriteAngleLabel!.text = blockSpriteAngleText as String
        blockSpriteAngleLabel!.fontSize = 12
        blockSpriteAngleLabel!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        blockSpriteAngleLabel!.position = CGPoint(x:25, y:10)
        
        return gameObjectSanityCheck()
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        levelArray = LevelParser.getLevelFromJSONFile("level")
        currentLevel = 0
        if constructGameLevel(levelArray[currentLevel]) == false {
            self.removeAllChildren()
            self.gameObjectInit()
            self.removeFromParent()
        } else {
            self.runAction(SKAction.playSoundFileNamed("bgmusic.mp3", waitForCompletion: true))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (PhysicsCategory.block | PhysicsCategory.barrier) {

            blockSprite!.removeFromParent()
            blockSprite!.removeAllActions()
            
            let expoNode = GameExplosionNode(pos: contact.contactPoint, pcolor: (blockSprite?.color)!, psize: (blockSprite?.size)! * 0.075)
            self.addChild(expoNode)
            expoNode.resetSimulation()
            expoNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.6), SKAction.removeFromParent()]))
            
            blockSprite!.zRotation = 0
            blockSprite!.position.y = blockSprite!.size.height * blockSprite!.anchorPoint.y + gameGround!.position.y + gameGround!.size.height
            blockSprite!.position.x = -blockSprite!.size.width * (1 - blockSprite!.anchorPoint.x)
            
            blockSprite!.physicsBody?.affectedByGravity = true
            blockSprite!.physicsBody?.velocity.dx = blockSprite!.moveSpeed
            addChild(blockSprite!)
        }
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if blockSprite!.hasActions() == false {
            blockSprite!.physicsBody?.affectedByGravity = false
            blockSprite!.physicsBody?.velocity = CGVectorMake(0, 0)
            
            blockSprite!.runAction(blockSprite!.getActionJump()!,
                completion: {
                    self.blockSprite!.removeAllActions()
                    self.blockSprite!.physicsBody?.affectedByGravity = true
            })
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let blockSpriteAngleText = NSString(format: "%@ -- Angle: %.02f\u{00B0}\r pos: (%.02f, %.02f)", self.levelString!, blockSprite!.zRotation * 180 / CGFloat(M_PI), blockSprite!.position.x, blockSprite!.position.y)
        blockSpriteAngleLabel!.text = blockSpriteAngleText as String
        
        if blockSprite!.hasActions() == false {
            blockSprite!.physicsBody?.velocity.dx = blockSprite!.moveSpeed
        }
        
        let posOffset: CGFloat = blockSprite!.size.width * (1 + cos(blockSprite!.zRotation) * (blockSprite!.anchorPoint.x * 2 - 1)) / 2
        if blockSprite!.position.x > self.size.width + posOffset {
            //blockSprite!.position.x = -(blockSprite!.size.width - posOffset)
            self.removeAllChildren()
            
            currentLevel = (currentLevel + 1) % 2
            if constructGameLevel(levelArray[currentLevel]) == false {
                self.removeAllChildren()
                self.gameObjectInit()
                self.removeFromParent()
            } else {
                self.runAction(SKAction.playSoundFileNamed("bgmusic.mp3", waitForCompletion: true))
            }
            
        }
    }
    
}
