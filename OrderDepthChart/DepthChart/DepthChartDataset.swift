//
//  DepthChartDataset.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 19.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import Foundation

public typealias Price = Double
public typealias Amount = Double

open class DepthChartDataset {
    public var buyOrders: [Price: Amount] = [:] {
        didSet {
            needsRecalc = true
        }
    }
    public var sellOrders: [Price: Amount] = [:] {
        didSet {
            needsRecalc = true
        }
    }
    
    private var needsRecalc: Bool = true {
        didSet {
            // this will be very inefficient when adding elements...
            // Perhaps rather call recalc on every public function?
            recalc()
        }
    }
    
    public var sortedBuyOrders: Array<(key: Double, value: Double)> = []
    public var sortedSellOrders: Array<(key: Double, value: Double)> = []
    public var accumulatedBuyOrders: Array<(key: Double, value: Double)> = []
    public var accumulatedSellOrders: Array<(key: Double, value: Double)> = []
    
    public init() {
        
    }
    
    private func recalc() {
        if needsRecalc {
            sortedBuyOrders = buyOrders.sorted(by: { (a, b) -> Bool in
                return a.key > b.key
            })
            
            sortedSellOrders = sellOrders.sorted(by: { (a, b) -> Bool in
                return a.key < b.key
            })
            
            var accBuy: Amount = 0
            accumulatedBuyOrders = []
            sortedBuyOrders.forEach { dataset in
                accBuy += dataset.value
                accumulatedBuyOrders.append((key: dataset.key, value: accBuy))
            }
            
            var accSell: Amount = 0
            accumulatedSellOrders = []
            sortedSellOrders.forEach { dataset in
                accSell += dataset.value
                accumulatedSellOrders.append((key: dataset.key, value: accSell))
            }
            
            needsRecalc = false
        }
    }
    
    public func clear() {
        buyOrders = [:]
        sellOrders = [:]
        sortedBuyOrders = []
        sortedSellOrders = []
        accumulatedBuyOrders = []
        accumulatedSellOrders = []
    }
    
    public func nearestPrice(using price: Price) -> Price {
        let middle = getMiddle()
        if price < middle {
            // ToDo: use for loop
            return sortedBuyOrders.reduce(middle) { (res, dataset) -> Price in
                if price <= dataset.key {
                    return dataset.key
                } else {
                    return res
                }
            }
        } else {
            return sortedSellOrders.reduce(middle) { (res, dataset) -> Amount in
                if price >= dataset.key {
                    return dataset.key
                } else {
                    return res
                }
            }
        }
    }
    
    public func accumulatedAmountFor(price: Price) -> Amount {
        let middle = getMiddle()
        if price < middle {
            // buy
            return sortedBuyOrders.reduce(0) { (res, dataset) -> Amount in
                if price <= dataset.key {
                    return res + dataset.value
                } else {
                    return res
                }
            }
        } else {
            // sell
            return sortedSellOrders.reduce(0) { (res, dataset) -> Amount in
                if price >= dataset.key {
                    return res + dataset.value
                } else {
                    return res
                }
            }
        }
    }
    
    public func addBuyOrder(with price: Price, amount: Amount) {
        if let o = buyOrders[price] {
            buyOrders[price] = o + amount
        } else {
            buyOrders[price] = amount
        }
        
        needsRecalc = true
    }
    
    public func addSellOrder(with price: Price, amount: Amount) {
        if let o = sellOrders[price] {
            sellOrders[price] = o + amount
        } else {
            sellOrders[price] = amount
        }
        
        needsRecalc = true
    }
    
    // ToDo: create lazy var
    open func getMiddle() -> Price {
        return (getMaxPrice() - getMinPrice()) / 2 + getMinPrice()
    }
    
    // ToDo: create lazy var
    open func getMinPrice() -> Price {
        return sortedBuyOrders.last?.key ?? sortedSellOrders.first?.key ?? 0
    }
    
    // ToDo: create lazy var
    open func getMaxPrice() -> Price {
        return sortedSellOrders.last?.key ?? sortedBuyOrders.first?.key ?? 0
    }
    
    // ToDo: create lazy var
    open func getMaxAmount() -> Amount {
        return max(accumulatedBuyOrders.last?.value ?? 0, accumulatedSellOrders.last?.value ?? 0)
    }
    
    // ToDo: create lazy var
    open func getMinAmount() -> Amount {
        return Amount(0)
    }
    
    open func hasData() -> Bool {
        return sellOrders.count > 0 || buyOrders.count > 0
    }
}
