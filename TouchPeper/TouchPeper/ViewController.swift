//
//  ViewController.swift
//  TouchPeper
//
//  Created by 新村彰啓 on 2016/11/23.
//  Copyright © 2016年 新村彰啓. All rights reserved.
//

/*
gitAddres
 https://github.com/mujika/touchesPaper.git
 */



import UIKit
import CoreGraphics
import RealmSwift


class ViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, LineMoveDelegate{
    
    
    private var textField:MoveTextField!
    private var redLine:DrawLineView!
    var touchPoint:CGPoint!
    let tWidth: CGFloat = 200
    let tHeight: CGFloat = 30
    var backPanelScrollWhite:BackPanelScroll = BackPanelScroll()
    var backPanelWhite:BackPanel = BackPanel()
    let plusWidth:CGFloat = 1800    //backPanelScrollWhite
    let plusHeight:CGFloat = 3600   //縦横
    var lineArray:[DrawLineView?] = [DrawLineView()]
    let frameAjust:CGFloat = 50.0 //フレームを調節する値（フレームよりラインがどれだけ内側に入るか）
    var lineNumber:Int = 0
    var realm = try! Realm()
    var realm2 = try! Realm()
    
    //var lineData:[RedLine]!
    var frameData:[FrameData]!
    var redLineFile: String!
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backPanelScrollWhite.isMultipleTouchEnabled = true
        
        //展開するUIViewの面積
        let panelWidth = self.view.frame.size.width + plusWidth
        let panelHeight = self.view.frame.size.height + plusHeight
        
        self.backPanelScrollWhite = BackPanelScroll(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        )
        
        self.backPanelScrollWhite.contentSize = CGSize(width: panelWidth, height: panelHeight)
        self.backPanelScrollWhite.isScrollEnabled = true
        self.backPanelScrollWhite.delegate = self
       
        //zoom
        self.backPanelScrollWhite.minimumZoomScale = 0.4
        self.backPanelScrollWhite.maximumZoomScale = 2
        
        self.backPanelScrollWhite.showsHorizontalScrollIndicator = true
        self.backPanelScrollWhite.showsVerticalScrollIndicator = true
        self.backPanelScrollWhite.isUserInteractionEnabled = true
        
        self.view.addSubview(backPanelScrollWhite)

