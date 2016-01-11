//
//  Bullet.swift
//  XFighter
//
//  Created by John Russel Usi on 10/30/15.
//  Copyright © 2015 CYS. All rights reserved.
//

import SpriteKit

class Bullet: Entity
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(entityPosition: CGPoint)
    {
        let entityTexture = Bullet.generateTexture()!
        
        super.init(position: entityPosition, texture: entityTexture)
        name = "bullet"
        
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
                let bullet = SKSpriteNode(imageNamed: "beam40")
                bullet.name = "bullet"
                bullet.size = CGSize(width: 40, height: 50)
                
                let textureView = SKView()
                SharedTexture.texture = textureView.textureFromNode(bullet)!
                SharedTexture.texture.filteringMode = .Nearest
        })
        
        return SharedTexture.texture
    }
    
    func configureCollisionBody()
    {
        let bulletTexture = SKTexture(imageNamed: "beam40")
        
        physicsBody = SKPhysicsBody(texture: bulletTexture, size: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyShip
    }
    
    override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact)
    {
        removeFromParent()
    }
}
