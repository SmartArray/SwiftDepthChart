//
//  DepthChartDelegate.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 19.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import UIKit

public protocol DepthChartDelegate: class {
    func formatXLabel(for value: Double) -> String
    func formatYLabel(for value: Double) -> String
    func showPointer(at price: Price, amount: Amount, x: CGFloat, y: CGFloat)
    func hidePointer()
}

extension DepthChartDelegate {
    public func formatXLabel(for value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf.string(from: NSNumber(value: value))!
    }
    
    public func formatYLabel(for value: Double) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 3
        nf.maximumFractionDigits = 3
        return nf.string(from: NSNumber(value: value))!
    }
    
    public func showPointer(at price: Price, amount: Amount, x: CGFloat, y: CGFloat) {}
    public func hidePointer() {}
}
