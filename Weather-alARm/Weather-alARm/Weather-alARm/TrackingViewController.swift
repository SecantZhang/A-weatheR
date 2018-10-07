//
//  TrackingViewController.swift
//  Weather-alARm
//
//  Created by Wilson Zhang on 10/7/18.
//  Copyright © 2018 Wilson Zhang. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class TrackingViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var trackSceneView: ARSCNView!
    @IBOutlet weak var currentBt: UIButton!
    
    var currentWeather : String = ""
    var weather_long : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather_long = currentWeather

        // Set the view's delegate
        trackSceneView.delegate = self
        
        // Show statistics such as fps and timing information
        trackSceneView.showsStatistics = true
        trackSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        trackSceneView.autoenablesDefaultLighting = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 3
            print("Images Successfully Added")
        }
        
        trackSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        trackSceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)

            if imageAnchor.referenceImage.name == "test" {
                if let pokeScene = SCNScene(named: "art.scnassets/cat.scn") {
                    if let pokeNode = pokeScene.rootNode.childNodes.first {
                        pokeNode.eulerAngles.x = .pi / 2
                        planeNode.addChildNode(pokeNode)
                    }
                }
            }
            
            else if imageAnchor.referenceImage.name == "playing" {
                if let pokeScene = SCNScene(named: "art.scnassets/cat.scn") {
                    if let pokeNode = pokeScene.rootNode.childNodes.first {
                        pokeNode.eulerAngles.x = .pi / 2
                        planeNode.addChildNode(pokeNode)
                    }
                }
            }
            
            else if imageAnchor.referenceImage.name == "square" {
                if let pokeScene = SCNScene(named: "art.scnassets/uh60.scn") {
                    if let pokeNode = pokeScene.rootNode.childNodes.first {
                        pokeNode.eulerAngles.x = .pi / 2
                        planeNode.addChildNode(pokeNode)
                    }
                }
            }
        }
        return node
        
    }
}
