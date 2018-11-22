//
//  ExampleViewController.swift
//  OrderDepthChart
//
//  Created by Julian Jäger on 19.11.18.
//  Copyright © 2018 Yoshi Jäger. All rights reserved.
//

import UIKit

let sampleOrderbookAsks = [[0.00000270,36210.3031261],[0.00000271,53725.82027941],[0.00000272,152532.53657004],[0.00000273,213965.82974235],[0.00000274,88661.82155611],[0.00000275,75861.77435155],[0.00000276,51728.70257559],[0.00000277,56741.1625427],[0.00000278,64367.3078315],[0.00000279,83930.2696271],[0.00000280,26969.09080291],[0.00000281,75499.40206802],[0.00000282,3001.06486558],[0.00000283,2228.07579559],[0.00000284,110.26633366],[0.00000285,38800.22532384],[0.00000286,22949.4108565],[0.00000287,11092.63082437],[0.00000288,5032.84595717],[0.00000289,36766.47555973]]
let sampleOrderbookBids = [[0.00000269,40.79109285],[0.00000268,529.69029851],[0.00000267,7593.42601897],[0.00000266,32187.98465655],[0.00000265,37847.42112083],[0.00000264,81646.33700038],[0.00000263,33121.84410649],[0.00000262,209673.34378684],[0.00000261,199310.08853613],[0.00000260,45211.53076923],[0.00000259,665942.29577133],[0.00000258,16806.75907916],[0.00000257,58711.02655269],[0.00000256,421226.7633053],[0.00000255,508063.29803922],[0.00000254,3189.57624967],[0.00000253,6995.77470356],[0.00000252,37029.82449881],[0.00000251,282825.4820717],[0.00000250,141663.86025289]]

class ExampleViewController: UIViewController {
    private let depthChart = DepthChart()
    private let segmentedX = UISegmentedControl(items: ["top", "bottom", "hidden"])
    private let segmentedY = UISegmentedControl(items: ["left", "right", "hidden"])
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // styling
        view.backgroundColor = UIColor.white
        
        // subviews
        view.addSubview(depthChart)
        depthChart.translatesAutoresizingMaskIntoConstraints = false
        
        // constraints
        depthChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        depthChart.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        depthChart.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        depthChart.heightAnchor.constraint(equalToConstant: 240).isActive = true

        // data
        sampleOrderbookBids.forEach { dataset in
            depthChart.data.addBuyOrder(with: dataset[0], amount: dataset[1])
        }
        
        sampleOrderbookAsks.forEach { dataset in
            depthChart.data.addSellOrder(with: dataset[0], amount: dataset[1])
        }
        
        // delegate
        depthChart.delegate = self
        
        // debug controls
        view.addSubview(segmentedX)
        segmentedX.translatesAutoresizingMaskIntoConstraints = false
        segmentedX.topAnchor.constraint(equalTo: depthChart.bottomAnchor, constant: 30).isActive = true
        segmentedX.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        view.addSubview(segmentedY)
        segmentedY.translatesAutoresizingMaskIntoConstraints = false
        segmentedY.topAnchor.constraint(equalTo: segmentedX.bottomAnchor, constant: 10).isActive = true
        segmentedY.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        segmentedX.addTarget(self, action: #selector(x), for: UIControl.Event.valueChanged)
        segmentedY.addTarget(self, action: #selector(y), for: UIControl.Event.valueChanged)
        segmentedX.selectedSegmentIndex = 0
        segmentedY.selectedSegmentIndex = 0
    }
    
    @objc private func x() {
        switch segmentedX.selectedSegmentIndex {
        case 0:
            depthChart.xAxisPosition = .top
        case 1:
            depthChart.xAxisPosition = .bottom
        case 2:
            depthChart.xAxisPosition = .hidden
        default:
            break
        }
        
        depthChart.update()
    }
    @objc private func y() {
        switch segmentedY.selectedSegmentIndex {
        case 0:
            depthChart.yAxisPosition = .left
        case 1:
            depthChart.yAxisPosition = .right
        case 2:
            depthChart.yAxisPosition = .hidden
        default:
            break
        }
        
        depthChart.update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExampleViewController: DepthChartDelegate {
    func formatXLabel(for value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.minimumFractionDigits = 8
        nf.maximumFractionDigits = 8
        return nf.string(from: NSNumber(value: value))!
    }
}
