//
//  DepthChartStyle.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 20.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import UIKit

open class DepthChartStyle {
    public var backgroundColor: UIColor = UIColor.white
    public var xAxisFont: UIFont = UIFont.systemFont(ofSize: 13)
    public var yAxisFont: UIFont = UIFont.systemFont(ofSize: 13)
    public var xAxisLabelSpacing: Double = 30.0
    public var yAxisLabelSpacing: Double = 30.0
    public var xAxisTextColor: UIColor = UIColor.gray
    public var yAxisTextColor: UIColor = UIColor.gray
    public var xGridColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    public var yGridColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    public var axisColor: UIColor = UIColor.gray.withAlphaComponent(1.0)
    
    public var gridStrokeWidth: Double = 1.0
    public var axisStrokeWidth: Double = 1.0
    public var strokeWidth: Double = 1.0
    
    public init() {
        
    }
    
    public static var `default`: DepthChartStyle {
        return DepthChartStyle()
    }
}
