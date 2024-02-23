//
//  Shaders.metal
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 18/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//
// todo: https://code.google.com/p/reaction-diffusion/source/browse/trunk/Ready/Patterns/Yang2006/jumping.vti
// todo: https://www.youtube.com/watch?v=JhipxYrgNvI


#include <metal_stdlib>
using namespace metal;

kernel void grayScottShader(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant float &Du [[buffer(0)]],
                            constant float &Dv [[buffer(1)]],
                            constant float &F [[buffer(2)]],
                            constant float &K [[buffer(3)]],
                            uint2 gid [[thread_position_in_grid]])
{
    const uint2 northIndex(gid.x, gid.y - 1);
    const uint2 southIndex(gid.x, gid.y + 1);
    const uint2 westIndex(gid.x - 1, gid.y);
    const uint2 eastIndex(gid.x + 1, gid.y);

    const float2 northColor = inTexture.read(northIndex).rb;
    const float2 southColor = inTexture.read(southIndex).rb;
    const float2 westColor = inTexture.read(westIndex).rb;
    const float2 eastColor = inTexture.read(eastIndex).rb;
 
    const float2 thisColor = inTexture.read(gid).rb;

    const float2 laplacian = (northColor.rg + southColor.rg + westColor.rg + eastColor.rg) - (4.0f * thisColor.rg);
    
    const float reactionRate = thisColor.r * thisColor.g * thisColor.g;
    
    float u = thisColor.r + (Du * laplacian.r) - reactionRate + F * (1.0f - thisColor.r);
    float v = thisColor.g + (Dv * laplacian.g) + reactionRate - (F + K) * thisColor.g;

    
    const float4 outColor(u, u, v, 1);
    outTexture.write(outColor, gid);
}
