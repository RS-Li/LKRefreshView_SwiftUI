# LKRefreshView_SwiftUI

#### 介绍
LKRefreshView是纯SwiftUI自定义的下拉刷新，上拉加载更多列表刷新控件，支持ScrollView列表快速对接

#### 软件架构
> 1.获取ScrollView的内容高度；
> 2.计算滑动偏移offsetY值与刷新事件的阈值对比回调刷新触发事件；
> 3.自定义滑动时的header、footer显示内容效果。

### 一、获取ScrollView的内容高度

```
//
//  LKChildSizeReader.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/20.
//

import SwiftUI

struct LKChildSizeReader<Content: View>: View {
    
    @Binding var size:CGSize
    let content:()->Content
    
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: LKSizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(LKSizePreferenceKey.self) { preferences in
            self.size = preferences
        }
        
    }
}
//计算内容size
private struct LKSizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero
  static func reduce(value _: inout Value, nextValue: () -> Value) {
    _ = nextValue()
  }
}
//计算滑动偏移量
struct LKScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = -(value + nextValue())
  }
}

```
### 二、计算垂直方向滑动偏移量得到offsetY与刷新触发阈值对比
有两种方案：
 **第一种：使用第一步中的LKScrollOffsetPreferenceKey来获取滑动时的偏移量；** 
 **第二种：通过计算LKMovingPositionView和LKFixedPositionView两者之间的y的差，得到offset；** 

 ** 1.LKFixedPositionView的代码** 
> 通过.preference为其绑定了一个LKRefreshPreferenceData类型的数据，最重要的目的是保存该view的bounds
```
import SwiftUI

//固定位置view
struct LKFixedPositionView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: LKRefreshPreferenceType.LKRefreshPreferenceKey.self,
                            value: [LKRefreshPreferenceType.LKRefreshPreferenceData(viewType: .fixedPositionView, bounds: proxy.frame(in: .global))])
            
        }
    }
}

```
 ** 2.LKMovingPositionView的代码 ** 


```
/// 位置随着滑动变化的view，高度为0
struct LKMovingPositionView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: LKRefreshPreferenceType.LKRefreshPreferenceKey.self, value: [LKRefreshPreferenceType.LKRefreshPreferenceData(viewType: .movingPositionView, bounds: proxy.frame(in: .global))])
        }.frame(height:0.0)
    }
}
```
 **这两个view对用户来说都是不可见的，一个作为背景，另一个放到ScrollView内容的最上边** 
 ** 3.计算offset ** 


```
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
}
```
### 三、实现自定义的header、footer控件效果

目前定义了两种样式，菊花和自定义的loading图效果，可以根据需求修改


```
 struct HeaderConfig {
        
        var indicatorStyle:LKRefreshUIStyle = .indicator
        var titleColor:Color = .gray
        var titleFont:Font = Font.system(size: 16.0,weight: .regular)
        var indicatorColor:Color = .gray
        
        var refreshingTitle:String = "正在刷新数据"
        var willRefreshTitle:String = "下拉刷新数据"
        
        var dateFormatter: String
        
        /*
        let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "MM月dd日 HH时mm分ss秒"
            return df
        }()
        */
        
        init(indicatorStyle: LKRefreshUIStyle = .indicator,
             titleColor: Color = .gray,
             titleFont: Font = Font.system(size: 16.0,weight: .regular),
             indicatorColor: Color = .gray,
             refreshingTitle: String = "正在刷新数据",
             willRefreshTitle: String = "下拉刷新数据",
             dateFormatter: String = "上次更新 MM-dd HH:mm") {
            
            self.indicatorStyle = indicatorStyle
            self.titleColor     = titleColor
            self.titleFont      = titleFont
            
            self.indicatorColor   = indicatorColor
            self.refreshingTitle  = refreshingTitle
            self.willRefreshTitle = willRefreshTitle
            self.dateFormatter    = dateFormatter
        }
    }
    
    
    struct FooterConfig {
       
        var indicatorStyle:LKRefreshUIStyle = .indicator
        var titleColor:Color
        var titleFont:Font
        var indicatorColor:Color
        
        var refreshingTitle:String
        var willRefreshTitle:String
        
        init(indicatorStyle:LKRefreshUIStyle = .indicator,
             titleColor: Color = .gray,
             titleFont: Font = Font.system(size: 16.0,weight: .regular),
             indicatorColor: Color = .gray,
             refreshingTitle: String = "正在加载更多数据",
             willRefreshTitle: String = "上拉加载更多") {
            
            self.indicatorStyle = indicatorStyle
            self.titleColor     = titleColor
            self.titleFont      = titleFont
            self.indicatorColor   = indicatorColor
            self.refreshingTitle  = refreshingTitle
            self.willRefreshTitle = willRefreshTitle
        }
    }

```



#### 安装教程

1.  xxxx


#### 调用参数说明


```
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

```


#### 参考来源

1.  参考来源：[swiftui-pull-to-refresh](https://github.com/globulus/swiftui-pull-to-refresh)
2.  解读参考：[原理解读](https://zhuanlan.zhihu.com/p/162051409)


