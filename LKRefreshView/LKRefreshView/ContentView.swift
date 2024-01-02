//
//  ContentView.swift
//  LKRefreshView
//
//  Created by 李棒棒 on 2023/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isHeaderRefreshing = false
    @State private var isFooterRefreshing = false
    
    let rowTitles = [["title":"菊花下拉刷新","subTitle":"只有下拉刷新，隐藏了上拉加载更多","type":0],
                     ["title":"菊花下拉刷新+上拉加载","subTitle":"菊花样式的下拉刷新上拉加载","type":1],
                     ["title":"loading下拉刷新","subTitle":"自定义的刷新样式","type":2]]
    
    var body: some View {
        NavigationView {

            VStack {
                List {
        
                    ForEach(rowTitles.indices,id:\.self) {index in
                        let item = rowTitles[index]
                        
                        NavigationLink(destination: NewsListPageView(refreshStyle: RefreshStyle(rawValue: item["type"] as! Int) ?? .headerFooter)) {
                            PageListRowCell(title: item["title"] as! String, subTitle: item["subTitle"] as? String)
                        }
                    }
                    
                }.listStyle(.plain)
                 .background(Color.LK.main_whiteBackground)
                 .padding(0.0)
                 .lineSpacing(1.0)
            }
            .background(Color.LK.main_background)
            .padding(0.0)
            .lkNavBar()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("LKRefreshView")
        }
    }
}

#Preview {
    ContentView()
}


struct PageListRowCell: View {
    
    var title:String
    var subTitle:String?
    
    var body: some View {
        
        VStack (alignment:.leading){
            
            Spacer(minLength: 6.0)
            Text(title)
                .foregroundColor(.LK.a_blackTitle)
                .font(Font.system(size: 18.0,weight: .bold))
            Spacer(minLength: 4.0)
            Text(subTitle ?? "")
                .foregroundColor(Color.LK.a_grayTitle)
                .font(.subheadline)
                .lineLimit(0)
            Spacer(minLength: 6.0)
            
        }//.frame(width: UIScreen.main.bounds.width)
         //.background(Color.LK.main_whiteBackground)
    }
}
