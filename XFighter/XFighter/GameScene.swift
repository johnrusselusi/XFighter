//
//  GameScene.swift
//  XFighter
//
//  Created by John Russel Usi on 10/29/15.
//  Copyright (c) 2015 CYS. All rights reserved.
//

import SpriteKit
import CoreMotion

@IBDesignable
class GameScene: SKScene, SKPhysicsContactDelegate
{
    let motionManager: CMMotionManager = CMMotionManager()
    
    let healthBarString: NSString = "======================"
    let playerHealthLabel = SKLabelNode(fontNamed: "Arial")
    
    var firstPath = UIBezierPath()
    
    var lasUpdateTime : NSTimeInterval = 0
    var dt : NSTimeInterval = 0
    let backgroundMovePointsPerSec: CGFloat = 1000
    
    let randomPath = UIBezierPath()
    
    var isGameOVer: Bool = false
    var playerShip: PlayerShip!
    var shipDestination: CGPoint = CGPointZero
    let shipAnimation: SKAction
    
    let backgroundLayer = SKNode()
    let playerLayerNode = SKNode()
    
    // Bullet Properties
    var bulletInterval: NSTimeInterval = 0
    let bulletLayerNode = SKNode()
    
    // Enemy Properties
    let enemyLayerNode = SKNode()
    
    let playableRect: CGRect
    let hudHeight: CGFloat = 90
    
    var deltaPoint = CGPointZero
    
    override init(size: CGSize)
    {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let maxAspectRatioWidth = size.height / maxAspectRatio
        let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
        playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin / 2, height: size.height)
        
        var textures: [SKTexture] = []
        
        for i in 1...3
        {
            textures.append(SKTexture(imageNamed: "ship_0\(i)"))
        }
        
        shipAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
        super.init(size: size)

        setupSceneLayers()
        setupEntities()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var newPoint: CGPoint = playerShip.position + deltaPoint
        
        newPoint.x.clamp(CGRectGetMinX(playableRect), CGRectGetMaxX(playableRect))
        newPoint.y.clamp(CGRectGetMinY(playableRect), CGRectGetMaxY(playableRect))
        
        playerShip.position = newPoint
        deltaPoint = CGPointZero
        
        if lasUpdateTime > 0
        {
            dt = currentTime - lasUpdateTime
        }
        else
        {
            dt = 0
        }
        
        lasUpdateTime = currentTime
        
        bulletInterval += dt
        
        if bulletInterval > 0.5 && !isGameOVer
        {
            bulletInterval = 0
            let playerBullet = Bullet(entityPosition: playerShip.position)
            bulletLayerNode.addChild(playerBullet)
            playerBullet.runAction(SKAction.sequence([SKAction.moveByX(0, y: size.height, duration: 1), SKAction.removeFromParent()]))
        }
        
        for node in enemyLayerNode.children
        {
            let enemy = node as! Enemy
            enemy.update(self.dt)
        }
        
        let healthBarLength = Double(healthBarString.length) * playerShip.health / 100.0
        playerHealthLabel.text = healthBarString.substringToIndex(Int(healthBarLength))
        
