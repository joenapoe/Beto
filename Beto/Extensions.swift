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

extension Int {
    func formatStringFromNumberShortenMillion() -> String {
        if self >= 1000000 {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            
            let newNumber: Double = floor(Double(self) / 10000) / 100.0
            let formattedNumber = formatter.string(from: NSNumber(value: newNumber))!
            
            return "\(formattedNumber)M"
        } else {
            return formatStringFromNumber()
        }
    }
    
    func formatStringFromNumber() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        let formattedNumber = formatter.string(from: NSNumber(value: self))!
        
        return "\(formattedNumber)"
    }
}
