import Foundation

/// Errors that can occur during UCS CSV parsing.
public enum UCSParserError: Error, LocalizedError, Sendable {
    case fileNotFound(URL)
    case emptyData
    case malformedRow(lineNumber: Int, rawContent: String)
    case encodingError

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "Could not find the UCS CSV file at \(url.path)."
        case .emptyData:
            return "The parsed UCS data is empty."
        case .malformedRow(let lineNumber, let content):
            return "Malformed row at line \(lineNumber): \(content)"
        case .encodingError:
            return "Failed to decode the CSV string as UTF-8."
        }
    }
}
