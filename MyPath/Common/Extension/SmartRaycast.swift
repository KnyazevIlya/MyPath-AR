//
//  SmartRaycast.swift
//  MyPath
//
//  Created by Illia Kniaziev on 20.05.2022.
//

import ARKit

extension ARSCNView {
    func smartRaycast(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: SIMD3<Float>? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal]) -> ARRaycastResult? {
        guard let query = raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) else {
            return nil
        }

        let results = session.raycast(query)
        
        if let nearestResult = results.first,
           let planeAnchor = nearestResult.anchor as? ARPlaneAnchor,
           allowedAlignments.contains(planeAnchor.alignment) {
            return nearestResult
        }
        
        if infinitePlane {
            guard let query = raycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal) else {
                return nil
            }
            
            let infiniteResults = session.raycast(query)
            
            for infiniteResult in infiniteResults {
                if let planeAnchor = infiniteResult.anchor as? ARPlaneAnchor,
                   allowedAlignments.contains(planeAnchor.alignment) {
                    if let objectY = objectPosition?.y {
                        let planeY = infiniteResult.worldTransform.translation.y
                        if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                            return infiniteResult
                        }
                    } else {
                        return infiniteResult
                    }
                }
            }
        }
        
        return results.first
    }
}
