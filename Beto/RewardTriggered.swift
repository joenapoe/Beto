//
//  RewardTriggered.swift
//  Beto
//
//  Created by Jem on 8/28/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class RewardTriggered: DropdownNode {
    
    init(rewardsDice: RewardsDice) {
        let container = SKSpriteNode(imageNamed: "rewardUnlocked")
        container.size = CGSize(width: 304, height: 225)
        container.position = CGPoint(x: 0, y: ScreenSize.Height)

        let rewardsLabel = SKLabelNode(text: "\(rewardsDice.key.rawValue.uppercased()) REWARDS DICE")
        rewardsLabel.fontName = Constant.FontNameExtraBold
        rewardsLabel.fontSize = 14
        rewardsLabel.position = CGPoint(x: 0, y: 40)
        
        let rewardsLabelShadow = rewardsLabel.createLabelShadow()
        
        let detailsLabel = SKLabelNode(text: "Click dice to open or claim to save for later")
        detailsLabel.fontName = Constant.FontName
        detailsLabel.fontColor = UIColor.darkGray
        detailsLabel.fontSize = 10
        detailsLabel.position = CGPoint(x: 0, y: 25)
        
        let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
        claimButton.size = CGSize(width: 110, height: 40)
        claimButton.position = CGPoint(x: 0, y: -80)
        
        container.addChild(rewardsLabelShadow)
        container.addChild(rewardsLabel)
        container.addChild(detailsLabel)
        container.addChild(rewardsDice)
        container.addChild(claimButton)
        
        super.init(container: container)
        
        claimButton.action = close

    }
}
