import XCTest
@testable import ComposableArchitecture
@testable import DerivedDataRemover

@MainActor
final class UT_DerivedDataRemover: XCTestCase {
    func test_fetchDerivedDataDirectoryContent_fromDefaultDirectory() async {
        var storageClientDerivedDataCustomUrlCallsCount = 0
        var fileManagerClinetUrlResivedDirectory: FileManager.SearchPathDirectory?
        var fileManagerClinetUrlResivedDomain: FileManager.SearchPathDomainMask?
        var fileManagerClientUrlCallsCount = 0
        var fileManagerClinetContentsOfDirectoryResivedUrl: URL?
        var fileManagerClientContentsOfDirectoryCallsCount = 0
        
        let expectedUrls = [URL]()
        
        let initialState = DerivedDataRemover.State()
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.storageClient.derivedDataCustomUrl = { @MainActor in
            storageClientDerivedDataCustomUrlCallsCount += 1
            return nil
        }
        store.dependencies.fileManagerClinet.url = { @MainActor directory, domain in
            fileManagerClinetUrlResivedDirectory = directory
            fileManagerClinetUrlResivedDomain = domain
            fileManagerClientUrlCallsCount += 1
            return URL(filePath: "/first_part_of_url/")
        }
        store.dependencies.fileManagerClinet.contentsOfDirectory = { @MainActor url in
            fileManagerClinetContentsOfDirectoryResivedUrl = url
            fileManagerClientContentsOfDirectoryCallsCount += 1
            return expectedUrls
        }
        
        await store.send(.fetchDerivedDataDirectoryContents)
        await store.receive(.resivedDerivedDataDirectoryContents(urls: expectedUrls))
        
        XCTAssertEqual(storageClientDerivedDataCustomUrlCallsCount, 1)
        XCTAssertEqual(
            fileManagerClinetUrlResivedDirectory,
            FileManager.SearchPathDirectory.libraryDirectory
        )
        XCTAssertEqual(
            fileManagerClinetUrlResivedDomain,
            FileManager.SearchPathDomainMask.userDomainMask
        )
        XCTAssertEqual(fileManagerClientUrlCallsCount, 1)
        XCTAssertEqual(
            fileManagerClinetContentsOfDirectoryResivedUrl,
            URL(filePath: "/first_part_of_url/Developer/Xcode/DerivedData")
        )
        XCTAssertEqual(fileManagerClientContentsOfDirectoryCallsCount, 1)
    }
    
    func test_fetchDerivedDataDirectoryContent_fromCustomDirectory() async {
        var storageClientDerivedDataCustomUrlCallsCount = 0
        var fileManagerClinetContentsOfDirectoryResivedUrl: URL?
        var fileManagerClientContentsOfDirectoryCallsCount = 0
        
        let expectedUrls = [URL]()
        let expectedUrl = URL(filePath: "/custom/derivedData/path")
        
        let initialState = DerivedDataRemover.State()
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.storageClient.derivedDataCustomUrl = { @MainActor in
            storageClientDerivedDataCustomUrlCallsCount += 1
            return expectedUrl
        }
        store.dependencies.fileManagerClinet.contentsOfDirectory = { @MainActor url in
            fileManagerClinetContentsOfDirectoryResivedUrl = url
            fileManagerClientContentsOfDirectoryCallsCount += 1
            return expectedUrls
        }
        
        await store.send(.fetchDerivedDataDirectoryContents)
        await store.receive(.resivedDerivedDataDirectoryContents(urls: expectedUrls))

        XCTAssertEqual(fileManagerClinetContentsOfDirectoryResivedUrl, expectedUrl)
        XCTAssertEqual(fileManagerClientContentsOfDirectoryCallsCount, 1)
    }
    
