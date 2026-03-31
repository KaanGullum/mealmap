import AppKit

enum RenderMode: String {
    case app
    case launch
}

struct Palette {
    static let launchBackground = NSColor(srgbRed: 0.968627451, green: 0.9490196078, blue: 0.9215686275, alpha: 1)
    static let tealStart = NSColor(srgbRed: 0.0588, green: 0.4431, blue: 0.4118, alpha: 1)
    static let tealEnd = NSColor(srgbRed: 0.0902, green: 0.2275, blue: 0.3333, alpha: 1)
    static let glow = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.18)
    static let secondaryGlow = NSColor(srgbRed: 0.741, green: 0.898, blue: 0.859, alpha: 0.18)
    static let ivory = NSColor(srgbRed: 1, green: 0.9686, blue: 0.9373, alpha: 1)
    static let plateInner = NSColor(srgbRed: 0.9059, green: 0.9373, blue: 0.9176, alpha: 1)
    static let yolk = NSColor(srgbRed: 1, green: 0.8392, blue: 0.6588, alpha: 1)
    static let marker = NSColor(srgbRed: 1, green: 0.4549, blue: 0.2549, alpha: 1)
    static let shadow = NSColor(srgbRed: 0.0431, green: 0.1686, blue: 0.2235, alpha: 0.22)
}

let args = CommandLine.arguments.dropFirst()
let mode = RenderMode(rawValue: String(args.first ?? "launch")) ?? .launch
let outputPath = String(args.dropFirst().first ?? "/tmp/MealMapLogo.png")
let canvasSize = CGSize(width: 1024, height: 1024)
let iconRect = CGRect(origin: .zero, size: canvasSize)

guard
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ),
    let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap)
else {
    fputs("Failed to create bitmap context.\n", stderr)
    exit(1)
}

bitmap.size = canvasSize

func roundedRectPath(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func fillLinearGradient(in context: CGContext, rect: CGRect, rounded: Bool) {
    let colors = [Palette.tealStart.cgColor, Palette.tealEnd.cgColor] as CFArray
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors,
        locations: [0, 1]
    )!

    context.saveGState()
    if rounded {
        context.addPath(roundedRectPath(rect, radius: 232))
        context.clip()
    }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 110, y: 114),
        end: CGPoint(x: 915, y: 915),
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )
    context.restoreGState()
}

func drawGlow(in context: CGContext) {
    context.saveGState()
    context.setFillColor(Palette.glow.cgColor)
    context.fillEllipse(in: CGRect(x: 200, y: 196, width: 624, height: 624))
    context.setFillColor(Palette.secondaryGlow.cgColor)
    context.fillEllipse(in: CGRect(x: 210, y: 220, width: 604, height: 604))
    context.restoreGState()
}

func drawFork(in context: CGContext) {
    context.saveGState()
    context.setFillColor(Palette.ivory.cgColor)

    [202, 224, 246, 268].forEach { x in
        let rect = CGRect(x: CGFloat(x), y: 320, width: 14, height: 138)
        context.addPath(roundedRectPath(rect, radius: 7))
        context.fillPath()
    }

    let head = CGMutablePath()
    head.move(to: CGPoint(x: 202, y: 442))
    head.addLine(to: CGPoint(x: 282, y: 442))
    head.addLine(to: CGPoint(x: 282, y: 458))
    head.addCurve(to: CGPoint(x: 251, y: 489), control1: CGPoint(x: 282, y: 475), control2: CGPoint(x: 268, y: 489))
    head.addLine(to: CGPoint(x: 233, y: 489))
    head.addCurve(to: CGPoint(x: 202, y: 458), control1: CGPoint(x: 216, y: 489), control2: CGPoint(x: 202, y: 475))
    head.closeSubpath()
    context.addPath(head)
    context.fillPath()

    context.addPath(roundedRectPath(CGRect(x: 229, y: 488, width: 26, height: 206), radius: 13))
    context.fillPath()
    context.restoreGState()
}

