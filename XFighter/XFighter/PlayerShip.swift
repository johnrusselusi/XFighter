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
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
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
                mainShip.name = "mainship"
                
                let textureView = SKView()
                SharedTexture.texture = textureView.textureFromNode(mainShip)!
                SharedTexture.texture.filteringMode = .Nearest
        })
        
        return SharedTexture.texture
    }
    
    init(entityPosition: CGPoint)
    {
        let entityTexture = PlayerShip.generateTexture()!
        
        super.init(position: entityPosition, texture: entityTexture)
        name = "playerShip"
    }
}