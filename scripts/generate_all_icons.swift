import AppKit
import Foundation

struct IconSpec {
    let id: String
    let bg0: (CGFloat, CGFloat, CGFloat)
    let bg1: (CGFloat, CGFloat, CGFloat)
    let border: (CGFloat, CGFloat, CGFloat)
    let text: String
    let textColor: (CGFloat, CGFloat, CGFloat)
    let fontSize: CGFloat
}

let specs: [IconSpec] = [
    IconSpec(id: "photocraft", bg0: (0.00, 0.08, 0.16), bg1: (0.00, 0.14, 0.26), border: (0.19, 0.66, 1.00), text: "Ps", textColor: (0.19, 0.66, 1.00), fontSize: 58),
    IconSpec(id: "vectorcraft", bg0: (0.17, 0.05, 0.00), bg1: (0.26, 0.08, 0.00), border: (1.00, 0.60, 0.00), text: "Ai", textColor: (1.00, 0.60, 0.00), fontSize: 58),
    IconSpec(id: "filmcraft", bg0: (0.11, 0.00, 0.18), bg1: (0.19, 0.00, 0.30), border: (0.92, 0.47, 1.00), text: "Pr", textColor: (0.92, 0.47, 1.00), fontSize: 58),
    IconSpec(id: "lightcraft", bg0: (0.00, 0.10, 0.17), bg1: (0.00, 0.17, 0.28), border: (0.22, 0.74, 0.97), text: "Lr", textColor: (0.22, 0.74, 0.97), fontSize: 58),
    IconSpec(id: "pdfcraft", bg0: (0.15, 0.00, 0.02), bg1: (0.25, 0.00, 0.05), border: (1.00, 0.23, 0.19), text: "Ac", textColor: (1.00, 0.23, 0.19), fontSize: 58),
    IconSpec(id: "effectcraft", bg0: (0.10, 0.00, 0.15), bg1: (0.18, 0.00, 0.28), border: (0.82, 0.40, 1.00), text: "Ae", textColor: (0.82, 0.40, 1.00), fontSize: 58),
    IconSpec(id: "designcraft", bg0: (0.16, 0.00, 0.08), bg1: (0.27, 0.00, 0.14), border: (1.00, 0.20, 0.40), text: "Id", textColor: (1.00, 0.20, 0.40), fontSize: 58),
    IconSpec(id: "wordcraft", bg0: (0.05, 0.23, 0.54), bg1: (0.07, 0.33, 0.73), border: (0.35, 0.60, 0.95), text: "W", textColor: (1.00, 1.00, 1.00), fontSize: 64),
    IconSpec(id: "deckcraft", bg0: (0.64, 0.19, 0.05), bg1: (0.78, 0.25, 0.11), border: (0.95, 0.48, 0.35), text: "P", textColor: (1.00, 1.00, 1.00), fontSize: 64),
    IconSpec(id: "gridcraft", bg0: (0.05, 0.36, 0.18), bg1: (0.07, 0.49, 0.25), border: (0.28, 0.75, 0.45), text: "X", textColor: (1.00, 1.00, 1.00), fontSize: 64),
    IconSpec(id: "cadcraft", bg0: (0.11, 0.11, 0.14), bg1: (0.17, 0.17, 0.21), border: (0.90, 0.15, 0.16), text: "CAD", textColor: (0.90, 0.15, 0.16), fontSize: 44),
    IconSpec(id: "soundcraft", bg0: (0.00, 0.12, 0.22), bg1: (0.00, 0.22, 0.36), border: (0.00, 0.71, 0.85), text: "Au", textColor: (0.00, 0.71, 0.85), fontSize: 58)
]

let size = NSSize(width: 128, height: 128)
let baseDir = "assets/app-icons"

