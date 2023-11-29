//
//  ContentView.swift
//  Aurora Editor Updater
//
//  Created by Nanashi Li on 2023/10/03.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Sentry

struct ContentView: View {

    let updateText = [
        "Why did the software developer go broke? Because he used up all his cache!",
        "How do software developers stay cool in the summer? They use fans.",
        "Why was the computer cold? It left its Windows open.",
        "What do you call a software developer from Finland? Nerdic.",
        "Why do programmers always mix up Christmas and Halloween? Because Oct 31 == Dec 25.",
        "What did the software developer do during lunchtime? He had a byte.",
        "Why did the software developer go broke? Because he lost his domain in a poker game!",
        "Why did the software developer always carry a pencil and paper? In case he had to draw a flowchart.",
        "Why do Java developers wear glasses? Because they don't see sharp!",
        "How do you comfort a JavaScript bug? You console it!"
    ]

    @State
    private var randomIndex: Int

    init() {
        self.randomIndex = Int.random(in: 0..<updateText.count)
    }

    var body: some View {
        VStack {
            Text("Installing Aurora Editor Update")
                .frame(width: 300)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .bold))

            LoaderView()
                .frame(maxWidth: 300, maxHeight: 300)

            Text(updateText[randomIndex])
                .frame(height: 32)
                .font(.system(size: 12))
                .padding(.vertical, 10)
                .multilineTextAlignment(.center)
                .onAppear {
                    // Start a timer to change the text every 5 seconds
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                        randomIndex = Int.random(in: 0..<updateText.count)
                    }
                }

        }
        .padding()
        .frame(width: 350, height: 400)
        .onOpenURL { url in
            // Define a set of allowed URL schemes.
            let allowedSchemes: Set<String> = ["updateservice", "aefallbackservice"]

            // Validate the URL scheme.
            guard let scheme = url.scheme, allowedSchemes.contains(scheme) else {
                return
            }

            let dataUrl = url.relativeString.components(separatedBy: "%5C")[1]

            do {
                if scheme == "updateservice" {
                    let fileManager = FileManager.default

                    // Ensure that the directory exists.
                    guard fileManager.fileExists(atPath: String(dataUrl)) else {
                        return
                    }

                    // Get the contents of the directory.
                    let contents = try fileManager.contentsOfDirectory(atPath: String(dataUrl))

                    if let firstContent = contents.first {
                        // Perform the update operation.
                        AEUpdateService().installAuroraEditorUpdate(updateFile: "\(dataUrl)/\(firstContent)")
                    }
                } else if scheme == "aefallbackservice" {
                    // Handle aefallbackservice scheme here if needed.
                }
            } catch {
                SentrySDK.capture(error: error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
