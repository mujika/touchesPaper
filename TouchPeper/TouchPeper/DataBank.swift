//
//  DataBank.swift
//  TouchPeper
//
//  Created by 新村彰啓 on 2017/04/27.
//  Copyright © 2017年 新村彰啓. All rights reserved.
//

import UIKit
import RealmSwift



class RedLine: Object {
    
    dynamic var redLineFirstPointX: Float = 0
    dynamic var redLineFirstPointY: Float = 0
    dynamic var redLineLastPointX: Float = 0
    dynamic var redLineLastPointY: Float = 0
    
}

class FrameData: RedLine {
    
    dynamic var redLineFrameWidth: Float = 0
    dynamic var redLineFrameHeight: Float = 0
    dynamic var redLineFramePointX: Float = 0
    dynamic var redLineFramePointY: Float = 0
}
