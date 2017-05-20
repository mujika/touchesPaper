//
//  DrawLineView.swift
//  TouchPeper
//
//  Created by 新村彰啓 on 2017/01/06.
//  Copyright © 2017年 新村彰啓. All rights reserved.
//

import UIKit

@objc protocol LineMoveDelegate {
    
    func stopScroll()
    func startScroll()
    //func pinchView(sender:UIPinchGestureRecognizer)
    
}

class DrawLineView: UIView{
    
    var deledgate:LineMoveDelegate?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   
    var firstPoint:CGPoint!  //開始ポイント
    var lastPoint: CGPoint!  //終着ポイント
    
    
    /* init(firstPoint:CGPoint, lastPoint:CGPoint){
        self.firstPoint = firstPoint
        self.lastPoint = lastPoint
        
    }*/
    
    /*
     表示を更新する必要が生ずると自動的に呼び出される.
     */
    override func draw(_ rect: CGRect) {
        
        
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        self.isMultipleTouchEnabled = true
        
        
        // BezierPathを生成.
        let myLine: UIBezierPath = UIBezierPath()
        
        // 線の色を青色に設定.
        UIColor.red.setStroke()
        
        
        // 始点を設定.
        myLine.move(to: self.firstPoint)
        
        // 終点を設定.
        myLine.addLine(to: self.lastPoint)
        
        
        // 線の太さを設定.
        myLine.lineWidth = 2.0
        myLine.lineCapStyle = CGLineCap.round
        
        //self.addGestureRecognizer(pinchGesture)
        
        // 描画.
        myLine.stroke()
        
       
    }
    
    //ピンチジェスチャー実装
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.deledgate?.stopScroll()
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.deledgate?.stopScroll()
        superview?.touchesMoved(touches, with: event)
        self.layer.borderColor = UIColor.blue.cgColor
        
           // self.deledgate?.pinchView(sender:pinchGesture)
            
        
        
        let touch = touches.first! as UITouch
        
        let dx = touch.location(in: self.superview).x - touch.previousLocation(in: self.superview).x
        let dy = touch.location(in: self.superview).y - touch.previousLocation(in: self.superview).y

        self.frame.origin.x += dx
        self.frame.origin.y += dy
        
        self.deledgate?.stopScroll()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.deledgate?.startScroll()
        layer.borderColor = UIColor.clear.cgColor
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.deledgate?.startScroll()
        layer.borderColor = UIColor.clear.cgColor
    }

}