    func test_resivedDerivedDataDirectoryContents_transformThemIntoItems() async {
        let initialState = DerivedDataRemover.State()
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.uuid = .incrementing
        
        let urls = [
            URL(filePath: "/some/filePath/first_name"),
            URL(filePath: "/another/path/second_name"),
            URL(filePath: "/custom/myPath69/third_name")
        ]
        
        await store.send(.resivedDerivedDataDirectoryContents(urls: urls)) {
            $0.items = [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: urls[0],
                    name: "first_name"
                ),
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    url: urls[1],
                    name: "second_name"
                ),
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    url: urls[2],
                    name: "third_name"
                )
            ]
        }
    }

    func test_deleteAll_fromDefaultDirectory() async {
        var fileManagerClientRemoveItemResivedUrl: URL?
        var fileManagerClientRemoveItemCallsCount = 0
        
        let expectedFirstPartOfUrl = "/root/"
        let expectedUrls = [URL]()
        
        let initialState = DerivedDataRemover.State(
            items: [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: URL(filePath: "/myRoot/"),
                    name: "name"
                )
            ]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.storageClient.derivedDataCustomUrl = { nil }
        store.dependencies.fileManagerClinet.url = { _, _ in
            URL(filePath: expectedFirstPartOfUrl)
        }
        store.dependencies.fileManagerClinet.removeItem = { @MainActor url in
            fileManagerClientRemoveItemResivedUrl = url
            fileManagerClientRemoveItemCallsCount += 1
        }
        store.dependencies.fileManagerClinet.contentsOfDirectory = { _ in expectedUrls }
        
        await store.send(.deleteAll)
        await store.receive(.fetchDerivedDataDirectoryContents)
        await store.receive(.resivedDerivedDataDirectoryContents(urls: expectedUrls)) {
            $0.items = []
        }
        
        XCTAssertEqual(
            fileManagerClientRemoveItemResivedUrl,
            URL(filePath: "\(expectedFirstPartOfUrl)Developer/Xcode/DerivedData")
        )
        XCTAssertEqual(fileManagerClientRemoveItemCallsCount, 1)
    }
    
    func test_deleteAll_fromCustomDirectory() async {
        var fileManagerClientRemoveItemResivedUrl: URL?
        var fileManagerClientRemoveItemCallsCount = 0
        
        let expectedUrl = URL(filePath: "/myCustomPath/21/37/")
        let expectedUrls = [URL]()
        
        let initialState = DerivedDataRemover.State(
            items: [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: URL(filePath: "/myRoot/"),
                    name: "name"
                )
            ]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.storageClient.derivedDataCustomUrl = { expectedUrl }
        store.dependencies.fileManagerClinet.removeItem = { @MainActor url in
            fileManagerClientRemoveItemResivedUrl = url
            fileManagerClientRemoveItemCallsCount += 1
        }
        store.dependencies.fileManagerClinet.contentsOfDirectory = { _ in expectedUrls }
        
        await store.send(.deleteAll)
        await store.receive(.fetchDerivedDataDirectoryContents)
        await store.receive(.resivedDerivedDataDirectoryContents(urls: expectedUrls)) {
            $0.items = []
        }
        
        XCTAssertEqual(fileManagerClientRemoveItemResivedUrl, expectedUrl)
        XCTAssertEqual(fileManagerClientRemoveItemCallsCount, 1)
    }
    
    func test_deleteItem() async {
        var fileManagerClientRemoveItemResivedUrl: URL?
        var fileManagerClientRemoveItemCallsCount = 0
        
        let itemToDelete = DerivedDateItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            url: URL(filePath: "/myRoot/"),
            name: "name"
        )
        let otherItem = DerivedDateItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            url: URL(filePath: "/root_123/second_name"),
            name: "second_name"
        )
        
        let initialState = DerivedDataRemover.State(
            items: [itemToDelete, otherItem]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.storageClient.derivedDataCustomUrl = { nil }
        store.dependencies.fileManagerClinet.removeItem = { @MainActor url in
            fileManagerClientRemoveItemResivedUrl = url
            fileManagerClientRemoveItemCallsCount += 1
        }
        store.dependencies.fileManagerClinet.url = { _, _ in URL(filePath: "") }
        store.dependencies.fileManagerClinet.contentsOfDirectory = { _ in [otherItem.url] }
        store.dependencies.uuid = .incrementing
        
        await store.send(.deleteItem(id: itemToDelete.id))
        await store.receive(.fetchDerivedDataDirectoryContents)
        await store.receive(.resivedDerivedDataDirectoryContents(urls: [otherItem.url])) {
            $0.items = [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: otherItem.url,
                    name: otherItem.name
                )
            ]
        }
        
        XCTAssertEqual(fileManagerClientRemoveItemResivedUrl, itemToDelete.url)
        XCTAssertEqual(fileManagerClientRemoveItemCallsCount, 1)
    }
    
    func test_deleteItem_whichDoesNotExistInArray() async {
        let initialState = DerivedDataRemover.State(
            items: [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: URL(filePath: "/myRoot/name"),
                    name: "name"
                )
            ]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.exhaustivity = .off
        
        await store.send(.deleteItem(
            id: DerivedDateItem.ID(uuidString: "00000000-1234-1234-1234-000000000123")!
        ))
        await store.receive(.fetchDerivedDataDirectoryContents)
    }
    
    func test_showInFinderItem() async {
        var fileManagerClientShowInFinderResivedPath: String?
        var fileManagerClientShowInFinderCallsCount = 0
        
        let itemToSeeInFinderPath = "/myRoot/name"
        
        let itemToSeeInFinder = DerivedDateItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            url: URL(filePath: itemToSeeInFinderPath),
            name: "name"
        )
        
        let initialState = DerivedDataRemover.State(
            items: [itemToSeeInFinder]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.dependencies.fileManagerClinet.showInFinder = { @MainActor path in
            fileManagerClientShowInFinderResivedPath = path
            fileManagerClientShowInFinderCallsCount += 1
        }
        
        await store.send(.showInFinderItem(id: itemToSeeInFinder.id))
        
        XCTAssertEqual(fileManagerClientShowInFinderResivedPath, itemToSeeInFinderPath)
        XCTAssertEqual(fileManagerClientShowInFinderCallsCount, 1)
    }
    
    func test_showInFinderItem_whichDoesNotExistInArray() async {
        let initialState = DerivedDataRemover.State(
            items: [
                DerivedDateItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    url: URL(filePath: "/myRoot/name"),
                    name: "name"
                )
            ]
        )
        
        let store = TestStore(initialState: initialState, reducer: DerivedDataRemover())
        
        store.exhaustivity = .off
        
        await store.send(.showInFinderItem(
            id: DerivedDateItem.ID(uuidString: "00000000-1234-1234-1234-000000000123")!
        ))
        await store.receive(.fetchDerivedDataDirectoryContents)
    }
}
