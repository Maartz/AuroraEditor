//
//  QuickHelpInspector.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
import SwiftUI

// When selecting a function in the editor the QuickHelp
// will give you a summary, decleration and discussion.
struct QuickHelpInspector: View {

    /// The preferences model
    @ObservedObject
    var preferences: AppPreferencesModel = .shared

    /// The workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The view body
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Help")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 13))
                .frame(minWidth: 250, maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 250, maxWidth: .infinity)
        .padding(5)
    }

    /// The view body when there is no quick help
    @ViewBuilder
    var noQuickHelp: some View {
        Text("No Quick Help")
            .foregroundColor(.secondary)
            .font(.system(size: 16))
            .fontWeight(.medium)
            .frame(minWidth: 250, maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 10)
        Button("Search Documentation") {

        }
        .background(in: RoundedRectangle(cornerRadius: 4))
        .frame(minWidth: 250, maxWidth: .infinity, alignment: .center)
        .font(.system(size: 12))
        Divider().padding(.top, 15)
    }
}

struct QuickHelpInspector_Previews: PreviewProvider {
    static var previews: some View {
        QuickHelpInspector()
    }
}
