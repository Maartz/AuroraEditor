//
//  NoSelectionView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// When a user doesn't have a file open but the Inspector View
// is open we will show them this view as empty placeholder.
struct NoSelectionView: View {
    /// The view body
    var body: some View {
        VStack {
            Text("No Selection")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoSelectionView()
    }
}
