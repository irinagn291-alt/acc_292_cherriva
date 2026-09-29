import Foundation

/// UserDefaults plus an atomic Application Support file. Views never call this.
actor EchoProjection {
    static let primaryKey = "epz.echo.v1"
    static let backupKey = "epz.echo.v1.backup"

    private let suiteName: String?
    private let fileURL: URL
    private let backupURL: URL
    private let fileManager: FileManager

    init(
        suiteName: String? = nil,
        directory: URL,
        fileManager: FileManager = .default
    ) {
        self.suiteName = suiteName
        self.fileManager = fileManager
        self.fileURL = directory.appendingPathComponent("echo.v1.json")
        self.backupURL = directory.appendingPathComponent("echo.v1.json.backup")
    }

    private var defaults: UserDefaults {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            return suite
        }
        return .standard
    }

    static func applicationSupportDirectory() throws -> URL {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = root.appendingPathComponent("Cherriva", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    func load() async -> EchoDocument {
        if let data = defaults.data(forKey: Self.primaryKey),
           let document = try? EchoDocumentCodec.decode(data) {
            return document
        }
        if let fileData = try? Data(contentsOf: fileURL),
           let document = try? EchoDocumentCodec.decode(fileData) {
            return document
        }
        if let backup = defaults.data(forKey: Self.backupKey),
           let document = try? EchoDocumentCodec.decode(backup) {
            var recovered = document
            recovered.loadWarning = "Restored the last good echo."
            return recovered
        }
        if let backupData = try? Data(contentsOf: backupURL),
           let document = try? EchoDocumentCodec.decode(backupData) {
            var recovered = document
            recovered.loadWarning = "Restored the last good echo."
            return recovered
        }
        var empty = EchoDocument.empty()
        empty.loadWarning = "Started a new echo."
        return empty
    }

    func save(_ document: EchoDocument) async {
        var outgoing = document
        outgoing.loadWarning = nil
        outgoing.schemaVersion = EchoDocument.currentSchema
        guard let data = try? EchoDocumentCodec.encoder().encode(outgoing) else { return }
        if let previous = defaults.data(forKey: Self.primaryKey) {
            defaults.set(previous, forKey: Self.backupKey)
        } else {
            defaults.set(data, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.primaryKey)
        await writeFile(data)
    }

    func reset() async {
        defaults.removeObject(forKey: Self.primaryKey)
        defaults.removeObject(forKey: Self.backupKey)
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: backupURL)
    }

    private func writeFile(_ data: Data) async {
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if fileManager.fileExists(atPath: fileURL.path) {
                if fileManager.fileExists(atPath: backupURL.path) {
                    try fileManager.removeItem(at: backupURL)
                }
                try fileManager.copyItem(at: fileURL, to: backupURL)
            }
            try data.write(to: fileURL, options: .atomic)
            if !fileManager.fileExists(atPath: backupURL.path) {
                try data.write(to: backupURL, options: .atomic)
            }
        } catch {
            return
        }
    }
}
