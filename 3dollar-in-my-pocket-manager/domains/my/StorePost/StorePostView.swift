import SwiftUI

struct StorePostView: View {
    @StateObject var viewModel: StorePostViewModel
    @State var hasAppeared = false
    @State var isShowDeleteAlert = false
    @State var deleteIndex: Int? = nil
    
    var body: some View {
        ZStack(content: {
            VStack(alignment: .leading, content: {
                if viewModel.isLoading {
                    EmptyView()
                } else if viewModel.postList.count == 0 {
                    StorePostEmptyView()
                } else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.flexible())], content: {
                            ForEach(0..<viewModel.postList.count, id: \.self) { index in
                                StorePostCell(post: $viewModel.postList[index], didTapEdit: {
                                    viewModel.didTapEdit.send(index)
                                }, didTapDelete: {
                                    deleteIndex = index
                                    isShowDeleteAlert = true
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
        .alert(isPresented: $viewModel.isShowErrorAlert, content: {
            guard let error = viewModel.error else { return Alert(title: Text("error.unknown".localizable)) }
            
            if let httpError = error as? HTTPError,
               httpError == .unauthorized {
                
                return Alert(
                    title: Text(httpError.description), dismissButton: .cancel(Text("common_ok".localized), action: {
                        UserDefaultsUtils().clear()
                        goToSignIn()
                    }))
            } else if let localizedError = error as? LocalizedError {
                guard let title = localizedError.errorDescription else { return Alert(title: Text("error.unknown")) }
                
                return Alert(title: Text(title), message: nil, dismissButton: .cancel(Text("common_ok".localized)))
            } else {
                return Alert(title: Text(error.localizedDescription), message: nil, dismissButton: .cancel(Text("common_ok".localized)))
            }
        })
        .alert(isPresented: $isShowDeleteAlert) {
            Alert(
                title: Text("store_post_menu.delete_alert.title"),
                message: nil,
                primaryButton: .destructive(Text("common.delete"), action: {
                    if let deleteIndex {
                        viewModel.didTapDelete.send(deleteIndex)
                    }
                }),
                secondaryButton: .cancel(Text("common.cancel"))
            )
        }
    }
    
    func fetchBackgroundColor() -> Color {
        if viewModel.postList.isEmpty {
            return .clear
        } else {
            return Color(red: 251/255, green: 251/255, blue: 251/255)
        }
    }
    
    private func goToSignIn() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
    }
}

#Preview {
    StorePostView(viewModel: StorePostViewModel())
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
