//
//  DiceMaker.swift
//  Beto
//
//  Created by Joseph Pelina on 3/9/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SceneKit

enum DiceType {
    case `default`
    case doublePayout
    case triplePayout
    case doubleDice
}

class DiceMaker {
    typealias Dice = SCNNode

    fileprivate var count = 3
    fileprivate var size: CGFloat = 0.33
    
    let diceMaterials: [SCNMaterial]!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type: DiceType) {
        var yellowImage = "defaultYellowFace"
        var cyanImage = "defaultCyanFace"
        var purpleImage = "defaultPurpleFace"
        var blueImage = "defaultBlueFace"
        var redImage = "defaultRedFace"
        var greenImage = "defaultGreenFace"
        
        switch type {
        case .default:
            break
        case .doubleDice:
            count = 6
            size = 0.28
        case .doublePayout:
            yellowImage = "doublePayYellowFace"
            cyanImage = "doublePayCyanFace"
            purpleImage = "doublePayPurpleFace"
            blueImage = "doublePayBlueFace"
            redImage = "doublePayRedFace"
            greenImage = "doublePayGreenFace"
        case .triplePayout:
            yellowImage = "triplePayYellowFace"
            cyanImage = "triplePayCyanFace"
            purpleImage = "triplePayPurpleFace"
            blueImage = "triplePayBlueFace"
            redImage = "triplePayRedFace"
            greenImage = "triplePayGreenFace"
        }
        
        let yellowSide = SCNMaterial()
        yellowSide.diffuse.contents = UIImage(named: yellowImage)
        
        let cyanSide = SCNMaterial()
        cyanSide.diffuse.contents = UIImage(named: cyanImage)
        
        let purpleSide = SCNMaterial()
        purpleSide.diffuse.contents = UIImage(named: purpleImage)
        
        let blueSide = SCNMaterial()
        blueSide.diffuse.contents = UIImage(named: blueImage)
        
        let redSide = SCNMaterial()
        redSide.diffuse.contents = UIImage(named: redImage)
        
        let greenSide = SCNMaterial()
        greenSide.diffuse.contents = UIImage(named: greenImage)

        diceMaterials = [yellowSide, cyanSide, purpleSide, blueSide, redSide, greenSide]
    
    }
    
    func addDiceSetTo(_ diceNode: SCNNode) {
        for num in 1...count {
            // Initialize position
            let xoffset = CGFloat(num % 3)
            let xposition: CGFloat = -0.2 + (0.2 * xoffset)
            
            var yposition: CGFloat = 0.15
            
            if num > 3 {
                yposition = 1.15
            }

            let position = SCNVector3(xposition, yposition, 1.15)

            let dice = Dice()
            dice.position = position
            dice.geometry = SCNBox(width: size, height: size, length: size, chamferRadius: size/6)
            dice.eulerAngles = SCNVector3Make(Float(M_PI/2 * Double(arc4random()%4)), Float(M_PI/2 * Double(arc4random()%4)),Float(M_PI/2 * Double(arc4random()%4)))
            dice.geometry!.materials = diceMaterials
            
            dice.physicsBody = SCNPhysicsBody.dynamic()
            dice.physicsBody?.mass = CGFloat(10)
            dice.physicsBody?.angularDamping = CGFloat(0.5)   //default 0.1
            dice.physicsBody?.rollingFriction = CGFloat(1.0)  //default 0.0
            
            diceNode.addChildNode(dice)
        }
    }
}
