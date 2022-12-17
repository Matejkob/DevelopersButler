import SwiftUI
import ComposableArchitecture
import DerivedDataRemover
import AppKit

@main
struct DevelopersButlerApp: App {
    var body: some Scene {
        MenuBarExtra {
            Menu {
                DerivedDataRemoverView(
                    store: Store(
                        initialState: DerivedDataRemover.State.build(),
                        reducer: DerivedDataRemover()
                    )
                )
            } label: {
                Text("Derived Data Remover")
            }
            
            Divider()
            
            Button("Preferences...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",")
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(systemName: "hammer")
        }
    }
}
//}

//    struct SettingsView: View {
//        @AppStorage("showCopyright") var showCopyright: Bool = false
//        @AppStorage("showMenuBar") var showMenuBar = true
//
//        var body: some View {
//            Form {
//                Toggle(isOn: $showCopyright) {
//                    Text("Show Copyright Notice")
//                }
//                Toggle(isOn: $showMenuBar) {
//                    Text("Show Menu Bar App")
//                }
//            }
//            .toggleStyle(.switch)
//            .formStyle(.grouped)
//            .frame(width: 300, height: 130)
//            .navigationTitle("Settings")
//        }
//    }

extension StorageClient: DependencyKey {
    public static let liveValue = Self(
        derivedDataCustomUrl: {
            nil
        }
    )
}
