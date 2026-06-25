import UIKit

/// Renders the two Anyline tire glyphs (sidewall, tread) into tintable template
/// images. This is the iOS counterpart of the Android vector drawables — pure
/// presentation, no SDK involvement. Path data is sourced from the handoff
/// assets; the tread glyph clips its wheel to the left half so it does not
/// overlap the tread bars (the SVG's `clipPath`, applied here in code).
enum TireGlyphs {

    /// Source viewBox is 24×24; everything below is expressed in those units.
    private static let viewBox: CGFloat = 24

    static func sidewall(pointSize: CGFloat = 24) -> UIImage {
        render(pointSize: pointSize) { ctx in
            fill(sidewallPaths, in: ctx)
        }
    }

    static func tread(pointSize: CGFloat = 24) -> UIImage {
        render(pointSize: pointSize) { ctx in
            fill(treadBarPaths, in: ctx)
            ctx.saveGState()
            ctx.clip(to: CGRect(x: 1, y: 2.26416, width: 11.8851, height: 18.7126))
            fill(treadWheelPaths, in: ctx)
            ctx.restoreGState()
        }
    }

    /// Material "center_focus_strong" — the Tire Sidewall scan-button icon.
    static func centerFocusStrong(pointSize: CGFloat = 18) -> UIImage {
        render(pointSize: pointSize) { ctx in fill([centerFocusStrongPath], in: ctx) }
    }

    /// Material "crop_free" — the Tire Tread scan-button icon.
    static func cropFree(pointSize: CGFloat = 18) -> UIImage {
        render(pointSize: pointSize) { ctx in fill([cropFreePath], in: ctx) }
    }

    // MARK: - Rendering

