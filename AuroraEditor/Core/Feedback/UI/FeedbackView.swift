//
//  FeedbackView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/14.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// A feedback view that allows users to report
// any issue they might have had on the editor.
public struct FeedbackView: View {
    /// Initialize feedback view
    public init() {}

    /// Feedback model
    @ObservedObject
    private var feedbackModel: FeedbackModel = .shared

    /// App preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    /// Shows alert
    @State
    var showsAlert: Bool = false

    /// Is submit button pressed
    @State
    var isSubmitButtonPressed: Bool = false

    /// Feedback view body
    public var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    basicInformation
                    description
                }
                .padding(.horizontal, 90)
                .padding(.vertical, 30)
            }
            FeedbackToolbar {
                HelpButton(action: {})
                Spacer()
                if feedbackModel.isSubmitted {
                    Text("Feedback submitted")
                } else if feedbackModel.failedToSubmit {
                    Text("Failed to submit feedback")
                }
                Button {
                    feedbackModel.createIssue(title: feedbackModel.feedbackTitle,
                                              description: feedbackModel.issueDescription,
                                              steps: feedbackModel.stepsReproduceDescription,
                                              expectation: feedbackModel.expectationDescription,
                                              actuallyHappened: feedbackModel.whatHappenedDescription)
                    isSubmitButtonPressed = true
                } label: {
                    Text("Submit")
                }
                .alert(isPresented: self.$showsAlert) {
                    Alert(title: Text("No Github Account"),
                          message: Text("A GitHub account is required to submit feedback."),
                          primaryButton: .default(Text("Cancel")),
                          secondaryButton: .default(Text("Add Account")))
                }
            }
            .padding(10)
            .border(Color(NSColor.separatorColor))
        }
        .frame(width: 1028, height: 762)
    }

    /// Basic information view
    private var basicInformation: some View {
        VStack(alignment: .leading) {
            Text("Basic Information")
                .fontWeight(.bold)
                .font(.system(size: 20))

            VStack(alignment: .leading) {
                HStack {
                    if isSubmitButtonPressed && feedbackModel.feedbackTitle.isEmpty {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel(Text("Required Field"))
                            Text("Please provide a descriptive title for your feedback:")
                        }.padding(.leading, -23)
                    } else {
                        Text("Please provide a descriptive title for your feedback:")
                    }
                }
                TextField("", text: $feedbackModel.feedbackTitle)
                Text("Example: Aurora Editor crashes when using autocomplete")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.top, -5)

            VStack(alignment: .leading) {
                HStack {
                    if isSubmitButtonPressed && feedbackModel.issueAreaListSelection == "none" {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel(Text("Required Field"))
                            Text("Which area are you seeing an issue with?")
                        }.padding(.leading, -23)
                    } else {
                        Text("Which area are you seeing an issue with?")
                    }
                }
                Picker("", selection: $feedbackModel.issueAreaListSelection) {
                    ForEach(feedbackModel.issueAreaList) {
                        if feedbackModel.issueAreaListSelection == "none" {
                            Text($0.name)
                                .tag($0.id)
                                .foregroundColor(.secondary)
                        } else {
                            Text($0.name).tag($0.id)
                        }
                    }
                }
                .frame(width: 350)
                .labelsHidden()
            }
            .padding(.top)

            VStack(alignment: .leading) {
                if isSubmitButtonPressed && feedbackModel.feedbackTypeListSelection == "none" {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.red)
                            .accessibilityLabel(Text("Required Field"))
                        Text("What type of feedback are you reporting?")
                    }.padding(.leading, -23)
                } else {
                    Text("What type of feedback are you reporting?")
                }
                Picker("", selection: $feedbackModel.feedbackTypeListSelection) {
                    ForEach(feedbackModel.feedbackTypeList) {
                        if feedbackModel.feedbackTypeListSelection == "none" {
                            Text($0.name)
                                .tag($0.id)
                                .foregroundColor(.secondary)
                        } else {
                            Text($0.name).tag($0.id)
                        }
                    }
                }
                .frame(width: 350)
                .labelsHidden()
            }
            .padding(.top)
        }
    }

    /// Description view
    private var description: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .fontWeight(.bold)
                .font(.system(size: 20))
                .padding(.top)

            VStack(alignment: .leading) {
                HStack {
                    if isSubmitButtonPressed && feedbackModel.issueDescription.isEmpty {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel(Text("Required Field"))
                            Text("Please describe the issue:")
                        }.padding(.leading, -23)
                    } else {
                        Text("Please describe the issue:")
                    }
                }
                TextEditor(text: $feedbackModel.issueDescription)
                           .frame(minHeight: 127, alignment: .leading)
                           .border(Color(NSColor.separatorColor))
                Text("Example: Aurora Editor crashes when the autocomplete popup appears on screen.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.top, -5)

            VStack(alignment: .leading) {
                Text("Please list the steps you took to reproduce the issue:")
                TextEditor(text: $feedbackModel.stepsReproduceDescription)
                           .frame(minHeight: 60, alignment: .leading)
                           .border(Color(NSColor.separatorColor))
                Text("Example:")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("1. Open the attached sample project")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("2. type #import and wait for autocompletion to begin")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            VStack(alignment: .leading) {
                Text("What did you expect to happen?")
                TextEditor(text: $feedbackModel.expectationDescription)
                           .frame(minHeight: 60, alignment: .leading)
                           .border(Color(NSColor.separatorColor))
                Text("Example: I expected autocomplete to show me a list of headers.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            VStack(alignment: .leading) {
                Text("What actually happened?")
                TextEditor(
                    text: $feedbackModel.whatHappenedDescription
                )
                .frame(minHeight: 60, alignment: .leading)
                .border(Color(NSColor.separatorColor))
                // swiftlint:disable:next line_length
                Text("Example: The autocomplete window flickered on screen and Aurora Editor crashed.\nSee attached crashlog.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
    }

    /// Show feedback window
    public func showWindow() {
        FeedbackWindowController(view: self, size: NSSize(width: 1028, height: 762)).showWindow(nil)
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
