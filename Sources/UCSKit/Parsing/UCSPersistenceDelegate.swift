import Foundation

/// A protocol that allows the host app to receive parsed UCS data in batches.
///
/// Conformers are responsible for persisting or processing each batch
/// (e.g., writing to Realm, CoreData, or an in-memory cache).
///
/// All methods are called from within the ``UCSParser`` actor's isolation
/// context. Implementations must be `Sendable`.
public protocol UCSPersistenceDelegate: AnyObject, Sendable {
    /// Called when the parser has finished a batch of categories.
    func didParseBatch(_ categories: [UCSCategory]) async throws

    /// Called when the parser has completed reading the entire file.
    func didFinishParsing(totalCount: Int) async

    /// Called if the parser encounters an unrecoverable error.
    func didEncounterError(_ error: UCSParserError) async
}
