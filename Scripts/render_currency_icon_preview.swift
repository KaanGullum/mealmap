import AppKit

struct Palette {
    static let background = NSColor(srgbRed: 0.969, green: 0.949, blue: 0.922, alpha: 1)
    static let cardFill = NSColor.white.withAlphaComponent(0.9)
    static let cardStroke = NSColor(srgbRed: 0.906, green: 0.902, blue: 0.886, alpha: 1)
    static let green = NSColor(srgbRed: 0.231, green: 0.784, blue: 0.373, alpha: 1)
    static let greenSoft = NSColor(srgbRed: 0.922, green: 0.980, blue: 0.941, alpha: 1)
    static let title = NSColor(srgbRed: 0.063, green: 0.333, blue: 0.361, alpha: 1)
    static let text = NSColor(srgbRed: 0.102, green: 0.118, blue: 0.149, alpha: 1)
    static let secondary = NSColor(srgbRed: 0.455, green: 0.471, blue: 0.510, alpha: 1)
    static let shadow = NSColor.black.withAlphaComponent(0.08)
}

struct PreviewOption {
    let symbolName: String
    let label: String
    let note: String
    let recommended: Bool
}

let outputPath = CommandLine.arguments.dropFirst().first
    ?? "/Users/kaangullu/Desktop/MealMap/MealMap/Design/Previews/currency-icon-preview.png"

let options = [
    PreviewOption(symbolName: "banknote", label: "banknote", note: "En temiz ve para biriminden bagimsiz", recommended: true),
    PreviewOption(symbolName: "wallet.pass", label: "wallet.pass", note: "Biraz daha urun hissi veriyor", recommended: false),
    PreviewOption(symbolName: "creditcard", label: "creditcard", note: "Daha odakli ama odeme hissi agir", recommended: false),
]

let canvasSize = CGSize(width: 1440, height: 1080)

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

func drawText(
    _ string: String,
    in rect: CGRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .left
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]

    string.draw(in: rect, withAttributes: attributes)
}

func roundedRectPath(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawSymbol(name: String, in rect: CGRect, color: NSColor) {
    let configuration = NSImage.SymbolConfiguration(pointSize: rect.height * 0.56, weight: .semibold)
    guard let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
        .withSymbolConfiguration(configuration) else {
        return
    }

    image.lockFocus()
    color.set()
    let imageBounds = NSRect(origin: .zero, size: image.size)
    imageBounds.fill(using: .sourceAtop)
    image.unlockFocus()

    let imageRect = CGRect(
        x: rect.midX - image.size.width / 2,
        y: rect.midY - image.size.height / 2,
        width: image.size.width,
        height: image.size.height
    )
    image.draw(in: imageRect)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphicsContext

let context = graphicsContext.cgContext
context.setFillColor(Palette.background.cgColor)
context.fill(CGRect(origin: .zero, size: canvasSize))

drawText(
    "MealMap planner cost icon direction",
    in: CGRect(x: 84, y: 930, width: 1272, height: 56),
    font: .systemFont(ofSize: 44, weight: .bold),
    color: Palette.text
)
drawText(
    "Turkce arayuzde tutar metni zaten TL olarak geliyor. Asagidaki fark, sadece sabit dolar ikonunu para biriminden bagimsiz bir sembolle degistirmek.",
    in: CGRect(x: 84, y: 864, width: 1200, height: 80),
    font: .systemFont(ofSize: 24, weight: .regular),
    color: Palette.secondary
)

let cardWidth: CGFloat = 392
let cardHeight: CGFloat = 548
let topY: CGFloat = 246
let startX: CGFloat = 84
let spacing: CGFloat = 48

for (index, option) in options.enumerated() {
    let x = startX + CGFloat(index) * (cardWidth + spacing)
    let cardRect = CGRect(x: x, y: topY, width: cardWidth, height: cardHeight)

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -10), blur: 28, color: Palette.shadow.cgColor)
    Palette.cardFill.setFill()
    roundedRectPath(cardRect, radius: 34).fill()
    context.restoreGState()

    Palette.cardStroke.setStroke()
    let strokePath = roundedRectPath(cardRect, radius: 34)
    strokePath.lineWidth = 1
    strokePath.stroke()

    if option.recommended {
        let badgeRect = CGRect(x: x + 28, y: topY + cardHeight - 64, width: 132, height: 34)
        Palette.greenSoft.setFill()
        roundedRectPath(badgeRect, radius: 17).fill()
        drawText(
            "Onerilen",
            in: CGRect(x: badgeRect.minX, y: badgeRect.minY + 6, width: badgeRect.width, height: 22),
            font: .systemFont(ofSize: 16, weight: .semibold),
            color: Palette.green,
            alignment: .center
        )
    }

    drawText(
        "Weekly Planner",
        in: CGRect(x: x + 28, y: topY + cardHeight - 118, width: 200, height: 24),
        font: .systemFont(ofSize: 18, weight: .medium),
        color: Palette.secondary
    )

    let metricRect = CGRect(x: x + 28, y: topY + 216, width: cardWidth - 56, height: 194)
    Palette.background.setFill()
    roundedRectPath(metricRect, radius: 26).fill()

    let symbolCircleRect = CGRect(x: metricRect.minX + 24, y: metricRect.maxY - 72, width: 48, height: 48)
    Palette.greenSoft.setFill()
    roundedRectPath(symbolCircleRect, radius: 24).fill()
    drawSymbol(name: option.symbolName, in: symbolCircleRect.insetBy(dx: 4, dy: 4), color: Palette.green)

    drawText(
        "₺148,75",
        in: CGRect(x: metricRect.minX + 24, y: metricRect.midY - 8, width: metricRect.width - 48, height: 42),
        font: .systemFont(ofSize: 34, weight: .bold),
        color: Palette.text
    )
    drawText(
        "Haftalik Tahmini Harcama",
        in: CGRect(x: metricRect.minX + 24, y: metricRect.minY + 30, width: metricRect.width - 48, height: 40),
        font: .systemFont(ofSize: 20, weight: .medium),
        color: Palette.secondary
    )

    drawText(
        option.label,
        in: CGRect(x: x + 28, y: topY + 138, width: cardWidth - 56, height: 34),
        font: .monospacedSystemFont(ofSize: 22, weight: .semibold),
        color: Palette.title
    )
    drawText(
        option.note,
        in: CGRect(x: x + 28, y: topY + 72, width: cardWidth - 56, height: 52),
        font: .systemFont(ofSize: 18, weight: .regular),
        color: Palette.secondary
    )
}

drawText(
    "Benim onerim: planner, recipe detail, dashboard ve tarif listesinde bu dili tek tip banknote ile kullanmak.",
    in: CGRect(x: 84, y: 88, width: 1230, height: 36),
    font: .systemFont(ofSize: 22, weight: .medium),
    color: Palette.title
)

NSGraphicsContext.restoreGraphicsState()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode PNG.\n", stderr)
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Wrote preview to \(outputPath)")
} catch {
    fputs("Failed to write PNG: \(error)\n", stderr)
    exit(1)
}
