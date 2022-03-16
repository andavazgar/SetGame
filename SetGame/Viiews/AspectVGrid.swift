//
//  AspectVGrid.swift
//  SetGame
//
//  Created by Andres Vazquez on 2022-03-01.
//

import SwiftUI

struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    let items: [Item]
    let minimumWidth: CGFloat
    let aspectRatio: CGFloat
    let bottomPadding: CGFloat
    let content: (Item) -> ItemView
    
    
    init(items: [Item], minimumWidth: CGFloat = .infinity, aspectRatio: CGFloat = 1, bottomPadding: CGFloat = 0, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.minimumWidth = minimumWidth
        self.aspectRatio = aspectRatio
        self.bottomPadding = bottomPadding
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollViewReader in
                    let width: CGFloat = max(minimumWidth, widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio))
                    
                    LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
                        ForEach(items) { item in
                            content(item)
                                .aspectRatio(aspectRatio, contentMode: .fit)
                        }
                        .onChange(of: items.count) { newValue in
                            if newValue > items.count {
                                // New items are being added, scroll to the bottom
                                withAnimation {
                                    scrollViewReader.scrollTo("endOfAspectVGrid")
                                }
                            }
                        }
                    }
                    .padding(.bottom, bottomPadding)
                    Color.clear.id("endOfAspectVGrid")
                }
            }
        }
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            
            if CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        
        if columnCount > itemCount {
            columnCount = itemCount
        }
        
        return floor(size.width / CGFloat(columnCount))
    }
}
