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

