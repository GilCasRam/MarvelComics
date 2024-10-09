//
//  VisualComponents.swift
//  MarvelComics
//
//  Created by Gil casimiro on 08/10/24.
//

import SwiftUI

struct SearchBarCustomV2: View {
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

#Preview {
    SearchBarCustomV2(textToSearch: .constant("hola"))
}
