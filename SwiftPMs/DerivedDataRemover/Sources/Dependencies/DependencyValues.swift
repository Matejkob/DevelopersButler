import Dependencies

extension DependencyValues {
    var fileManagerClinet: FileManagerClient {
        get { self[FileManagerClient.self] }
        set { self[FileManagerClient.self] = newValue }
    }
    
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
