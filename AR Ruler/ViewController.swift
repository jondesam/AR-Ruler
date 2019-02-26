//
//  ViewController.swift
//  AR Ruler
//
//  Created by MyMac on 2019-02-25.
//  Copyright © 2019 Apex. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var textNode = SCNNode()
    
    var dotNodesArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
      
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if dotNodesArray.count >= 2 {
            for dot in dotNodesArray {
                dot.removeFromParentNode()
            }
            
            dotNodesArray = [SCNNode]()
        }
        
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    func addDot(at hitResult : ARHitTestResult) {
        
        let sphere = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        sphere.materials = [material]
        
        let dotNode = SCNNode(geometry: sphere)
    

        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodesArray.append(dotNode)
        
        if dotNodesArray.count >= 2 {
            calculate()
        }
        
        
    }
    
    
    func calculate() {
        let start = dotNodesArray[0]
        let end = dotNodesArray[1]
        
        print(start.position)
        print(end.position)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text: "\(abs(distance))", startPosition: start.position , endPosition: end.position)
        
        
        //print(abs(distance))
        
        //distance = √((x2 - x1)^2 + (y2 - y1)^2 +(z2 - z1)^2 )
        // √((a^2) + (b^2) + (c^2))
        
    }
    
    func updateText(text: String, startPosition: SCNVector3, endPosition:SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(
            startPosition.x,
            startPosition.y,
            endPosition.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    
    }
    
}
