//
//  Square.swift
//  Beto
//
//  Created by Jem on 2/4/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class Square: ButtonNode {
    var color: Color
    var wager: Int
    var selected: Bool
    var label: SKLabelNode
    var defaultButtonImage: String
    
    var placeBetHandler: ((Square) -> ())?
    
    init(color: Color) {
        self.color = color
        self.wager = 0
        self.selected = false
        self.defaultButtonImage = color.rawValue + "Square"
        
        label = SKLabelNode(fontNamed: Constant.FontNameCondensed)
        label.fontSize = 28
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.isHidden = true
        
        let activeButtonImage = defaultButtonImage + "_active"
        
        super.init(defaultButtonImage: defaultButtonImage, activeButtonImage: activeButtonImage)

        self.updateLabel()
        addChild(label)
        
        self.action = squarePressed
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func squarePressed() {
        placeBetHandler!(self)
    }
    
    func updateLabel() {
        label.text = wager.formatStringFromNumberShortenMillion()
    }
}
