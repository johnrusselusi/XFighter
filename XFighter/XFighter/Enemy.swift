//
//  Enemy.swift
//  XFighter
//
//  Created by John Russel Usi on 11/20/15.
//  Copyright © 2015 CYS. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: Entity
{
    var enemyExplodeAnimation = SKAction()
    
    let healthMeterLabel = SKLabelNode(fontNamed: "Arial")
    let healthMeterText: NSString = "________"
    
    var aiSteering: AISteering!
    var health = 100.0
    var damagePerHit = 10.0
    
    override func update(delta: NSTimeInterval)
    {
        if aiSteering.waypointReached
        {
            let mainScene = scene as! GameScene
            aiSteering.updateWaypoint(mainScene.playerShip.position)
        }
        
        aiSteering.update(delta)
        
        let healthBarLength = 8.0 * health / 100
        healthMeterLabel.text = "\(healthMeterText.substringToIndex(Int(healthBarLength)))"
        healthMeterLabel.fontColor = SKColor(red: CGFloat(2 * (1 - health / 100)),
            green:CGFloat(2 * health / 100), blue:0, alpha:1)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(entityPosition: CGPoint)
    {
        var explosionTextures: [SKTexture] = []
        
        for i in 1...4
        {
            explosionTextures.append(SKTexture(imageNamed: "explosion0\(i)"))
        }
        
        enemyExplodeAnimation = SKAction.animateWithTextures(explosionTextures, timePerFrame: 0.1)
        
        let entityTexture = Enemy.generateTexture()!
        
        super.init(position: entityPosition, texture: entityTexture)
        name = "enemyShip"
        
        aiSteering = AISteering(entity: self, waypoint: CGPointZero)
        configureHealthBar()
        configureCollisionBody()
    }
    
    override class func generateTexture() -> SKTexture?
    {
        struct SharedTexture
        {
            static var texture = SKTexture()
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&SharedTexture.onceToken,
            {
                let enemyShip = SKSpriteNode(imageNamed: "enemy_big01")
                enemyShip.name = "enemyShip"
                enemyShip.size = CGSizeMake(50, 50)
                
                let textureView = SKView()
                SharedTexture.texture = textureView.textureFromNode(enemyShip)!
                SharedTexture.texture.filteringMode = .Nearest
        })
        
        return SharedTexture.texture
    }
    
    override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact)
    {
        removeAllActions()
        if health > 0
        {
            health -= damagePerHit
        }
        else
        {
            runAction(SKAction.sequence([enemyExplodeAnimation, SKAction.removeFromParent()]))
        }
    }
    
    func configureHealthBar()
    {
        healthMeterLabel.name = "healthMeter"
        healthMeterLabel.text = healthMeterText as String
        healthMeterLabel.fontSize = 20
        healthMeterLabel.fontColor = SKColor.greenColor()
        healthMeterLabel.position = CGPointMake(0, 30)
        addChild(healthMeterLabel)
    }
    
    func configureCollisionBody()
    {
        physicsBody = SKPhysicsBody(rectangleOfSize: frame.size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.EnemyShip
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.PlayerShip
    }
}
