//
//  Bundle+Extension.swift
//  SSCustomPullToRefresh
//
//  Created by Matheus Gois on 04/12/21.
//

import Foundation

public extension UIColor {
    var redValue: Double { return Double(CIColor(color: self).red) }
    var greenValue: Double { return Double(CIColor(color: self).green) }
    var blueValue: Double { return Double(CIColor(color: self).blue) }
    var alphaValue: Double { return Double(CIColor(color: self).alpha) }
}
