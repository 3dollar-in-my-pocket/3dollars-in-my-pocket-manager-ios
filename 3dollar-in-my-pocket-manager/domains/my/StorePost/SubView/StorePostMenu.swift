import SwiftUI

struct StorePostMenu: View {
    var didTapEdit: (() -> Void)?
    var didTapDelete: (() -> Void)?
    
    var body: some View {
        SwiftUI.Menu {
            Button(action: {
                didTapEdit?()
            }, label: {
                HStack {
                    Text("store_post_menu.edit")
                        .font(.regular(size: 12))
                        .foregroundColor(.gray80)
                    
                    Image("ic_write_line")
                        .renderingMode(.template)
                        .foregroundColor(.gray80)
                        .frame(width: 16, height: 16)
                }
            })
            
            Button(action: {
                didTapDelete?()
            }, label: {
                HStack {
                    Text("store_post_menu.delete")
                        .font(.regular(size: 12))
                        .foregroundColor(.gray80)
                    
                    Image("ic_trash")
                        .renderingMode(.template)
                        .foregroundColor(.gray80)
                        .frame(width: 16, height: 16)
                }
            })
        } label: {
            Image("ic_more")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.gray40)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    StorePostMenu()
}
