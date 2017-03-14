//
//  XZYRefreshComponent.swift
//  XZYRefreshExample
//
//  Created by x.z.y on 2017/3/12.
//  Copyright © 2017年 肖振阳. All rights reserved.
//  刷新控件的基类

import UIKit

/// 刷新控件的状态
///
/// - idle: 普通闲置状态
/// - pulling: 松开就可以进行刷新的状态
/// - refreshing: XZYRefreshStateRefreshing
/// - willRefresh: 即将刷新的状态
/// - noMoreData: 所有数据加载完毕，没有更多的数据了
enum XZYRefreshState {
    /// 普通闲置状态
   case idle
   /// 松开就可以进行刷新的状态
   case pulling
   ///  正在刷新中的状态
   case refreshing
   /// 即将刷新的状态
   case willRefresh
   /// 所有数据加载完毕，没有更多的数据了
   case noMoreData
    
}
class XZYRefreshComponent: UIView {

    // 初始化并设置 默认是 普通状态
    var state = XZYRefreshState.idle
    
    /// 父控件
    var scrollView = UIScrollView()
    
    var pan = UIPanGestureRecognizer()
    
    /// 记录scrollView刚开始的inset
    var scrollViewOriginalInset = UIEdgeInsets()
    
    /// 回调对象
    var refreshingTarget = #selector(voidObject) as AnyObject
    
    /// 回调方法
    var refreshingAction:Selector = #selector(voidMethods)
    
    ///进入刷新状态的回调
    var xzyRefreshingBlock: (()->())?
    
    ///开始刷新后的回调(进入刷新状态后的回调)
    var xzyBeginRefreshingCompletionBlock : (()->())?
    
    ///结束刷新后的回调
    var xzyEndRefreshingCompletionBlock : (()->())?
    
   
    override  init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 准备工作
        prepare()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 准备工作
extension XZYRefreshComponent{

    /// 初始化
    func prepare()  {
        // 基本属性
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
    }

    override func layoutSubviews() {
        placeSubviews()
        
        super.layoutSubviews()
    }
    
    /// 摆放子控件frame
    func placeSubviews() {
        
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        
        /// 如果不是UIScrollView，不做任何事情
        if newSuperview == nil,!(newSuperview is UIScrollView) {
            return
        }
        /// 旧的父控件移除监听
        removeObservers()
        
        if (newSuperview != nil) {// 新的父控件
            
            /// 设置宽度
            self.xzy_w = newSuperview?.xzy_w ?? 0;
            /// 设置位置
            self.xzy_x = 0;
            
            /// 记录UIScrollView
            scrollView = newSuperview as! UIScrollView
            /// 设置永远支持垂直弹簧效果
            scrollView.alwaysBounceVertical = true;
            /// 记录UIScrollView最开始的contentInset
            scrollViewOriginalInset = scrollView.contentInset;

            // 添加监听
            addObservers()
        }
        
    }
    
    /// 返回一个空方法
    func voidMethods() {
        
    }
    
    /// 返回一个 AnyObject?，等价于在 Objective-C 中返回一个 id
    ///
    /// - Returns: AnyObject?
    func voidObject() -> AnyObject? {
        
        return refreshingTarget
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if state == XZYRefreshState.willRefresh {
            // 预防view还没显示出来就调用了beginRefreshing
            state = XZYRefreshState.refreshing
        }
    }
}

// MARK: - KVO监听
extension XZYRefreshComponent{


    /// 添加监听
    func addObservers()  {
        
        scrollView .addObserver(self, forKeyPath: XZYRefreshKeyPathContentOffset, options: [.new,.old], context: nil)
        scrollView .addObserver(self, forKeyPath: XZYRefreshKeyPathContentSize, options: [.new,.old], context: nil)
        pan = scrollView.panGestureRecognizer;
        pan.addObserver(self, forKeyPath:XZYRefreshKeyPathPanState, options:[.new,.old], context:nil);

    }

    /// 移除监听
    func removeObservers(){
        
        self.superview?.removeObserver(self, forKeyPath: XZYRefreshKeyPathContentOffset)
        self.superview?.removeObserver(self, forKeyPath: XZYRefreshKeyPathContentSize)
        self.pan.removeObserver(self, forKeyPath: XZYRefreshKeyPathPanState)
        _ = self.pan
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        /// 遇到这些情况就直接返回
        if !self.isUserInteractionEnabled {return}
        
        /// 这个就算看不见也需要处理
        if  keyPath == XZYRefreshKeyPathContentSize{
            
          scrollViewContentOffsetDidChange(change: change)
        
        } else if keyPath ==  XZYRefreshKeyPathPanState {
            
            scrollViewPanStateDidChange(change: change)
        }
    }
}
// MARK: - UIScrollView 的方法
extension XZYRefreshComponent{

