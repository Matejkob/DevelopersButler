import Dependencies
import AppKit
import Foundation
import XCTestDynamicOverlay

struct FileManagerClient {
    var url: @Sendable (
        _ directory: FileManager.SearchPathDirectory,
        _ domain: FileManager.SearchPathDomainMask
    ) async throws -> URL
    var contentsOfDirectory: @Sendable (_ url: URL) async throws -> [URL]
    var removeItem: @Sendable (_ url: URL) async throws -> Void
    var showInFinder: @Sendable (_ path: String) async -> Void
}

extension FileManagerClient: DependencyKey {
    static let liveValue = Self(
        url: { directory, domain in
            try FileManager.default.url(
                for: directory,
                in: domain,
                appropriateFor: nil,
                create: false
            )
        },
        contentsOfDirectory: { url in
            try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            )
        },
        removeItem: { url in
            try FileManager.default.removeItem(at: url)
        },
        showInFinder: { path in
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
        }
    )
}

extension FileManagerClient: TestDependencyKey {
    static let testValue = Self(
        url: unimplemented(),
        contentsOfDirectory: unimplemented(),
        removeItem: unimplemented(),
        showInFinder: unimplemented()
    )
}
