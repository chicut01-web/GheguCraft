import Cocoa

let root = "/Users/christianizzo/Projects/GheguCraft"
let destDir = "\(root)/assets/app-icons"

// Update cadcraft.svg with exact geometry
let cadSvg = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <rect x="8" y="8" width="240" height="240" rx="52" ry="52" fill="#E51937"/>
  <g transform="translate(48, 48) scale(6.666)">
    <path fill="#FFFFFF" d="M3.8672 1.0527v.0157L0 3.3848v17.914l3.8965-2.332h18.3398V2.3301c0-.702-.5773-1.2774-1.2793-1.2774H3.8672zm7.5058 4.0098h3.3008l2.9844 9.9512h-2.5879l-.5683-2.1895h-2.9844l-.5703 2.1621h-2.416l2.8417-9.9238zm11.8633.0273v14.877H4.172l-2.0684 1.2383v.4648c0 .702.5793 1.2774 1.2813 1.2774H24V5.0898h-.7637zM12.9668 6.6816l-.9941 4.3243h2.0468l-1.0527-4.3243z"/>
  </g>
</svg>
"""
try! cadSvg.write(toFile: "/tmp/official_icons/cadcraft.svg", atomically: true, encoding: .utf8)

let apps = [
    "photocraft", "vectorcraft", "filmcraft", "lightcraft", "pdfcraft",
    "effectcraft", "designcraft", "wordcraft", "gridcraft", "deckcraft",
    "cadcraft", "soundcraft", "figcraft"
]

for app in apps {
    var svgPath = "/tmp/official_icons/\(app).svg"
    if app == "soundcraft" {
        svgPath = "/tmp/official_icons/audacity_app.svg"
    } else if app == "figcraft" {
        svgPath = "/tmp/official_icons/figcraft_square.svg"
    }
    
    guard let img = NSImage(contentsOfFile: svgPath) else {
        fatalError("Could not load \(svgPath)")
    }
    
    let canvasSize: CGFloat = 256.0
    let maxContent: CGFloat = 240.0
    
    // Compute aspect-fit rect within 240x240, centered in 256x256
    let aspect = img.size.width / img.size.height
    var drawW: CGFloat
    var drawH: CGFloat
    if aspect >= 1.0 {
        drawW = maxContent
        drawH = maxContent / aspect
    } else {
        drawH = maxContent
        drawW = maxContent * aspect
    }
    let drawX = (canvasSize - drawW) / 2.0
    let drawY = (canvasSize - drawH) / 2.0
    let drawRect = NSRect(x: drawX, y: drawY, width: drawW, height: drawH)
    
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize),
        pixelsHigh: Int(canvasSize),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    
    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = ctx
    
    // Clear to 100% transparent
    ctx.cgContext.clear(CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize))
    
    // High quality interpolation
    ctx.cgContext.interpolationQuality = .high
    
    img.draw(in: drawRect, from: NSRect(origin: .zero, size: img.size), operation: .sourceOver, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    
    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed PNG representation for \(app)")
    }
    
    let destPath = "\(destDir)/\(app).png"
    try! pngData.write(to: URL(fileURLWithPath: destPath))
    print("Rendered transparent \(app).png (\(Int(drawW))x\(Int(drawH)) inside 256x256)")
}
