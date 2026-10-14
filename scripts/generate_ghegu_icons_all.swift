import Cocoa

let photoPath = "/Users/christianizzo/Projects/GheguCraft/foto_ghegu/WhatsApp Image 2026-10-14 at 16.50.39.jpeg"
let url = URL(fileURLWithPath: photoPath)
guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    fatalError("Failed to load source image")
}

// Face crop: 720x720 centered horizontally, slightly towards top
let cropSize: CGFloat = 720
let cropX = (CGFloat(cgImage.width) - cropSize) / 2.0
let cropY: CGFloat = 10
let cropRect = CGRect(x: cropX, y: cropY, width: cropSize, height: cropSize)
guard let faceCrop = cgImage.cropping(to: cropRect) else {
    fatalError("Failed to crop")
}

func savePNG(_ image: CGImage, to path: String) {
    let destUrl = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(destUrl as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("Failed destination for \(path)")
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// Circular Avatar with Gold & Cyan rings
func generateAvatar(size: Int) -> CGImage {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let w = CGFloat(size)
    let pad = max(1.0, w * 0.02)
    
    ctx.saveGState()
    let circlePath = CGPath(ellipseIn: CGRect(x: pad, y: pad, width: w - 2*pad, height: w - 2*pad), transform: nil)
    
    // Background fill (dark)
    ctx.setFillColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
    ctx.addPath(circlePath)
    ctx.fillPath()
    
    // Clip to inner circle
    let innerPad: CGFloat = pad + w * 0.03
    let innerRect = CGRect(x: innerPad, y: innerPad, width: w - 2*innerPad, height: w - 2*innerPad)
    let innerPath = CGPath(ellipseIn: innerRect, transform: nil)
    ctx.addPath(innerPath)
    ctx.clip()
    
    // Draw face crop
    ctx.draw(faceCrop, in: innerRect)
    ctx.restoreGState()
    
    // Outer Gold ring
    ctx.saveGState()
    let ringRect = CGRect(x: pad, y: pad, width: w - 2*pad, height: w - 2*pad)
    ctx.setLineWidth(max(1.0, w * 0.05))
    ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.95) // Gold
    ctx.addEllipse(in: ringRect)
    ctx.strokePath()
    
    // Inner fine cyan hairline
    let fineRect = CGRect(x: innerPad, y: innerPad, width: w - 2*innerPad, height: w - 2*innerPad)
    ctx.setLineWidth(max(0.5, w * 0.02))
    ctx.setStrokeColor(red: 0.35, green: 0.75, blue: 0.98, alpha: 0.8) // Cyan
    ctx.addEllipse(in: fineRect)
    ctx.strokePath()
    ctx.restoreGState()
    
    return ctx.makeImage()!
}

// macOS App Icon (Squircle conforming to macOS 824/1024 grid)
func generateMacAppIcon(canvasSize: Int) -> CGImage {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: canvasSize, height: canvasSize, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let canvas = CGFloat(canvasSize)
    let iconSize = canvas * (824.0 / 1024.0)
    let margin = (canvas - iconSize) / 2.0
    let iconRect = CGRect(x: margin, y: margin, width: iconSize, height: iconSize)
    let cornerRadius = iconSize * 0.225
    
    // Drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -canvas * 0.02), blur: canvas * 0.04, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.45))
    
    let squircle = CGPath(roundedRect: iconRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(squircle)
    ctx.setFillColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1.0)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Draw background & image clipped to squircle
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    
    // Draw dark background gradient
    let colors = [
        CGColor(red: 0.10, green: 0.13, blue: 0.20, alpha: 1.0),
        CGColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1.0)
    ] as CFArray
    let gradient = CGGradient(colorsSpace: cs, colors: colors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: margin, y: margin + iconSize), end: CGPoint(x: margin, y: margin), options: [])
    
    // Draw face
    ctx.draw(faceCrop, in: iconRect)
    
    // Vignette at bottom
    let vignetteColors = [
        CGColor(red: 0.04, green: 0.06, blue: 0.10, alpha: 0.0),
        CGColor(red: 0.04, green: 0.06, blue: 0.10, alpha: 0.70)
    ] as CFArray
    let vigGrad = CGGradient(colorsSpace: cs, colors: vignetteColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(vigGrad, start: CGPoint(x: margin, y: margin + iconSize * 0.42), end: CGPoint(x: margin, y: margin), options: [])
    
    // Subtle inner border (1.5 px)
    ctx.setLineWidth(max(1.0, canvas * 0.003))
    ctx.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25)
    ctx.addPath(squircle)
    ctx.strokePath()
    
    // Subtle Gold rim at border
    ctx.setLineWidth(max(1.0, canvas * 0.006))
    ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.6)
    ctx.addPath(squircle)
    ctx.strokePath()
    
    // Bottom badge: "👑 GHEGUCRAFT"
    if canvasSize >= 64 {
        let badgeW = iconSize * 0.68
        let badgeH = iconSize * 0.13
        let badgeRect = CGRect(x: (canvas - badgeW)/2, y: margin + iconSize * 0.05, width: badgeW, height: badgeH)
        let badgePath = CGPath(roundedRect: badgeRect, cornerWidth: badgeH/2, cornerHeight: badgeH/2, transform: nil)
        
        ctx.setFillColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 0.92)
        ctx.addPath(badgePath)
        ctx.fillPath()
        
        ctx.setLineWidth(max(1.0, canvas * 0.002))
        ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.85)
        ctx.addPath(badgePath)
        ctx.strokePath()
        
        // Text inside badge
        let fontSize = badgeH * 0.50
        let font = NSFont.systemFont(ofSize: fontSize, weight: .black)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.98, green: 0.82, blue: 0.28, alpha: 1.0),
            .paragraphStyle: style,
            .kern: 1.2
        ]
        let str = NSAttributedString(string: "👑 GHEGUCRAFT", attributes: attrs)
        
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsCtx
        let textRect = CGRect(x: badgeRect.origin.x, y: badgeRect.origin.y + (badgeH - fontSize * 1.1)/2, width: badgeW, height: fontSize * 1.2)
        str.draw(in: textRect)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    ctx.restoreGState()
    
    return ctx.makeImage()!
}

