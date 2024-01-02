//
//  LKRefresh.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import Foundation
import SwiftUI

enum LKRefreshUIStyle {
    
    ///菊花
    case indicator
    ///自定义loading动画效果
    case loading
    
}

struct LKRefresh {
    
    struct Layout {
        
        public static let screen_h = UIScreen.main.bounds.height
        public static let screen_w = UIScreen.main.bounds.width
        
        ///导航状态栏高度
        public static let statusBar_height = Layout().NAV_STATUSBAR_HEIGHT()
        ///底部导航菜单的指示条高度（屏幕底部安全距离）
        public static let bottomSafe_height = Layout().TABBAR_INDICATOR_HEIGHT()
        
        /// 导航栏内容高度
        public static let navBarContent_height = 44.0
        ///导航栏整体高度 状态栏高 + 导航栏内容高
        public static let navBar_height = (statusBar_height + navBarContent_height)
        ///底部导航菜单高度 内容高 + 底部指示条高度
        public static let tabBar_height = (49.0 + bottomSafe_height)
        
        
        //状态栏高度
       
        private func NAV_STATUSBAR_HEIGHT() -> CGFloat {
            if #available(iOS 13.0, *) {
                return lkWindow()?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }
        
        //底部指示条
        private func TABBAR_INDICATOR_HEIGHT() -> CGFloat {
            if #available(iOS 11.0, *) {
                   return lkWindow()?.safeAreaInsets.bottom ?? 0
               } else {
                   return 0
               }
        }
        
        //获取window
        private func lkWindow() -> UIWindow? {
            if #available(iOS 13.0, *) {
                let winScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                return winScene?.windows.first
            } else {
                return UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow
            }
        }
        
    }
    
    struct LK_ICON {
        
        public static let refresh_headerLoading:String = "lk_header_refresh"
        
        
    }
    
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
}



struct LKRefreshPreferenceType {
    
    enum ViewType: Int {
        case fixedPositionView
        case movingPositionView
    }
    
    struct LKRefreshPreferenceData: Equatable {
        let viewType: ViewType
        let bounds: CGRect
    }
    
    //获取滚动偏移量
    struct LKRefreshPreferenceKey: PreferenceKey {
        static var defaultValue: [LKRefreshPreferenceData] = []
        static func reduce(value: inout [LKRefreshPreferenceData],
                           nextValue: () -> [LKRefreshPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
}

//菊花
struct LKRefreshActivityIndicator: UIViewRepresentable {
    
    var color:Color? = .white
    var style:UIActivityIndicatorView.Style? = .medium
    
    func makeUIView(context: UIViewRepresentableContext<LKRefreshActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style ?? .medium)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LKRefreshActivityIndicator>) {
        uiView.style = self.style ?? .medium
        uiView.color = UIColor(self.color ?? .white)
        uiView.startAnimating()
    }
    
}
