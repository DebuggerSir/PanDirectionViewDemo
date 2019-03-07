//
//  ZTPanDirectionView.swift
//  PanDirectionViewDemo
//
//  Created by Skyer God on 2018/12/3.
//  Copyright © 2018 zhangtian. All rights reserved.
//

import UIKit
import MediaPlayer

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
    /// 避免手指开屏幕后抖动造成的影响
    private let offsetPix:CGFloat = 0
    private (set) var direction:PanDirecrion = .none
    private (set) var panDirection:PanDirecrion = .none {
        didSet {
            if panDirection != oldValue{
                oldMovePoint = movePoint
            }
        }
    }
    
    private (set) var absolutionOffset:CGPoint = .zero
    private (set) var oldMovePoint:CGPoint = .zero
    private let thresholdValue:CGFloat = 10
    private var startPoint: CGPoint = .zero
    private var movePoint: CGPoint = .zero
    private var endPoint: CGPoint = .zero
    private var panPoint:CGPoint = .zero {
        didSet {
            if direction == .left || direction == .right {
                if panPoint.x < oldValue.x - offsetPix {
                    panDirection = .left
                } else if panPoint.x > oldValue.x + offsetPix{
                    panDirection = .right
                }
            } else if direction == .up || direction == .down {
                if panPoint.y < oldValue.y - offsetPix{
                    panDirection = .up
                } else if panPoint.y > oldValue.y + offsetPix{
                    panDirection = .down
                }
            }
        }
    }
    var sliderView = UISlider()
    var volumeView = MPVolumeView()
    /// state：枚举值- 触摸的状态
    /// direction：滑动方向
    /// pointMeta：state对应的point值
    /// panPoint：拖动位移
    /// complete：是否拖动结束
    var touchesActions:((_ state:TouchStatus, _ direction:PanDirecrion, _ pointMeta:(begin:CGPoint, move:CGPoint, end:CGPoint, panPoint:CGPoint), _ complete:Bool)->())? = nil
    var touchesSingleTapAction:((_ touchePoint:CGPoint)->())? = nil
    var touchesContinueTapAction:((_ touchePoint:CGPoint)->())? = nil
    
    private var task:GCDTask? = nil
    private var lastTapTime:TimeInterval = 0
    private var lastTapPoint:CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playOrPause(tapGestrue:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        
        sliderView = UISlider()
        volumeView = MPVolumeView()
        volumeView.sizeToFit()
        for view in volumeView.subviews {
            if view.classForCoder.description() == "MPVolumeSlider" {
                sliderView = view as! UISlider
            }
        }
        volumeView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 9 / 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func playOrPause(tapGestrue:UITapGestureRecognizer) {
        //获取点击坐标，用于设置爱心显示位置
        let point = tapGestrue.location(in: self)
        //获取当前时间
        let time = CFAbsoluteTimeGetCurrent()//CACurrentMediaTime()
        //判断当前点击时间与上次点击时间的时间间隔
        if (time - lastTapTime) > 0.3 {
            //推迟0.3秒执行单击方法
            self.task = delayTask(0.3) {[weak self] in
                guard let `self` = self else {return}
                self.touchesSingleTapAction?(self.lastTapPoint)
            }
        } else {
            //取消执行单击方法
            self.cancelTask(self.task)
            
            //执行连击显示爱心的方法
            self.touchesContinueTapAction?(self.lastTapPoint)
        }
        //更新上一次点击位置
        lastTapPoint = point
        //更新上一次点击时间
        lastTapTime = time
    }
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        guard let startPoint = point else {return}
        //记录开始点击位置
        self.startPoint = startPoint
        self.direction = .none
        self.panDirection = .none
        self.panPoint = .zero
        self.endPoint = .zero
        
        absolutionOffset = .zero
        oldMovePoint = .zero
        panPoint = .zero
        touchesActions?(.begin, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), false)
    }
    
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        guard let endPoint = point else {return}
        self.endPoint = endPoint
        touchesActions?(.end, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), true)
    }
    
    internal override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        //        if direction == .none { return }
        
        
        absolutionOffset = CGPoint(x: movePoint.x - oldMovePoint.x, y: movePoint.y - oldMovePoint.y)
        touchesActions?(.move, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), false)
    }
    
    internal override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        
        guard let cancelPoint = point else {return}
        //计算滑动的距离
        
        panPoint = CGPoint(x: cancelPoint.x - startPoint.x, y: cancelPoint.y - startPoint.y)
        absolutionOffset = CGPoint(x: cancelPoint.x - oldMovePoint.x, y: cancelPoint.y - oldMovePoint.y)
        touchesActions?(.cancel, direction, (self.startPoint, self.movePoint, self.endPoint, panPoint), true)
    }
    
    //如果发现添加后，所在控制器不走这里的ToucheDelegate方法，则实现此方法
    //    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        return false
    //    }
}

//如果此view全屏且所属控制器需要侧滑返回，或底s上滑返回，则需要在 所在控制器实现UIGestureDelegate的以下代理方法
//func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//    let point = touch.location(in: gestureRecognizer.view)
//    if CGRect(x: 20, y: 0, width: Constants.SCREEN_WIDTH - 20, height: Constants.SCREEN_HEIGHT - 20).contains(point) {
//        return false
//    }
//    return true
//}



extension ZTPanDirectionView {
    typealias GCDTask = (_ cancel: Bool) -> Void
    
    /// block延迟可取消任务
    ///
    /// - Parameters:
    ///   - time: 延迟时间
    ///   - task: 任务
    /// - Returns: 任务
    func delayTask(_ time: TimeInterval, task: @escaping () -> ()) -> GCDTask? {
        
        func dispatch_later(block: @escaping () -> ()) {
            let t = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (() -> Void)? = task
        var result: GCDTask?
        
        let delayedClosure: GCDTask = { cancel in
            
            if let internalClosure = closure {
                if (cancel == false) {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result
    }
    
    /// 取消任务
    ///
    /// - Parameter task: 将要取消的任务
    func cancelTask(_ task: GCDTask?) {
        task?(true)
    }
}
