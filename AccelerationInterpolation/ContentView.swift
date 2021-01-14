//
//  ContentView.swift
//  AccelerationInterpolation
//
//  Created by Vincent on 07/01/2021.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    
    // MARK: Properties
    
    @State var setupID: String = ""
    @State var lastKnownSize: CGSize = .zero
    
    // Points & curve.
    @State var fewPoints: [CGPoint] = []
    @State var interpolatedPoints: [CGPoint] = []
    @State var curvePath: Path? = nil
    
    // Preferences.
    @State var prefInterpolationAlgo: Array<CGPoint>.InterpolationAlgorithm = .linear
    @State var prefShowCurvePath: Bool = false
    
    // MARK: Body
    
    var body: some View {
        VStack {
            // Canva.
            GeometryReader { (geometry) in
                ZStack {
                    if self.prefShowCurvePath == true, let path = self.curvePath {
                        path
                            .stroke(Color.blue, lineWidth: 1)
                    } else {
                        ForEach(self.interpolatedPoints) { (point) in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 2, height: 2)
                                .position(x: point.x, y: point.y)
                        }
                    }
                    ForEach(self.fewPoints) { (point) in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .position(x: point.x, y: point.y)
                    }
                }
                .id("\(geometry.size)")
                .onChange(of: self.prefInterpolationAlgo, perform: { _ in
                    self.recalculateInterpolation()
                })
                .onAppear {
                    self.setupData(with: geometry)
                }
            }
            // Parameters.
            HStack {
                Button("Reset points") {
                    self.resetFewPoints()
                }
                .padding()
                .border(Color.blue)
                Spacer()
                Toggle(isOn: self.$prefShowCurvePath) {
                    Text("Draw curve")
                }
                Spacer()
                Picker("Algorithm", selection: self.$prefInterpolationAlgo) {
                    ForEach(Array<CGPoint>.InterpolationAlgorithm.allCases, id: \.self) { choice in
                        Text((choice == .linear) ? "linear" : "quadratic").tag(choice)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding()
    }
    
    // MARK: Setup
    
    func setupData(with geometry: GeometryProxy) -> Void {
        
        let newID: String = "\(geometry.size)"
        if self.setupID == newID {
            return
        }
        self.setupID = newID
        self.lastKnownSize = geometry.size
        
        self.resetFewPoints()
        
    }
    
    func resetFewPoints() -> Void {
        
        // Make few points.
        self.fewPoints = self.makeRadomPoints(
            count: Int(self.lastKnownSize.width / 40),
            size: self.lastKnownSize
        )
        
        self.recalculateInterpolation()
        
    }
    
    func recalculateInterpolation() -> Void {
        
        // Make interpolated points.
        self.interpolatedPoints = self.makeInterpolatedPoints(
            count: Int(self.lastKnownSize.width / 5),
            through: self.fewPoints
        )
        
        // Make path through interpolated points.
        self.curvePath = self.makeCurvePath(through: self.interpolatedPoints)
        
    }
    
    func makeRadomPoints(count: Int, size: CGSize) -> [CGPoint] {
        
        let numberOfPoints: Int = count
        let pointSpacing = max(size.width / CGFloat(numberOfPoints - 1), 1)
        let randomHeightRange: Range<CGFloat> = (0.1*size.height..<0.9*size.height)

        return (0..<numberOfPoints).map { (index) -> CGPoint in
            CGPoint(
                x: CGFloat(index) * pointSpacing,
                y: CGFloat.random(in: randomHeightRange)
            )
        }
        
    }
    
    func makeInterpolatedPoints(count: Int, through points: [CGPoint]) -> [CGPoint] {
        
        return points.interpolated(
            direction: .horizontal,
            algorithm: self.prefInterpolationAlgo, steps: count
        )
        
    }
    
    func makeCurvePath(through points: [CGPoint]) -> Path {
        
        var path = Path()
        path.addLines(points)
        return path
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 500, height: 300))
            .background(Color.white)
            .padding()
            .background(Color(white: 0.9))
    }
}
