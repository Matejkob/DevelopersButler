import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct StorageClient {
    var derivedDataCustomUrl: @Sendable () -> URL?

    public init(derivedDataCustomUrl: @Sendable @escaping () -> URL?) {
        self.derivedDataCustomUrl = derivedDataCustomUrl
    }
}

extension StorageClient: TestDependencyKey {
    public static let testValue = Self(
        derivedDataCustomUrl: unimplemented()
    )
}
