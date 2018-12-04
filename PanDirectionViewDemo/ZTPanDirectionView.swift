//
//  ZTPanDirectionView.swift
//  PanDirectionViewDemo
//
//  Created by Skyer God on 2018/12/3.
//  Copyright © 2018 zhangtian. All rights reserved.
//

import UIKit

class ZTPanDirectionView: UIView {
    enum PanDirecrion:Int {
        case left = 0
        case right
        case down
        case up
        case none
    }
    enum TouchStatus:Int {
        case begin = 0
        case move
        case end
        case cancel
    }
    
    var direction:PanDirecrion = .none
    fileprivate let thresholdValue:CGFloat = 20
    fileprivate var startPoint: CGPoint = .zero
    fileprivate var movePoint: CGPoint = .zero
    fileprivate var endPoint: CGPoint = .zero
    fileprivate var panPoint:CGPoint = .zero
    
    /// state：枚举值- 触摸的状态
    /// direction：滑动方向
    /// pointMeta：state对应的point值
    /// panPoint：拖动位移
    /// complete：是否拖动结束
    var touchesActions:((_ state:TouchStatus, _ direction:PanDirecrion, _ pointMeta:(begin:CGPoint, move:CGPoint, end:CGPoint, panPoint:CGPoint), _ complete:Bool)->())? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        guard let startPoint = point else {return}
        //记录开始点击位置
        self.startPoint = startPoint
        self.direction = .none
        
        panPoint = .zero
        touchesActions?(.begin, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        guard let endPoint = point else {return}
        self.endPoint = endPoint
        touchesActions?(.end, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        
        guard let movePoint = point else {return}
        self.movePoint = movePoint
        //计算滑动的距离
        panPoint = CGPoint(x: movePoint.x - startPoint.x, y: movePoint.y - startPoint.y)
        if direction == .none {
            if panPoint.x <= -thresholdValue {
                direction = .left
            } else if panPoint.x >= thresholdValue {
                direction = .right
            } else if panPoint.y <= -thresholdValue {
                direction = .up
            } else if panPoint.y >= thresholdValue {
                direction = .down
            }
        }
        if direction == .none { return }
        
        touchesActions?(.move, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), false)
    }
    
}
