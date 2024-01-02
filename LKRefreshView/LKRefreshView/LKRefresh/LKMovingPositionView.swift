//
//  LKMovingPositionView.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import SwiftUI

struct LKMovingPositionView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: LKRefreshPreferenceType.LKRefreshPreferenceKey.self, value: [LKRefreshPreferenceType.LKRefreshPreferenceData(viewType: .movingPositionView, bounds: proxy.frame(in: .global))])
        }.frame(height:0.0)
    }
}

#Preview {
    LKMovingPositionView()
}
