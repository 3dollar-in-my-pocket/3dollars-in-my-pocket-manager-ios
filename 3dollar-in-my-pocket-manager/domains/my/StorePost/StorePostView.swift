import SwiftUI

struct StorePostView: View {
    @StateObject private var viewModel = StorePostViewModel()
    @State var hasAppeared = false
    
    var body: some View {
        ZStack(content: {
            VStack(alignment: .leading, content: {
                if viewModel.postList.count == 0 {
                    StorePostEmptyView()
                } else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.flexible())], content: {
                            ForEach(0..<viewModel.postList.count, id: \.self) { index in
                                StorePostCell(post: $viewModel.postList[index], didTapEdit: {
                                    viewModel.didTapEdit.send(index)
                                }, didTapDelete: {
                                    viewModel.didTapDelete.send(index)
                                })
                                .onAppear(perform: {
                                    viewModel.cellWillDisplay.send(index)
                                })
                            }
                        })
                    }
                }
            })
            .onAppear(perform: {
                if hasAppeared.isNot {
                    viewModel.onAppear.send(())
                    hasAppeared = true
                }
            })
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    UploadButton(viewModel: viewModel)
                        .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
            }
        })
        .background(Color(red: 251/255, green: 251/255, blue: 251/255))
    }
    
    func fetchBackgroundColor() -> Color {
        if viewModel.postList.isEmpty {
            return .clear
        } else {
            return Color(red: 251/255, green: 251/255, blue: 251/255)
        }
    }
}

#Preview {
    StorePostView()
}

extension StorePostView {
    struct UploadButton: View {
        @StateObject var viewModel: StorePostViewModel
        
        var body: some View {
            Button(action: {
                viewModel.didTapWrite.send(())
            }) {
                HStack(spacing: 4) {
                    Image("ic_write_solid")
                        .frame(width: 20, height: 20)
                    
                    Text("store_post.upload")
                        .font(.medium(size: 16))
                }
                .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                .frame(height: 44)
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .background(Color.dollorGreen)
                .cornerRadius(22)
                .shadow(color: Color.dollorGreen.opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }
}
