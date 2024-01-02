//
//  LKRefreshHeader.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import SwiftUI

struct LKRefreshHeader: View {
    
    var height: CGFloat
    var loading: Bool
    var frozen: Bool
    var rotation: Angle
    var updateTime: Date
    
    var config:LKRefresh.HeaderConfig
    var hidden: Bool = false
    
    init(height: CGFloat, 
         loading: Bool,
         frozen: Bool,
         rotation: Angle,
         updateTime: Date,
         config: LKRefresh.HeaderConfig = LKRefresh.HeaderConfig(),
         hidden: Bool) {
        
        self.height = height
        self.loading = loading
        self.frozen = frozen
        self.rotation = rotation
        self.updateTime = updateTime
        self.config = config
        self.hidden = hidden
    }
    
    var body: some View {
        
        HStack(alignment:.center, spacing: 16.0) {
            if hidden == false {
                Spacer()
                Group {
                    if self.loading {
                        
                        VStack {
                            Spacer()
                            if config.indicatorStyle == .indicator {
                                LKRefreshActivityIndicator(color: config.indicatorColor, style: .medium)
                            }else {
                                SwiftUIGIFPlayerView(gifName: LKRefresh.LK_ICON.refresh_headerLoading).frame(width: 32.0, height: 32.0)
                            }
                            Spacer()
                        }.foregroundColor(config.indicatorColor)
                        
                    } else {
                        
                        VStack {
                            Spacer()
                            Image(systemName: "arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .rotationEffect(rotation)
                                
                            Spacer()
                        }.foregroundColor(config.indicatorColor)
                            .frame(width: 38.0, height: 38.0)
                            .fixedSize()
                        
                    }
                }
                .frame(width: height * 0.25, height: height * 0.8)
                .fixedSize()
                .offset(y: (loading && frozen) ? 0.0 : -height)
                
                VStack(spacing: 5) {
                    Text("\(self.loading ? config.willRefreshTitle : config.refreshingTitle)")
                        .foregroundColor(config.titleColor)
                        .font(config.titleFont)
                    Text("\(self.dateFormatter(config.dateFormatter).string(from: updateTime))")
                        .foregroundColor(config.titleColor)
                        .font(config.titleFont)
                }
                .offset(y: -height + (loading && frozen ? +height : 0.0))
                Spacer()
            }
        }
        .frame(height: (self.hidden==true ? 0.0 : height))
    }
}

extension LKRefreshHeader {
    func dateFormatter(_ formatter:String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = formatter
        return df
    }
}

//#Preview {
//    LKRefreshHeader()
//}
