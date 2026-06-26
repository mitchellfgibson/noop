package com.noop.testcentre

/**
 * The mandatory review-before-share gate (spec sections 9 and 12), twin of
 * Strand/System/ReportReviewGate.swift. Nothing is shared until the user has seen the exact redacted
 * report.txt and explicitly confirmed. Not skippable: confirm() is the only path to cleared. The
 * Compose review sheet binds to previewText and calls confirm() / cancel().
 */
class ReportReviewGate(private val entries: List<Pair<String, ByteArray>>) {

    var isCleared: Boolean = false
        private set

    /** The report.txt body the user is about to share, so they can read and cancel; "" if absent. */
    val previewText: String
        get() = entries.firstOrNull { it.first == "report.txt" }?.second?.let { String(it) } ?: ""

    /** Explicit user confirmation: the only way the gate clears. */
    fun confirm() { isCleared = true }
    /** Explicit cancel: leaves the gate uncleared so the share never fires. */
    fun cancel() { isCleared = false }
}
