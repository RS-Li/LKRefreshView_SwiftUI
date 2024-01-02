//
//  NewsListPageView.swift
//  LKRefreshView
//
//  Created by 李棒棒 on 2023/12/28.
//

import SwiftUI

enum RefreshStyle:Int {
    case header = 0
    case headerFooter = 1
    case loading = 2
}

struct NewsListPageView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isHeaderRefreshing = false
    @State private var isFooterRefreshing = false

    @State private var cellItems: [String] = []
    var cellTitles:[String] = {
        return ["昨天下午小米首款汽车SU7正式亮相，堪比跑车的颜值和所向披靡的性能，瞬间登上科技界头条",
                "张朝阳跨年演讲推导广义相对论：百年前的方程决定了GPS精确到米量级",
                "浙能电力：2023年1—11月完成发电量1467.40亿千瓦时 同比增长5.75%",
                "2023年青藏铁路累计运送进出藏旅客创历史新高",
                "盘江股份：子公司关岭县盘江百万千瓦级光伏基地项目一期实现部分并网发电"]
    }()
    
    var footerHidden: Bool = true
    
    var headerConfig:LKRefresh.HeaderConfig = LKRefresh.HeaderConfig(indicatorStyle: .loading)
    var footerConfig:LKRefresh.FooterConfig = LKRefresh.FooterConfig(indicatorStyle: .loading)
    
    init(refreshStyle: RefreshStyle) {
        
        //self.refreshStyle = refreshStyle
        
        if refreshStyle == .header {
            
            self.footerHidden = true
            headerConfig.indicatorStyle = .indicator
            footerConfig.indicatorStyle = .indicator
            
        } else if refreshStyle == .headerFooter {
            
            self.footerHidden = false
            headerConfig.indicatorStyle = .indicator
            footerConfig.indicatorStyle = .indicator
            
        } else if refreshStyle == .loading {
            
            self.footerHidden = false
            headerConfig.indicatorStyle = .loading
            footerConfig.indicatorStyle = .loading
        }
    }
    
    var body: some View {
        
        LKRefreshView(headerRefreshing: $isHeaderRefreshing,
                      footerRefreshing: $isFooterRefreshing,
                      footerHidden: footerHidden,
                      headerConfig: headerConfig,
                      footerConfig: footerConfig) {
            // 下拉刷新触发
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                //模拟加载数据
                self.loadData()
                // 刷新完成，关闭刷新
                isHeaderRefreshing = false
            })
        } moreTrigger: {
            
            // 上拉加载更多触发
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                //模拟加载更多
                for i in 0..<5{
                    cellItems.append(String("\((i - 1) + cellItems.count) - 苹果iPhone 15 Pro现品控问题，部分用户后玻璃盖板有粘合剂渗出"))
                }
                // 加载完成，关闭加载
                isFooterRefreshing = false
            })
            
        } content: {
            
            ScrollView {
                
                ForEach(cellItems.indices, id:\.self) { index in
                    let newsTitle:String = cellItems[index]
                    NewsListCell(title:newsTitle)
                }
                
            }
            .padding(0.0)
            .navigationBarHidden(false)
            .navigationBarTitle(Text("最新资讯"), displayMode: .inline)
            .navigationViewStyle(.stack)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button{
                presentationMode.wrappedValue.dismiss() //返回上级页面
            }label: {
                Image("nav_back_icon")
            }, trailing: Button{
                
                
            }label: {
                
                //Image("nav_back_icon")
            })
            .padding(0.0)
            .background(Color.LK.main_background)
            .onAppear {
                self.loadData()
            }
            
        }.background(Color.LK.main_background)
         .lkNavBar()
    }
}


extension NewsListPageView {
    
    func loadData() {
        cellItems = cellTitles
    }
}

//#Preview {
//    NewsListPageView()
//}


struct NewsListCell: View {
    
    var title:String = "昨天下午小米首款汽车SU7正式亮相，堪比跑车的颜值和所向披靡的性能，瞬间登上科技界头条"
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Image("news_img")
                    .resizable()
                    .frame(width: 120.0,height: 120.0)
                    .fixedSize(horizontal: true, vertical: true)
                    .cornerRadius(4.0)
                
                Spacer(minLength: 6.0)
                
                VStack(alignment: .leading){
                    
                    //Spacer(minLength: 4.0)
                    //昨天下午小米首款汽车SU7正式亮相，堪比跑车的颜值和所向披靡的性能，瞬间登上科技界头条
                    Text(title)
                        .foregroundColor(.LK.a_blackTitle)
                        .font(Font.system(size: 18.0,weight: .bold))
                        //.background(Color.green)
                        .padding(6.0)
                    
                    Spacer()
                    
                    HStack {
                        
                        VStack {
                            Text("百度百科")
                                .font(Font.system(size: 12.0))
                                .foregroundColor(.white)
                                
                        }.padding(2.0)
                         .cornerRadius(2.0)
                         .background(Color.cyan.opacity(0.6))
                        
                        Spacer()
                        Text("2023-12-29 10:11")
                            .font(Font.system(size: 12.0))
                            .foregroundColor(.LK.a_grayTitle)
                        Spacer()
                        Text("1.8万阅读")
                            .font(Font.system(size: 12.0))
                            .foregroundColor(.LK.a_grayTitle)
                        
                    }.padding(EdgeInsets(top: 0.0, leading: 6.0, bottom: 4.0, trailing: 6.0))
                    
                }//.background(Color.yellow)
                
            }.padding(0.0)
                
        }.padding(8.0)
         .background(Color.LK.main_whiteBackground)
        
    }
}
