//
//  LKFixedPositionView.swift
//  ZgwBosssCockpit
//
//  Created by 李棒棒 on 2023/12/14.
//

import SwiftUI

struct LKFixedPositionView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: LKRefreshPreferenceType.LKRefreshPreferenceKey.self,
                            value: [LKRefreshPreferenceType.LKRefreshPreferenceData(viewType: .fixedPositionView, bounds: proxy.frame(in: .global))])
            
        }
    }
}

#Preview {
    LKFixedPositionView()
}
