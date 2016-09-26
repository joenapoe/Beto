//
//  Extensions.swift
//  Beto
//
//  Created by Jem on 6/15/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

extension SKLabelNode {
    func createLabelShadow() -> SKLabelNode {
        let shadow = SKLabelNode(text: text)
        shadow.fontName = fontName
        shadow.fontColor = UIColor.darkGray
        shadow.fontSize = fontSize
        shadow.position = CGPoint(x: position.x + 1, y: position.y - 1)
        
        return shadow
    }
}

extension String {
    var count: Int { return self.characters.count }
}
