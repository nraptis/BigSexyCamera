//
//  Recycler.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal

protocol RecyclerNodeConforming: AnyObject {
    associatedtype VertexUniforms: Uniforms
    associatedtype FragmentUniforms: Uniforms
    var uniformsFragment: FragmentUniforms { get }
    var uniformsFragmentBuffer: MTLBuffer! { get }
    var uniformsVertex: VertexUniforms { get }
    var uniformsVertexBuffer: MTLBuffer! { get }
    init(graphics: Graphics)
}

class Recycler<SliceType: RecyclerNodeConforming> {
    var slices = [SliceType]()
    var recycle = [SliceType]()
    
    var red: Float = 1.0
    var green: Float = 1.0
    var blue: Float = 1.0
    var alpha: Float = 1.0
    
    func clear() {
        recycle.removeAll()
        slices.removeAll()
    }

    func reset() {
        recycle.append(contentsOf: slices)
        slices.removeAll(keepingCapacity: true)
    }

    func slice(graphics: Graphics) -> SliceType {
        if let result = recycle.popLast() {
            slices.append(result)
            return result
        } else {
            let slice = SliceType(graphics: graphics)
            slices.append(slice)
            return slice
        }
    }
    
    func set(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    func set(red: Float, green: Float, blue: Float) {
        set(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func set(intensity: Float, alpha: Float) {
        set(red: intensity, green: intensity, blue: intensity, alpha: alpha)
    }

    func set(intensity: Float) {
        set(red: intensity, green: intensity, blue: intensity, alpha: 1.0)
    }

    func set(alpha: Float) {
        set(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha)
    }
}
