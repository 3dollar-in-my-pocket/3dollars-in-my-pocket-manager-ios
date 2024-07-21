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
                .foregroundColor(.gray95)
                .font(.extraBold(size: 18))
                .multilineTextAlignment(.center)
                .padding(.top, 36)
            
            Spacer()
        })
    }
    
    func makeAttributedString() -> AttributedString {
        var attributedString = AttributedString("다양한 우리 가게의\n새로운 소식을 알려보세요!")
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
