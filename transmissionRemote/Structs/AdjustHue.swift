//
//  adjustHy.swift
//  Transmission Remote
//
//  Created by Derek Oakley on 02/09/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import AppKit

struct AdjustHue {
    static let Green = CIFilter(name: "CIHueAdjust", withInputParameters: ["inputAngle": NSNumber(value: 4)])!
}