        processUserMotionForUpdate(currentTime)
        moveBackground()
    }
    
    override func didMoveToView(view: SKView)
    {
        motionManager.startAccelerometerUpdates()
        
        for i in 0...1
        {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: 0, y: CGFloat(i) * background.size.height)
            background.name = "background"
            backgroundLayer.addChild(background)
        }
        
        physicsWorld.contactDelegate = self

        startShipAnimation()
        debugDrawPlayableArea()
        drawHealthBar()
    }
    
    func debugDrawPlayableArea()
    {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func drawHealthBar()
    {
        let healthBarBackground = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: size.width, height: 90))
        healthBarBackground.anchorPoint = CGPointZero
        
        // 1
        let playerHealthBackgroundLabel =
        SKLabelNode(fontNamed: "Arial")
        playerHealthBackgroundLabel.name = "playerHealthBackground"
        playerHealthBackgroundLabel.fontColor = SKColor.darkGrayColor()
        playerHealthBackgroundLabel.fontSize = 50
        playerHealthBackgroundLabel.text = healthBarString as String
        playerHealthBackgroundLabel.zPosition = 200
        // 2
        playerHealthBackgroundLabel.horizontalAlignmentMode = .Left
        playerHealthBackgroundLabel.verticalAlignmentMode = .Top
        playerHealthBackgroundLabel.position = CGPoint(
            x: CGRectGetMinX(playableRect),
            y: CGRectGetMidY(playableRect) - (size.height / 2) + 25)
        addChild(playerHealthBackgroundLabel)
        // 3
        playerHealthLabel.name = "playerHealthLabel"
        playerHealthLabel.fontColor = SKColor.greenColor()
        playerHealthLabel.fontSize = 50
        playerHealthLabel.text =
            healthBarString.substringToIndex(20*75/100)
        playerHealthLabel.zPosition = 201
        playerHealthLabel.horizontalAlignmentMode = .Left
        playerHealthLabel.verticalAlignmentMode = .Top
        playerHealthLabel.position = CGPoint(
            x: CGRectGetMinX(playableRect),
            y: CGRectGetMidY(playableRect) - (size.height / 2) + 25)
        addChild(playerHealthLabel)
    }
    
    func setupSceneLayers()
    {
        backgroundLayer.zPosition = -1
        bulletLayerNode.zPosition = 25
        playerLayerNode.zPosition = 50
        enemyLayerNode.zPosition = 35
        
        addChild(playerLayerNode)
        addChild(backgroundLayer)
        addChild(bulletLayerNode)
        addChild(enemyLayerNode)
    }
    
    func setupEntities()
    {
        playerShip = PlayerShip(entityPosition: CGPoint(x: size.width / 2, y: 100))
        playerLayerNode.addChild(playerShip)
        
        spawnEnemyShips()
    }
    
    func spawnEnemyShips()
    {
        for _ in 0..<5
        {
            let enemy = Enemy(entityPosition: generateRandomPoint(playableRect))

            enemyLayerNode.addChild(enemy)
        }
    }
    
    func generateRandomPoint(bounds: CGRect) ->CGPoint
    {
        let randomX = CGRectGetMinX(bounds) + CGFloat(arc4random()) % CGRectGetWidth(bounds)
        let randomY = CGRectGetMidY(bounds) + CGFloat(arc4random()) % CGRectGetHeight(bounds)
        
        return CGPointMake(randomX, randomY)
    }

    func moveBackground()
    {
        let backgroundVelocity = CGPoint(x: 0, y: -backgroundMovePointsPerSec)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        backgroundLayer.enumerateChildNodesWithName("background")
            {
                node, _ in
                
                let background = node as! SKSpriteNode
                let backgroundScreenPos = self.backgroundLayer.convertPoint(background.position, toNode: self)
                
                if backgroundScreenPos.y <= -background.size.height
                {
                    background.position = CGPoint(x: background.position.x,
                                                  y: background.position.y + background.size.height * 2)
                }
        }
    }
    
    func backgroundNode() -> SKSpriteNode
    {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPointZero
        background.position = CGPointZero
        background.size = CGSize(width: size.width, height: size.height * 2)
        backgroundNode.addChild(background)
        
        backgroundNode.size = background.size
        
        return backgroundNode
    }
    
    func startShipAnimation()
    {
        playerShip.runAction(SKAction.repeatActionForever(shipAnimation))
    }
    
    func boundsCheckShip()
    {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if shipDestination.x <= bottomLeft.x
        {
            shipDestination.x = bottomLeft.x
        }
        
        if shipDestination.x >= topRight.x
        {
            shipDestination.x = topRight.x
        }
        
        if shipDestination.y <= bottomLeft.y
        {
            shipDestination.y = bottomLeft.y
        }
        
        if shipDestination.y >= topRight.y
        {
            shipDestination.y = topRight.y
        }
    }
    
    //MARK: UITouch Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        deltaPoint = CGPointZero
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first as UITouch?
        {
            let currentPoint = touch.locationInNode(self)
            let previousPoint = touch.previousLocationInNode(self)
            
            deltaPoint = currentPoint - previousPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        deltaPoint = CGPointZero
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        if let enemyNode = contact.bodyA.node
        {
            if enemyNode.name == "enemyShip" || enemyNode.name == "mainShip"
            {
                let enemy = enemyNode as! Entity
                enemy.collidedWith(contact.bodyA, contact: contact)
            }
        }
        
        if let playerNode = contact.bodyB.node
        {
            if playerNode.name == "mainShip" || playerNode.name == "bullet"
            {
                let player = playerNode as! Entity
                player.collidedWith(contact.bodyA, contact: contact)
            }
        }
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval)
    {
        let ship = playerLayerNode.childNodeWithName("mainShip") as! SKSpriteNode
        
        if let data = motionManager.accelerometerData
        {
            ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 40.0 * CGFloat(data.acceleration.y)))
        }
    }
}
