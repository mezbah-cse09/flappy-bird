//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Guilherme Souza on 9/28/15.
//  Copyright (c) 2015 Guilherme Souza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    
    var scoreLabel = SKLabelNode()
    
    var gameOverLabel = SKLabelNode()
    
    var bg = SKSpriteNode()
    
    var bird = SKSpriteNode()
    
    var pipe1 = SKSpriteNode()
    
    var pipe2 = SKSpriteNode()
    
    var gameOver = false
    
    // Onde serão armazenados as senas que se movem (background, bird e gap)
    var movingObjects = SKSpriteNode()
    
    // Onde serão armazenados todos os labels
    var labelContainer = SKSpriteNode()
    
    // Define os tipos de colisões de corpos
    enum ColliderType: UInt32 {
        case bird = 1
        case object = 2
        case gap = 4
    }
    
    /*
    =====================================
    FUNÇÃO QUE DEFINE AS IMAGENS DE FUNDO
    =====================================
    */
    func makeBg() {
        
        // Define a textura(imagem) do fundo
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        // Define o movimento do fundo para a esquerda.
        let moveBg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 9)
        
        // Define o movimento do fundo de volta ao começo instantaneamente
        let replaceBg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        
        // Define uma ação que repete a sequencia de movimentos para sempre
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        // Adiciona 3 fundos que vão aparecendo periodicamente
        for i in 0...3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            
            // Define a posição do bg como sendo o centro da imagem no centro do frame
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(integerLiteral: i), y: self.frame.midY)
            
            // Define a largura do fundo como a largura do frame, no caso a largura do dispositivo
            bg.size.height = self.frame.height
            bg.zPosition = -5
            
            // Execulta a ação definida acima
            bg.run(moveBgForever)
            
            // Adiciona a sena ao objeto
            movingObjects.addChild(bg)
            
        }
        
    }
    
    /*
    ==========================
    FUNÇÃO QUE DEFINE OS CANOS
    ==========================
    */
    func makePipes() {
        
        // Define a distância entre os canos como sendo 4x a altura do pássaro
        let gapHeight = bird.size.height * 4
        
        // Define aleatoriamente onde o gap aparece
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        
        // Define o movimento dos canos para a esquerda
        let movePipes = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width / 100))
        
        // Remove o cano quando chega ao final do frame
        let removePipes = SKAction.removeFromParent()
        
        // Define a ação de adicionar e remover os canos
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        // Define o cano de cima
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        
        // Adiciona um corpo ao cano
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        
        // "Desligar" a gravidade
        pipe1.physicsBody?.isDynamic = false
        
        // Define a categoria do objeto e colisões
        pipe1.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        // Adiciona a sena ao objeto
        movingObjects.addChild(pipe1)
        
        // Define o cano de baixo
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        
        // Adiciona um corpo ao cano
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        
        // "Desligar" a gravidade
        pipe2.physicsBody?.isDynamic = false
        
        // Define a categoria do objeto e colisões
        pipe2.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        // Adiciona a sena ao objeto
        movingObjects.addChild(pipe2)
        
        // Define um objeto entre os canos para testar se o pássaro passou ou não pelos canos
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipeOffset)
        gap.run(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width / 2, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        
        gap.physicsBody?.categoryBitMask = ColliderType.gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.gap.rawValue
        
        movingObjects.addChild(gap)
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // Adiciona os elementos a sena
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        // Chama a funcão que faz o fundo quando a view aparece.
        makeBg()
        
        // Define o score no topo da sena
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 70)
        self.addChild(scoreLabel)
        
        /*
        ==========================
        BIRD
        ==========================
        */
        
        // Define as imagens do pássaro
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // Ocila entre as imagens para dar movimento ao pássaro
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // Execulta a ação de animar o pássaro
        bird.run(makeBirdFlap)
        
        // Adiciona um corpo ao pássaro com gravidade
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody?.isDynamic = true
        
        // Desabilita a rotação do corpo
        bird.physicsBody?.allowsRotation = false
        
        // Define a categoria de colisão
        bird.physicsBody?.categoryBitMask = ColliderType.bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        self.addChild(bird)
        
        /*
        ==========================
        GROUND
        ==========================
        */
        // Define o chão sem gravidade, pois geralemente o chão não despenca do nada :)
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        
        // Adiciona o chão a mesma categoria que os canos
        ground.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        self.addChild(ground)
        
        
        // Repete a função makePipes a cada 3 segundos
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Checar se houve contato com objetos da categoria Gap, o que indica que o pássaro passou pelos canos
        if contact.bodyA.categoryBitMask == ColliderType.gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.gap.rawValue {
            // Adiciona 1 ao score
            score += 1
            scoreLabel.text = String(score)
        } else {
            // Precimos checar se gameOver é falso pois quando o pássaro cai no chão ele bate umas 3 vezes no chão rodando esta função na primera mas dando crash nas outras duas.
            // Então checamos se gameOver é falso, assim a função roda só a primeira vez
            if gameOver == false {
                
                gameOver = true
                
                // Define a velocidade da sena como 0 para o jogador não interagir com o pássaro depois de perder
                self.speed = 0
                
                // Adicona a frase de Game Over
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                labelContainer.addChild(gameOverLabel)
            }
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        // Se game over é falso quer dizer o jogador ainda não perdeu
        if gameOver == false {
            // Adiona um impulso de valor 80 no eixo y fazendo o pássaro voar
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        } else {
            // Se gameOver é true então quer dizer que houve colisão com objetos que não são do tipo Gap
            
            // Aqui volta o score para 0, a posição do pássaro para o centro, a velocidade da sena para a original (1), gameOver para false e remove os labels de game over.
            score = 0
            scoreLabel.text = "0"
            
            bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            movingObjects.removeAllChildren()
            makeBg()
            
            self.speed = 1
            
            gameOver = false
            
            labelContainer.removeAllChildren()
            
        }
        
    }
    
}
