import Foundation

/// The mandatory review-before-share gate (spec sections 9 and 12): nothing leaves the device until the
/// user has seen the exact redacted report.txt they are about to share and explicitly confirmed. The
/// gate is a small value type so its clear/cancel logic is unit-tested; the SwiftUI review sheet binds
/// to `previewText` and calls `confirm()` / `cancel()`. It is NOT skippable: the only path to cleared
/// is an explicit confirm.
struct ReportReviewGate {
    /// The bundle the user is about to share, already redacted by TestBundleAssembler.
    let entries: [FileExport.BundleEntry]
    private(set) var isCleared: Bool = false

    init(entries: [FileExport.BundleEntry]) { self.entries = entries }

    /// The report.txt body shown in the review sheet so the user can read what they're sharing and
    /// cancel if anything looks personal. Empty string if no report.txt is present.
    var previewText: String {
        guard let report = entries.first(where: { $0.name == "report.txt" }),
              let text = String(data: report.data, encoding: .utf8) else { return "" }
        return text
    }

    /// Explicit user confirmation: the only way the gate clears.
    mutating func confirm() { isCleared = true }
    /// Explicit cancel: leaves the gate uncleared so the share never fires.
    mutating func cancel() { isCleared = false }
}
