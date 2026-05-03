import Foundation
import os

final class FileLog: @unchecked Sendable {
    static let shared = FileLog()

    private let queue = DispatchQueue(label: "dev.xueshi.macos-app-starter.filelog")
    private let url: URL
    private let osLog = Logger(subsystem: AppInfo.bundleID, category: "app")

    private init() {
        let logsDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs", isDirectory: true)
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        self.url = logsDir.appendingPathComponent("MacOSAppStarter.log")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
    }

    func info(_ message: String, file: String = #fileID, line: Int = #line) {
        write(level: "INFO", message: message, file: file, line: line)
    }

    func warn(_ message: String, file: String = #fileID, line: Int = #line) {
        write(level: "WARN", message: message, file: file, line: line)
    }

    func error(_ message: String, file: String = #fileID, line: Int = #line) {
        write(level: "ERROR", message: message, file: file, line: line)
    }

    private func write(level: String, message: String, file: String, line: Int) {
        osLog.log(level: .default, "\(level, privacy: .public): \(message, privacy: .public)")
        let stamp = ISO8601DateFormatter().string(from: Date())
        let line = "\(stamp) [\(level)] (\(file):\(line)) \(message)\n"
        let data = Data(line.utf8)
        let url = self.url
        queue.async {
            if let handle = try? FileHandle(forWritingTo: url) {
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
                try? handle.close()
            }
        }
    }

    var fileURL: URL { url }
}
