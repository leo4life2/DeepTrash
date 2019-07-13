//
//  Scene.swift
//  TrashClassifier
//
//  Created by Leo on 2019/7/13.
//  Copyright © 2019 leo. All rights reserved.
//

import SpriteKit
import ARKit
import CoreML
import Vision

class Scene: SKScene {
    
    var idNode = SKLabelNode()
    let handSignsModel = try? VNCoreMLModel(for: img().model)
    var request: VNCoreMLRequest!
    var count = 0
    
    var menuVC: MenuViewController?
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        idNode = self.scene?.childNode(withName: "ID") as! SKLabelNode
        
        request =  VNCoreMLRequest(model: handSignsModel!) { (finishedRequest, err) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstResult = results.first else { return }
            
//            DispatchQueue.main.async {
                print(firstResult.identifier)
            let hhwaste = ["bread",
            "cookies",
            "corn",
            "eggShell",
            "greenery",
            "melonSkin",
            "orangeSkin",
            "peeledStuff",
            "potatoes",
            "shrimpSkin"]
            
            let recWaste = ["backpack",
            "book",
            "cardboard",
            "clothing",
            "glassCup",
            "newsPaper",
            "plasticBottle",
            "plasticToys",
            "tinCan",
            "toothbrush",
            "foodCan"]
            
            let resWaste = ["bigBones",
            "ceramics",
            "cigs",
            "clips",
            "lipstick",
            "makeupBrush",
            "napkins",
            "plasticBags",
            "singleUseCup",
            "toiletPaper",
            "gum",
            "flowerPots"]
            
            if hhwaste.contains(firstResult.identifier){
                self.idNode.attributedText = NSAttributedString(string: firstResult.identifier + ", 湿垃圾", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 24)! ])
            } else if recWaste.contains(firstResult.identifier) {
                self.idNode.attributedText = NSAttributedString(string: firstResult.identifier + ", 可回收垃圾", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 24)! ])
            } else if resWaste.contains(firstResult.identifier) {
                self.idNode.attributedText = NSAttributedString(string: firstResult.identifier + ", 干垃圾", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 24)! ])
            }
        }
        
        let quitTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(quit(sender:)))
        quitTapRecognizer.numberOfTapsRequired = 3
        self.view?.addGestureRecognizer(quitTapRecognizer)
    }
    
    @objc func quit(sender: UITapGestureRecognizer){
        menuVC?.dismiss(animated: true, completion: nil)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        count += 1
        if count % 50 == 0{
            guard let sceneView = self.view as? ARSKView else {
                return
            }
            // Create anchor using the camera's current position
            if let currentFrame = sceneView.session.currentFrame {
                
                let pixelBuffer = currentFrame.capturedImage
                
                try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            }
        }
    }
}
