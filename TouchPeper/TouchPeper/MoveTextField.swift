//
//  MoveTextField.swift
//  TouchPeper
//
//  Created by 新村彰啓 on 2016/12/27.
//  Copyright © 2016年 新村彰啓. All rights reserved.
//

import UIKit

class MoveTextField: UITextField {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.superview?.bringSubview(toFront: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        
        let dx = touch.location(in: self.superview).x - touch.previousLocation(in: self.superview).x
        let dy = touch.location(in: self.superview).y - touch.previousLocation(in: self.superview).y

        
        //ここ書きかけ
        self.frame.origin.x += dx
        self.frame.origin.y += dy
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("エンド感知！")
    }
    
}


