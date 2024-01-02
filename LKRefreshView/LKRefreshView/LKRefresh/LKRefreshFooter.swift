//
//  LKRefreshFooter.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import SwiftUI


struct LKRefreshFooter: View {
    
    var height: CGFloat
    var loading: Bool
    var frozen: Bool
    var rotation: Angle
    var config:LKRefresh.FooterConfig
    var hidden: Bool
    
    private var footerHeight = 0.0
    private var footerHidden = true
    
    init(height: CGFloat,
         loading: Bool,
         frozen: Bool,
         rotation: Angle,
         config:LKRefresh.FooterConfig = LKRefresh.FooterConfig(),
         hidden: Bool = false) {
        
        self.height = height
        self.loading = loading
        self.frozen = frozen
        self.rotation = rotation
        self.config = config
        self.hidden = hidden
        
        if self.loading ,self.frozen {
            footerHeight = self.height
            footerHidden = false
        }else {
            footerHeight = self.height
            footerHidden = true
        }
    }
    
    var body: some View {
        VStack (alignment:.leading){
            if hidden == false {
                Spacer(minLength: 8.0).frame(height: 8.0)
                HStack(alignment:.center, spacing: 16.0) {
                    
                    Spacer()
                    
                    Group {
                        VStack {
                            Spacer()
                            if self.loading {//加载中
                                
                                if config.indicatorStyle == .indicator {
                                    LKRefreshActivityIndicator(color: config.indicatorColor, style: .medium)
                                } else {
                                    SwiftUIGIFPlayerView(gifName: LKRefresh.LK_ICON.refresh_headerLoading).frame(width: 30.0, height: 30.0)
                                }
                                
                            } else {
                                Image(systemName: "arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .rotationEffect(rotation)
                            }
                            Spacer()
                            
                        }.foregroundColor(config.indicatorColor)
                        
                    }.frame(width: 38.0, height: 38.0)
                        .fixedSize()
                    
                    //.offset(y: (loading && frozen) ? 0.0 : -height)
                    VStack() {
                        
                        Text("\(self.loading ? config.refreshingTitle : config.willRefreshTitle)")
                            .foregroundColor(config.titleColor)
                            .font(config.titleFont)
                        
                    }.foregroundColor(config.titleColor)
                    //.offset(y: (loading && frozen) ? 0.0 : -height)
                    
                    Spacer()
                }//.background(Color.yellow)
                Spacer()
            }
            
        }//.background(Color.green)
         .animation(.spring(), value: footerHeight)
         //.frame(height: footerHeight)
    }
    
}

//#Preview {
//    LKRefreshFooter()
//}
