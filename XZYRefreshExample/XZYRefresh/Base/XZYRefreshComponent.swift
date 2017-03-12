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
/// - XZYRefreshStateIdle: 普通闲置状态
/// - XZYRefreshStatePulling: 松开就可以进行刷新的状态
/// - XZYRefreshStateRefreshing: XZYRefreshStateRefreshing
/// - XZYRefreshStateWillRefresh: 即将刷新的状态
/// - XZYRefreshStateNoMoreData: 所有数据加载完毕，没有更多的数据了
enum XZYRefreshState {
    /// 普通闲置状态
   case XZYRefreshStateIdle
   /// 松开就可以进行刷新的状态
   case XZYRefreshStatePulling
   ///  正在刷新中的状态
   case XZYRefreshStateRefreshing
   /// 即将刷新的状态
   case XZYRefreshStateWillRefresh
   /// 所有数据加载完毕，没有更多的数据了
   case XZYRefreshStateNoMoreData
    
}
class XZYRefreshComponent: UIView {

    // 初始化并设置 默认是 普通状态
    let state = XZYRefreshState.XZYRefreshStateIdle
    
    /// 父控件
    var scrollView = UIScrollView()
    
    var pan = UIPanGestureRecognizer()
    
    /// 记录scrollView刚开始的inset
    var scrollViewOriginalInset = UIEdgeInsets()
    
    /// 回调对象
    var refreshingTarget = #selector(voidObject) as AnyObject
    
    
    /// 回调方法
    var refreshingAction:Selector = #selector(voidMethods)
    
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

    /// 添加监听
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
    func setRefreshingTarget(target:AnyObject?,action:Selector) {
        
    }
}



































