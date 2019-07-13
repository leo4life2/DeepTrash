//
//  ViewController.swift
//  PaperToss
//
//  Created by Leo on 2019/7/13.
//  Copyright © 2019 leo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var ball = SCNNode()
    var recBin = SCNNode()
    var hhBin = SCNNode()
    var hzBin = SCNNode()
    var rsBin = SCNNode()
    var textNode:SCNText = SCNText()
    var tapRecognizer = UITapGestureRecognizer()
    var panRecognizer = UIPanGestureRecognizer()
    
    var menuVC: MenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
//        sceneView.debugOptions = [.showPhysicsShapes]
        
        setupPhase1Recognizers()
    }
    
    func setupPhase1Recognizers(){
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addObjToSceneView(withGestureRecognizer:)))
        tapRecognizer.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(tapRecognizer)
    
        let quitTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(quit(sender:)))
        quitTapRecognizer.numberOfTapsRequired = 3
        sceneView.addGestureRecognizer(quitTapRecognizer)
    }
    
    @objc func quit(sender: UITapGestureRecognizer){
        menuVC?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){

        if sender.state == .cancelled {
            ball.removeFromParentNode()
            //If it actually shoots
        } else if sender.state == .ended {
            //Takes swipe velocity in CGFloat/seconds
            let velocity = sender.velocity(in: sceneView)
            // X: negative = left, positive = right.
            // Y: negative = forward

            ball.position = sceneView.pointOfView!.convertPosition(ball.position, to: sceneView.scene.rootNode)
            ball.removeFromParentNode()
            sceneView.scene.rootNode.addChildNode(ball)
            ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: [SCNPhysicsShape.Option.scale: SCNVector3(0.2, 0.2, 0.2)]))
//            ball.childNode(withName: "text", recursively: false)!.physicsBody = nil
            ball.physicsBody?.isAffectedByGravity = true
            
//            let force = SCNVector3(Float(velocity.x) / 1000, 0, 0)
            let force = SCNVector3(getUserVector().0.x, getUserVector().0.y * Float(velocity.y) / 1000, getUserVector().0.z)
            
            //I give force to physicBody
            ball.physicsBody?.applyForce(force, asImpulse: true)
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        resetBallInFrontOfCamera()
    }
    
    @objc func addObjToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        guard let scene = SCNScene(named: "art.scnassets/MainScene.scn") else {return}
        
        let node = scene.rootNode.childNode(withName: "dummy", recursively: false)!
        
        node.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(node)
        
        setupPhase2Recognizers()
        setupScene()
    }
    
    func setupPhase2Recognizers(){
        sceneView.removeGestureRecognizer(tapRecognizer)
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        sceneView.addGestureRecognizer(panRecognizer)
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func setupScene(){
        ball = sceneView.scene.rootNode.childNode(withName: "ball", recursively: true)!
        
        recBin = sceneView.scene.rootNode.childNode(withName: "RecBin", recursively: true)!
        rsBin = sceneView.scene.rootNode.childNode(withName: "RSBin", recursively: true)!
        hhBin = sceneView.scene.rootNode.childNode(withName: "HHBin", recursively: true)!
        hzBin = sceneView.scene.rootNode.childNode(withName: "HZBin", recursively: true)!
        
        recBin.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: recBin, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.1, 0.1, 0.1)]))
        rsBin.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: rsBin, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.1, 0.1, 0.1)]))
        hhBin.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: hhBin, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.1, 0.1, 0.1)]))
        hzBin.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: hzBin, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.1, 0.1, 0.1)]))
        
        rsBin.physicsBody?.restitution = 1
        recBin.physicsBody?.restitution = 1
        hhBin.physicsBody?.restitution = 1
        hzBin.physicsBody?.restitution = 1
        
        resetBallInFrontOfCamera()
    }
    
    func resetBallInFrontOfCamera(){
        ball.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: ball, options: [SCNPhysicsShape.Option.scale: SCNVector3(0.3, 0.3, 0.3)]))
        ball.physicsBody?.isAffectedByGravity = false
        ball.physicsBody?.restitution = 0.5
        
        ball.removeFromParentNode()
        sceneView.pointOfView?.addChildNode(ball)
        let orientation = SCNVector3(x: 0, y: -0.1, z: -0.2)
        ball.position = orientation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.isAutoFocusEnabled = true
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func acotForSwipes(x : Double) -> Double {
        if x > 1.0 || x < -1.0{
            return atan(1.0/x)
        } else {
            return .pi/2 - atan(x)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor(red: 20/255, green: 20/255, blue: 100/255, alpha: 0)
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
//        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: planeNode, options: nil))
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

public enum UIPanGestureRecognizerDirection {
    case undefined
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
}
public enum TransitionOrientation {
    case unknown
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

extension SCNVector3 {
    static public func * (left:SCNVector3, scalar:Float) -> SCNVector3 {
        return SCNVector3(left.x * scalar, left.y * scalar, left.z * scalar)
    }
}

extension UIPanGestureRecognizer {
    public var direction: UIPanGestureRecognizerDirection {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        
        var direction: UIPanGestureRecognizerDirection
        
        if isVertical {
            direction = velocity.y > 0 ? .topToBottom : .bottomToTop
        } else {
            direction = velocity.x > 0 ? .leftToRight : .rightToLeft
        }
        
        return direction
    }
    
    public func isQuickSwipe(for orientation: TransitionOrientation) -> Bool {
        let velocity = self.velocity(in: view)
        return isQuickSwipeForVelocity(velocity, for: orientation)
    }
    
    private func isQuickSwipeForVelocity(_ velocity: CGPoint, for orientation: TransitionOrientation) -> Bool {
        switch orientation {
        case .unknown : return false
        case .topToBottom : return velocity.y > 1000
        case .bottomToTop : return velocity.y < -1000
        case .leftToRight : return velocity.x > 1000
        case .rightToLeft : return velocity.x < -1000
        }
    }
}

extension UIPanGestureRecognizer {
    typealias GestureHandlingTuple = (gesture: UIPanGestureRecognizer? , handle: (UIPanGestureRecognizer) -> ())
    fileprivate static var handlers = [GestureHandlingTuple]()
    
    public convenience init(gestureHandle: @escaping (UIPanGestureRecognizer) -> ()) {
        self.init()
        UIPanGestureRecognizer.cleanup()
        set(gestureHandle: gestureHandle)
    }
    
    public func set(gestureHandle: @escaping (UIPanGestureRecognizer) -> ()) {
        weak var weakSelf = self
        let tuple = (weakSelf, gestureHandle)
        UIPanGestureRecognizer.handlers.append(tuple)
        addTarget(self, action: #selector(handleGesture))
    }
    
    fileprivate static func cleanup() {
        handlers = handlers.filter { $0.0?.view != nil }
    }
    
    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let handleTuples = UIPanGestureRecognizer.handlers.filter{ $0.gesture === self }
        handleTuples.forEach { $0.handle(gesture)}
    }
}



extension UIPanGestureRecognizerDirection {
    public var orientation: TransitionOrientation {
        switch self {
        case .rightToLeft: return .rightToLeft
        case .leftToRight: return .leftToRight
        case .bottomToTop: return .bottomToTop
        case .topToBottom: return .topToBottom
        default: return .unknown
        }
    }
}

extension UIPanGestureRecognizerDirection {
    public var isHorizontal: Bool {
        switch self {
        case .rightToLeft, .leftToRight:
            return true
        default:
            return false
        }
    }
}
