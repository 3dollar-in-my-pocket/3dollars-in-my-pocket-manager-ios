//
//  StorePostEmptyView.swift
//  3dollar-in-my-pocket-manager
//
//  Created by Hyun Sik Yoo on 6/19/24.
//

import SwiftUI

struct StorePostEmptyView: View {
    var body: some View {
        VStack(content: {
            Image("img_empty_post")
                .frame(width: 208)
                .padding(.top, 60)
            
            Text(makeAttributedString())
                .font(.extraBold(size: 18))
                .multilineTextAlignment(.center)
                .padding(.top, 36)
            
            Spacer()
        })
    }
    
    func makeAttributedString() -> AttributedString {
        var attributedString = AttributedString("store_post.empty.title".localizable)
        // 특정 부분의 색상 변경
        if let range = attributedString.range(of: "store_post.empty.title.bold".localizable) {
            attributedString[range].foregroundColor = .dollorGreen
        }

        return attributedString
    }
}

#Preview {
    StorePostEmptyView()
}
