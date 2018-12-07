//
//  RedPointView.swift
//  PanDirectionViewDemo
//
//  Created by Skyer God on 2018/12/6.
//  Copyright © 2018 zhangtian. All rights reserved.
//

import UIKit

class RedPointView: UIView {
 
    private override init(frame: CGRect) {
        super.init(frame:frame)
        
    }
    
    convenience init(frame:CGRect = .zero, count:Int = 1) {
        self.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
