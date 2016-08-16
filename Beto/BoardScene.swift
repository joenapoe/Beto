//
//  BoardScene.swift
//  Beto
//
//  Created by Jem on 4/9/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class BoardScene: SKScene {
    var board: Board!
    var gameHUD: GameHUD!
    var boardLayer: SKNode!
    var gameHUDLayer: SKNode!
    var dropdownQueue: [DropdownNode]!
    var bonusPayoutNode: SKSpriteNode! // DELETE: Change to double?
    var bonusPayoutLabel: SKLabelNode!
    var bonusDiceNode: SKSpriteNode! // DELETE: Change to double?
    var bonusDiceLabel: SKLabelNode!
        
    private var shouldAddReward = false
    private var rewardType = 99
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
                
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        GameData.unlockedCoinHandler = showUnlockedCoin
        GameData.unlockedLevelHandler = addToDropdownQueue
        
        dropdownQueue = []
        
        let background = SKSpriteNode(imageNamed: GameData.theme.background)
        background.size = self.frame.size
        
        board = Board(scene: self)
        boardLayer = board.createLayer()
        
        board.toggleReplayButton()
        
        gameHUD = GameHUD(scene: self)
        gameHUDLayer = gameHUD.createLayer()
        
        bonusPayoutNode = SKSpriteNode(imageNamed: "bonusPayoutIcon")
        bonusPayoutNode.size = CGSize(width: 31, height: 36)
        bonusPayoutNode.position = CGPoint(x: 30 - ScreenSize.Width/2, y: ScreenSize.Height/2 - 60)
        
        bonusPayoutLabel = SKLabelNode()
        bonusPayoutLabel.fontName = Constant.FontNameExtraBold
        bonusPayoutLabel.fontSize = 14
        bonusPayoutLabel.horizontalAlignmentMode = .Center
        bonusPayoutLabel.position = CGPoint(x: 32 - ScreenSize.Width/2, y: ScreenSize.Height/2 - 95)
        
        bonusDiceNode = SKSpriteNode(imageNamed: "bonusDice")
        bonusDiceNode.size = CGSize(width: 48, height: 38)
        bonusDiceNode.position = CGPoint(x: ScreenSize.Width/2 - 30, y: ScreenSize.Height/2 - 60)
        
        // DELETE: Dumbed down bonus dice for now
        let label = SKLabelNode(text: "+3")
        label.fontName = Constant.FontNameExtraBold
        label.fontSize = 24
        label.position = CGPoint(x: 10, y: -20)
        
        let labelShadow = label.createLabelShadow()
        
        bonusDiceLabel = SKLabelNode()
        bonusDiceLabel.fontName = Constant.FontNameExtraBold
        bonusDiceLabel.fontSize = 18
        bonusDiceLabel.horizontalAlignmentMode = .Center
        bonusDiceLabel.position = CGPoint(x: ScreenSize.Width/2 - 32, y: ScreenSize.Height/2 - 95)
    
        if !Audio.musicMuted {
            runAction(SKAction.waitForDuration(0.5), completion: {
                self.addChild(Audio.backgroundMusic)
            })
        }
        
        bonusDiceNode.addChild(labelShadow)
        bonusDiceNode.addChild(label)
        
        addChild(background)
        addChild(gameHUDLayer)
        addChild(boardLayer)
        
        addChild(bonusPayoutNode)
        addChild(bonusPayoutLabel)
        addChild(bonusDiceNode)
        addChild(bonusDiceLabel)
                
        updateRewards()
    }
    
    func updateRewards() {
        bonusPayoutLabel.text = "\(GameData.doublePayout)"
        bonusDiceLabel.text = "\(GameData.doubleDice)"
        
        if GameData.doublePayout == 0 {
            bonusPayoutNode.hidden = true
            bonusPayoutLabel.hidden = true
        } else {
            bonusPayoutNode.hidden = false
            bonusPayoutLabel.hidden = false
        }
        
        if GameData.doubleDice == 0 {
            bonusDiceNode.hidden = true
            bonusDiceLabel.hidden = true
        } else {
            bonusDiceNode.hidden = false
            bonusDiceLabel.hidden = false
        }
    }
    
    func resolveRandomReward() {
        // Increment Win Percentage by 0.33/0.67/1 based on number of colors selected
        
        let rand = Int(arc4random_uniform(30)) + 1
        
        if rand <= GameData.rewardChance {
            shouldAddReward = true
            rewardType = rand % 3
        } else {
            shouldAddReward = false
        }
    }
    
    func addToDropdownQueue(achievement: Achievement) {
        let unlocked = UnlockedLevel(achievement: achievement)
        dropdownQueue.append(unlocked)
    }
        
    func showUnlockedCoin() {
        let container = SKSpriteNode(imageNamed: "rewardUnlocked")
        container.size = CGSize(width: 304, height: 225)
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        let details = SKNode()
        
        let titleLabel = SKLabelNode(text: "COIN UNLOCKED")
        titleLabel.fontName = Constant.FontNameExtraBold
        titleLabel.fontColor = UIColor.whiteColor()
        titleLabel.fontSize = 14
        titleLabel.position = CGPoint(x: 0, y: 50)
        
        let titleShadow = titleLabel.createLabelShadow()
        
        let descriptionLabel = SKLabelNode(text: "Now available in the Coin Vault")
        descriptionLabel.fontName = Constant.FontName
        descriptionLabel.fontColor = UIColor.darkGrayColor()
        descriptionLabel.fontSize = 10
        descriptionLabel.position = CGPoint(x: 0, y: 35)
        
        let coin = SKSpriteNode(imageNamed: "coin\(Constant.Denominations[GameData.coinsUnlocked])")
        coin.size = CGSize(width: 38, height: 39)
        coin.position = CGPoint(x: 0, y: 10)
        
        // Add progress bar
        let progressBar = SKSpriteNode(imageNamed: "progressBar")
        progressBar.size = CGSize(width: 120, height: 6)
        progressBar.position = CGPoint(x: 0, y: -20)
        
        var progress = 1.0
        
        // Don't show label and calculate progress on last coin
        if GameData.coinsUnlocked != 7 {
            let nextCoinLabel = SKLabelNode(text: "Next Coin unlocks at \(Constant.CoinUnlockedAt[GameData.coinsUnlocked]) coins")
            nextCoinLabel.fontName = Constant.FontName
            nextCoinLabel.fontColor = UIColor.darkGrayColor()
            nextCoinLabel.fontSize = 10
            nextCoinLabel.position = CGPoint(x: 0, y: -40)
            
            details.addChild(nextCoinLabel)
            
            progress = Double(GameData.highscore) / Double(Constant.CoinUnlockedAt[GameData.coinsUnlocked])
            
            if progress > 1.0 {
                progress = 1.0
            }
        }
        
        let width = 120 * progress
        let offsetX = (width - 119.5) / 2
        
        let currentProgress = SKSpriteNode(imageNamed: "currentProgress")
        currentProgress.size = CGSize(width: width, height: 6)
        currentProgress.position = CGPoint(x: offsetX, y: 0)
        
        // Claim button
        let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
        claimButton.size = CGSize(width: 110, height: 40)
        claimButton.position = CGPoint(x: 0, y: -80)
        
        // Add nodes
        details.addChild(titleShadow)
        details.addChild(titleLabel)
        details.addChild(descriptionLabel)
        details.addChild(coin)
        
        progressBar.addChild(currentProgress)
        details.addChild(progressBar)
        
        container.addChild(details)
        container.addChild(claimButton)
        
        let coinUnlocked = DropdownNode(container: container)
        
        claimButton.action = coinUnlocked.close
        
        addChild(coinUnlocked.createLayer())
    }
    
    func showUnlockedNodes() {
        if shouldAddReward {
            /*** Random Reward ***/
            let container = SKSpriteNode(imageNamed: "rewardUnlocked")
            container.size = CGSize(width: 304, height: 225)
            container.position = CGPoint(x: 0, y: ScreenSize.Height)
            
            let rewardsLabel = SKLabelNode(text: "BONUS REWARD")
            rewardsLabel.fontName = Constant.FontNameExtraBold
            rewardsLabel.fontColor = Constant.BetoGreen
            rewardsLabel.fontSize = 14
            rewardsLabel.position = CGPoint(x: 0, y: 30)
            
            let rewardsLabelShadow = rewardsLabel.createLabelShadow()
            
            var imageName = ""
            var tempText = 5
            
            // DELETE: Temp rewards
            if rewardType == 0 {
                imageName = "starCoin"
                tempText = 1
            } else if rewardType == 1 {
                imageName = "bonusPayoutIcon"
            } else if rewardType == 2 {
                imageName = "bonusDice"
            }
            
            let sprite = SKSpriteNode(imageNamed: imageName)
            
            // DELETE: Temp text
            let label = SKLabelNode(text: "x\(tempText)")
            label.fontName = Constant.FontName
            label.fontColor = UIColor.darkGrayColor()
            label.fontSize = 14
            label.position = CGPoint(x: 40, y: -5)
            
            // Claim button
            let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
            claimButton.size = CGSize(width: 110, height: 40)
            claimButton.position = CGPoint(x: 0, y: -80)
            
            // Add nodes
            sprite.addChild(label)
            
            container.addChild(rewardsLabelShadow)
            container.addChild(rewardsLabel)
            container.addChild(sprite)
            container.addChild(claimButton)
            
            let randomReward = DropdownNode(container: container)
            
            claimButton.action = {
                if self.rewardType == 0 {
                    GameData.addStarCoins(1)
                } else if self.rewardType == 1 {
                    GameData.addPayoutReward(5)
                } else if self.rewardType == 2 {
                    GameData.addDiceReward(5)
                }
                
                GameData.save()
                
                self.updateRewards()
                
                randomReward.close()
            }
            
            addChild(randomReward.createLayer())
        }
        
        if GameData.coins == 0 {
            let container = SKSpriteNode(imageNamed: "goldenTicketBackground")
            container.size = CGSize(width: 304, height: 267)
            container.position = CGPoint(x: 0, y: ScreenSize.Height)
            
            var text = ""
            
            let rand = Int(arc4random_uniform(5))
            
            switch rand {
            case 0:
                text = "WHO DOESN'T LOVE FREE STUFF"
            case 1:
                text = "I THINK YOU DROPPED THIS"
            case 2:
                text = "AWWW, STOP CRYING. HERE TAKE THIS"
            case 3:
                text = "OUCH! CONSOLATION PRIZE?"
            case 4:
                text = "YOU INHERIT 100 BETO COINS"
            default:
                text = "WHO DOESN'T LOVE FREE STUFF"
            }
            
            let titleLabel = SKLabelNode(text: text)
            titleLabel.fontName = Constant.FontNameExtraBold
            titleLabel.fontColor = UIColor.whiteColor()
            titleLabel.fontSize = 14
            titleLabel.position = CGPoint(x: 0, y: 65)
            
            let titleShadow = titleLabel.createLabelShadow()
            
            container.addChild(titleShadow)
            container.addChild(titleLabel)
            
            let ticket = SKSpriteNode(imageNamed: "goldenTicket")
            container.addChild(ticket)
            
            // Claim button
            let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
            claimButton.size = CGSize(width: 110, height: 40)
            claimButton.position = CGPoint(x: 0, y: -100)
            
            // Add nodes
            container.addChild(claimButton)
            
            let goldenTicket = DropdownNode(container: container)

            claimButton.action = {
                goldenTicket.close()
                GameData.addCoins(100)
                GameData.save()
                
                // Update labels
                self.gameHUD.updateCoinsLabel(GameData.coins)
                self.gameHUD.updateHighscoreLabel(GameData.highscore)
            }
            
            addChild(goldenTicket.createLayer())
        }
        
        for node in dropdownQueue.reverse() {
            addChild(node.createLayer())
        }
        
        dropdownQueue = []
    }
    
    func presentGameScene() {
        self.view!.window!.rootViewController!.performSegueWithIdentifier("showGameScene", sender: self)
    }
    
    func presentMenuScene() {
        Audio.backgroundMusic.removeFromParent()
        
        let transition = SKTransition.flipVerticalWithDuration(0.4)
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .AspectFill
        
        view!.presentScene(menuScene, transition: transition)
    }
}

