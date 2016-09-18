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
    private var gameHUDView: UIImageView!
    private var backButton: UIButton!
    private var highscoreView: UIImageView!
    private var coinsView: UIImageView!
    private var highscoreLabel: UILabel!
    private var coinsLabel: UILabel!
    
    private var sceneView: SCNView!
    private var panGesture = UIPanGestureRecognizer.self()
    private var tapGesture = UITapGestureRecognizer.self()
    private var tapRecognizer = UITapGestureRecognizer.self()
    private var touchCount = 0.0
    private var rerollEnabled = false
    private var rerolling = false
        
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //this is the hud for the gameScene
        gameHUDView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320 * Constant.ScaleFactor, height: 38 * Constant.ScaleFactor))
        gameHUDView.image = UIImage(named: "gameSceneHUD")
        self.view.addSubview(gameHUDView)
        
        backButton = UIButton(frame: CGRect(x: 5, y: 7, width: 60 * Constant.ScaleFactor, height: 25 * Constant.ScaleFactor))
        backButton.setBackgroundImage(UIImage(named: "backButton"), forState: .Normal)
        backButton.contentMode = .ScaleAspectFill
        backButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        let font = UIFont(name: "Futura-CondensedMedium", size: 14 * Constant.ScaleFactor)
        
        highscoreLabel = UILabel()
        highscoreLabel.frame = CGRect(x: 110 * Constant.ScaleFactor, y: 9 * Constant.ScaleFactor, width: 80  * Constant.ScaleFactor, height: 18  * Constant.ScaleFactor)
        highscoreLabel.text = "\(GameData.highscore)"
        highscoreLabel.font = font
        highscoreLabel.textColor = UIColor.whiteColor()
        highscoreLabel.textAlignment = .Center
        self.view.addSubview(highscoreLabel)
        
        let coins = GameData.coins - boardScene.getWagers()
        
        coinsLabel = UILabel()
        coinsLabel.frame = CGRect(x: 220 * Constant.ScaleFactor, y: 9 * Constant.ScaleFactor, width: 80  * Constant.ScaleFactor, height: 18  * Constant.ScaleFactor)
        coinsLabel.text = "\(coins)"
        coinsLabel.font = font
        coinsLabel.textColor = UIColor.whiteColor()
        coinsLabel.textAlignment = .Center
        self.view.addSubview(coinsLabel)
        
        // Configure PowerUps
        if boardScene.activePowerUp != "" {
            let activePowerUpView = UIImageView(frame: CGRect(x: 10, y: gameHUDView.frame.height + 5, width: 48 * Constant.ScaleFactor, height: 48 * Constant.ScaleFactor))
            activePowerUpView.image = UIImage(named: boardScene.activePowerUp)
            activePowerUpView.contentMode = .TopLeft
            self.view.addSubview(activePowerUpView)
        }
        
        if boardScene.activePowerUp == PowerUpKey.reroll.rawValue {
            rerollEnabled = true
        }
        
        // Configure the Game scene
        var diceType: DiceType!
        
        switch(boardScene.activePowerUp) {
        case PowerUpKey.doublePayout.rawValue:
            diceType = .DoublePayout
        case PowerUpKey.triplePayout.rawValue:
            diceType = .TriplePayout
        case PowerUpKey.doubleDice.rawValue:
            diceType = .DoubleDice
        default:
            diceType = .Default
        }
        
        gameScene = GameScene(dice: diceType)
        gameScene.resolveGameplayHandler = { [unowned self] in self.handleResolveGameplay() }
        
        // Configure the view
        sceneView = self.view as! SCNView
        sceneView.scene = gameScene
        sceneView.delegate = gameScene
        sceneView.playing = true
        sceneView.backgroundColor = UIColor.clearColor()
        sceneView.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        
        // Configure the background
        gameScene.background.contents = UIImage(named: GameData.theme.background)
        
        // Configure the gestures
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
        
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
    }
    
    func handlePan(gesture:UIPanGestureRecognizer) {
        let translationY = gesture.translationInView(self.view).y
        let translationX = gesture.translationInView(self.view).x
        
        if touchCount < 2 {
            if translationY < -100 {
                for node in gameScene.getDice() {
                    node.physicsBody!.applyTorque(SCNVector4(1,1,1,(translationY/400-1)), impulse: true) // Perfect spin
                    node.physicsBody!.applyForce(SCNVector3(translationX/17,(-translationY/130)+9,(translationY/5)-11), impulse: true) // MIN (0,17,-31) MAX (0,21,-65)
                }
                
                touchCount += 1
             
                backButton.enabled = false
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
            let didPayout = boardScene.payout(winningColor)
            
            
            print("The winning color is \(winningColor)... did i win \(didPayout)")

            if !didWin {
                didWin = didPayout
            }
            
            if didPayout {
                let winMsg = SCNText(string: "+\(boardScene.calculateWinnings(winningColor))", extrusionDepth: 0.02)
                winMsg.chamferRadius = 0.001
                winMsg.font = UIFont(name: "Futura-CondensedMedium", size: (0.2/1.29375)*Constant.ScaleFactor)
                
                let whiteSide = SCNMaterial()
                whiteSide.diffuse.contents = UIColor.whiteColor()
                let yellowSide = SCNMaterial()
                yellowSide.diffuse.contents = UIColor.yellowColor()
                let blackSide = SCNMaterial()
                blackSide.diffuse.contents = UIColor.blackColor()
                
                winMsg.materials = [whiteSide,blackSide,blackSide,blackSide,blackSide]
                winMsg.flatness = 0.000000000001
                winMsg.alignmentMode = kCAAlignmentCenter
                
                let winMsgNode = SCNNode(geometry: winMsg)
                winMsgNode.position = SCNVector3Make(node.presentationNode.position.x-0.15 , node.presentationNode.position.y+0.25 , node.presentationNode.position.z+0.1 )
                winMsgNode.eulerAngles = SCNVector3Make(Float(-M_PI/2), 0,0)
                
                winMsgNode.physicsBody = SCNPhysicsBody.dynamicBody()
                winMsgNode.physicsBody?.affectedByGravity = false
                winMsgNode.physicsBody?.applyForce(SCNVector3(0,0.03,0), impulse: true)
                
                gameScene.rootNode.addChildNode(winMsgNode)
            }
            
            
            if didPayout && !winningColors.contains(winningColor) {
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
            
            gameScene.animateRollResult(node, didWin: didPayout)
            delay(1.0) {}
        }
        
        if !didWin && rerollEnabled {
            // Save data before resetting for the reroll
            GameData.save()
            
            rerollEnabled = false
            rerolling = true

            delay(2.0) {
                self.touchCount = 0.0
                self.gameScene = GameScene(dice: .Default)
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
            self.dismissViewControllerAnimated(true, completion: self.boardScene.showUnlockedNodes)
        }
    }
        
    func buttonAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
}

