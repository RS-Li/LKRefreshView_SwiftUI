//
//  LKRefreshView.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import SwiftUI

struct LKRefreshView<Content: View>: View {
    
    @State private var preOffset: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var headerFrozen = false
    @State private var footerFrozen = false
    @State private var headerRotation: Angle = .degrees(0)
    @State private var footerRotation: Angle = .degrees(0)
    @State private var updateTime: Date = Date()
    
    @State private var listContentSize:CGSize = CGSize.zero// 列表内容size
    @State private var listContentH : CGFloat = 0.0 // 列表内容总高(不包含头部、尾部的刷新控件)
    @State private var listSizeH : CGFloat = 0.0  // 列表size高度
    @Namespace private var listViewSpace  // 标识ScrollView的空间坐标，标明是基于ScrollView坐标的偏移量
    
    var threshold: CGFloat = 120 //触发的临界高度
    /// 下拉刷新
    @Binding var headerRefreshing: Bool
    /// 加载更多
    @Binding var footerRefreshing: Bool
    
    ///是否隐藏头部刷新控件 默认false 不隐藏
    var headerHidden: Bool
    ///是否隐藏尾部刷新控件 默认false 不隐藏
    var footerHidden: Bool
    
    ///配置 头部刷新控件样式配置
    var headerConfig:LKRefresh.HeaderConfig
    ///配置 尾部刷新控件样式配置
    var footerConfig:LKRefresh.FooterConfig
    
    // 下拉刷新出发回调
    var refreshTrigger: (() -> Void)?
    // 上拉加载更多回调
    var moreTrigger: (() -> Void)?
    
    let content: Content
    
    init(_ threshold: CGFloat = 120,
         headerRefreshing: Binding<Bool>,
         footerRefreshing: Binding<Bool>,
         headerHidden: Bool = false,
         footerHidden: Bool = false,
         headerConfig:LKRefresh.HeaderConfig = LKRefresh.HeaderConfig(),
         footerConfig:LKRefresh.FooterConfig = LKRefresh.FooterConfig(),
         refreshTrigger: @escaping () -> Void,
         moreTrigger: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        
        self.threshold = threshold
        
        self._headerRefreshing = headerRefreshing
        self._footerRefreshing = footerRefreshing
        
        self.headerHidden = headerHidden
        self.footerHidden = footerHidden
        
        self.headerConfig = headerConfig
        self.footerConfig = footerConfig
        
        self.refreshTrigger = refreshTrigger
        self.moreTrigger    = moreTrigger
        
        self.content        = content()
    }
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack {
                        ZStack(alignment: .top) {
                            
                            LKMovingPositionView()
                            LKChildSizeReader(size: $listContentSize) {//计算list的内容尺寸
                                VStack {
                                    self.content
                                        .alignmentGuide( .top, computeValue: { _ in
                                            if self.headerRefreshing , self.headerFrozen, !self.headerHidden{
                                                -self.threshold
                                            } else {
                                                0.0
                                            }
                                        })
                                }
                            }.onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    withAnimation {
                                        print("scrollViewContentSize: \(listContentSize)")
                                        self.listContentH = listContentSize.height
                                    }
                                }
                            }
                            
                            LKRefreshHeader(height: self.threshold,
                                            loading: self.headerRefreshing,
                                            frozen: self.headerFrozen,
                                            rotation: self.headerRotation,
                                            updateTime: self.updateTime,
                                            config: headerConfig,
                                            hidden: self.headerHidden)
                            
                        }
                        
                        if footerHidden == false {
                            LKRefreshFooter(height: self.threshold,
                                            loading: footerRefreshing,
                                            frozen: footerFrozen,
                                            rotation: self.footerRotation,
                                            config: self.footerConfig,
                                            hidden: self.footerHidden)
                            .onTapGesture {
                                print("刷新控件获取到的屏幕参数：width:\(proxy.size.width) - height:\(proxy.size.height) - contentHeight:\(self.listContentH) 屏幕高度：\(LKRefresh.Layout.screen_h)")
                            }
                        }
                        
                    }.background(
                        GeometryReader { reader in
                            Color.clear.preference(key: LKScrollOffsetPreferenceKey.self, value: -reader.frame(in: .named(listViewSpace)).minY)
                        }
                    )
                    .onPreferenceChange(LKScrollOffsetPreferenceKey.self) { offset in
                        print("#######滑动偏移量：\(offset)")
                        if offset >= abs(listContentH - listSizeH) {
                            print("reached bottom.")
                        }
                    }
                    
                }.coordinateSpace(name:listViewSpace)// 标识ScrollView的空间坐标，标明是基于ScrollView坐标的偏移量
                 .background(
                        LKFixedPositionView()
                    )
                 .onPreferenceChange(LKRefreshPreferenceType.LKRefreshPreferenceKey.self) { values in
                        if headerHidden == false || footerHidden == false {
                            self.calculate(values)
                        }
                    }
                 .onChange(of: headerRefreshing) { refreshing in
                        DispatchQueue.main.async {
                            if !refreshing {
                                self.updateTime = Date()
                            }
                        }
                    }
                 .onAppear {//计算list的自身尺寸
                     DispatchQueue.main.asyncAfter(deadline: .now()) {
                         withAnimation {
                             self.listSizeH = proxy.size.height
                         }
                     }
                 }
            }
        }
    }
}


