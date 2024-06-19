import SwiftUI

struct StorePostMenu: View {
    var didTapEdit: (() -> Void)?
    var didTapDelete: (() -> Void)?
    @State var isShowDeleteAlert = false
    
    var body: some View {
        SwiftUI.Menu {
            Button(action: {
                didTapEdit?()
            }, label: {
                HStack {
                    Text("수정하기")
                        .font(.regular(size: 12))
                        .foregroundColor(.gray80)
                    
                    Image("ic_write_line")
                        .renderingMode(.template)
                        .foregroundColor(.gray80)
                        .frame(width: 16, height: 16)
                }
            })
            
            Button(action: {
                isShowDeleteAlert = true
            }, label: {
                HStack {
                    Text("삭제하기")
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
        .alert(isPresented: $isShowDeleteAlert) {
            Alert(
                title: Text("게시글을 삭제하시겠습니까?"),
                message: nil,
                primaryButton: .destructive(Text("삭제"), action: {
                    didTapDelete?()
                }),
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
}

#Preview {
    StorePostMenu()
}
