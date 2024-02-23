//
//  Doer.swift
//  MetalReactionDiffusion
//
//  Created by Xiaoyi Liu on 2/22/24.
//  Copyright © 2024 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit
import Metal
import QuartzCore
import CoreData

let channels_ct: Int = 4 // RGBA
let image_side: Int = 640

// Simulates reaction diffusion
class Simulate: UIViewController, UIPopoverControllerDelegate{
    // Image
    let bitmap_info = CGBitmapInfo(
        rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) // byte ordering of pixel format
    let renderingIntent = CGColorRenderingIntent.defaultIntent // how Quartz maps colors from one color space to another
    let image_size = CGSize(width: Int(image_side), height: Int(image_side)) // width and height
    let image_byte_count = Int(image_side * image_side * channels_ct)
    let bytes_per_pixel = Int(4)
    let bits_per_component = Int(8)
    let bits_per_pixel: Int = 32
    let rgb_ColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bytes_per_row = Int(image_side * channels_ct)
    let provider_length = Int(image_side * image_side * channels_ct) * 64 // 64 replace size of int
    var image_bytes = [UInt8](
        repeating: 0,
        count: Int(image_side * image_side * channels_ct))
    let image_view =  UIImageView(frame: CGRectZero)
    let editor = ReactionDiffusionEditor(frame: CGRectZero) // skip for now
    
    // Metal
    var pipeline_state: MTLComputePipelineState!
    var default_library: MTLLibrary! = nil
    var device: MTLDevice! = nil
    var command_queue: MTLCommandQueue! = nil
    
    var region: MTLRegion!
    var textureA: MTLTexture!
    var textureB: MTLTexture!
    var use_texture_a_for_input = true
    var reset = false
    var new_model_loaded = false
    var image: UIImage!
    var runtime = CFAbsoluteTimeGetCurrent()
    var error_flag:Bool = false
    var thread_group_count:MTLSize!
    var thread_groups: MTLSize!
    
    // Model
    var model = GrayScottModel()
    var running = false
    
    // App initialize
    let app_delegate: AppDelegate
    let managed_object_context: NSManagedObjectContext
    let browse_and_load_controller: BrowseAndLoadController
    let popover_controller: UIPopoverController
    required init(coder aDecoder: NSCoder)
    {
        app_delegate = UIApplication.shared.delegate as! AppDelegate
        managed_object_context = app_delegate.managedObjectContext!
        browse_and_load_controller = BrowseAndLoadController()
        popover_controller = UIPopoverController(contentViewController: browse_and_load_controller)
        super.init(coder: aDecoder)!
        browse_and_load_controller.preferredContentSize = CGSize(width: 640, height: 480)
        popover_controller.delegate = self
    }
    
    func setUpTexture()
    {
        let image = model.defaultImage.cgImage!
        thread_group_count = MTLSizeMake(16, 16, 1)
        thread_groups = MTLSizeMake(
            Int(image_side) / thread_group_count.width,
            Int(image_side) / thread_group_count.height, 1)
        var raw = [UInt8](repeating: 0, count: Int(image_side * image_side * channels_ct))
        let context = CGContext(
            data: &raw, width: image_side, height: image_side,
            bitsPerComponent: bits_per_component, bytesPerRow: bytes_per_row,
            space: rgb_ColorSpace, bitmapInfo: bitmap_info.rawValue)! // added unwrap
        // see https://stackoverflow.com/questions/42226158/value-of-optional-type-cgcontext-not-unwrapped
        context.draw(image, in : CGRectMake(0, 0, CGFloat(image_side), CGFloat(image_side)))
        let texture_descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: Int(image_side), height: Int(image_side), mipmapped: false)
        textureA = device.makeTexture(descriptor: texture_descriptor)
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: textureA.pixelFormat, width: textureA.width, height: textureA.height,
            mipmapped: false)
        textureB = device.makeTexture(descriptor: outTextureDescriptor)
        region = MTLRegionMake2D(0, 0, Int(image_side), Int(image_side))
        textureA.replace(region: region, mipmapLevel: 0,
            withBytes: &raw, bytesPerRow: Int(bytes_per_row))
    }
    
    final func applyFilter() -> UIImage
    {
        let commandBuffer = command_queue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(pipeline_state)
        var buffer: MTLBuffer = device.makeBuffer(
            bytes: &model.parameters.values,
            length: MemoryLayout.size(ofValue: model.parameters.values),
            options: <#T##MTLResourceOptions#>)! // replaced newBufferWithBytes
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
        
        command_queue = device.makeCommandQueue()
        
        for _ in 0 ... model.iterationsPerFrame
        {
            if use_texture_a_for_input
            {
                commandEncoder?.setTexture(textureA, index: 0)
                commandEncoder?.setTexture(textureB, index: 1)
            }
            else
            {
                commandEncoder?.setTexture(textureB, index: 0)
                commandEncoder?.setTexture(textureA, index: 1)
            }
            commandEncoder?.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: thread_group_count)
            use_texture_a_for_input = !use_texture_a_for_input
        }
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        if !use_texture_a_for_input{
            textureB.getBytes(&image_bytes,
                bytesPerRow: Int(bytes_per_row), from: region, mipmapLevel: 0)
        }
        else{
            textureA.getBytes(&image_bytes,
                bytesPerRow: Int(bytes_per_row), from: region, mipmapLevel: 0)
        }
        let providerRef = CGDataProvider(data: NSData(bytes: &image_bytes, length: provider_length))!
        let imageRef = CGImage(width: Int(image_size.width), height: Int(image_size.height), bitsPerComponent: bits_per_component, bitsPerPixel: bits_per_pixel, bytesPerRow: bytes_per_row, space: rgb_ColorSpace, bitmapInfo: bitmap_info, provider: providerRef, decode: nil, shouldInterpolate: false, intent: renderingIntent)!
        return UIImage(cgImage: imageRef)
    }
    
    final func run()
    {
        if device == nil || !running{
            return
        }
        self.image = self.applyFilter()
        self.image_view.image = self.image
        if self.use_texture_a_for_input
        {
            if self.reset{
                self.reset = false
                self.setUpTexture()
            }
        }
        let fps = Int( 1 / (CFAbsoluteTimeGetCurrent() - self.runtime))
        self.runtime = CFAbsoluteTimeGetCurrent()
        self.run()
    }
    
    func setUpMetal()
    {
        device = MTLCreateSystemDefaultDevice()
        print("device = \(String(describing: device))")
        if device == nil
        {
            error_flag = true
        }
        else
        {
            default_library = device.makeDefaultLibrary()
            command_queue = device.makeCommandQueue()
            let kernel_function = default_library.makeFunction(name: model.shader) // grabs
            do {
              let pipeline_state = try device.makeComputePipelineState(function: kernel_function!) // there was a completionHandler, but 'nil' no work for it!
            }
            catch {
              print("Simulate/setUpMetal/makeComputePipelineState failed!")
            }
            setUpTexture()
            run()
        }
    }
    
    //
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        image_view.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(image_view)
        setUpMetal()
    }
}
