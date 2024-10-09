//
//  VisualComponents.swift
//  MarvelComics
//
//  Created by Gil casimiro on 08/10/24.
//

import SwiftUI

/// A custom search bar view.
///
/// `SearchBarCustomV` is a view that includes a text field where the user can type their search query.
/// It also includes a magnifying glass icon indicating the search functionality.
///
/// - Parameters:
///   - textToSearch: A `Binding` to the variable that holds the text the user types in the search field.
///
struct SearchBarCustom: View {
    @Binding var textToSearch: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.init(hex: "#A09898")!)
                TextField("Buscar", text: $textToSearch)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color.white)
                    .frame(height: 50)
            )
        }
        .padding(.horizontal)
    }
}
/// A view representing a comic item.
///
/// `ComicItemView` displays the comic's thumbnail and title in a card-like design.
/// If the thumbnail image is available, it is loaded asynchronously.
/// It visually adapts to a specific size and handles cases where the title is too long.
///
/// - Parameters:
///   - comic: The comic to be displayed, which includes properties like the thumbnail and title.
///
struct ComicItemView: View {
    let comic: Comic
    
    var body: some View {
        VStack {
            if let url = comic.thumbnail.url{
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 150)
            }
            Text(comic.title)
                .font(.footnote)
                .foregroundStyle(Color.black)
                .lineLimit(2)
        }
        .padding()
        .background(Color.init(hex: "#518cca")!)
        .cornerRadius(8)
    }
}

#Preview {
    SearchBarCustom(textToSearch: .constant("hola"))
}