func drawKnife(in context: CGContext) {
    context.saveGState()
    context.setFillColor(Palette.ivory.cgColor)

    let blade = CGMutablePath()
    blade.move(to: CGPoint(x: 771, y: 318))
    blade.addCurve(to: CGPoint(x: 807, y: 441), control1: CGPoint(x: 795, y: 351), control2: CGPoint(x: 807, y: 392))
    blade.addCurve(to: CGPoint(x: 791, y: 529), control1: CGPoint(x: 807, y: 473), control2: CGPoint(x: 802, y: 502))
    blade.addLine(to: CGPoint(x: 771, y: 529))
    blade.closeSubpath()
    context.addPath(blade)
    context.fillPath()

    context.addPath(roundedRectPath(CGRect(x: 771, y: 529, width: 26, height: 165), radius: 13))
    context.fillPath()
    context.restoreGState()
}

func drawPlate(in context: CGContext) {
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: 22), blur: 20, color: Palette.shadow.cgColor)
    context.setFillColor(Palette.ivory.cgColor)
    context.fillEllipse(in: CGRect(x: 292, y: 290, width: 440, height: 440))
    context.setFillColor(Palette.plateInner.cgColor)
    context.fillEllipse(in: CGRect(x: 338, y: 336, width: 348, height: 348))
    context.setFillColor(Palette.yolk.cgColor)
    context.fillEllipse(in: CGRect(x: 366, y: 364, width: 292, height: 292))
    context.restoreGState()

    context.saveGState()
    context.setStrokeColor(Palette.ivory.withAlphaComponent(0.4).cgColor)
    context.setLineWidth(4)
    context.strokeEllipse(in: CGRect(x: 372, y: 370, width: 280, height: 280))
    context.restoreGState()
}

func drawMarker(in context: CGContext) {
    context.saveGState()
    context.setFillColor(Palette.marker.cgColor)

    let marker = CGMutablePath()
    marker.move(to: CGPoint(x: 512, y: 412))
    marker.addCurve(to: CGPoint(x: 444, y: 480), control1: CGPoint(x: 474, y: 412), control2: CGPoint(x: 444, y: 442))
    marker.addCurve(to: CGPoint(x: 512, y: 588), control1: CGPoint(x: 444, y: 523), control2: CGPoint(x: 484, y: 558))
    marker.addCurve(to: CGPoint(x: 580, y: 480), control1: CGPoint(x: 540, y: 558), control2: CGPoint(x: 580, y: 523))
    marker.addCurve(to: CGPoint(x: 512, y: 412), control1: CGPoint(x: 580, y: 442), control2: CGPoint(x: 550, y: 412))
    marker.closeSubpath()
    context.addPath(marker)
    context.fillPath()

    context.setFillColor(Palette.ivory.cgColor)
    context.fillEllipse(in: CGRect(x: 488, y: 455, width: 48, height: 48))
    context.restoreGState()
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphicsContext

let cgContext = graphicsContext.cgContext

cgContext.clear(iconRect)

cgContext.saveGState()
cgContext.translateBy(x: 0, y: canvasSize.height)
cgContext.scaleBy(x: 1, y: -1)

if mode == .launch {
    cgContext.setFillColor(Palette.launchBackground.cgColor)
    cgContext.fill(iconRect)
}

fillLinearGradient(in: cgContext, rect: iconRect, rounded: mode == .launch)
drawGlow(in: cgContext)
drawFork(in: cgContext)
drawKnife(in: cgContext)
drawPlate(in: cgContext)
drawMarker(in: cgContext)

cgContext.restoreGState()

NSGraphicsContext.restoreGraphicsState()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode PNG.\n", stderr)
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Wrote \(mode.rawValue) logo to \(outputPath)")
} catch {
    fputs("Failed to write PNG: \(error)\n", stderr)
    exit(1)
}
