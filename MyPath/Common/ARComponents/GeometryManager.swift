//
//  GeometryManager.swift
//  MyPath
//
//  Created by Illia Kniaziev on 20.05.2022.
//

import ARKit

final class GeometryManager {
    static func getNormalizedRotation(eulerAngleY: Float, rotation: Float) -> Float {
        var normalized = (eulerAngleY - rotation).truncatingRemainder(dividingBy: 2 * .pi)
        normalized = (normalized + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
        if normalized > .pi {
            normalized -= 2 * .pi
        }
        
        return normalized
    }
    
    static func getPointDevidingLineSegment(withRatio ratio: Float, from start: SCNVector3, to end: SCNVector3) -> SCNVector3 {
        return (start + end * ratio) / (1 + ratio)
    }
    
    static func getEndPoint(withRatio ratio: Float, startPoint start: SCNVector3, devider: SCNVector3) -> SCNVector3 {
        return (devider * (1 + ratio) - start) / ratio
    }
    
    static func rotateOnHorizontalPlain(point: SCNVector3, around pivot: SCNVector3, by angle: Float) -> SCNVector3 {
        var res = point
        let cosValue = cos(angle)
        let sinValue = sin(angle)
        
        res.x = cosValue * (point.x - pivot.x) - sinValue * (point.z - pivot.z) + pivot.x
        res.z = sinValue * (point.x - pivot.x) + cosValue * (point.z - pivot.z) + pivot.z
        
        return res
    }
   
}
