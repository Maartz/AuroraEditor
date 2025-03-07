//
//  ExtensionInstallationView.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 8.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension installation view.
struct ExtensionInstallationView: View {

    /// Plugin model
    @State
    var extensionData: Plugin

    /// The view body.
    @EnvironmentObject
    var document: WorkspaceDocument

    /// reopen alert
    @State
    var reopenAlert = false

    /// Installed
    @State
    var installed: Bool = false

    /// The view body.
    var body: some View {
        VStack {
//            Text(self.model.plugin.manifest.displayName)
//                .font(.headline)
            HStack {
//                if !self.installed {
//                    Picker("Release", selection: $model.release) {
//                        ForEach(model.releases) { release in
//                            Text(release.version)
//                                .tag(release as PluginRelease?)
//                        }
//
//                        if !model.listFull {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                                .onAppear {
//                                    model.fetch()
//                                }
//                        }
//                    }
//                    Button {
//                        Task {
//                            do {
//                                if let release = self.model.release {
//                                    try await ExtensionsManager.shared?.install(
//                                        plugin: self.model.plugin, release: release)
//                                    self.installed = ExtensionsManager.shared?.isInstalled(
//                                        plugin: model.plugin) ?? false
//                                    if self.installed {
//                                       self.reopenAlert = true
//                                   }
//                                }
//                            } catch let error {
//                                self.loggererror(error.localizedDescription)
//                            }
//                        }
//                    } label: {
//                        Text("Install")
//                    }
//                    .disabled(self.model.release == nil)
//                } else {
//                    Button {
//                        do {
//                           try ExtensionsManager.shared?.remove(plugin: self.model.plugin)
//                            self.installed = ExtensionsManager.shared?.isInstalled(plugin: model.plugin) ?? false
//                        } catch let error {
//                            self.loggererror(error.localizedDescription)
//                        }
//                    } label: {
//                        Text("Uninstall")
//                    }
//                }
            }
        }
        .alert("Extension is installed", isPresented: $reopenAlert) {
            Button("Reopen workspace") {
                guard let url = document.fileURL else { return }
                document.close()
                AuroraEditorDocumentController.shared.reopenDocument(for: url,
                                                                 withContentsOf: url,
                                                                 display: true) { _, _, _ in
                }
            }
            Button("Reopen later") {
                self.reopenAlert = false
            }
        } message: {
            Text("To make extension work, you need to reopen the workspace.")
        }
        .padding(.vertical)
        .onAppear {
//            self.installed = ExtensionsManager.shared.isInstalled(plugin: model.plugin) ?? false
        }
    }
}