        self.backPanelWhite = BackPanel(frame:CGRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
        self.backPanelScrollWhite.addSubview(backPanelWhite)
       
        
        
        //ダブルタップ実装
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDouble(sender:)))
        doubleTap.numberOfTapsRequired = 2                     //タップ回数
        doubleTap.numberOfTouchesRequired = 2                  //タップ指数（この本数出ないと反応しない）
        self.view.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapSingle(sender:)))  //Swift3
        singleTap.numberOfTapsRequired = 1
        //singleTap.numberOfTouchesRequired = 2  //こう書くと2本指じゃないとタップに反応しない
        
        //これを書かないとダブルタップ時にもシングルタップのアクションも実行される
        singleTap.require(toFail: doubleTap)  //Swift3
        
        self.view.addGestureRecognizer(singleTap)
        
        //readLine()
        let readButton = UIButton(type: .system)
        readButton.setTitle("読み込み", for: .normal)
        readButton.addTarget(self, action: #selector(self.showTextInputAlertRead), for: .touchUpInside)
        readButton.sizeToFit()
        readButton.center = CGPoint(x: 100, y: 100)
        self.view.addSubview(readButton)
        
        
        let writeButton = UIButton(type: .system)
        writeButton.setTitle("書き込み", for: .normal)
        writeButton.addTarget(self, action: #selector(self.showTextInputAlertWrite), for: .touchUpInside)
        writeButton.sizeToFit()
        writeButton.center = CGPoint(x: 200, y: 100)
        self.view.addSubview(writeButton)
        
       
        
           }
    
   
    
    //データを読み込み描画する
    func readLine() {
        let redLineData = realm.objects(FrameData.self)
        print("シュッシュー\(redLineData)")
        for redData in redLineData {
            if frameData == nil {
                frameData = [redData]
            } else {
                frameData.append(redData)
            }
            
        }
        
        if frameData != nil {
            print("ショショ\(frameData)")
            for num in frameData {
                redLine = DrawLineView(frame: CGRect(x: CGFloat(num.redLineFramePointX), y: CGFloat(num.redLineFramePointY), width:CGFloat(num.redLineFrameWidth), height:CGFloat(num.redLineFrameHeight)))
                
                lineArray += [redLine]
                
                print("れいれいれいれい！\(lineArray)")
                redLine.backgroundColor = UIColor.clear
                redLine.isUserInteractionEnabled = true
                redLine.isMultipleTouchEnabled = true
                self.redLine.layer.borderColor = UIColor.clear.cgColor
                
                redLine.firstPoint = CGPoint(x: CGFloat(num.redLineFirstPointX), y: CGFloat(num.redLineFirstPointY))
                redLine.lastPoint = CGPoint(x:CGFloat(num.redLineLastPointX), y: CGFloat(num.redLineLastPointY))
                redLine.deledgate = self
                //ピンチジェスチャーをredLineに設定
                let pinchGesture:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(sender:)))
                self.redLine.addGestureRecognizer(pinchGesture)
                
                self.backPanelWhite.addSubview(redLine)
            }
            
        }

    }
    //realmのファイル名を指定して描画
    func readRedLineDraw() {
        var config = Realm.Configuration()
        print("前\(String(describing: self.realm.configuration.fileURL))")
        
        // 保存先のディレクトリはデフォルトのままで、ファイル名をユーザー名を使うように変更します
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(redLineFile + ".realm")
        realm = try! Realm(configuration: config)
        print("後\(String(describing: realm.configuration.fileURL))")
        readLine()
    }
    
    //読み込みアラートの表示と設定
    func showTextInputAlertRead() {
        // テキストフィールド付きアラート表示
        
        let alert = UIAlertController(title: "読み込み", message: "メッセージ", preferredStyle: .alert)
        
        // OKボタンの設定
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            // OKを押した時入力されていたテキストを表示
            if let textFields = alert.textFields {
                
                // アラートに含まれるすべてのテキストフィールドを調べる
                for textField in textFields {
                    print(textField.text!)
                    self.redLineFile = textField.text!
                    self.readRedLineDraw()
                }
            }
        })
        alert.addAction(okAction)
        
        // キャンセルボタンの設定
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // テキストフィールドを追加
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "テキスト"
        })
        
        // 複数追加したいならその数だけ書く
        // alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
        //     textField.placeholder = "テキスト"
        // })
        
        alert.view.setNeedsLayout() // シミュレータの種類によっては、これがないと警告が発生
        
        // アラートを画面に表示
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //書き込みアラートの表示と設定
    func showTextInputAlertWrite() {
        // テキストフィールド付きアラート表示
        
        let alert = UIAlertController(title: "書き込み", message: "メッセージ", preferredStyle: .alert)
        
        // OKボタンの設定
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            // OKを押した時入力されていたテキストを表示
            if let textFields = alert.textFields {
                
                // アラートに含まれるすべてのテキストフィールドを調べる
                for textField in textFields {
                    print(textField.text!)
                    self.redLineFile = textField.text!
                    
                    /*
                    var config = Realm.Configuration()
                    print("書き前\(String(describing: self.realm.configuration.fileURL))")
                    
                    // 保存先のディレクトリはデフォルトのままで、ファイル名をユーザー名を使うように変更します
                    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(self.redLineFile + ".realm")
                    self.realm = try! Realm(configuration: config)
                    */
                    
                    //ファイルを別名でコピーして保存
                    do {
                        let fileURL = self.realm.configuration.fileURL!.deletingLastPathComponent().appendingPathComponent(self.redLineFile + ".realm")
                        try self.realm.writeCopy(toFile: fileURL)
                        
                    } catch {
                        
                    }
                    
                    print("書き後\(String(describing: self.realm.configuration.fileURL))")
                    
                    
                }
            }
        })
        alert.addAction(okAction)
        
        // キャンセルボタンの設定
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // テキストフィールドを追加
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "テキスト"
        })
        
        // 複数追加したいならその数だけ書く
        // alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
        //     textField.placeholder = "テキスト"
        // })
        
        alert.view.setNeedsLayout() // シミュレータの種類によっては、これがないと警告が発生
        
        // アラートを画面に表示
        self.present(alert, animated: true, completion: nil)
        
    }

    
         //シングルタップでUITextFieldを生成
    func tapSingle(sender: UITapGestureRecognizer) {
        print("single")
        //readRedLineDraw()
        
        //キーボード以外をタッチするとキーボードが下がる
        self.view.endEditing(true)
        
       
        
        let youX:CGFloat = sender.location(in: self.backPanelWhite).x
        let youY:CGFloat = sender.location(in: self.backPanelWhite).y
        
        if self.backPanelScrollWhite.isScrollEnabled == true {
            
            // テキスト・フィールドを生成
            textField = MoveTextField(frame: CGRect(x: youX, y: youY, width: 220, height: 35))
            
            textField.isUserInteractionEnabled = true
            textField.textColor = UIColor.blue          // テキストの色
            textField.placeholder = "  入力プリーズ"         // ブランク時の説明テキスト
            textField.backgroundColor = UIColor.clear    // 背景色
            textField.borderStyle = .none                // ボーダー
            textField.layer.cornerRadius = 17.5
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth  = 1
            textField.layer.masksToBounds = true
            //入力位置の変更　左に余白を入れる
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            paddingView.backgroundColor = UIColor.clear
            textField.leftView = paddingView
            textField.leftViewMode = UITextFieldViewMode.always
            textField.font = UIFont.systemFont(ofSize: CGFloat(18))
            //textField.keyboardType = UIKeyboardType.asciiCapable　　// キーボードの種類
            textField.returnKeyType = UIReturnKeyType.done   // キーボードのリターンキーの種類
            textField.clearButtonMode = .whileEditing
            textField.adjustsFontSizeToFitWidth = true
            textField.becomeFirstResponder()                 //最初からUITextField を選択状態にする
            textField.delegate = self
            
            self.backPanelWhite.addSubview(textField)       // テキスト・フィールドを画面に追加
            
            
        }
        
        
        /*UIView.animate(withDuration: 0.06,
                       // アニメーション中の処理.
            animations: { () -> Void in
                // 縮小用アフィン行列を作成する.
                self.textField.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        { (Bool) -> Void in
        }
        */
        

        
        
    }
   
   
    
    
    
    
    /// ダブルタップで線を作成
    func tapDouble(sender: UITapGestureRecognizer) {
        print("double")
        
        
        /*var config = Realm.Configuration()
        print("前\(String(describing: realm.configuration.fileURL))")
        
        // 保存先のディレクトリはデフォルトのままで、ファイル名をユーザー名を使うように変更します
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("other.realm")
        //Realm.Configuration.defaultConfiguration = config
        realm = try! Realm(configuration: config)
        print("後\(String(describing: realm.configuration.fileURL))")*/
        let tapDoubleFirstLocation:CGPoint = sender.location(ofTouch: 0, in: self.backPanelWhite)
        let tapDoubleSecondLocation:CGPoint = sender.location(ofTouch: 1, in: self.backPanelWhite)
        
        //タップしたロケーションの左上の座標を抽出
        let x_location:CGFloat!
        let y_location:CGFloat!
        //タップしたロケーションの幅と高さを抽出
        var tapWidth:CGFloat!
        var tapHeight:CGFloat!
        
        if tapDoubleFirstLocation.x < tapDoubleSecondLocation.x {
            
            x_location = tapDoubleFirstLocation.x
            tapWidth = tapDoubleSecondLocation.x - tapDoubleFirstLocation.x
            
        } else if tapDoubleFirstLocation.x > tapDoubleSecondLocation.x {
            
            x_location = tapDoubleSecondLocation.x
            tapWidth = tapDoubleFirstLocation.x - tapDoubleSecondLocation.x
            
        } else {
            
            x_location = tapDoubleFirstLocation.x
            tapWidth = 0
        }
        
        if tapDoubleFirstLocation.y < tapDoubleSecondLocation.y {
            
            y_location = tapDoubleFirstLocation.y
            tapHeight = tapDoubleSecondLocation.y - tapDoubleFirstLocation.y
            
        } else if tapDoubleFirstLocation.y > tapDoubleSecondLocation.y {
            
            y_location = tapDoubleSecondLocation.y
            tapHeight = tapDoubleFirstLocation.y - tapDoubleSecondLocation.y
            
        } else {
            
            y_location = tapDoubleFirstLocation.y
            tapHeight = 0
        }
        
       
        redLine = DrawLineView(frame: CGRect(x:x_location - frameAjust / 2.0, y:y_location - frameAjust / 2.0, width:tapWidth + frameAjust, height:tapHeight + frameAjust))
        lineArray += [redLine]
        /*
        let realm = try! Realm()
        let realmLineArray = DataBank(value: [])
        try! realm.write {
            realm.add(lineArray)
        }*/
        redLine.backgroundColor = UIColor.clear
        redLine.isUserInteractionEnabled = true
        redLine.isMultipleTouchEnabled = true
        self.redLine.layer.borderColor = UIColor.clear.cgColor
        
        redLine.firstPoint = CGPoint(x:(tapDoubleFirstLocation.x  - x_location + frameAjust / 2.0), y:  (tapDoubleFirstLocation.y - y_location + frameAjust / 2.0))
        redLine.lastPoint = CGPoint(x:(tapDoubleSecondLocation.x - x_location + frameAjust / 2.0), y:(tapDoubleSecondLocation.y - y_location + frameAjust / 2.0))
        redLine.deledgate = self
        //ピンチジェスチャーをredLineに設定
        let pinchGesture:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(sender:)))
        self.redLine.addGestureRecognizer(pinchGesture)
        
    
        self.backPanelWhite.addSubview(redLine)
        
        
        
        /*
        UIView.animate(withDuration: 0.06,
                       // アニメーション中の処理.
            animations: { () -> Void in
                // 縮小用アフィン行列を作成する.
                self.textField.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        { (Bool) -> Void in
        }*/
        
        let lineDataIn = FrameData()
        lineDataIn.redLineFirstPointX = Float(self.redLine.firstPoint.x)
        lineDataIn.redLineFirstPointY = Float(self.redLine.firstPoint.y)
        lineDataIn.redLineLastPointX = Float(self.redLine.lastPoint.x)
        lineDataIn.redLineLastPointY = Float(self.redLine.lastPoint.y)
        lineDataIn.redLineFrameWidth = Float(tapWidth) + Float(frameAjust)
        lineDataIn.redLineFrameHeight = Float(tapHeight + frameAjust)
        lineDataIn.redLineFramePointX = Float(x_location - frameAjust / 2.0)
        lineDataIn.redLineFramePointY = Float(y_location - frameAjust / 2.0)
        
        
        
        
        try! realm.write {
                
            
            
            if frameData == nil {
                frameData = [lineDataIn]
            } else {
                frameData.append(lineDataIn)
            }
            print("ララぽ\(frameData)")
            realm.add(frameData)
            
            }
        
        
        
    }
    
    
    func pinchView(sender:UIPinchGestureRecognizer) {
        let senderCount:Int = sender.numberOfTouches
        
        for n in lineArray {
            if sender.view == n {
                redLine = n
            }
        }

            if senderCount != 2 {
                self.redLine.layer.borderColor = UIColor.clear.cgColor
            }
            
            if senderCount == 2 {
                self.redLine.layer.borderColor = UIColor.blue.cgColor
                
                //タップしたロケーション抽出
                let tapDoubleFirstLocation:CGPoint = sender.location(ofTouch: 0, in: self.backPanelWhite)
                let tapDoubleSecondLocation:CGPoint = sender.location(ofTouch: 1, in: self.backPanelWhite)
                
                //タップしたロケーションの左上の座標を抽出
                let x_location:CGFloat!
                let y_location:CGFloat!
                //タップしたロケーションの幅と高さを抽出
                let tapWidth:CGFloat!
                let tapHeight:CGFloat!
                
              
                //タップ座標からredLineの(0, 0)座標とheight,widthを導く。
                if tapDoubleFirstLocation.x < tapDoubleSecondLocation.x {
                    
                    x_location = tapDoubleFirstLocation.x
                    tapWidth = tapDoubleSecondLocation.x - tapDoubleFirstLocation.x
                    
                } else if tapDoubleFirstLocation.x > tapDoubleSecondLocation.x {
                    
                    x_location = tapDoubleSecondLocation.x
                    tapWidth = tapDoubleFirstLocation.x - tapDoubleSecondLocation.x
                    
                } else {
                    
                    x_location = tapDoubleFirstLocation.x
                    tapWidth = 0
                }
                
                if tapDoubleFirstLocation.y < tapDoubleSecondLocation.y {
                    
                    y_location = tapDoubleFirstLocation.y
                    tapHeight = tapDoubleSecondLocation.y - tapDoubleFirstLocation.y
                    
                } else if tapDoubleFirstLocation.y > tapDoubleSecondLocation.y {
                    
                    y_location = tapDoubleSecondLocation.y
                    tapHeight = tapDoubleFirstLocation.y - tapDoubleSecondLocation.y
                    
                } else {
                    
                    y_location = tapDoubleFirstLocation.y
                    tapHeight = 0
                }

                
                
                self.redLine.frame = CGRect(x:x_location - frameAjust / 2.0, y:y_location - frameAjust / 2.0, width:tapWidth + frameAjust, height:tapHeight + frameAjust) //タップした位置（フレームの幅）より線が内側に入るために
                
                self.redLine.firstPoint = CGPoint(x:(tapDoubleFirstLocation.x  - x_location + frameAjust / 2.0), y:  (tapDoubleFirstLocation.y - y_location + frameAjust / 2.0))
                self.redLine.lastPoint = CGPoint(x:(tapDoubleSecondLocation.x - x_location + frameAjust / 2.0), y:(tapDoubleSecondLocation.y - y_location + frameAjust / 2.0))
                
                //ピンチした時にredLineのデータも保存
                
                for n in 1..<lineArray.count {
                    
                    if sender.view == lineArray[n] {
                        let nom = n - 1
                        
                        
                        try! realm.write {
                            
                            //lineDataIn.redLineFirstPointX = Float(self.redLine.firstPoint.x)
                            frameData[nom].redLineFirstPointX = Float(self.redLine.firstPoint.x)
                            frameData[nom].redLineFirstPointY = Float(self.redLine.firstPoint.y)
                            frameData[nom].redLineLastPointX = Float(self.redLine.lastPoint.x)
                            frameData[nom].redLineLastPointY = Float(self.redLine.lastPoint.y)
                            frameData[nom].redLineFrameWidth = Float(tapWidth + frameAjust)
                            frameData[nom].redLineFrameHeight = Float(tapHeight + frameAjust)
                            frameData[nom].redLineFramePointX = Float(x_location - frameAjust / 2.0)
                            frameData[nom].redLineFramePointY = Float(y_location - frameAjust / 2.0)
                            //realm.add(frameData)
                            print("更新しまくりんぐ\(frameData)")
                        }
                    }
                }
        }
        self.redLine.setNeedsDisplay()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    
    //"入力開始前に呼び出し"
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //エンター押したらキーボード消える
        textField.resignFirstResponder()
        textField.layer.borderColor = UIColor.lightGray.cgColor
        if redLine != nil {
            
            for i in 0..<lineArray.count {
                lineArray[i]?.layer.borderColor = UIColor.clear.cgColor
                
            }
        }
        
        return true
        
    }
    
    
    // UITextFieldが編集された直前に呼ばれる "入力開始後に呼び出し"
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
    // UITextFieldが編集された直後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
     
        // textField内がからならオブジェクトを消す
        if textField.text == "" {
            textField.removeFromSuperview()
        
            
        }
        
        
    }
    
    
     //改行ボタンが押された際に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        self.backPanelScrollWhite.isScrollEnabled = true
        textField.layer.borderColor = UIColor.clear.cgColor
        
        textField.resignFirstResponder()  // 改行ボタンが押されたらKeyboardを閉じる処理.
        // textField内がからならオブジェクトを消す
        if textField.text == "" {
            textField.removeFromSuperview()
            print("削除しまた")
            
        }
        
        return true
    }
    
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("pinch")
        return self.backPanelWhite
    }
 
 /*
    //zoom
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.backPanelScrollWhite.frame.size.height / scale
        zoomRect.size.width = self.backPanelScrollWhite.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
 */
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        //キーボード以外をタッチするとキーボードが下がる
        self.view.endEditing(true)
    
        //タッチ座標検知
        if let touch = touches.first as UITouch? {
            let locations = touch.location(in: self.backPanelWhite)
            self.touchPoint = locations
        }
        
        let youX:CGFloat = self.touchPoint.x
        let youY:CGFloat = self.touchPoint.y
        
        if self.backPanelScrollWhite.isScrollEnabled == true {
        
        // テキスト・フィールドを生成
        textField = MoveTextField(frame: CGRect(x: youX, y: youY, width: 220, height: 35))
            
            textField.isUserInteractionEnabled = true
            textField.textColor = UIColor.white           // テキストの色
            textField.placeholder = "  入力プリーズ"         // ブランク時の説明テキスト
            textField.backgroundColor = UIColor.orange    // 背景色
            textField.borderStyle = .none                // ボーダー
            textField.layer.cornerRadius = 17.5
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth  = 1
            textField.layer.masksToBounds = true
            //入力位置の変更　左に余白を入れる
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            paddingView.backgroundColor = UIColor.clear
            textField.leftView = paddingView
            textField.leftViewMode = UITextFieldViewMode.always
            textField.font = UIFont.systemFont(ofSize: CGFloat(18))
            //textField.keyboardType = UIKeyboardType.asciiCapable　　// キーボードの種類
            textField.returnKeyType = UIReturnKeyType.done   // キーボードのリターンキーの種類
            textField.clearButtonMode = .whileEditing
            textField.adjustsFontSizeToFitWidth = true
            textField.becomeFirstResponder()                 //最初からUITextField を選択状態にする
            textField.delegate = self
            
            self.backPanelWhite.addSubview(textField)       // テキスト・フィールドを画面に追加
 
            
        }
        
        
        UIView.animate(withDuration: 0.06,
                       // アニメーション中の処理.
            animations: { () -> Void in
                // 縮小用アフィン行列を作成する.
                self.textField.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        { (Bool) -> Void in
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }*/
    
    

     //指が離れたことを感知した際に呼ばれるメソッド.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touchesEnded")
        
        
        // Labelアニメーション.
        /*UIView.animate(withDuration: 0.1,
                       
                       // アニメーション中の処理.
            animations: { () -> Void in
                // 拡大用アフィン行列を作成する.
                self.textField.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                // 縮小用アフィン行列を作成する.
                self.textField.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        { (Bool) -> Void in
            
        }*/
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        
    }
    
    //LineMoveDelegateの関数（スクロールが止まると動く）
    func stopScroll() {
        self.backPanelScrollWhite.isScrollEnabled = false
        print("スト")
    }
    
    func startScroll() {
        self.backPanelScrollWhite.isScrollEnabled = true
        print("すた")
    }

}
