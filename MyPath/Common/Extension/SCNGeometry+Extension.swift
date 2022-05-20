//
//  SCNGeometry+Extension.swift
//  MyPath
//
//  Created by Illia Kniaziev on 20.05.2022.
//

import SceneKit

extension SCNGeometry {
    static func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNNode {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let lineMaterial = SCNMaterial()
        lineMaterial.diffuse.contents = UIColor.systemMint
        lineMaterial.lightingModel = .physicallyBased
        lineMaterial.name = "Line texture"
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let lineNode = SCNNode(geometry: geometry)
        lineNode.geometry?.materials = [lineMaterial]
        lineNode.position = SCNVector3Zero
        
        return lineNode
    }
    
    static func shpere(at point: SCNVector3, withRadius radius: CGFloat = 0.003, withColour colour: UIColor = .systemMint) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = colour
        
        let node = SCNNode(geometry: geometry)
        node.position = point
        
        return node
    }
}