let root = "/Users/christianizzo/Projects/GheguCraft"
let appIconDir = "\(root)/assets/app-icon"
let brandDir = "\(root)/docs/brand"
let tmpDir = "/tmp/ghegu_icons"
try? FileManager.default.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)

// 1. Generate Avatars
let avatar512 = generateAvatar(size: 512)
savePNG(avatar512, to: "\(brandDir)/ghegu-avatar.png")
savePNG(avatar512, to: "\(brandDir)/artcraft-mark.png")
savePNG(generateAvatar(size: 64), to: "\(brandDir)/artcraft-mark-64.png")
savePNG(generateAvatar(size: 44), to: "\(brandDir)/artcraft-mark-black-44.png")

// 2. Generate macOS 1024 Master Icon
let mac1024 = generateMacAppIcon(canvasSize: 1024)
savePNG(mac1024, to: "\(appIconDir)/artcraft-launcher-1024.png")

// 3. Generate PNGs for ICNS
let icnsSizes = [16, 32, 64, 128, 256, 512, 1024]
for s in icnsSizes {
    let img = generateMacAppIcon(canvasSize: s)
    savePNG(img, to: "\(tmpDir)/icns-\(s).png")
}

// 4. Generate PNGs for Windows ICO
let icoSizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
for s in icoSizes {
    let img = generateMacAppIcon(canvasSize: s)
    savePNG(img, to: "\(tmpDir)/ico-\(s).png")
}

// 5. Generate Linux hicolor PNGs
let hicolorSizes = [16, 24, 32, 48, 64, 128, 256, 512]
let appId = "ai.storyteller.artcraft-launcher"
for s in hicolorSizes {
    let dir = "\(appIconDir)/hicolor/\(s)x\(s)/apps"
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let img = generateMacAppIcon(canvasSize: s)
    savePNG(img, to: "\(dir)/\(appId).png")
}

print("All icon files rendered successfully!")
