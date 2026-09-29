import SwiftUI
import UIKit

/// Commons thumbs for the quiz. URLSession carries a User-Agent Wikimedia will serve.
@MainActor
@Observable
final class PaintingCache {
    static let shared = PaintingCache()

    private(set) var images: [String: UIImage] = [:]
    private var inflight: [String: Task<UIImage?, Never>] = [:]

    func cached(_ urlString: String) -> UIImage? {
        images[urlString]
    }

    func image(for urlString: String) async -> UIImage? {
        if let hit = images[urlString] { return hit }
        if let task = inflight[urlString] { return await task.value }
        let task = Task { await Self.load(urlString) }
        inflight[urlString] = task
        let loaded = await task.value
        inflight[urlString] = nil
        if let loaded {
            images[urlString] = loaded
        }
        return loaded
    }

    func prefetch(_ urls: [String]) async {
        let unique = Array(Set(urls.filter { !$0.isEmpty && images[$0] == nil }))
        let fetched = await Self.fetchAll(unique)
        for (url, data) in fetched {
            if images[url] == nil, let picture = UIImage(data: data) {
                images[url] = picture
            }
        }
    }

    private static func load(_ urlString: String) async -> UIImage? {
        guard let row = await fetchAll([urlString]).first else { return nil }
        return UIImage(data: row.data)
    }

    private static func fetchAll(_ urls: [String]) async -> [(url: String, data: Data)] {
        await withTaskGroup(of: (String, Data)?.self) { group in
            for url in urls {
                group.addTask {
                    await fetch(url)
                }
            }
            var rows: [(url: String, data: Data)] = []
            for await row in group {
                if let row {
                    rows.append((url: row.0, data: row.1))
                }
            }
            return rows
        }
    }

    private static func fetch(_ urlString: String) async -> (String, Data)? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.setValue(CatalogClient.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("image/jpeg,image/png,image/*", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            return (urlString, data)
        } catch {
            return nil
        }
    }
}

/// Clipped painting. The frame owns the size; scaledToFill cannot spill into the title.
struct WorkPainting: View {
    let urlString: String

    var body: some View {
        Group {
            if let picture = PaintingCache.shared.cached(urlString) {
                Image(uiImage: picture)
                    .resizable()
                    .scaledToFill()
            } else {
                EchoColor.ink.opacity(0.08)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .task(id: urlString) {
            guard PaintingCache.shared.cached(urlString) == nil else { return }
            _ = await PaintingCache.shared.image(for: urlString)
        }
    }
}
