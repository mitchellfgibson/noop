import Foundation
import WhoopProtocol

// SleepReadout.swift - pure values for the Sleep & Rest live-readout panel.
//
// hrDensityNow + gravityCoverageNow are computed from the same streams detection reads, so the
// panel shows what the detector sees. lastNightGateFired is parsed from the tagged log tail
// (the gate-trace lines E2/E3 emit), so the panel reflects exactly which gate fired tonight.
// No state, no side effects, no em-dashes.

public enum SleepReadout {

    /// HR samples per minute over the stream's own span. 0 when fewer than 2 samples.
    public static func hrDensityPerMinute(hr: [HRSample]) -> Double {
        guard hr.count >= 2 else { return 0 }
        let sorted = hr.sorted { $0.ts < $1.ts }
        let spanS = Double(sorted.last!.ts - sorted.first!.ts)
        if spanS <= 0 { return 0 }
        return Double(sorted.count) / (spanS / 60.0)
    }

    /// Fraction of the HR window the gravity stream spans, in [0, 1]. The same ratio the
    /// sparse-gravity gate keys on (`SleepStager.sparseGravitySpanFrac`); a value below that
    /// constant means tonight's gravity is sparse.
    public static func gravityCoverageFraction(gravity: [GravitySample], hr: [HRSample]) -> Double {
        guard gravity.count >= 2, hr.count >= 2 else { return 0 }
        let g = gravity.sorted { $0.ts < $1.ts }
        let h = hr.sorted { $0.ts < $1.ts }
        let hrSpan = Double(h.last!.ts - h.first!.ts)
        if hrSpan <= 0 { return 0 }
        let gravSpan = Double(g.last!.ts - g.first!.ts)
        return max(0.0, min(1.0, gravSpan / hrSpan))
    }

    /// The gate named by the most recent gate-trace line in the tagged log tail, or nil.
    /// Lines look like "[sleep] gate run=1 ... gate=accepted ...".
    public static func lastGateFired(taggedTail: [String]) -> String? {
        for line in taggedTail.reversed() where line.contains("gate=") {
            guard let range = line.range(of: "gate=") else { continue }
            let after = line[range.upperBound...]
            let token = after.prefix { $0 != " " }
            if !token.isEmpty { return String(token) }
        }
        return nil
    }
}
