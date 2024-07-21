import SwiftUI
import Combine

struct StorePostCell: View {
    @Binding var post: StorePostApiResponse
    var didTapEdit: (() -> Void)?
    var didTapDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(post: $post, didTapEdit: didTapEdit, didTapDelete: didTapDelete)
            ImageGroupView(postSectionList: $post.sections)
            ContentView(description: $post.body)
        }
        .padding(.bottom, 16)
        .background(Color.white)
    }
}

#Preview {
    StorePostCell(post: .constant(PreviewMock.storePostList.contents.first!))
}

extension StorePostCell {
    struct HeaderView: View {
        @Binding var post: StorePostApiResponse
        var didTapEdit: (() -> Void)?
        var didTapDelete: (() -> Void)?
        
        var body: some View {
            HStack(content: {
                AsyncImage(url: URL(string: post.store.categories.first?.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .clipped()
                    default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(post.store.storeName)
                        .font(.bold(size: 14))
                        .foregroundColor(.gray100)
                        .frame(height: 20)
                    
                    Text(post.createdAt.createdAtFormatted)
                        .font(.regular(size: 14))
                        .foregroundColor(.gray40)
                        .frame(height: 18)
                }
                
                Spacer()
                
                StorePostMenu(didTapEdit: didTapEdit, didTapDelete: didTapDelete)
            })
            .padding(EdgeInsets(top: 16, leading: 24, bottom: 12, trailing: 24))
        }
    }
    
    struct ImageGroupView: View {
        @Binding var postSectionList: [PostSectionApiResponse]
        
        var body: some View {
            if postSectionList.isNotEmpty {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible(minimum: 208))], spacing: 12, content: {
                        ForEach(postSectionList, id: \.self) { postSection in
                            AsyncImage(url: URL(string: postSection.url)) { phase in
                                
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 200, height: 200)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(8)
                                        .frame(height: 208)
                                        .clipped()
                                default:
                                    Color.gray10
                                        .frame(minWidth: 208, minHeight: 208)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    })
                    .frame(height: 208)
                    .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                }
                .scrollIndicators(.hidden)
            } else {
                EmptyView()
            }
        }
    }
    
    struct ContentView: View {
        @Binding var description: String
        
        var body: some View {
            Text(description)
                .font(.regular(size: 14))
                .foregroundColor(.gray95)
                .lineSpacing(3)
                .padding(.leading, 24)
                .padding(.trailing, 24)
        }
    }
}
