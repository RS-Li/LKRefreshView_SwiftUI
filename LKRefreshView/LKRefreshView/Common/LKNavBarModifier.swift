//
//  LKNavBarModifier.swift
//  LKRefreshView
//
//  Created by 李棒棒 on 2023/12/28.
//

import SwiftUI

struct LKNavBarModifier: ViewModifier {
    
    var navColor: UIColor? = nil
    var titleFont: UIFont? = nil
    var titleColor: UIColor? = nil
    
    init(navColor: UIColor? = UIColor(Color.LK.main_navBackground),
         titleFont: UIFont? = UIFont.monospacedSystemFont(ofSize: 18.0, weight: .bold),
         titleColor: UIColor? = UIColor(Color.LK.main_navTitle)) {
        
        self.navColor = navColor
        self.titleFont = titleFont
        self.titleColor = titleColor
        
        let navibarAppearance = UINavigationBarAppearance()
        navibarAppearance.configureWithTransparentBackground()
        //修改背景的颜色
        navibarAppearance.backgroundColor = self.navColor
        //设置字体的颜色和大小
        navibarAppearance.titleTextAttributes = [
            .foregroundColor:self.titleColor!,
            .font:self.titleFont!
        ]
        
        UINavigationBar.appearance().standardAppearance   = navibarAppearance
        UINavigationBar.appearance().compactAppearance    = navibarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navibarAppearance
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.navColor!)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
    
}

extension View {
    
    func lkNavBar(bgColor:     Color?  = Color.LK.main_navBackground,
                   titleFont:  UIFont? = UIFont.monospacedSystemFont(ofSize: 18.0, weight: .bold),
                   titleColor: Color?  = Color.LK.main_navTitle) -> some View {
        
        self.modifier(LKNavBarModifier(navColor: UIColor(bgColor!),
                                        titleFont: titleFont,
                                        titleColor: UIColor(titleColor!)))
    }
}
