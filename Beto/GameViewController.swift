//
//  GameViewController.swift
//  Beto
//
//  Created by Jem on 2/4/16.
//  Copyright (c) 2016 redgarage. All rights reserved.
//

import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    var gameScene: GameScene!
    var boardScene: BoardScene!
    
    // HUD
    fileprivate var gameHUDView: UIImageView!
    fileprivate var backButton: UIButton!
    fileprivate var highscoreView: UIImageView!
    fileprivate var coinsView: UIImageView!
    fileprivate var highscoreLabel: UILabel!
    fileprivate var coinsLabel: UILabel!
    
    fileprivate var sceneView: SCNView!
    fileprivate var panGesture = UIPanGestureRecognizer.self()
    fileprivate var tapGesture = UITapGestureRecognizer.self()
    fileprivate var tapRecognizer = UITapGestureRecognizer.self()
    fileprivate var touchCount = 0.0
    fileprivate var rerollEnabled = false
    fileprivate var rerolling = false
        
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure GameSceneHUD
        gameHUDView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320 * Constant.ScaleFactor, height: 38 * Constant.ScaleFactor))
        gameHUDView.image = UIImage(named: "gameSceneHUD")
        self.view.addSubview(gameHUDView)
        
        backButton = UIButton(frame: CGRect(x: 5, y: 7, width: 60 * Constant.ScaleFactor, height: 25 * Constant.ScaleFactor))
        backButton.setBackgroundImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.contentMode = .scaleAspectFill
        backButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        let font = UIFont(name: "Futura-CondensedMedium", size: 14 * Constant.ScaleFactor)
        
        highscoreLabel = UILabel()
        highscoreLabel.frame = CGRect(x: 110 * Constant.ScaleFactor, y: 9 * Constant.ScaleFactor, width: 80  * Constant.ScaleFactor, height: 18  * Constant.ScaleFactor)
        highscoreLabel.text = "\(GameData.highscore)"
        highscoreLabel.font = font
        highscoreLabel.textColor = UIColor.white
        highscoreLabel.textAlignment = .center
        self.view.addSubview(highscoreLabel)
        
        let coins = GameData.coins - boardScene.getWagers()
        
        coinsLabel = UILabel()
        coinsLabel.frame = CGRect(x: 220 * Constant.ScaleFactor, y: 9 * Constant.ScaleFactor, width: 80  * Constant.ScaleFactor, height: 18  * Constant.ScaleFactor)
        coinsLabel.text = "\(coins)"
        coinsLabel.font = font
        coinsLabel.textColor = UIColor.white
        coinsLabel.textAlignment = .center
        self.view.addSubview(coinsLabel)
        
        // Configure PowerUps
        if boardScene.activePowerUp != "" {
            let activePowerUpView = UIImageView(frame: CGRect(x: 10, y: gameHUDView.frame.height + 5, width: 48 * Constant.ScaleFactor, height: 48 * Constant.ScaleFactor))
            activePowerUpView.image = UIImage(named: boardScene.activePowerUp)
            activePowerUpView.contentMode = .topLeft
            self.view.addSubview(activePowerUpView)
        }
        
        if boardScene.activePowerUp == PowerUpKey.reroll.rawValue {
            rerollEnabled = true
        }
        
        // Configure the Game scene
        var diceType: DiceType!
        
        switch(boardScene.activePowerUp) {
        case PowerUpKey.doublePayout.rawValue:
            diceType = .doublePayout
        case PowerUpKey.triplePayout.rawValue:
            diceType = .triplePayout
        case PowerUpKey.doubleDice.rawValue:
            diceType = .doubleDice
        default:
            diceType = .default
        }
        
        gameScene = GameScene(dice: diceType)
        gameScene.resolveGameplayHandler = { [unowned self] in self.handleResolveGameplay() }
        
        // Configure the view
        sceneView = self.view as! SCNView
        sceneView.scene = gameScene
        sceneView.delegate = gameScene
        sceneView.isPlaying = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
        
        // Configure the background
        gameScene.background.contents = UIImage(named: GameData.theme.background)
        
        // Configure the gestures
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
        
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
    }
    
    func handlePan(_ gesture:UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: self.view).y
        let translationX = gesture.translation(in: self.view).x
        
        if touchCount < 2 {
            if translationY < -100 {
                for node in gameScene.getDice() {
                    node.physicsBody!.applyTorque(SCNVector4(1,1,1,(translationY/400-1)), asImpulse: true) // Perfect spin
                    node.physicsBody!.applyForce(SCNVector3(translationX/17,(-translationY/130)+9,(translationY/5)-11), asImpulse: true) // MIN (0,17,-31) MAX (0,21,-65)
                }
                
                touchCount += 1
             
                backButton.isEnabled = false
            }
        } else if touchCount == 2 {
            gameScene.shouldCheckMovement = true
        }
    }
    
    func handleResolveGameplay() {
        // Only update coins and gamesPlayed during the first roll.
        if !rerolling {
            GameData.subtractCoins(boardScene.getWagers())
            
            GameData.incrementGamesPlayed()
            GameData.incrementAchievement(.GamesPlayed)
        }
        
        var winningColors: [Color] = []
        var didWin = false
        
        for node in gameScene.getDice() {
            let winningColor = gameScene.getWinningColor(node)
            let square = boardScene.squareWithColor(winningColor)!
            
            boardScene.resolvePayout(square)
            
            // Keeps track if you match at least one color this roll
            if !didWin {
                didWin = boardScene.didPayout(square)
            }
            
            if boardScene.didPayout(square) {
                let winMsg = SCNText(string: "+\(boardScene.calculateWinnings(square))", extrusionDepth: 0.02)
                winMsg.chamferRadius = 0.001
                winMsg.font = UIFont(name: "Futura-CondensedExtraBold", size: (0.2/1.29375)*Constant.ScaleFactor)
                
                let whiteSide = SCNMaterial()
                whiteSide.diffuse.contents = UIColor.white
                let blackSide = SCNMaterial()
                blackSide.diffuse.contents = UIColor.black
                
                winMsg.materials = [whiteSide,blackSide,blackSide,blackSide,blackSide]
                winMsg.flatness = 0.000000000001
                winMsg.alignmentMode = kCAAlignmentCenter
                
                let winMsgNode = SCNNode(geometry: winMsg)
                winMsgNode.position = SCNVector3Make(node.presentation.position.x-0.15 , node.presentation.position.y+0.25 , node.presentation.position.z+0.1 )
                winMsgNode.eulerAngles = SCNVector3Make(Float(-M_PI/2), 0,0)
                
                winMsgNode.physicsBody = SCNPhysicsBody.dynamic()
                winMsgNode.physicsBody?.isAffectedByGravity = false
                winMsgNode.physicsBody?.applyForce(SCNVector3(0,0.03,0), asImpulse: true)
                
                gameScene.rootNode.addChildNode(winMsgNode)
            }
            
            if didWin && !winningColors.contains(winningColor) {
                switch winningColor {
                case .Blue:
                    GameData.incrementAchievement(.BlueWin)
                case .Red:
                    GameData.incrementAchievement(.RedWin)
                case .Green:
                    GameData.incrementAchievement(.GreenWin)
                case .Yellow:
                    GameData.incrementAchievement(.YellowWin)
                case .Cyan:
                    GameData.incrementAchievement(.CyanWin)
                case .Purple:
                    GameData.incrementAchievement(.PurpleWin)
                }
                
                winningColors.append(winningColor)
            }
            
            gameScene.animateRollResult(node, didWin: boardScene.didPayout(square))
            delay(1.0) {}
        }
        
        if !didWin && rerollEnabled {
            // Save data before resetting for the reroll
            GameData.save()
            
            rerollEnabled = false
            rerolling = true

            delay(2.0) {
                self.touchCount = 0.0
                self.gameScene = GameScene(dice: .default)
                self.gameScene.resolveGameplayHandler = { [unowned self] in self.handleResolveGameplay() }
                self.gameScene.background.contents = UIImage(named: GameData.theme.background)
             
                self.sceneView.scene = self.gameScene
                self.sceneView.delegate = self.gameScene
            }

            return
        }
        
        boardScene.resolveWagers(didWin)
        boardScene.toggleReplayButton()
        
        // Increment appropriate achievement
        switch(boardScene.activePowerUp) {
        case PowerUpKey.lifeline.rawValue:
            GameData.incrementAchievement(.Lifeline)
        case PowerUpKey.rewardBoost.rawValue:
            GameData.incrementAchievement(.RewardBoost)
        case PowerUpKey.doubleDice.rawValue:
            GameData.incrementAchievement(.DoubleDice)
        case PowerUpKey.doublePayout.rawValue:
            GameData.incrementAchievement(.DoublePayout)
        case PowerUpKey.triplePayout.rawValue:
            GameData.incrementAchievement(.TriplePayout)
        case PowerUpKey.reroll.rawValue:
            GameData.incrementAchievement(.Reroll)
        default:
            break
        }
        
        GameData.subtractPowerUpCount(boardScene.activePowerUp, num: 1)
        
        if didWin {
            // Increment MoneyGrabber achievement
            GameData.incrementAchievement(.MoneyGrabber)

            // Calculate rewardChance
            let num = 4 - boardScene.squaresSelectedCount
            
            GameData.increaseRewardChance(num)
            boardScene.resolveRandomReward()
        } else {
            GameData.resetRewardChance()
        }
        
        // If autoLoad is OFF or no more powerUP remaining, set activePowerUp to nil
        if !GameData.autoLoadEnabled || GameData.powerUps[boardScene.activePowerUp] == 0 {
            boardScene.deactivatePowerUpButtonPressed()
        }
        
        boardScene.resetSquaresSelectedCount()
        
        GameData.save()
        
        delay(1.0) {
            self.dismiss(animated: true, completion: self.boardScene.showUnlockedNodes)
        }
    }
        
    func buttonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

