//
//  RewardsDice.swift
//  Beto
//
//  Created by Jem on 8/20/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

enum RewardsDiceKey: String {
    case Bronze
    case Silver
    case Gold
    case Platinum
    case Diamond
    case Ruby
    
    static let allValues = [Bronze, Silver, Gold, Platinum, Diamond, Ruby]
}

class RewardsDice: ButtonNode {
    let key: RewardsDiceKey
    
    fileprivate var count: Int

    fileprivate let label: SKLabelNode
    fileprivate let labelShadow: SKLabelNode
    
    var openRewardsDiceHandler: ((RewardsDice) -> ())?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(key: RewardsDiceKey, count: Int) {
        self.key = key
        self.count = count
        
        label = SKLabelNode(text: "\(count)")
        label.fontName = Constant.FontNameExtraBold
        label.fontSize = 18
        label.position = CGPoint(x: 10, y: -20)
        
        labelShadow = label.createLabelShadow()
    
        let imageName = key.rawValue.lowercased() + "Reward"
        
        super.init(defaultButtonImage: imageName, activeButtonImage: imageName)
        
        activeButton.color = UIColor.black
        activeButton.colorBlendFactor = 0.3

        // NOTE: -99 is for when you find a rewards dice during gameplay
        if count != -99 {
            addChild(labelShadow)
            addChild(label)
        }

        self.action = buttonPressed
    }
    
    func buttonPressed() {        
        if count <= 0 && count != -99 {
            return
        } else {
            GameData.subtractRewardsDiceCount(key.rawValue, num: 1)
            count = GameData.getRewardsDiceCount(key.rawValue)
            
            if count != 99 {
                label.text = "\(count)"
                labelShadow.text = "\(count)"
            }
            
            openRewardsDiceHandler!(self)
        }
        
    }
}
