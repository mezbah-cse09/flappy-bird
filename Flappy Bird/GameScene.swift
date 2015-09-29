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
        case Bird = 1
        case Object = 2
        case Gap = 4
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
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        
        // Define o movimento do fundo de volta ao começo instantaneamente
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        
        // Define uma ação que repete a sequencia de movimentos para sempre
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        // Adiciona 3 fundos que vão aparecendo periodicamente
        for var i: CGFloat = 0; i < 3; i++ {
            
            bg = SKSpriteNode(texture: bgTexture)
            
            // Define a posição do bg como sendo o centro da imagem no centro do frame
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            
            // Define a largura do fundo como a largura do frame, no caso a largura do dispositivo
            bg.size.height = self.frame.height
            bg.zPosition = -5
            
            // Execulta a ação definida acima
            bg.runAction(moveBgForever)
            
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
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        
        // Remove o cano quando chega ao final do frame
        let removePipes = SKAction.removeFromParent()
        
        // Define a ação de adicionar e remover os canos
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        // Define o cano de cima
        var pipeTexture = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        
        // Adiciona um corpo ao cano
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        
        // "Desligar" a gravidade
        pipe1.physicsBody?.dynamic = false
        
        // Define a categoria do objeto e colisões
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        // Adiciona a sena ao objeto
        movingObjects.addChild(pipe1)
        
        // Define o cano de baixo
        var pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        
        // Adiciona um corpo ao cano
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2Texture.size())
        
        // "Desligar" a gravidade
        pipe2.physicsBody?.dynamic = false
        
        // Define a categoria do objeto e colisões
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        // Adiciona a sena ao objeto
        movingObjects.addChild(pipe2)
        
        // Define um objeto entre os canos para testar se o pássaro passou ou não pelos canos
        var gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeTexture.size().width / 2, gapHeight))
        gap.physicsBody?.dynamic = false
        
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
        
    }
    
    override func didMoveToView(view: SKView) {
        
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
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
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
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        // Execulta a ação de animar o pássaro
        bird.runAction(makeBirdFlap)
        
        // Adiciona um corpo ao pássaro com gravidade
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody?.dynamic = true
        
        // Desabilita a rotação do corpo
        bird.physicsBody?.allowsRotation = false
        
        // Define a categoria de colisão
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(bird)
        
        /*
        ==========================
        GROUND
        ==========================
        */
        // Define o chão sem gravidade, pois geralemente o chão não despenca do nada :)
        var ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        
        // Adiciona o chão a mesma categoria que os canos
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        
        // Repete a função makePipes a cada 3 segundos
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "makePipes", userInfo: nil, repeats: true)
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // Checar se houve contato com objetos da categoria Gap, o que indica que o pássaro passou pelos canos
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            // Adiciona 1 ao score
            score++
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
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelContainer.addChild(gameOverLabel)
            }
        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        // Se game over é falso quer dizer o jogador ainda não perdeu
        if gameOver == false {
            
            // Adiona um impulso de valor 80 no eixo y fazendo o pássaro voar
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 80))
        } else {
            // Se gameOver é true então quer dizer que houve colisão com objetos que não são do tipo Gap
            
            // Aqui volta o score para 0, a posição do pássaro para o centro, a velocidade da sena para a original (1), gameOver para false e remove os labels de game over.
            score = 0
            scoreLabel.text = "0"
            
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            
            movingObjects.removeAllChildren()
            makeBg()
            
            self.speed = 1
            
            gameOver = false
            
            labelContainer.removeAllChildren()
            
        }
        
    }
    
}
