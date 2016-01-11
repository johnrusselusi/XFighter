//
//  Ship.swift
//  XFighter
//
//  Created by John Russel Usi on 10/30/15.
//  Copyright © 2015 CYS. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerShip: Entity
{
    var enemyExplodeAnimation = SKAction()

    
    let healthMeterLabel = SKLabelNode(fontNamed: "Arial")
    let healthMeterText: NSString = "________"
    
    var health = 100.0
    var damagePerHit = 10.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func update(delta: NSTimeInterval)
    {
        let healthBarLength = 8.0 * health / 100
        healthMeterLabel.text = "\(healthMeterText.substringToIndex(Int(healthBarLength)))"
        healthMeterLabel.fontColor = SKColor(red: CGFloat(2 * (1 - health / 100)),
            green:CGFloat(2 * health / 100), blue:0, alpha:1)
    }
    
    init(entityPosition: CGPoint)
    {
        let entityTexture = PlayerShip.generateTexture()!
        
        super.init(position: entityPosition, texture: entityTexture)
        name = "mainShip"
        
        var explosionTextures: [SKTexture] = []
        
        for i in 1...4
        {
            explosionTextures.append(SKTexture(imageNamed: "explosion0\(i)"))
        }
        
        enemyExplodeAnimation = SKAction.animateWithTextures(explosionTextures, timePerFrame: 0.1)
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
                let mainShip = SKSpriteNode(imageNamed: "ship_01")
                mainShip.name = "mainShip"
                
                let textureView = SKView()
                SharedTexture.texture = textureView.textureFromNode(mainShip)!
                SharedTexture.texture.filteringMode = .Nearest
        })
        
        return SharedTexture.texture
    }
    
    func configureCollisionBody()
    {
        let shipTexture = SKTexture(imageNamed: "ship_texture")
        
        physicsBody = SKPhysicsBody(texture: shipTexture, size: size)
        
        //physicsBody?.mass = 0.05
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.PlayerShip
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyShip
    }
    
    override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact)
    {
        if health > 0
        {
            health -= damagePerHit
        }
        else
        {
            runAction(SKAction.sequence([enemyExplodeAnimation, SKAction.removeFromParent()]))
        }
    }
}