    /// 当scrollView的contentOffset发生改变的时候调用
    ///
    /// - Parameter change: 偏移数据
    func scrollViewContentOffsetDidChange(change:[NSKeyValueChangeKey : Any]?) {
        
    }
    /// 当scrollView的contentSize发生改变的时候调用
    ///
    /// - Parameter change: 偏移数据
    func scrollViewContentSizeDidChange(change:[NSKeyValueChangeKey : Any]?) {
        
    }
    /// 当scrollView的拖拽状态发生改变的时候调用
    ///
    /// - Parameter change: 偏移数据
    func scrollViewPanStateDidChange(change:[NSKeyValueChangeKey : Any]?) {
        
    }
}
// MARK: -公共方法 设置回调对象和回调方法
extension XZYRefreshComponent{
    
    /// 设置回调对象和回调方法
    ///
    /// - Parameters:
    ///   - target: target
    ///   - action: action
    func setRefreshingTarget(target:AnyObject,action:Selector) {
        
        refreshingTarget = target
        refreshingAction = action
    }
    
    var setState:XZYRefreshState?{
        
        get{
            return XZYRefreshState.idle
            
        }
        set(newState){
            state = newState!
            
            ///加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.setNeedsLayout()
            }
        }
    }
}

// MARK: - 刷新状态控制
extension XZYRefreshComponent{
    
    /// 进入刷新状态
    func beginRefreshing() {
        
       UIView.animate(withDuration: XZYRefreshFastAnimationDuration) { 
            self.alpha = 1.0
        }
        pullingPercent = 1.0
        
        /// 只要正在刷新，就完全显示
        if (window != nil) {
            state = XZYRefreshState.refreshing
        }else{
            ///预防正在刷新中时，调用本方法使得header inset回置失败
            if self.state != XZYRefreshState.refreshing {
                self.state = XZYRefreshState.willRefresh;
                /// 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                setNeedsDisplay()
            }
        }
    }
    
    func beginRefreshingWithCompletionBlock(completionBlock: (()->())?)  {
        
        self.xzyBeginRefreshingCompletionBlock = completionBlock
        
        beginRefreshing()
    }
    
    ///结束刷新状态
    func endRefreshing() {
        state = XZYRefreshState.idle
    }
    
    func endRefreshingWithCompletionBlock(completionBlock: (()->())?)  {
        
        self.xzyEndRefreshingCompletionBlock = completionBlock
        
        beginRefreshing()
    }
    
    ///是否正在刷新
    var isRefreshing:Bool{
        
        get{
            return state == XZYRefreshState.refreshing || state == XZYRefreshState.willRefresh
        }
    }
    
    ///根据拖拽比例自动切换透明度
    var autoChangeAlpha:Bool{
        get{
            return self.autoChangeAlpha
        }
        
        set(newVal){
            self.autoChangeAlpha = newVal
        }
    }
      ///根据拖拽比例自动切换透明度
    var automaticallyChangeAlpha:Bool{
        get{
            return self.automaticallyChangeAlpha
        }
        
        set(newVal){
            self.automaticallyChangeAlpha = newVal
            
            if automaticallyChangeAlpha {
                alpha = pullingPercent
            }else{
                alpha = 1.0
            }
        }
    }
    
    ///根据拖拽进度设置透明度
    var pullingPercent :CGFloat{
    
        get{
            return self.pullingPercent
        }
        set(newVal){
            
            self.pullingPercent = newVal
            
            if self.isRefreshing {return}
            
            if self.automaticallyChangeAlpha {
                
                self.alpha = newVal
            }
        }
        
    }
}

// MARK: - 内部方法
extension XZYRefreshComponent{

    /// 触发回调（交给子类去调用）
    func executeRefreshingCallback() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {

            if (self.xzyRefreshingBlock != nil){
                self.xzyRefreshingBlock!()
            }
            
            /// FIST
            if self.refreshingTarget .responds(to: self.refreshingAction){
            
                
            
            }
            if (self.xzyBeginRefreshingCompletionBlock != nil){
                self.xzyBeginRefreshingCompletionBlock!()
            }

        }
    }

}


















































