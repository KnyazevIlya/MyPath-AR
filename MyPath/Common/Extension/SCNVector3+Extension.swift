//
//  SCNVector3+Extension.swift
//  MyPath
//
//  Created by Illia Kniaziev on 20.05.2022.
//

import SceneKit

extension SCNVector3 {
    init(_ vector: simd_float4) {
        self.init(x: vector.x, y: vector.y, z: vector.z)
    }
}
