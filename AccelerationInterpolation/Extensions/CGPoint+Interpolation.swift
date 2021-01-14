//
//  CGPoint+Interpolation.swift
//  AccelerationInterpolation
//
//  Created by Vincent on 07/01/2021.
//

import CoreGraphics.CGGeometry
import Accelerate.vecLib
import simd

extension Array where Element == CGPoint {
    
    enum InterpolationAxis: CaseIterable {
        case horizontal, vertical
    }
    
    enum InterpolationAlgorithm: CaseIterable {
        case linear, quadratic
    }
    
    func interpolated(direction: InterpolationAxis = .horizontal, algorithm: InterpolationAlgorithm = .linear, steps: Int = 1024) -> [CGPoint] {
        
        if self.count <= 2 { return self }
        
        let n = vDSP_Length(steps)
        let stride = vDSP_Stride(1)
        let isHorizontal: Bool = (direction == .horizontal)

        let values: [Float] = isHorizontal ? self.map({ Float($0.y) }) : self.map({ Float($0.x) })
        let denominator = Float(n) / Float(values.count - 1)

        let control: [Float] = (0..<n).map {
            let x = Float($0) / denominator
            return floor(x) + simd_smoothstep(0, 1, simd_fract(x))
        }
        
        var result = [Float](repeating: 0, count: Int(n))
        
        // Run accelerate.
        switch algorithm {
        case .linear:
            vDSP_vlint(values, control, stride, &result, stride, n, vDSP_Length(values.count))
        case .quadratic:
            vDSP_vqint(values, control, stride, &result, stride, n, vDSP_Length(values.count))
        }
        
        // Transform back into (cg)points.
        let pointMinimum: CGFloat = (isHorizontal ? self.first?.x : self.first?.y) ?? 0
        let pointMaximum: CGFloat = (isHorizontal ? self.last?.x : self.last?.y) ?? 0
        let pointStep: CGFloat = (pointMaximum - pointMinimum) / CGFloat(steps - 1)
        if isHorizontal == true {
            return result.enumerated().map { (index, value) -> CGPoint in
                CGPoint(
                    x: pointMinimum + (CGFloat(index) * pointStep),
                    y: CGFloat(value)
                )
            }
        } else {
            return result.enumerated().map { (index, value) -> CGPoint in
                CGPoint(
                    x: CGFloat(value),
                    y: pointMinimum + (CGFloat(index) * pointStep)
                )
            }
        }
        
    }
    
}