    private static func render(pointSize: CGFloat, _ draw: (CGContext) -> Void) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pointSize, height: pointSize))
        let image = renderer.image { rendererContext in
            let ctx = rendererContext.cgContext
            let scale = pointSize / viewBox
            ctx.scaleBy(x: scale, y: scale)
            UIColor.black.setFill()
            draw(ctx)
        }
        // Template so the call site can tint it with the card's accent color.
        return image.withRenderingMode(.alwaysTemplate)
    }

    /// Each path is painted independently with the even-odd rule, matching how a
    /// browser renders separate `<path>` elements (so concentric ring paths read
    /// as rings, and separate shapes never cancel each other out).
    private static func fill(_ pathData: [String], in ctx: CGContext) {
        for d in pathData {
            ctx.addPath(SVGPath.cgPath(from: d))
            ctx.fillPath(using: .evenOdd)
        }
    }

    // MARK: - Path data (from icon-tire-sidewall.svg / icon-tire-tread.svg)

    private static let sidewallPaths: [String] = [
        "M4.27121,11.9998C4.27121,16.2853 7.77809,19.7593 12.104,19.7593C16.43,19.7593 19.9369,16.2853 19.9369,11.9998C19.9369,7.71441 16.43,4.24039 12.104,4.24039C7.77809,4.24039 4.27121,7.71441 4.27121,11.9998ZM18.0953,12.847C18.1868,12.3023 17.7306,11.8516 17.1784,11.8516H14.4178C14.1023,11.8516 13.8551,12.1128 13.757,12.4126C13.6578,12.7156 13.7041,13.0781 13.9634,13.2636L16.195,14.8603C16.6395,15.1784 17.2657,15.0834 17.515,14.5969C17.7972,14.0459 17.9929,13.4558 18.0953,12.847ZM13.5862,16.6897C13.7603,17.2175 13.4704,17.7945 12.9207,17.8768C12.3039,17.9693 11.6762,17.9693 11.0593,17.8768C10.5097,17.7945 10.2197,17.2175 10.3939,16.6897L11.2337,14.144C11.3348,13.8375 11.6672,13.6799 11.99,13.6799C12.3128,13.6799 12.6452,13.8375 12.7464,14.144L13.5862,16.6897ZM6.46512,14.5969C6.71436,15.0834 7.34058,15.1784 7.78513,14.8603L10.0167,13.2636C10.2759,13.0781 10.3223,12.7156 10.2231,12.4126C10.1249,12.1128 9.87777,11.8516 9.56225,11.8516L6.80173,11.8516C6.24945,11.8516 5.79327,12.3023 5.88482,12.847C5.98716,13.4558 6.18284,14.0459 6.46512,14.5969ZM7.80873,8.85967C7.35497,8.53499 7.24999,7.89455 7.65077,7.50635C8.0963,7.07481 8.60576,6.71211 9.16167,6.43078C9.65133,6.18297 10.2163,6.47528 10.3883,6.99643L11.2325,9.55531C11.3338,9.86232 11.1555,10.1872 10.8933,10.3763C10.6354,10.5623 10.2805,10.6283 10.0219,10.4433L7.80873,8.85967ZM14.8184,6.43078C14.3288,6.18297 13.7638,6.47528 13.5918,6.99643L12.7476,9.55531C12.6463,9.86232 12.8245,10.1872 13.0868,10.3763C13.3447,10.5623 13.6996,10.6283 13.9582,10.4433L16.1714,8.85967C16.6251,8.53499 16.7301,7.89455 16.3293,7.50635C15.8838,7.07481 15.3743,6.71211 14.8184,6.43078Z",
        "M23.208,12C23.208,18.0751 18.2366,23 12.104,23C5.97144,23 1,18.0751 1,12C1,5.92487 5.97144,1 12.104,1C18.2366,1 23.208,5.92487 23.208,12ZM20.8072,11.9998C20.8072,16.7614 16.9107,20.6215 12.104,20.6215C7.29743,20.6215 3.4009,16.7614 3.4009,11.9998C3.4009,7.23825 7.29743,3.37822 12.104,3.37822C16.9107,3.37822 20.8072,7.23825 20.8072,11.9998Z",
    ]

    private static let treadBarPaths: [String] = [
        "M16.942,1H19.44875V22.3073H16.942Z",
        "M13.3908,3.29785C13.6747,1.75455 14.0665,1.08274 16.1064,1V3.29785C15.3115,3.07835 14.696,3.07044 13.3908,3.29785Z",
        "M13.3908,20.0093C13.6747,21.5526 14.0665,22.2244 16.1064,22.3071V20.4271C16.1064,20.2182 15.0401,19.8555 13.3908,20.0093Z",
        "M16.1064,4.02044C15.3997,3.68252 14.7913,3.64658 13.3908,3.81062V5.80386C14.5008,5.76187 15.0924,5.81585 16.1064,6.01367V4.02044Z",
        "M16.1064,6.73577C15.3997,6.39785 14.7913,6.36191 13.3908,6.52595V8.51919C14.5008,8.4772 15.0924,8.53118 16.1064,8.729V6.73577Z",
        "M16.1064,9.45159C15.3997,9.11367 14.7913,9.07773 13.3908,9.24177V11.235C14.5008,11.193 15.0924,11.247 16.1064,11.4448V9.45159Z",
        "M16.1064,12.1674C15.3997,11.8295 14.7913,11.7936 13.3908,11.9576V13.9508C14.5008,13.9088 15.0924,13.9628 16.1064,14.1606V12.1674Z",
        "M16.1064,14.8827C15.3997,14.5448 14.7913,14.5089 13.3908,14.6729V16.6662C14.5008,16.6242 15.0924,16.6782 16.1064,16.876V14.8827Z",
        "M16.1064,17.5986C15.3997,17.2606 14.7913,17.2247 13.3908,17.3887V19.382C14.5008,19.34 15.0924,19.394 16.1064,19.5918V17.5986Z",
        "M23,3.29785C22.7161,1.75455 22.3243,1.08274 20.2844,1V3.29785C21.0793,3.07835 21.6948,3.07044 23,3.29785Z",
        "M23,20.0093C22.7161,21.5526 22.3243,22.2244 20.2844,22.3071V20.4271C20.2844,20.2182 21.3507,19.8555 23,20.0093Z",
        "M20.2844,4.02044C20.9911,3.68252 21.5996,3.64658 23,3.81062V5.80386C21.89,5.76187 21.2984,5.81585 20.2844,6.01367V4.02044Z",
        "M20.2844,6.73577C20.9911,6.39785 21.5996,6.36191 23,6.52595V8.51919C21.89,8.4772 21.2984,8.53118 20.2844,8.729V6.73577Z",
        "M20.2844,9.45159C20.9911,9.11367 21.5996,9.07773 23,9.24177V11.235C21.89,11.193 21.2984,11.247 20.2844,11.4448V9.45159Z",
        "M20.2844,12.1674C20.9911,11.8295 21.5996,11.7936 23,11.9576V13.9508C21.89,13.9088 21.2984,13.9628 20.2844,14.1606V12.1674Z",
        "M20.2844,14.8827C20.9911,14.5448 21.5996,14.5089 23,14.6729V16.6662C21.89,16.6242 21.2984,16.6782 20.2844,16.876V14.8827Z",
        "M20.2844,17.5986C20.9911,17.2606 21.5996,17.2247 23,17.3887V19.382C21.89,19.34 21.2984,19.394 20.2844,19.5918V17.5986Z",
    ]

    private static let treadWheelPaths: [String] = [
        "M3.75632,11.6205C3.75632,15.2656 6.71124,18.2205 10.3563,18.2205C14.0014,18.2205 16.9563,15.2656 16.9563,11.6205C16.9563,7.9754 14.0014,5.02048 10.3563,5.02048C6.71124,5.02048 3.75632,7.9754 3.75632,11.6205ZM6.85699,9.03582C6.40752,8.71117 6.30268,8.07382 6.70985,7.69748C7.02021,7.41062 7.36464,7.1624 7.73544,6.95838C8.21815,6.6928 8.78741,6.98743 8.95857,7.51112L9.62386,9.54674C9.70829,9.80509 9.55914,10.0777 9.33904,10.2372C9.12033,10.3956 8.81791,10.4522 8.59899,10.2941L6.85699,9.03582ZM5.53548,13.6869C5.7693,14.1849 6.40202,14.2809 6.84797,13.9588L8.59731,12.6952C8.81645,12.5369 8.85589,12.2304 8.77214,11.9733C8.68871,11.7173 8.47771,11.494 8.20844,11.494H6.04598C5.49369,11.494 5.0362,11.9459 5.14268,12.4878C5.22404,12.9019 5.35596,13.3046 5.53548,13.6869ZM14.4746,11.494C15.0269,11.494 15.4844,11.9459 15.3779,12.4878C15.2965,12.9019 15.1646,13.3046 14.9851,13.6869C14.7513,14.1849 14.1186,14.2809 13.6726,13.9588L11.9233,12.6952C11.7041,12.5369 11.6647,12.2304 11.7484,11.9733C11.8319,11.7173 12.0429,11.494 12.3121,11.494H14.4746ZM11.5599,15.4704C11.7319,15.9967 11.4427,16.5728 10.8931,16.6396C10.4728,16.6907 10.0478,16.6907 9.62748,16.6396C9.0779,16.5728 8.78871,15.9967 8.9607,15.4704L9.62426,13.4401C9.70864,13.1819 9.98866,13.0492 10.2603,13.0492C10.5319,13.0492 10.8119,13.1819 10.8963,13.4401L11.5599,15.4704ZM12.7851,6.95838C12.3024,6.6928 11.7332,6.98743 11.562,7.51112L10.8967,9.54674C10.8123,9.80509 10.9614,10.0777 11.1815,10.2372C11.4002,10.3956 11.7027,10.4522 11.9216,10.2941L13.6636,9.03582C14.1131,8.71117 14.2179,8.07382 13.8107,7.69748C13.5004,7.41062 13.1559,7.1624 12.7851,6.95838Z",
        "M19.7126,11.6205C19.7126,16.7878 15.5237,20.9768 10.3563,20.9768C5.18897,20.9768 1,16.7878 1,11.6205C1,6.45313 5.18897,2.26416 10.3563,2.26416C15.5237,2.26416 19.7126,6.45313 19.7126,11.6205ZM17.6897,11.6205C17.6897,15.6706 14.4064,18.9538 10.3563,18.9538C6.30623,18.9538 3.02299,15.6706 3.02299,11.6205C3.02299,7.57039 6.30623,4.28715 10.3563,4.28715C14.4064,4.28715 17.6897,7.57039 17.6897,11.6205Z",
    ]

    // Material glyphs (same path data as the Android vector drawables).
    private static let centerFocusStrongPath =
        "M12,8c-2.21,0 -4,1.79 -4,4s1.79,4 4,4 4,-1.79 4,-4 -1.79,-4 -4,-4zm-7,7H3v4c0,1.1 0.9,2 2,2h4v-2H5v-4zM5,5h4V3H5c-1.1,0 -2,0.9 -2,2v4h2V5zm14,-2h-4v2h4v4h2V5c0,-1.1 -0.9,-2 -2,-2zm0,16h-4v2h4c1.1,0 2,-0.9 2,-2v-4h-2v4z"
    private static let cropFreePath =
        "M3,5v4h2V5h4V3H5c-1.1,0 -2,0.9 -2,2zm2,10H3v4c0,1.1 0.9,2 2,2h4v-2H5v-4zm14,4h-4v2h4c1.1,0 2,-0.9 2,-2v-4h-2v4zm0,-16h-4v2h4v4h2V5c0,-1.1 -0.9,-2 -2,-2z"
}

