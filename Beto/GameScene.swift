//
//  GameScene.swift
//  Beto
//
//  Created by Jem on 2/4/16.
//  Copyright (c) 2016 redgarage. All rights reserved.
//

import SceneKit

class GameScene: SCNScene, SCNSceneRendererDelegate {
    private let cameraNode: SCNNode
    private let floorNode: SCNNode
    private let diceNode: SCNNode
    private let boundary: SCNNode
    
    private let planeScalar: CGFloat = 2
    
    var shouldCheckMovement = false
    var resolveGameplayHandler: (() -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dice: DiceType) {
        cameraNode = SCNNode()
        floorNode = SCNNode()
        diceNode = SCNNode()
        boundary = SCNNode()

        super.init()
        
        cameraNode.camera = SCNCamera()
        cameraNode.eulerAngles = SCNVector3Make(Float(-M_PI/2), 0, 0)
        cameraNode.position = SCNVector3(0, 3.7, 0)
        
        floorNode.geometry = SCNBox(width: 2.25, height: 0.5, length: 4, chamferRadius: 0)
        floorNode.physicsBody = SCNPhysicsBody.staticBody()
        floorNode.opacity = 0.0
        floorNode.position = SCNVector3(0, 0, 0)

        let diceMaker = DiceMaker(type: dice)
        diceMaker.addDiceSetTo(diceNode)
        
        // Initialize boundary objects
        let invisiPlaneFront = SCNNode()
        let invisiPlaneBack = SCNNode()
        let invisiPlaneLeft = SCNNode()
        let invisiPlaneRight = SCNNode()
        let invisiPlaneTop = SCNNode()
        
        setBoundaryProperties(invisiPlaneFront)
        setBoundaryProperties(invisiPlaneBack)
        
        invisiPlaneLeft.rotation = SCNVector4(0, 1, 0, Float(M_PI_2))
        setBoundaryProperties(invisiPlaneLeft)
        
        invisiPlaneRight.rotation = SCNVector4(0, 1 , 0, Float(-M_PI_2))
        setBoundaryProperties(invisiPlaneRight)
        
        invisiPlaneTop.rotation = SCNVector4(1, 0, 0, Float(M_PI_2))
        setBoundaryProperties(invisiPlaneTop)
        
        // Initialize positions
        let planePositionScalar: Float = Float(planeScalar)
        
        invisiPlaneFront.position = SCNVector3(0, 0, 0.9 * planePositionScalar)
        invisiPlaneBack.position = SCNVector3(0, 0, -0.80 * planePositionScalar)
        invisiPlaneLeft.position = SCNVector3(-planePositionScalar / 2, 0, 0)
        invisiPlaneRight.position = SCNVector3(planePositionScalar / 2, 0, 0)
        invisiPlaneTop.position = SCNVector3(0, planePositionScalar, 0)
        
        boundary.addChildNode(invisiPlaneFront)
        boundary.addChildNode(invisiPlaneBack)
        boundary.addChildNode(invisiPlaneLeft)
        boundary.addChildNode(invisiPlaneRight)
        boundary.addChildNode(invisiPlaneTop)
        
        rootNode.addChildNode(cameraNode)
        rootNode.addChildNode(floorNode)
        rootNode.addChildNode(diceNode)
        rootNode.addChildNode(boundary)
    }
    
    private func setBoundaryProperties(plane: SCNNode) {
        let planeOpacity:CGFloat = 0.0
        
        plane.geometry = SCNBox(width: planeScalar * 2, height: planeScalar * 2, length: 0.05, chamferRadius: 0)
        plane.opacity = planeOpacity
        plane.physicsBody = SCNPhysicsBody.staticBody()
    }
    
    func nearlyAtRest(node: SCNNode) -> Bool {
        if node.physicsBody!.isResting {
            return true
        }
        
        let dx = Float((node.physicsBody?.velocity.x)!)
        let dy = Float((node.physicsBody?.velocity.y)!)
        let dz = Float((node.physicsBody?.velocity.z)!)
        
        let speed = sqrtf(dx*dx+dy*dy+dz*dz)
        
        let x = Float((node.physicsBody?.angularVelocity.x)!)
        let y = Float((node.physicsBody?.angularVelocity.y)!)
        let z = Float((node.physicsBody?.angularVelocity.z)!)
        
        let angularSpeed = sqrtf(x*x+y*y+z*z)
        
        return (speed < 0.001 || angularSpeed < 0.9)
    }
    
    func getDice() -> [SCNNode] {
        return diceNode.childNodes
    }
    
    func getWinningColor(node: SCNNode) -> Color {
        let rotation: SCNVector4 = node.presentationNode.rotation
        var invRotation: SCNVector4 = rotation
        invRotation.w = -invRotation.w
        
        let up = SCNVector3Make(0,1,0)
        
        let transform: SCNMatrix4 = SCNMatrix4MakeRotation(invRotation.w, invRotation.x, invRotation.y, invRotation.z)
        let glkTransform: GLKMatrix4 = SCNMatrix4ToGLKMatrix4(transform)
        let glkUp: GLKVector3 = SCNVector3ToGLKVector3(up)
        let rotatedUp: GLKVector3 = GLKMatrix4MultiplyVector3(glkTransform, glkUp)
        
        var boxNormals: [GLKVector3] = [GLKVector3(v: (0,0,1)),
                                        GLKVector3(v: (1,0,0)),
                                        GLKVector3(v: (0,0,-1)),
                                        GLKVector3(v: (-1,0,0)),
                                        GLKVector3(v: (0,1,0)),
                                        GLKVector3(v: (0,-1,0))]
        
        var winningIndex: Int = 0
        var maxDot: Float = -1
        
        for  i in 0...5 {
            let dot: Float = GLKVector3DotProduct(boxNormals[i], rotatedUp)
            
            if (dot > maxDot) {
                maxDot = dot
                winningIndex = i
            }
        }
        
        var colors = [Color.Yellow, Color.Cyan, Color.Purple, Color.Blue, Color.Red, Color.Green]
        
        return colors[winningIndex]
    }
    
    func animateRollResult(node: SCNNode, didWin: Bool) {
        node.paused = false
        
        var actions: SCNAction = SCNAction()
        
        if !didWin {
            actions = SCNAction.sequence([SCNAction.fadeOutWithDuration(0.5), SCNAction.removeFromParentNode()])
        }
        
        node.runAction(actions)
        
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        if shouldCheckMovement {
            shouldCheckMovement = false
            
            for node in getDice() {
                if nearlyAtRest(node) && !node.paused {
                    node.paused = true
                }
                
                if !node.paused {
                    shouldCheckMovement = true
                }
            }
            
            if !shouldCheckMovement {
                resolveGameplayHandler!()
            }
        }
    }
}