for spec in specs {
    let image = NSImage(size: size)
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    
    let rect = NSRect(x: 4, y: 4, width: 120, height: 120)
    let path = NSBezierPath(roundedRect: rect, xRadius: 28, yRadius: 28)
    
    // Draw gradient fill
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(colorSpace: colorSpace, components: [spec.bg0.0, spec.bg0.1, spec.bg0.2, 1.0])!,
        CGColor(colorSpace: colorSpace, components: [spec.bg1.0, spec.bg1.1, spec.bg1.2, 1.0])!
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    
    ctx.saveGState()
    path.addClip()
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 64, y: 124), end: CGPoint(x: 64, y: 4), options: [])
    ctx.restoreGState()
    
    // Inner outline
    let innerPath = NSBezierPath(roundedRect: NSRect(x: 7.5, y: 7.5, width: 113, height: 113), xRadius: 24, yRadius: 24)
    NSColor(calibratedRed: spec.border.0, green: spec.border.1, blue: spec.border.2, alpha: 0.20).setStroke()
    innerPath.lineWidth = 1.0
    innerPath.stroke()
    
    // Outer border stroke
    NSColor(calibratedRed: spec.border.0, green: spec.border.1, blue: spec.border.2, alpha: 1.0).setStroke()
    path.lineWidth = 3.5
    path.stroke()
    
    // Text drawing
    let str = spec.text as NSString
    let font = NSFont.systemFont(ofSize: spec.fontSize, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(calibratedRed: spec.textColor.0, green: spec.textColor.1, blue: spec.textColor.2, alpha: 1.0)
    ]
    let textSize = str.size(withAttributes: attrs)
    let textRect = NSRect(x: (128 - textSize.width) / 2, y: (128 - textSize.height) / 2 - 2, width: textSize.width, height: textSize.height)
    str.draw(in: textRect, withAttributes: attrs)
    
    image.unlockFocus()
    
    let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
    let pngData = rep.representation(using: .png, properties: [:])!
    let pathUrl = URL(fileURLWithPath: "\(baseDir)/\(spec.id).png")
    try! pngData.write(to: pathUrl)
    print("Generated \(spec.id).png")
}

// Draw Figma Icon
do {
    let image = NSImage(size: size)
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    
    let rect = NSRect(x: 4, y: 4, width: 120, height: 120)
    let path = NSBezierPath(roundedRect: rect, xRadius: 28, yRadius: 28)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(colorSpace: colorSpace, components: [0.06, 0.09, 0.16, 1.0])!,
        CGColor(colorSpace: colorSpace, components: [0.01, 0.02, 0.07, 1.0])!
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    
    ctx.saveGState()
    path.addClip()
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 64, y: 124), end: CGPoint(x: 64, y: 4), options: [])
    ctx.restoreGState()
    
    NSColor(calibratedRed: 0.63, green: 0.35, blue: 1.0, alpha: 1.0).setStroke()
    path.lineWidth = 3.5
    path.stroke()
    
    // Draw Figma 5 component shapes: 2 columns of 22px elements
    let ox: CGFloat = 43
    let oy: CGFloat = 33
    let r: CGFloat = 21
    let rad: CGFloat = r / 2
    
    // Top-left: Orange #F24E1E
    let tlPath = NSBezierPath()
    tlPath.appendRoundedRect(NSRect(x: ox, y: oy + 2 * r, width: r, height: r), xRadius: rad, yRadius: rad)
    NSColor(calibratedRed: 0.95, green: 0.31, blue: 0.12, alpha: 1.0).setFill()
    tlPath.fill()
    
    // Top-right: Salmon/Peach #FF7262
    let trPath = NSBezierPath()
    trPath.appendRoundedRect(NSRect(x: ox + r, y: oy + 2 * r, width: r, height: r), xRadius: rad, yRadius: rad)
    NSColor(calibratedRed: 1.00, green: 0.45, blue: 0.38, alpha: 1.0).setFill()
    trPath.fill()
    
    // Middle-left: Purple #A259FF
    let mlPath = NSBezierPath()
    mlPath.appendRoundedRect(NSRect(x: ox, y: oy + r, width: r, height: r), xRadius: rad, yRadius: rad)
    NSColor(calibratedRed: 0.64, green: 0.35, blue: 1.00, alpha: 1.0).setFill()
    mlPath.fill()
    
    // Middle-right: Blue circle #1ABCFE
    let mrPath = NSBezierPath(ovalIn: NSRect(x: ox + r, y: oy + r, width: r, height: r))
    NSColor(calibratedRed: 0.10, green: 0.74, blue: 0.99, alpha: 1.0).setFill()
    mrPath.fill()
    
    // Bottom-left: Green teardrop #0ACF83
    let blPath = NSBezierPath()
    blPath.appendRoundedRect(NSRect(x: ox, y: oy, width: r, height: r), xRadius: rad, yRadius: rad)
    NSColor(calibratedRed: 0.04, green: 0.81, blue: 0.51, alpha: 1.0).setFill()
    blPath.fill()
    
    image.unlockFocus()
    let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
    let pngData = rep.representation(using: .png, properties: [:])!
    try! pngData.write(to: URL(fileURLWithPath: "\(baseDir)/figcraft.png"))
    print("Generated figcraft.png")
}

print("All 13 icons generated successfully!")
