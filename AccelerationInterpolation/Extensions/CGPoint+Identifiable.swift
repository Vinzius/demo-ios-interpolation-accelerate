//
//  CGPoint+Identifiable.swift
//  AccelerationInterpolation
//
//  Created by Vincent on 07/01/2021.
//

import CoreGraphics.CGGeometry

extension CGPoint: Identifiable {
    public var id: String {
        "\(self.x)-\(self.y)"
    }
}
