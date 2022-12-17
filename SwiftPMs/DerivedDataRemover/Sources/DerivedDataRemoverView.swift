import SwiftUI
import ComposableArchitecture

public struct DerivedDataRemoverView: View {
    private let store: StoreOf<DerivedDataRemover>
    @ObservedObject private var viewStore: ViewStoreOf<DerivedDataRemover>
    
    public init(store: StoreOf<DerivedDataRemover>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
        
        viewStore.send(.fetchDerivedDataDirectoryContents)
    }
    
    public var body: some View {
        Group {
            deleteAllButton
        
            refreshListButton
            
            Divider()
            
            itemsList
        }
    }
    
    private var deleteAllButton: some View {
        Button {
            viewStore.send(.deleteAll)
        } label: {
            Text("Delete all")
                .foregroundColor(.red)
        }
    }
    
    private var refreshListButton: some View {
        Button {
            viewStore.send(.fetchDerivedDataDirectoryContents)
        } label: {
            Text("Refresh list")
        }
    }
    
    private var itemsList: some View {
        ForEach(viewStore.items) { item in
            Menu(item.name) {
                Button {
                    viewStore.send(.deleteItem(id: item.id))
                } label: {
                    Text("Delete")
                        .foregroundColor(.red)
                }
                .keyboardShortcut(.delete)

                Button("Show in finder") {
                    viewStore.send(.showInFinderItem(id: item.id))
                }
            } primaryAction: {
                viewStore.send(.deleteItem(id: item.id))
            }
        }
    }
}
