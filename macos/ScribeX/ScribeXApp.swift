import ScribeXUI
import SwiftUI

@main
struct ScribeXApp: App {
    @State private var engine = Engine(worker: Engine.bundledWorker)

    init() {
        #if DEBUG
        DebugScript.runIfRequested()
        #endif
    }

    var body: some Scene {
        // Shown at launch instead of an untitled document, and from the Window menu.
        Window("Welcome to ScribeX", id: HomeView.windowID) {
            HomeView().environment(engine)
        }
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .defaultSize(width: 1280, height: 820)
        .defaultLaunchBehavior(.presented)
        // The Window menu lists it once, with a shortcut, from MenuBar.
        .commandsRemoved()

        DocumentGroup(newDocument: { TexDocument() }) { file in
            DocumentView(document: file.document, fileURL: file.fileURL, engine: engine)
                .environment(engine)
                // Revert and Versions hand over a new document object. The window
                // starts over on it, or the editor would go on showing the old one
                // and typing into it, while saves wrote the new.
                .id(ObjectIdentifier(file.document))
        }
        .defaultSize(width: 1280, height: 820)
        .defaultLaunchBehavior(.suppressed)
        .commands { MenuBar(engine: engine) }
    }
}
