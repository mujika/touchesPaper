//
//  BackPanelScroll.swift
//  TouchPeper
//
//  Created by 新村彰啓 on 2016/11/29.
//  Copyright © 2016年 新村彰啓. All rights reserved.
//

import UIKit
import CoreFoundation

class BackPanelScroll: UIScrollView {
    
    var moveArray:[CGPoint] = []
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
        
        
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesMoved(touches, with: event)
   
        /*let mou = event?.allTouches
        
        
        print("毛頭\(mou)")
        for touch: AnyObject in touches {
            
            // タッチされた場所の座標を取得.
            moveArray += [touch.location(in: self)]
            
            //
            for i in 0..<moveArray.count{
            print("てれ\(i)\(moveArray[i])")
    
            }
            
        }
 
        moveArray = []     */
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesCancelled(touches, with: event)
    }
}
