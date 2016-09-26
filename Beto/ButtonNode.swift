//
//  ButtonNode.swift
//  Beto
//
//  Created by Jem on 2/17/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class ButtonNode: SKNode {
    let defaultButton: SKSpriteNode
    let activeButton: SKSpriteNode
    var action: () -> Void
    
    var size: CGSize {
        get {
            return defaultButton.size
        }
        set {
            defaultButton.size = CGSize(width: size.width, height: size.height)
            activeButton.size = CGSize(width: size.width, height: size.height)
        }
    }
    
    init(defaultButtonImage: String, activeButtonImage: String) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        activeButton.isHidden = true
        action = {}
        
        super.init()
        
        isUserInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    convenience init(defaultButtonImage: String) {
        self.init(defaultButtonImage: defaultButtonImage, activeButtonImage: defaultButtonImage)
        activeButton.color = UIColor.black
        activeButton.colorBlendFactor = 0.3
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeButton.isHidden = false
        defaultButton.isHidden = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self)
        
        if defaultButton.contains(location) {
            activeButton.isHidden = false
            defaultButton.isHidden = true
        } else {
            activeButton.isHidden = true
            defaultButton.isHidden = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self)
        
        if defaultButton.contains(location) {
            action()
        }
        
        activeButton.isHidden = true
        defaultButton.isHidden = false
    }
    
    func changeTexture(_ texture: String) {
        defaultButton.texture = SKTexture(imageNamed: texture)
        activeButton.texture = SKTexture(imageNamed: texture)
    }

    func changeTexture(_ defaultTexture: String, activeTexture: String) {
        defaultButton.texture = SKTexture(imageNamed: defaultTexture)
        activeButton.texture = SKTexture(imageNamed: activeTexture)
    }
    
    func addWobbleAnimation() {
        let rotR = SKAction.rotate(byAngle: 0.15, duration: 0.2)
        let rotL = SKAction.rotate(byAngle: -0.15, duration: 0.2)
        let pause = SKAction.rotate(byAngle: 0, duration: 1.0)
        let cycle = SKAction.sequence([pause, rotR, rotL, rotL, rotR])
        let wobble = SKAction.repeatForever(cycle)
        
        self.run(wobble, withKey: "wobble")
    }
}
