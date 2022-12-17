import ComposableArchitecture
import SwiftUI

public struct DerivedDataRemover: ReducerProtocol {
    public struct State: Equatable {
        var items: IdentifiedArrayOf<DerivedDateItem> = []
        
        public static func build() -> Self { Self() }
    }
    
    public enum Action: Equatable {
        case fetchDerivedDataDirectoryContents
        case resivedDerivedDataDirectoryContents(urls: [URL])
        case deleteAll
        case deleteItem(id: DerivedDateItem.ID)
        case showInFinderItem(id: DerivedDateItem.ID)
    }
    
    @Dependency(\.fileManagerClinet) private var fileManagerClient
    @Dependency(\.storageClient) private var storageClient
    @Dependency(\.uuid) private var uuid

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchDerivedDataDirectoryContents:
                return fetchDerivedDataDirectoryContent()
                
            case let .resivedDerivedDataDirectoryContents(urls):
                return resivedDerivedDataDirectoryContents(
                    state: &state,
                    urls: urls
                )
                
            case .deleteAll:
                return .task {
                    let derivedDataUrl = try await derivedDataUrl()
                    try await fileManagerClient.removeItem(derivedDataUrl)
                    return .fetchDerivedDataDirectoryContents
                }
                
            case .deleteItem(id: let id):
                return .task { [items = state.items] in
                    guard let itemUrl = items[id: id]?.url else {
                        return .fetchDerivedDataDirectoryContents
                    }
                    try await fileManagerClient.removeItem(itemUrl)
                    return .fetchDerivedDataDirectoryContents
                }
                
            case .showInFinderItem(id: let id):
                guard let itemUrl = state.items[id: id]?.url else {
                    return .task { .fetchDerivedDataDirectoryContents }
                }
                
                let itemUrlAbsoluteString = itemUrl.absoluteString
                let itemPath = itemUrlAbsoluteString.replacingOccurrences(of: "file://", with: "")
                
                return .fireAndForget {
                    await fileManagerClient.showInFinder(itemPath)
                }
            }
        }
    }
    
    private func fetchDerivedDataDirectoryContent() -> EffectTask<Action> {
        .task {
            let derivedDataUrl = try await derivedDataUrl()
            let directoryContents = try await fileManagerClient
                .contentsOfDirectory(derivedDataUrl)
            return .resivedDerivedDataDirectoryContents(urls: directoryContents)
        }
    }
    
    private func derivedDataUrl() async throws -> URL {
        if let customUrl = storageClient.derivedDataCustomUrl() {
            return customUrl
        }
        
        return try await fileManagerClient
            .url(.libraryDirectory, .userDomainMask)
            .appending(path: "Developer/Xcode/DerivedData")
    }
    
    private func resivedDerivedDataDirectoryContents(
        state: inout State,
        urls: [URL]
    ) -> EffectTask<Action> {
        let items = urls.map { url in
            DerivedDateItem(
                id: uuid(),
                url: url,
                name: url.lastPathComponent
            )
        }
        state.items = IdentifiedArray(uniqueElements: items)
        
        return .none
    }
}
