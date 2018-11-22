//
//  DepthChart.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 19.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import UIKit
import simd

open class DepthChart: UIView, DepthChartDelegate {
    
    private let yStackView = UIStackView()
    private let xStackView = UIStackView()
    
    public enum YAxisPosition {
        case hidden
        case left
        case right
    }
    
    public enum XAxisPosition {
        case hidden
        case top
        case bottom
    }
    
    public var drawingEnabled: Bool = false
    
    public var xAxisPosition: XAxisPosition = .top
    public var yAxisPosition: YAxisPosition = .left
    
    public var xGridVisible: Bool = true
    public var yGridVisible: Bool = true
    
    public var style = DepthChartStyle.default { didSet { updateStyle() } }
    public var data = DepthChartDataset()
    
    public weak var delegate: DepthChartDelegate!
    
    // MARK: Private
    private var deltaY: Double = 0.0
    private var deltaX: Double = 0.0
    private var xHeight: Double = 0.0
    private var yWidth: Double = 0.0
    
    private var offsetX: Double = 0.0
    private var offsetY: Double = 0.0
    
    private var drawRect: CGRect = .zero
    private var drawWidth: Double = 0.0
    private var drawHeight: Double = 0.0
    
    private var subtractX: Double = 0.0
    private var subtractY: Double = 0.0
    
    private var scaleX: Double = 0.0
    private var scaleY: Double = 0.0
    