/// Minimal SVG path-data parser supporting the commands used by the tire glyphs
/// (M/L/H/V/C and their relative forms, plus Z). Not a general SVG parser.
private enum SVGPath {

    private enum Token { case command(Character); case number(CGFloat) }

    static func cgPath(from d: String) -> CGPath {
        let path = CGMutablePath()
        let tokens = tokenize(d)
        var i = 0
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastControl: CGPoint?  // 2nd control point of the previous cubic, for smooth (S/s) curves

        func nextNumber() -> CGFloat {
            while i < tokens.count {
                defer { i += 1 }
                if case let .number(value) = tokens[i] { return value }
            }
            return 0
        }
        func peekIsNumber() -> Bool {
            if i < tokens.count, case .number = tokens[i] { return true }
            return false
        }

        while i < tokens.count {
            guard case let .command(command) = tokens[i] else { i += 1; continue }
            i += 1
            let relative = command.isLowercase
            if command != "C" && command != "c" && command != "S" && command != "s" {
                lastControl = nil
            }
            switch command {
            case "M", "m":
                var x = nextNumber(), y = nextNumber()
                if relative { x += current.x; y += current.y }
                current = CGPoint(x: x, y: y)
                subpathStart = current
                path.move(to: current)
                // Extra coordinate pairs after a moveto are implicit linetos.
                while peekIsNumber() {
                    var lx = nextNumber(), ly = nextNumber()
                    if relative { lx += current.x; ly += current.y }
                    current = CGPoint(x: lx, y: ly)
                    path.addLine(to: current)
                }
            case "L", "l":
                while peekIsNumber() {
                    var x = nextNumber(), y = nextNumber()
                    if relative { x += current.x; y += current.y }
                    current = CGPoint(x: x, y: y)
                    path.addLine(to: current)
                }
            case "H", "h":
                while peekIsNumber() {
                    var x = nextNumber()
                    if relative { x += current.x }
                    current.x = x
                    path.addLine(to: current)
                }
            case "V", "v":
                while peekIsNumber() {
                    var y = nextNumber()
                    if relative { y += current.y }
                    current.y = y
                    path.addLine(to: current)
                }
            case "C", "c":
                while peekIsNumber() {
                    var c1 = CGPoint(x: nextNumber(), y: nextNumber())
                    var c2 = CGPoint(x: nextNumber(), y: nextNumber())
                    var end = CGPoint(x: nextNumber(), y: nextNumber())
                    if relative {
                        c1 = CGPoint(x: c1.x + current.x, y: c1.y + current.y)
                        c2 = CGPoint(x: c2.x + current.x, y: c2.y + current.y)
                        end = CGPoint(x: end.x + current.x, y: end.y + current.y)
                    }
                    path.addCurve(to: end, control1: c1, control2: c2)
                    lastControl = c2
                    current = end
                }
            case "S", "s":
                while peekIsNumber() {
                    var c2 = CGPoint(x: nextNumber(), y: nextNumber())
                    var end = CGPoint(x: nextNumber(), y: nextNumber())
                    if relative {
                        c2 = CGPoint(x: c2.x + current.x, y: c2.y + current.y)
                        end = CGPoint(x: end.x + current.x, y: end.y + current.y)
                    }
                    let c1 = lastControl.map { CGPoint(x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                    path.addCurve(to: end, control1: c1, control2: c2)
                    lastControl = c2
                    current = end
                }
            case "Z", "z":
                path.closeSubpath()
                current = subpathStart
            default:
                // Unsupported command — drop any trailing numbers so we don't stall.
                while peekIsNumber() { _ = nextNumber() }
            }
        }
        return path
    }

    private static func tokenize(_ d: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(d)
        var i = 0
        let commandSet = Set("MmLlHhVvCcSsQqTtAaZz")

        while i < chars.count {
            let c = chars[i]
            if c == " " || c == "," || c == "\n" || c == "\t" || c == "\r" { i += 1; continue }
            if commandSet.contains(c) { tokens.append(.command(c)); i += 1; continue }

            var s = ""
            if c == "+" || c == "-" { s.append(c); i += 1 }
            while i < chars.count {
                let n = chars[i]
                if n.isNumber || n == "." {
                    s.append(n); i += 1
                } else if n == "e" || n == "E" {
                    s.append(n); i += 1
                    if i < chars.count, chars[i] == "+" || chars[i] == "-" { s.append(chars[i]); i += 1 }
                } else {
                    break
                }
            }
            if let value = Double(s) { tokens.append(.number(CGFloat(value))) }
        }
        return tokens
    }
}
