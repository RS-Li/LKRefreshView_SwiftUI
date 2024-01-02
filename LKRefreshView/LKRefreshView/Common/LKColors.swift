//
//  LKColors.swift
//  LKRefreshView
//
//  Created by 李棒棒 on 2023/12/28.
//

import SwiftUI

extension Color {
    
    public struct LK {
        
        ///主背景色
        public
        static let main_navBackground: Color = Color("auto_NavBg_color", bundle: Bundle.main)
        
        ///主背景色
        public
        static let main_background: Color = Color("auto_Background_color", bundle: Bundle.main)
        
        ///主背景色
        public
        static let main_whiteBackground: Color = Color("auto_WhiteBackground_color", bundle: Bundle.main)
        
        ///导航标题
        public
        static let main_navTitle: Color = Color("auto_NavTitle_color", bundle: Bundle.main)
        
        ///导航标题
        public
        static let a_blackTitle: Color = Color("auto_BlackTitle_color", bundle: Bundle.main)
        
        ///导航标题
        public
        static let a_grayTitle: Color = Color("auto_GrayTitle_color", bundle: Bundle.main)
    }
    
    
    /// 16进制转化颜色
    /// - Parameter hex: 例如 "0xffffff" "#ffffff" "ffffff"
    /// - Parameter alpha: 透明度 0~1
    /// - Returns: Color
    static func hex(_ hex: String, alpha: Double = 1) -> Color {
        var hexColor:Color = .clear
        
        var hex = hex
        hex = hex.trimmingCharacters(in: .whitespaces)
        
        if hex.hasPrefix("#") {
            hex = (hex as NSString).replacingOccurrences(of: "#", with: "")
        }else if hex.hasPrefix("0x") {
            hex = (hex as NSString).replacingOccurrences(of: "0x", with: "")
        }
        
        if hex.count != 6 {
            hexColor = Color.clear
        }
        
        var rgbValue: UInt64 = 0
        if Scanner(string: hex).scanHexInt64(&rgbValue) {
            let components = (
                R:  Double((rgbValue >> 16) & 0xff) / 255,
                G:  Double((rgbValue >> 08) & 0xff) / 255,
                B:  Double((rgbValue >> 00) & 0xff) / 255
            )
            hexColor = Color(.sRGB, red: components.R, green: components.G, blue: components.B, opacity: alpha)
        }else {
            hexColor = Color.clear
        }
        
        return hexColor
    }
    
    
}