extension LKRefreshView {
    
    func calculate(_ values: [LKRefreshPreferenceType.LKRefreshPreferenceData]) {
        
        DispatchQueue.main.async {
            
            /// 计算sroll offset
            let movingBounds = values.first(where: { $0.viewType == .movingPositionView })?.bounds ?? .zero
            let fixedBounds = values.first(where: { $0.viewType == .fixedPositionView })?.bounds ?? .zero
            self.offset = movingBounds.minY - fixedBounds.minY
            
            if (self.offset >= 0.0) {//下拉
                self.headerRotation = self.headerRotation(self.offset)
            } else {//上拽
                self.footerRotation = self.footerRotation(self.offset)
            }
            
            /// 触发刷新
            if self.headerRefreshing == false ,
                self.offset > self.threshold ,
                self.preOffset <= self.threshold {
                
                self.footerRefreshing = false
                self.footerFrozen = false
                
                self.headerRefreshing = true
                
                if refreshTrigger != nil {
                    refreshTrigger!()
                }
            }
            
            if self.headerRefreshing {
                if self.preOffset > self.threshold, 
                    self.offset <= self.threshold {
                    
                    self.headerFrozen = true
                }
            } else {
                self.headerFrozen = false
            }
            self.preOffset = self.offset
            
            print("滑动位置偏移：\(self.offset)")
            
            //加载更多触发条件
            //print("内容高度\(listContentH)","列表物理高度：\(listSizeH)", "当前偏移量\(-(self.preOffset - listSizeH))")
            
            if self.footerRefreshing == false, 
                self.footerFrozen == false,
                self.preOffset < 0.0,
                listContentH > 0.0 ,
               (listContentH > listSizeH ? ((listContentH + threshold) <= abs(self.preOffset - listSizeH)) : abs(self.preOffset) > self.threshold) {
                
            //if self.footerRefreshing == false && ((listContentH + threshold) <= -(self.preOffset - listSizeH)) && listContentH > 0.0 {
                
                self.headerRefreshing = false
                self.headerFrozen = false
                
                self.footerRefreshing = true
                
                if footerHidden == false {//底部控件未隐藏，允许上拉回调
                    if moreTrigger != nil {
                        moreTrigger!()
                    }
                }
                
            }
            
            if self.footerRefreshing {
                if listContentH > listSizeH ? ((listContentH + threshold) <= -(self.preOffset - listSizeH)) : (abs(self.preOffset) > threshold){
                //if ((listContentH + threshold) <= -(self.preOffset - listSizeH)) {
                    self.footerFrozen = true
                }
            } else {
                self.footerFrozen = false
            }
        }
        
    }
    
    //偏移量换算角度
    func headerRotation(_ scrollOffset: CGFloat) -> Angle {
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            let height = Double(self.threshold)
            let offsetY = Double(scrollOffset)
            let v = max(min(offsetY - height * 0.5, height * 0.4), 0.0)
            return .degrees(180.0 * v / (height * 0.4))
        }
    }
    
    //偏移量换算角度
    func footerRotation(_ scrollOffset: CGFloat) -> Angle {
        
        if listContentH > listSizeH {//列表内容高度 > 列表物理高度
            
            //print(listContentH ,"当前位置：\(abs(scrollOffset - listSizeH))" )

            if ((listContentH + threshold) <= abs(scrollOffset - listSizeH)) {
                
                let height = Double(self.threshold)
                let offsetY = Double(((scrollOffset - listSizeH) + (listContentH + threshold)))
                //let offsetY = Double(scrollOffset)
                let v = max(min(offsetY - height * 0.5, height * 0.4), 0.0)
                return .degrees(-180.0 * v / (height * 0.4))
                
            }else {
                
                return .degrees(0)
            }
            
        } else {
            
            if abs(scrollOffset) < self.threshold * 0.60 {
                return .degrees(0)
            } else {
                let height = Double(self.threshold)
                let offsetY = Double(abs(scrollOffset))
                let v = max(min(offsetY - height * 0.5, height * 0.4), 0.0)
                return .degrees(-(180.0 * v / (height * 0.4)))
            }
        }
    }
}


//#Preview {
//    LKRefreshView()
//}
