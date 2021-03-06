//
//  ViewController.swift
//  ARSolarSystem
//
//  Created by Marla Na on 16.09.17.
//  Copyright © 2017 Marla Na. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var solarNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        self.createPlanets(scene: scene)
        
        // Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func handleTap(gestureRecognize :UITapGestureRecognizer) {
        let sceneView = gestureRecognize.view as! ARSCNView
        let touchLocation = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        if !hitResults.isEmpty {
            //TODO:
        }
    }
    
    func createPlanets(scene: SCNScene){
        //create the Earth
        let earthNode = self.createObject(radius: 0.2, materialName: "earth.jpg", position: SCNVector3(0.5,-1.5,-2))
        self.rotateObject(node: earthNode, duration: 3, from: SCNVector4Make(0, 1, 0, 0), to: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0), key: "earth_rotation")
        
        // create the Moon
        let moonNode = self.createObject(radius: 0.1, materialName: "moon.jpg", position: SCNVector3(0.5,-1.5,-2))
        self.rotateObject(node: moonNode, duration: 3.5, from: SCNVector4Make(0, 1, 0, 0), to: SCNVector4Make(0, 1, 0, Float.pi * 2.0), key: "moon_rotation")
        
        // Moon-Earth System
        let moonRotationNode = self.createDoubleRotationObject(node: moonNode)
        let earthRotationNode = self.createDoubleRotationObject(node: earthNode)
        let moonEarthNode = self.createMiniSystems(firstNode: earthRotationNode, secondNode: moonRotationNode)
        self.rotateObject(node: moonRotationNode, duration: 4, from:  SCNVector4Make(0, 2, 1, 0), to: SCNVector4Make(0, 2, 1, Float.pi * 2.0) , key: "moon_from_earth_rotation")
        self.rotateObject(node: earthRotationNode, duration: 4, from: SCNVector4Make(0, 2, 1, 0), to: SCNVector4Make(0, 2, 1, Float.pi * 2.0), key: "earth_from_sun_rotation")
        
        //Create the Sun
        let sunNode = self.createObject(radius: 0.5, materialName: "sun.jpg", position: SCNVector3(0.1,-1,-2))
        self.rotateObject(node: sunNode, duration: 3, from: SCNVector4Make(0, 1, 0, 0), to: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0), key: "sun_rotation")
        sunNode.addChildNode(earthRotationNode)
        
       solarNode.addChildNode(moonEarthNode)
       solarNode.addChildNode(sunNode)
       
       scene.rootNode.addChildNode(solarNode)
    }
    
    func createObject(radius: CGFloat, materialName: String, position: SCNVector3) -> SCNNode {
        let object = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: materialName)
        object.materials = [material]
        let node = SCNNode(geometry: object)
        node.position = position
        return node
    }
    func createMiniSystems(firstNode: SCNNode, secondNode: SCNNode) -> SCNNode {
        let miniSystem = SCNNode()
        miniSystem.addChildNode(firstNode)
        miniSystem.addChildNode(secondNode)
        return miniSystem
    }
    func createDoubleRotationObject(node: SCNNode) -> SCNNode {
        let rotationNode = SCNNode()
        rotationNode.addChildNode(node)
        return rotationNode
    }
    func rotateObject(node: SCNNode, duration: CFTimeInterval, from: SCNVector4, to: SCNVector4, key: String){
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = duration
        animation.fromValue = NSValue(scnVector4: from)
        animation.toValue = NSValue(scnVector4: to)
        animation.repeatCount = Float.greatestFiniteMagnitude
        node.addAnimation(animation, forKey: key)
    }
}
