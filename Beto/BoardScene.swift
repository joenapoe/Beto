//
//  BoardScene.swift
//  Beto
//
//  Created by Jem on 4/9/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class BoardScene: SKScene {
    private let layer: SKNode
    
    // GameHUD
    private let gameHUD: SKSpriteNode
    private let menuButton: ButtonNode
    private let highscoreButton: ButtonNode
    private let highscoreLabel: SKLabelNode
    private let betoCoinsButton: ButtonNode
    private let coinsLabel: SKLabelNode
    
    // Board
    private let board: SKSpriteNode
    private let playButton: ButtonNode
    private let clearReplayButton: ButtonNode
    private let powerUpButton: ButtonNode
    private let deactivatePowerUpSprite: SKSpriteNode
    private let coinVaultButton: ButtonNode
    private let diceVaultButton: ButtonNode

    // Squares
    private let squareSize: CGFloat = 92.0
    private(set) var squaresSelectedCount = 0
    private var squares: [Square]
    private var winningSquares: [Square]
    private var previousBets: [(color: Color, wager: Int)]
    
    private var dropdownQueue: [DropdownNode]
    private var rewardTriggered = false
    private var rewardBoostActivated = false
    private var diceType: DiceType = .Default
    
    private(set) var activePowerUp = ""
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        /***** Initialize Variables *****/
        squares = []
        winningSquares = []
        previousBets = []
        dropdownQueue = []
        
        layer = SKNode()
        layer.setScale(Constant.ScaleFactor)
        
        // NOTE: setScale also affects ScreenSize.Height. Need to adjust accordingly
        
        /***** Initialize GameHUD *****/
        gameHUD = SKSpriteNode(imageNamed: "headerBackground")
        gameHUD.size = CGSize(width: 320, height: 38)
        gameHUD.position = CGPoint(x: 0, y: (ScreenSize.Height / Constant.ScaleFactor - gameHUD.size.height) / 2)

        menuButton = ButtonNode(defaultButtonImage: "menuButton", activeButtonImage: "menuButton_active")
        menuButton.size = CGSize(width: 60, height: 25)
        menuButton.position = CGPoint(x: (-gameHUD.size.width + menuButton.size.width + Constant.Margin) / 2 , y: 0)
        
        betoCoinsButton = ButtonNode(defaultButtonImage: "betoCoinsButton")
        betoCoinsButton.size = CGSize(width: 100, height: 25)
        betoCoinsButton.position = CGPoint(x: (gameHUD.size.width - betoCoinsButton.size.width) / 2 - Constant.Margin, y: 0)
        
        coinsLabel = SKLabelNode()
        coinsLabel.fontName = Constant.FontNameCondensed
        coinsLabel.fontSize = 14
        coinsLabel.horizontalAlignmentMode = .Center
        coinsLabel.verticalAlignmentMode = .Center
        
        highscoreButton = ButtonNode(defaultButtonImage: "highscoreButton")
        highscoreButton.size = CGSize(width: 100, height: 25)
        highscoreButton.position = CGPoint(x: betoCoinsButton.position.x - (highscoreButton.size.width + Constant.Margin), y: 0)
        
        highscoreLabel = SKLabelNode()
        highscoreLabel.fontName = Constant.FontNameCondensed
        highscoreLabel.fontSize = 14
        highscoreLabel.horizontalAlignmentMode = .Center
        highscoreLabel.verticalAlignmentMode = .Center
        
        /***** Initialize Board *****/
        board = SKSpriteNode(imageNamed: GameData.theme.board)
        board.size = CGSize(width: 300, height: 280)
        board.position = CGPoint(x: 0, y: (-ScreenSize.Height / Constant.ScaleFactor + board.size.height) / 2 + 52) // AdMob Height: 50
        
        playButton = ButtonNode(defaultButtonImage: "playButton", activeButtonImage: "playButton_active")
        playButton.size = CGSize(width: 130, height: 40)
        playButton.position = CGPoint(x: (-board.size.width + playButton.size.width) / 2 + Constant.Margin,
                                      y: (-board.size.height + playButton.size.height) / 2 + Constant.Margin)
        
        clearReplayButton = ButtonNode(defaultButtonImage: "clearButton", activeButtonImage: "clearButton_active")
        clearReplayButton.name = "clearButton"
        clearReplayButton.size = CGSize(width: 130, height: 40)
        clearReplayButton.position = CGPoint(x: (board.size.width - clearReplayButton.size.width) / 2 - Constant.Margin,
                                             y: (-board.size.height + clearReplayButton.size.height) / 2 + Constant.Margin)
        
        // Initialize the squares
        for color in Color.allValues {
            let square = Square(color: color)
            square.size = CGSize(width: squareSize, height: squareSize)
            
            squares.append(square)
        }
        
        /***** Initialize Misc. Buttons *****/
        powerUpButton = ButtonNode(defaultButtonImage: "powerUpButton")
        powerUpButton.size = CGSize(width: 38, height: 39)
        powerUpButton.position = CGPoint(x: (-board.size.width + powerUpButton.size.width) / 2,
                                         y: board.position.y + (board.size.height + powerUpButton.size.height + Constant.Margin) / 2)
        
        coinVaultButton = ButtonNode(defaultButtonImage: "coin\(GameData.betDenomination)")
        coinVaultButton.size = CGSize(width: 38, height: 39)
        coinVaultButton.position = CGPoint(x: (board.size.width - coinVaultButton.size.width) / 2,
                                           y: board.position.y + (board.size.height + powerUpButton.size.height + Constant.Margin) / 2)
        
        diceVaultButton = ButtonNode(defaultButtonImage: "rewardsDiceButton")
        diceVaultButton.size = CGSize(width: 31, height: 36)
        diceVaultButton.position = CGPoint(x: (board.size.width - diceVaultButton.size.width) / 2,
                                           y: gameHUD.position.y - (gameHUD.size.height + diceVaultButton.size.height + Constant.Margin) / 2)
        
        deactivatePowerUpSprite = SKSpriteNode(imageNamed: "deactivateButton")
        deactivatePowerUpSprite.size = CGSize(width: 18, height: 19)
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        GameData.unlockedCoinHandler = showUnlockedCoin
        GameData.unlockedLevelHandler = addToDropdownQueue
        
        // Set button actions
        menuButton.action = presentMenuScene
        betoCoinsButton.action = displayShop
        highscoreButton.action = displayAchievements
        
        playButton.action = playButtonPressed
        clearReplayButton.action = clearButtonPressed
        powerUpButton.action = powerUpButtonPressed
        coinVaultButton.action = coinVaultButtonPressed
        diceVaultButton.action = diceVaultButtonPressed
        
        // Set text for labels
        updateCoinsLabel(GameData.coins)
        updateHighscoreLabel(GameData.highscore)

        // Add labels to corresponding nodes
        betoCoinsButton.addChild(coinsLabel)
        highscoreButton.addChild(highscoreLabel)
        
        // Add nodes to gameHUD
        gameHUD.addChild(menuButton)
        gameHUD.addChild(highscoreButton)
        gameHUD.addChild(betoCoinsButton)
        
        // Add nodes to board
        board.addChild(playButton)
        board.addChild(clearReplayButton)
        
        // Add action to square and add each square to board
        for square in squares {
            square.position = pointForPosition(squares.indexOf(square)!)
            square.placeBetHandler = handlePlaceBet
            
            board.addChild(square)
        }
        
        layer.addChild(gameHUD)
        layer.addChild(board)
        layer.addChild(powerUpButton)
        layer.addChild(coinVaultButton)
        layer.addChild(diceVaultButton)
        
        // Initialize background
        let background = SKSpriteNode(imageNamed: GameData.theme.background)
        background.size = self.frame.size
        
        if !Audio.musicMuted {
            runAction(SKAction.waitForDuration(0.5), completion: {
                self.addChild(Audio.backgroundMusic)
            })
        }
        
        // Add background and main layer to the scene
        addChild(background)
        addChild(layer)
    }
    
    /***** GameHUD Functions *****/
    func updateCoinsLabel(coins: Int) {
        coinsLabel.text = formatStringFromNumber(coins)
    }
    
    func updateHighscoreLabel(highscore: Int) {
        highscoreLabel.text = formatStringFromNumber(highscore)
    }
    
    private func formatStringFromNumber(number: Int) -> String {
        if number >= 1000000 {
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            
            let newNumber: Double = floor(Double(number) / 10000) / 100.0
            let formattedNumber = formatter.stringFromNumber(newNumber)!
            
            return "\(formattedNumber)M"
        } else {
            return "\(number)"
        }
    }
    
    private func displayAchievements() {
        let achievements = AchievementsListNode()
        let layer = achievements.createLayer()
        
        addChild(layer)
    }
    
    // DELETE: Might have to drop this feature
    private func displayShop() {        
        let closeButton = ButtonNode(defaultButtonImage: "closeButton")
        closeButton.size = CGSize(width: 44, height: 45)
        closeButton.position = CGPoint(x: 140, y: 190)
        
        let container = SKSpriteNode(imageNamed: "shopBackground")
        container.size = CGSize(width: 304, height: 412)
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        // Custom scale for iPhone 4 (Screen size: 320 x 480)
        if UIScreen.mainScreen().bounds.height == 480 {
            container.setScale(0.93)
        }
        
        let coinsBackground = SKSpriteNode(imageNamed: "coinsBackground")
        coinsBackground.size = CGSize(width: 276, height: 55)
        coinsBackground.position = CGPoint(x: 0, y: 124)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        let coins = numberFormatter.stringFromNumber(GameData.coins)
        
        let coinsLabel = SKLabelNode(text: coins)
        coinsLabel.fontName = Constant.FontNameCondensed
        coinsLabel.fontSize = 28
        coinsLabel.horizontalAlignmentMode = .Center
        coinsLabel.verticalAlignmentMode = .Center
        
        coinsBackground.addChild(coinsLabel)
        
        // DELETE: Add buy rewardsDice action, need to update labels after buying
        
        let buyBasic = ButtonNode(defaultButtonImage: "buyPlaceholder")
        buyBasic.size = CGSize(width: 137, height: 124)
        buyBasic.position = CGPoint(x: -69, y: 33)
        
        let buyDeluxe = ButtonNode(defaultButtonImage: "buyPlaceholder")
        buyDeluxe.size = CGSize(width: 137, height: 124)
        buyDeluxe.position = CGPoint(x: 69, y: 33)
        
        let buyPremium = ButtonNode(defaultButtonImage: "buyPlaceholder")
        buyPremium.size = CGSize(width: 137, height: 124)
        buyPremium.position = CGPoint(x: -69, y: -92)
        
        let buyPremiumPlus = ButtonNode(defaultButtonImage: "buyPlaceholder")
        buyPremiumPlus.size = CGSize(width: 137, height: 124)
        buyPremiumPlus.position = CGPoint(x: 69, y: -92)
        
        // Add nodes
        container.addChild(closeButton)
        container.addChild(coinsBackground)
        container.addChild(buyBasic)
        container.addChild(buyDeluxe)
        container.addChild(buyPremium)
        container.addChild(buyPremiumPlus)
        
        let shopNode = DropdownNode(container: container)
        closeButton.action = shopNode.close
        
        addChild(shopNode.createLayer())
    }
    
    /***** Board Functions *****/
    private func pointForPosition(position: Int) -> CGPoint {
        var column = 0
        var row = 0
        
        // Position squares based on a 2x3 grid
        if position <= 2 {
            column = position
        } else  {
            row = 1
            column = position - 3
        }
        
        let squareMargin: CGFloat = 6
        let squareWithMargin = squareSize + squareMargin
        
        let offsetX = -squareWithMargin + (squareWithMargin * CGFloat(column))
        let offsetY = -squareMargin + (squareWithMargin * CGFloat(row))
        
        return CGPoint(x: offsetX, y: -Constant.Margin + offsetY)
    }
    
    private func handlePlaceBet(square: Square) {
        let coinsAvailable = GameData.coins - getWagers()
        
        if coinsAvailable == 0 {
            runAction(Audio.lostSound)
            return
        }
        
        // Limit selected squares to 3 colors
        if !square.selected && squaresSelectedCount == 3 {
            let colorLimitNode = SKLabelNode(text: "SELECT UP TO 3 COLORS")
            colorLimitNode.fontName = Constant.FontName
            colorLimitNode.fontSize = 16
            colorLimitNode.position = CGPoint(x: 0, y: board.position.y + 50)
    
            layer.addChild(colorLimitNode)
            
            let fade = SKAction.fadeOutWithDuration(1.0)
            let actions = SKAction.sequence([fade, SKAction.removeFromParent()])
            
            colorLimitNode.runAction(actions)
            
            runAction(Audio.lostSound)
            
            return
        }
        
        // Wager all remaining coins if less than betDenomination
        if GameData.betDenomination <= coinsAvailable  {
            square.wager += GameData.betDenomination
        } else {
            square.wager += coinsAvailable
        }
        
        // In order to safe guard from crashes, we don't subtract the coins
        // from the GameData until after we roll the dice
        let coins = GameData.coins - getWagers()
        updateCoinsLabel(coins)
        runAction(Audio.placeBetSound)
        
        square.updateLabel()
        
        if !square.selected {
            square.label.hidden = false
            square.selected = true
            
            squaresSelectedCount += 1
        }
        
        // Hard toggle to clearButton
        if clearReplayButton.name == "replayButton" {
            clearReplayButton.name = "clearButton"
            clearReplayButton.changeTexture("clearButton", activeTexture: "clearButton_active")
            clearReplayButton.action = clearButtonPressed
        }
    }
    
    private func playButtonPressed() {
        if getWagers() > 0 {
            // Reset previousBets
            previousBets = []
            
            // Save bets for the replay button
            for square in squares {
                if square.selected {
                    previousBets.append((color: square.color, wager: square.wager))
                }
            }
            
            presentGameScene()
        }
    }
    
    private func replayButtonPressed() {
        clearButtonPressed()
        
        for previousBet in previousBets {
            if let index = squares.indexOf(squareWithColor(previousBet.color)) {
                squares[index].wager = previousBet.wager
                squares[index].label.hidden = false
                squares[index].updateLabel()
                squares[index].selected = true
                
                squaresSelectedCount += 1
            }
        }
        
        // In order to safe guard from crashes, we don't subtract the coins
        // from the GameData until after we roll the dice
        let coins = GameData.coins - getWagers()
        updateCoinsLabel(coins)
        
        clearReplayButton.name = "clearButton"
        clearReplayButton.changeTexture("clearButton", activeTexture: "clearButton_active")
        clearReplayButton.action = clearButtonPressed
    }
    
    private func clearButtonPressed() {
        // reset each square
        for square in squares {
            square.wager = 0
            square.label.hidden = true
            square.selected = false
        }
        
        resetSquaresSelectedCount()
        
        runAction(Audio.clearBetSound)
        updateCoinsLabel(GameData.coins)
        
        toggleReplayButton()
    }
    
    func toggleReplayButton() {
        var wagers = 0
        
        for previousBet in previousBets {
            wagers += previousBet.wager
        }
        
        let coinsAvailable = GameData.coins - wagers
        
        if !previousBets.isEmpty && coinsAvailable >= 0 {
            clearReplayButton.name = "replayButton"
            clearReplayButton.changeTexture("replayButton", activeTexture: "replayButton_active")
            clearReplayButton.action = replayButtonPressed
        }
    }
    
    /***** Misc. Button Functions *****/
    private func powerUpButtonPressed() {
        let powerUpVault = PowerUpVault(activePowerUp: activePowerUp)
        powerUpVault.activatePowerUpHandler = activatePowerUp
        
        addChild(powerUpVault.createLayer())
    }
    
    private func activatePowerUp(powerUp: PowerUp) {
        deactivatePowerUpButtonPressed()
        
        let button = ButtonNode(defaultButtonImage: powerUp.name!)
        button.action = deactivatePowerUpButtonPressed
        // DELETE: Optimize size/position
        button.position = CGPoint(x: (-board.size.width + button.size.width) / 2,
                                  y: gameHUD.position.y - (gameHUD.size.height + diceVaultButton.size.height + Constant.Margin) / 2)

        deactivatePowerUpSprite.position = CGPoint(x: 12, y: -16)
        
        button.addChild(deactivatePowerUpSprite)
        layer.addChild(button)
        
        activePowerUp = powerUp.name!
    }
    
    func deactivatePowerUpButtonPressed() {
        deactivatePowerUpSprite.parent?.removeFromParent()
        deactivatePowerUpSprite.removeFromParent()
        
        activePowerUp = ""
    }
    
    private func coinVaultButtonPressed() {
        let coinVault = CoinVault()
        coinVault.changeDenominationHandler = {
            self.coinVaultButton.changeTexture("coin\(GameData.betDenomination)")
        }
        
        addChild(coinVault.createLayer())
    }
    
    private func diceVaultButtonPressed() {
        let rewardsDiceVault = RewardsDiceVault()
        rewardsDiceVault.openRewardsDiceHandler = openRewardsDice
        
        addChild(rewardsDiceVault.createLayer())
    }
    
    private func openRewardsDice(dice: RewardsDice) {
        let openRewards = OpenRewardsNode(diceKey: dice.key)
        addChild(openRewards.createLayer())        
    }
    
    /***** Gameplay Functions *****/    
    func resolvePayout(square: Square) {
        if !winningSquares.contains(square) {
            winningSquares.append(square)
        }
        
        // Add winnings
        if square.wager > 0 {
            let winnings = calculateWinnings(square)
            
            GameData.addCoins(winnings)
        
            runAction(Audio.winSound)
            
            // Update labels
            updateCoinsLabel(GameData.coins)
            updateHighscoreLabel(GameData.highscore)
        }
    }
    
    func calculateWinnings(square: Square) -> Int {
        var winnings = square.wager
        
        if activePowerUp == "" {
            // Skip if no payout powerup is active
        } else if activePowerUp == PowerUpKey.doublePayout.rawValue {
            winnings *= 2
        } else if activePowerUp == PowerUpKey.triplePayout.rawValue {
            winnings *= 3
        }
        
        return winnings
    }
    
    func didPayout(square: Square) -> Bool {
        if square.wager > 0 {
            return true
        } else {
            return false
        }
    }
    
    func resolveWagers(didWin: Bool) {
        var highestWager = 0
        
        // Add winning wagers back to GameData.coins, clear the board
        for square in squares {
            // PowerUp: Lifeline - Return half the wagers on a complete lost
            if !didWin && activePowerUp == PowerUpKey.lifeline.rawValue {
                GameData.addCoins(square.wager/2)
            }
            
            if winningSquares.contains(square) {
                GameData.addCoins(square.wager)
            }
            
            if square.wager > highestWager {
                highestWager = square.wager
            }
            
            let scaleAction = SKAction.scaleTo(0.0, duration: 0.3)
            scaleAction.timingMode = .EaseOut
            square.label.runAction(scaleAction)
            square.label.hidden = true
            
            let restore = SKAction.scaleTo(1.0, duration: 0.3)
            square.label.runAction(restore)
            square.wager = 0
            square.selected = false
            
            // Update labels
            updateCoinsLabel(GameData.coins)
            updateHighscoreLabel(GameData.highscore)
        }
        
        // Check Achievement: HighestWager
        GameData.updateHighestWager(highestWager)
        
        // Reset winning squares
        winningSquares = []
    }
    
    func getWagers() -> Int {
        var wagers = 0
        
        for square in squares {
            wagers += square.wager
        }
        
        return wagers
    }
    
    func squareWithColor(color: Color) -> Square! {
        for square in squares {
            if square.color == color {
                return square
            }
        }
        
        // Return nil if square is not found. This code should never execute
        return nil
    }
    
    func resetSquaresSelectedCount() {
       squaresSelectedCount = 0
    }
    
    /***** Dropdown Functions *****/
    private func addToDropdownQueue(achievement: Achievement) {
        let unlocked = UnlockedLevel(achievement: achievement)
        dropdownQueue.append(unlocked)
    }
    
    private func showUnlockedCoin() {
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
    
    func resolveRandomReward() {
        let rand = Int(arc4random_uniform(100)) + 1
    
        var rewardChance = GameData.rewardChance
        
        if activePowerUp == PowerUpKey.rewardBoost.rawValue {
            rewardChance += rewardChance
            rewardBoostActivated = true
        } else {
            rewardBoostActivated = false
        }
        
        if rand <= rewardChance {
            rewardTriggered = true
        } else {
            rewardTriggered = false
            
            // Increment Unlucky achievement
            GameData.incrementAchievement(.Unlucky)
        }
    }
    
    func showUnlockedNodes() {
        if rewardTriggered {
            let rewardsDice: RewardsDice
            
            let rand = Int(arc4random_uniform(100)) + 1
            
            if rewardBoostActivated {
                // Chance: Bronze (50%), Silver (25%), Gold (15%), Platinum (5%), Diamond (4%), Ruby (1%)
                if rand <= 50 {
                    rewardsDice = RewardsDice(key: .Bronze, count: -99)
                } else if rand <= 75 {
                    rewardsDice = RewardsDice(key: .Silver, count: -99)
                } else if rand <= 90 {
                    rewardsDice = RewardsDice(key: .Gold, count: -99)
                } else if rand <= 95{
                    rewardsDice = RewardsDice(key: .Platinum, count: -99)
                } else if rand <= 99 {
                    rewardsDice = RewardsDice(key: .Diamond, count: -99)
                } else {
                    rewardsDice = RewardsDice(key: .Ruby, count: -99)
                }
            } else {
                // Chance: Bronze (70%), Silver (15%), Gold (9%), Platinum (3%), Diamond (2%), Ruby (1%)
                if rand <= 70 {
                    rewardsDice = RewardsDice(key: .Bronze, count: -99)
                } else if rand <= 85 {
                    rewardsDice = RewardsDice(key: .Silver, count: -99)
                } else if rand <= 94 {
                    rewardsDice = RewardsDice(key: .Gold, count: -99)
                } else if rand <= 97{
                    rewardsDice = RewardsDice(key: .Platinum, count: -99)
                } else if rand <= 99 {
                    rewardsDice = RewardsDice(key: .Diamond, count: -99)
                } else {
                    rewardsDice = RewardsDice(key: .Ruby, count: -99)
                }
            }

            GameData.addRewardsDiceCount(rewardsDice.key.rawValue, num: 1)
            GameData.save()
            
            let rewardTriggeredNode = RewardTriggered(rewardsDice: rewardsDice)
            
            rewardsDice.openRewardsDiceHandler = openRewardsDice
            rewardsDice.addWobbleAnimation()
            rewardsDice.action = {
                rewardsDice.buttonPressed()
                rewardTriggeredNode.close()
            }
            
            addChild(rewardTriggeredNode.createLayer())
            
            // reset rewardTriggered, rewardBoostActivated, and rewardChance
            rewardTriggered = false
            rewardBoostActivated = false
            GameData.resetRewardChance()

        }
        
        // DELETE: Temp Gameplay Rewards - Revised code later
        
        if GameData.gamesPlayed % 10000 == 0 {
            let rewardsDice = RewardsDice(key: .Diamond, count: -99)
            
            GameData.addRewardsDiceCount(rewardsDice.key.rawValue, num: 1)
            GameData.save()
            
            let rewardTriggeredNode = RewardTriggered(rewardsDice: rewardsDice)
            
            rewardsDice.openRewardsDiceHandler = openRewardsDice
            rewardsDice.addWobbleAnimation()
            rewardsDice.action = {
                rewardsDice.buttonPressed()
                rewardTriggeredNode.close()
            }
            
            addChild(rewardTriggeredNode.createLayer())
        }
        
        // DELETE: Temp Gameplay Rewards - Revised code later
        if GameData.gamesPlayed % 1000 == 0 {
            let rewardsDice = RewardsDice(key: .Platinum, count: -99)
            
            GameData.addRewardsDiceCount(rewardsDice.key.rawValue, num: 1)
            GameData.save()
            
            let rewardTriggeredNode = RewardTriggered(rewardsDice: rewardsDice)
            
            rewardsDice.openRewardsDiceHandler = openRewardsDice
            rewardsDice.addWobbleAnimation()
            rewardsDice.action = {
                rewardsDice.buttonPressed()
                rewardTriggeredNode.close()
            }
            
            addChild(rewardTriggeredNode.createLayer())
        }
        
        // DELETE: Temp Gameplay Rewards - Revised code later
        if GameData.gamesPlayed % 100 == 0 {
            let rewardsDice = RewardsDice(key: .Gold, count: -99)
            
            GameData.addRewardsDiceCount(rewardsDice.key.rawValue, num: 1)
            GameData.save()
            
            let rewardTriggeredNode = RewardTriggered(rewardsDice: rewardsDice)
            
            rewardsDice.openRewardsDiceHandler = openRewardsDice
            rewardsDice.addWobbleAnimation()
            rewardsDice.action = {
                rewardsDice.buttonPressed()
                rewardTriggeredNode.close()
            }
            
            addChild(rewardTriggeredNode.createLayer())
        }
    
        if GameData.coins == 0 {
            let container = SKSpriteNode(imageNamed: "goldenTicketBackground")
            container.size = CGSize(width: 304, height: 267)
            container.position = CGPoint(x: 0, y: ScreenSize.Height)
            
            
            let rand = Int(arc4random_uniform(5))
            let flavorText = ["WHO DOESN'T LOVE FREE STUFF",
                              "HEY, LOOK WHAT I FOUND",
                              "AWWW, STOP CRYING. HERE TAKE THIS",
                              "OUCH! CONSOLATION PRIZE?",
                              "YOU INHERIT 100 BETO COINS!"]
            
            let titleLabel = SKLabelNode(text: flavorText[rand])
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
                self.updateCoinsLabel(GameData.coins)
                self.updateHighscoreLabel(GameData.highscore)
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