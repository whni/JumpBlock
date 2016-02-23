//
//  GameObjects.swift
//  ios_game_test
//
//  Created by Weiheng Ni on 2016-02-03.
//  Copyright © 2016 Weiheng Ni. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let block     : UInt32 = 0x00000001
    static let barrier   : UInt32 = 0x00000002
    static let ground    : UInt32 = 0x80000000
}

struct GameBlockDefaultParam {
    static let size    : CGSize    = CGSize(width: 30, height: 30)
    static let color   : UIColor   = UIColor(red: 4/255, green: 175/255, blue: 200/255, alpha: 1)
}


public class GameBlock: SKSpriteNode {
    
    // components
    public var moveSpeed: CGFloat = 0.0
    public var jumpDuration: CGFloat = 0.0
    public var jumpScale: CGFloat = 0.0
    
    private var jumpPath = UIBezierPath()
    private var actionJump: SKAction?
    private var actionSpeed: SKAction?
    private var actionRotate: SKAction?

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(texture: nil, color: GameBlockDefaultParam.color, size: GameBlockDefaultParam.size)
    }
    
    public convenience init(color co: UIColor, size: CGSize, moveSpeed: CGFloat, jumpDuration: CGFloat, jumpScale: CGFloat) {
        
        self.init()
        
        // UI components
        self.color = co
        self.size = size
        
        // physics components
        self.moveSpeed = moveSpeed
        self.jumpDuration = jumpDuration
        self.jumpScale = jumpScale
        
        // set jump path and actions
        self.jumpPath.removeAllPoints()
        self.jumpPath.moveToPoint(CGPointZero)
        self.jumpPath.addQuadCurveToPoint(CGPointMake(self.jumpDuration * self.moveSpeed, 0.0), controlPoint: CGPointMake(self.jumpDuration * self.moveSpeed / 2, self.size.height * self.jumpScale))
        
        self.actionJump = SKAction.followPath(self.jumpPath.CGPath, asOffset: true, orientToPath: false, duration: Double(self.jumpDuration))
        self.actionSpeed = SKAction.group([SKAction.speedTo(1.5, duration: 0), SKAction.speedTo(0.5, duration: Double(self.jumpDuration / 2)), SKAction.speedTo(1.5, duration: Double(self.jumpDuration / 1.5))])
        self.actionRotate = SKAction.rotateByAngle(CGFloat(-M_PI + 0.1), duration: (actionJump!.duration))
        
        self.anchorPoint = CGPointMake(0.5, 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size, center: CGPointMake(0.0, 0.0))
        self.physicsBody?.categoryBitMask = PhysicsCategory.block
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.barrier
        self.physicsBody?.contactTestBitMask = PhysicsCategory.barrier
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.velocity.dx = self.moveSpeed
    }
    
    public func getActionJump() -> SKAction? {
        
        if actionRotate == nil || actionJump == nil || actionSpeed == nil {
            return nil
        }
        return SKAction.group([actionRotate!, actionJump!, actionSpeed!])
    }

}


public class GameBarrier: SKSpriteNode {
    
    // components
    var moveAction: SKAction?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(texture: nil, color: GameBlockDefaultParam.color, size: GameBlockDefaultParam.size)
    }
    
    public convenience init(color co: UIColor, size: CGSize) {
        self.init()
        
        // UI components
        self.color = co
        self.size = size
        
        // physics components
        self.anchorPoint = CGPointMake(0.5, 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size, center: CGPointMake(0.0, 0.0))
        self.physicsBody?.categoryBitMask = PhysicsCategory.barrier
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.dynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.friction = 0.0
    }
    
    public func addMoveAction(delta: CGVector, moveDuration: Double) {
        let storedPos = self.position
        self.moveAction = SKAction.sequence([SKAction.moveTo(storedPos + delta, duration: moveDuration/2), SKAction.moveTo(storedPos, duration: moveDuration/2)])
        self.runAction(SKAction.repeatActionForever(self.moveAction!))
    }
    
}


public class GameExplosionNode: SKEmitterNode {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override init() {
        super.init()
    }
    
    public convenience init(pos: CGPoint, pcolor: UIColor, psize: CGSize) {
        self.init()
        
        self.position = pos
        
        self.particleBirthRate = 2000
        self.numParticlesToEmit = 20
        
        self.particleLifetime = 0.5
        self.particleLifetimeRange = 0.1
        
        self.emissionAngle = 0
        self.emissionAngleRange = CGFloat(2 * M_PI)
        self.particleRotationRange = CGFloat(2 * M_PI)
        
        self.particleSpeed = 100
        self.particleSpeedRange = 200
        self.xAcceleration = 0
        self.yAcceleration = -500
        
        self.particleAlpha = 1
        self.particleScale = 1
        self.particleTexture = SKTexture(image: UIImage.imageWithColor(pcolor, size: psize))
        
        self.particleBlendMode = SKBlendMode.Add
    }
}


