//
//  ViewController.swift
//  PanDirectionViewDemo
//
//  Created by Skyer God on 2018/12/3.
//  Copyright © 2018 zhangtian. All rights reserved.
//

import UIKit
import MediaPlayer
class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var sliderView = UISlider()
        let volumeView = MPVolumeView()
        volumeView.sizeToFit()
        for view in volumeView.subviews {
            if view.classForCoder.description() == "MPVolumeSlider" {
                sliderView = view as! UISlider
            }
        }
        volumeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height * 9 / 16)
        
        let panView = ZTPanDirectionView()
        panView.isUserInteractionEnabled = true
        panView.frame = view.bounds
        view.backgroundColor = .cyan
        view.addSubview(panView)
        
        let button = UIButton(type: .system)
        button.sizeToFit()
        button.setTitle("👀", for: .normal)
        button.setTitle("👀😭", for: .highlighted)
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 50, width: 100, height: 50)
        
        
        var startBrightness = UIScreen.main.brightness
        var startVolume = sliderView.value
        panView.touchesActions = { (state, direction, pointMata, complete) in
            if state == .begin {
                startBrightness = UIScreen.main.brightness
                startVolume = sliderView.value
            }
            switch direction {
            case .up, .down:
                if pointMata.begin.x > self.view.frame.size.width / 2{
                    //控制亮度
                    UIScreen.main.brightness = startBrightness - pointMata.panPoint.y / 300
                } else {
                    //控制音量
                    sliderView.setValue(startVolume - Float(pointMata.panPoint.y / 300), animated: true)
                }
            case .left, .right:
                //控制音量
                sliderView.setValue(startVolume + Float(pointMata.panPoint.x / 200), animated: true)
            default:
                break
            }
        }
    }
    
    @objc func buttonAction(){
        print("buttton  ")
    }
    
}
