//
//  FileCreationSelectionView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// File creation selection view
struct FileCreationSelectionView: View {
    /// Presentation mode
    @Environment(\.presentationMode)
    var presentationMode

    /// File creation model
    @StateObject
    private var creationSheetModel: FileCreationModel = .shared

    /// Workspace
    @State
    var workspace: WorkspaceDocument?

    /// Show file naming sheet
    @State
    var showFileNamingSheet: Bool = false

    /// The view body
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a template for your new file:")
                .font(.system(size: 12))
                .padding(.top, -10)

            FileCreationGridView()

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showFileNamingSheet = true
                } label: {
                    Text("Next")
                        .padding(10)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showFileNamingSheet) {
                    let ext = creationSheetModel.selectedLanguageItem.languageExtension
                    FileCreationNamingView(
                        workspace: workspace,
                        fileName: "untitled.\(ext)"
                    )
                }
            }
        }
        .frame(width: 697, height: 487)
        .padding()
    }
}
