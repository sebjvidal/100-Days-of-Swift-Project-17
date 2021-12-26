//
//  GameScene.swift
//  100 Days of Swift Projectc 17
//
//  Created by Seb Vidal on 25/12/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var draggingPlayer = false
    
    var totalEnemies = 0 {
        didSet {
            updateTimer()
        }
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupStarField()
        setupPlayer()
        setupScoreLabel()
        setupPhysics()
        initTimer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children where node.position.x < -300 {
            node.removeFromParent()
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        if let node = nodes(at: location).first {
            if node.name == "player" {
                draggingPlayer = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        var location = touch.location(in: self)
        
        if draggingPlayer {
            if location.y < 100 {
                location.y = 100
            } else if location.y > 668 {
                location.y = 668
            }
            
            player.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingPlayer = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node, let bodyB = contact.bodyB.node else {
            return
        }
        
        if bodyA.name == "player" || bodyB.name == "player" {
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = player.position
            
            addChild(explosion)
            
            player.removeFromParent()
            
            isGameOver = true
        }
    }
    
    func setupBackground() {
        backgroundColor = .black
    }
    
    func setupStarField() {
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        
        addChild(starfield)
        
        starfield.zPosition = -1
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        player.name = "player"
        
        addChild(player)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        
        addChild(scoreLabel)
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func initTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if totalEnemies % 20 != 0 {
            return
        }
        
        guard let currentTimer = gameTimer else {
            return
        }
        
        currentTimer.invalidate()
        
        var tick = TimeInterval(1 - (Double(totalEnemies) / 200))
        
        if tick < 0.4 {
            tick = 0.4
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: tick, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        if isGameOver {
            return
        }
        
        guard let enemy = possibleEnemies.randomElement() else {
            return
        }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        totalEnemies += 1
    }
    
}
