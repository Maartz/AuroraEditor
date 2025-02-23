//
//  CreateNewTagView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/05.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control
import OSLog

struct CreateNewTagView: View {
    @Environment(\.dismiss)
    private var dismiss

    let workspace: WorkspaceDocument

    @State
    var commitHash: String = ""

    @State
    var tagName: String = ""

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "VCS Create new tag view")

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a new tag from revision:")
                .fontWeight(.bold)

            HStack {
                Text("From:")
                Text(commitHash)
                    .fontWeight(.medium)
            }
            .padding(.top, 5)

            HStack {
                Text("To:")
                TextField("", text: $tagName)
            }

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }

                if tagName.isEmpty
                    || tagName.count < 3
                    || tagName.count > 250 {
                    Button {} label: {
                        Text("Create...")
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                } else {
                    Button {
                        do {
                            logger.debug("\(commitHash)")

                            // Create a tag
                            try Tag().createTag(
                                directoryURL: workspace.workspaceURL(),
                                name: tagName,
                                targetCommitSha: commitHash
                            )

                            dismiss()
                        } catch {
                            logger.fault("Unable to create tag...")
                        }
                    } label: {
                        Text("Create")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 500, height: 150)
    }
}

struct CreateNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewTagView(workspace: WorkspaceDocument())
    }
}