    public var cursorPos: CGPoint? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        
        updateStyle()
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
    }
    
    @objc private func pan(_ event: UIPanGestureRecognizer) {
        var loc = event.location(in: self)
        loc.x -= CGFloat(offsetX)
        loc.y -= CGFloat(offsetY)
        
        // satuate
//        if loc.x < drawRect.minX { loc.x = drawRect.minX }
//        if loc.x > drawRect.maxX { loc.x = drawRect.maxX }
        
        if event.state == .began {
            
        } else if event.state == .changed {
            let price = priceOf(x: loc.x)
            let nearestPrice = data.nearestPrice(using: price)
            let amount = data.accumulatedAmountFor(price: nearestPrice)
            
            let mappedCoordinate = map(CGPoint(x: nearestPrice, y: amount))
            cursorPos = mappedCoordinate
            
            delegate.showPointer(at: nearestPrice, amount: amount, x: mappedCoordinate.x, y: mappedCoordinate.y)
        } else {
            cursorPos = nil
            delegate.hidePointer()
        }
        
        setNeedsDisplay()
    }
    
    open override func draw(_ rect: CGRect) {
        recalcInterface()
        
        if !drawingEnabled {
            return
        }
        
        drawGrid()
        drawData()
        drawContainerBorder()
        drawCursor()
    }
    
    private func drawGrid() {
        let middlePrice = data.getMiddle()
        let maxPrice = data.getMaxPrice()
        let minPrice = data.getMinPrice()
        
        // debug draw diagonal
//        let diag = UIBezierPath()
//        let c = CGPoint(x: minPrice, y: data.getMinAmount())
//        let d = CGPoint(x: maxPrice, y: data.getMaxAmount())
//        diag.move(to: map(c))
//        diag.addLine(to: map(d))
//        UIColor.green.set()
//        diag.stroke()
        
        // draw x grid
        // start from the middle (price = 0)
        if xGridVisible, xAxisPosition != .hidden {
            let xAxisPath = UIBezierPath()
            // missing: fromX, toX
            
            // label attributes
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: style.xAxisFont,
                NSAttributedString.Key.foregroundColor: style.xAxisTextColor,
                ]
            
            // we won't start from the very left, because we want to have equal distant grid lines,
            // starting from the middle price
            let mostLeftPrice = middlePrice.truncatingRemainder(dividingBy: deltaX / scaleX)
            
            // start from 0, goto bounds.height
            for i in stride(from: mostLeftPrice, to: maxPrice, by: deltaX / scaleX) {
                let from = map(CGPoint(x: i, y: data.getMinAmount()))
                let to = map(CGPoint(x: i, y: data.getMaxAmount()))
                
                // it needs to be within container
                if from.x < CGFloat(offsetX) { continue }
                
                xAxisPath.move(to: from)
                xAxisPath.addLine(to: to)
                
                // draw label
                let label = delegate.formatXLabel(for: Double(i)) as NSString
                let labelWidth = Double(label.size(withAttributes: attr).width)
                let labelOffset = xAxisPosition == .top ? 0 : drawHeight
                label.draw(at: CGPoint(x: mapX(Price(i)) - labelWidth / 2, y: labelOffset), withAttributes: attr)
            }
            
            // start from middle price (0), goto the very left
            //            for i in stride(from: middlePrice, to: minPrice, by: -deltaX / scaleX) {
            //                let from = map(CGPoint(x: i, y: data.getMinAmount()))
            //                let to = map(CGPoint(x: i, y: data.getMaxAmount()))
            //
            //                xAxisPath.move(to: from)
            //                xAxisPath.addLine(to: to)
            //
            //                // draw label
            //                let label = delegate.formatXLabel(for: Double(i)) as NSString
            //                let labelWidth = Double(label.size(withAttributes: attr).width)
            //                let labelOffset = xAxisPosition == .top ? 0 : drawHeight
            //                label.draw(at: CGPoint(x: mapX(Price(i)) - labelWidth / 2, y: labelOffset), withAttributes: attr)
            //            }
            
            style.xGridColor.set()
            xAxisPath.lineWidth = CGFloat(style.gridStrokeWidth)
            xAxisPath.stroke()
        }
        
        // draw y grid
        // start from the bottom
        if xGridVisible, yAxisPosition != .hidden {
            let yAxisPath = UIBezierPath()
            
            // we will not start from the very bottom, because there should already be a rect,
            // hence we add deltaY / scaleY (value step)
            let pFrom = CGPoint(x: minPrice, y: data.getMinAmount() + deltaY / scaleY)
            let pTo = CGPoint(x: maxPrice, y: data.getMaxAmount())
            
            // label attributes
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: style.yAxisFont,
                NSAttributedString.Key.foregroundColor: style.yAxisTextColor,
                ]
            
            // draw axis lines
            for i in stride(from: pFrom.y, to: pTo.y, by: CGFloat(deltaY / scaleY)) {
                let from = map(CGPoint(x: pFrom.x, y: i))
                let to = map(CGPoint(x: pTo.x, y: i))
                yAxisPath.move(to: from)
                yAxisPath.addLine(to: to)
                
                // draw label
                let label = delegate.formatYLabel(for: Double(i)) as NSString
                let labelHeight = Double(label.size(withAttributes: attr).height)
                let labelOffset = yAxisPosition == .left ? 0 : drawWidth
                label.draw(at: CGPoint(x: labelOffset, y: mapY(Amount(i)) - labelHeight / 2), withAttributes: attr)
            }
            
            style.yGridColor.set()
            yAxisPath.lineWidth = CGFloat(style.gridStrokeWidth)
            yAxisPath.stroke()
        }
    }
    
    private func drawData() {
        let minPrice = data.getMinPrice()
        let maxPrice = data.getMaxPrice()
        let minAmount = data.getMinAmount()
        
        // DRAW BUY
        
        let buyShape = UIBezierPath()
        
        let sortedBuy = data.accumulatedBuyOrders
        buyShape.move(to: map(CGPoint(x: sortedBuy[0].key, y: 0)))
        sortedBuy.forEach { dataset in
            buyShape.addLine(to: map(CGPoint(x: dataset.key, y: dataset.value)))
        }
        
        buyShape.addLine(to: map(CGPoint(x: minPrice, y: minAmount)))
        buyShape.close()
        UIColor.green.set()
        UIColor.green.withAlphaComponent(0.2).setFill()
        buyShape.lineWidth = CGFloat(style.strokeWidth)
        buyShape.stroke()
        buyShape.fill()
        
        // DRAW SELL
        
        let sellShape = UIBezierPath()
        
        let sortedSell = data.accumulatedSellOrders
        sellShape.move(to: map(CGPoint(x: sortedBuy[0].key, y: 0)))
        
        sortedSell.forEach { (dataset) in
            sellShape.addLine(to: map(CGPoint(x: dataset.key, y: dataset.value)))
        }
        
        sellShape.addLine(to: map(CGPoint(x: maxPrice, y: minAmount)))
        sellShape.close()
        UIColor.red.set()
        UIColor.red.withAlphaComponent(0.2).setFill()
        sellShape.lineWidth = CGFloat(style.strokeWidth)
        sellShape.stroke()
        sellShape.fill()
    }
    
    private func drawContainerBorder() {
        // draw border
        let containerRectPath = UIBezierPath(rect: CGRect(x: offsetX, y: offsetY, width: drawWidth, height: drawHeight))
        containerRectPath.lineWidth = CGFloat(style.axisStrokeWidth)
        style.axisColor.set()
        containerRectPath.stroke()
    }
    
    private func drawCursor() {
        if let cursor = cursorPos {
            let path = UIBezierPath(arcCenter: cursor, radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            UIColor.blue.setStroke()
            path.stroke()
        }
    }
    
    // maps value to drawing point within bounds
    // .----- offset + x * scaleX
    // -----. x * scaleX * (bounds.width - offset) / bounds.width
    // ------ scaleX * value
    private func mapX(_ val: Price) -> Double {
        return Double(map(CGPoint(x: CGFloat(val), y: 0)).x)
    }
    
    // maps amount (y-val) to drawing point within bounds
    private func mapY(_ val: Amount) -> Double {
        return Double(map(CGPoint(x: 0, y: CGFloat(val))).y)
    }
    
    // maps a value point (price - amount) to the available drawing area within bounds
    open func map(_ point: CGPoint) -> CGPoint {
        let y = Double(point.y) - data.getMinAmount()
        
        // scale
        let x = simd_double2(Double(point.x) - data.getMinPrice(), data.getMaxAmount() - y)
        let m = double2x2(rows: [
            simd_double2(Double(scaleX), 0),
            simd_double2(0, Double(scaleY)),
        ])
        let r = x * m
        
        // translate
        return CGPoint(x: r.x + offsetX, y: r.y + offsetY)
    }
    
    private func priceOf(x: CGFloat) -> Price {
        return Double(x) / scaleX + data.getMinPrice()
    }
    
    private func recalcInterface() {
        drawingEnabled = false
        guard data.hasData() else { return }
        
        if yAxisPosition == .hidden {
            yWidth = 0
            offsetX = 0
        } else {
            // the biggest label should be the max amount,
            // hence we calculate the label width according to the biggest amount
            let maxAmount = data.getMaxAmount()
            let yAxisLabel = delegate!.formatYLabel(for: maxAmount)
            let yAxisLabelAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: style.yAxisFont,
                NSAttributedString.Key.foregroundColor: style.yAxisTextColor
            ]
            
            // calculate size
            let yAxisLabelSize = (yAxisLabel as NSString).size(withAttributes: yAxisLabelAttributes)
            
            // export values regarding the yAxis
            deltaY = style.yAxisLabelSpacing + Double(yAxisLabelSize.height)
            yWidth = Double(yAxisLabelSize.width) + 15
            offsetX = yAxisPosition == .left ? yWidth : 0
        }
        
        if xAxisPosition == .hidden {
            xHeight = 0
            offsetY = 0
        } else {
            // the biggest label should be the max price,
            // hence we calculate the label height according to the biggest price
            let maxPrice = data.getMaxPrice()
            let xAxisLabel = delegate!.formatXLabel(for: maxPrice)
            let xAxisLabelAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: style.xAxisFont,
                NSAttributedString.Key.foregroundColor: style.xAxisTextColor
            ]
            
            // Calculate size
            let xAxisLabelSize = (xAxisLabel as NSString).size(withAttributes: xAxisLabelAttributes)
            
            // export values regarding the xAxis
            // deltaX = bounds.width / (xAxisLabelSize.width + style.xAxisLabelSpacing)
            deltaX = style.xAxisLabelSpacing + Double(xAxisLabelSize.width)
            xHeight = Double(xAxisLabelSize.height)
            offsetY = xAxisPosition == .top ? xHeight : 0
        }

        // calucalate the scale factors
        scaleX = (Double(bounds.width) - yWidth) / (data.getMaxPrice() - data.getMinPrice())
        scaleY = (Double(bounds.height) - xHeight) / (data.getMaxAmount() - data.getMinAmount())
        
        // subtract points from the calculated vector, note that y-values are mirrored
        subtractX = scaleX * data.getMinPrice()
        subtractY = -scaleY * data.getMinAmount()
        
        // drawing board size
        drawWidth = Double(bounds.width) - yWidth
        drawHeight = Double(bounds.height) - xHeight
        
        // rect for drawing
        drawRect = CGRect(x: offsetX, y: offsetY, width: drawWidth, height: drawHeight)
        
        drawingEnabled = true
    }
    
    private func clearInterface() {
        
    }
    
    private func updateStyle() {
        backgroundColor = style.backgroundColor
    }
    
    public func update() {
        setNeedsDisplay()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
