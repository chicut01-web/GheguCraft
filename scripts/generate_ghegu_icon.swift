import Cocoa

let photoPath = "/Users/christianizzo/Projects/GheguCraft/foto_ghegu/WhatsApp Image 2026-10-14 at 16.50.39.jpeg"
let url = URL(fileURLWithPath: photoPath)
guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    fatalError("Failed to load source image")
}

// 1. Crop to square centered on face:
// The image is 1376 x 768.
let cropSize: CGFloat = 720
let cropX = (CGFloat(cgImage.width) - cropSize) / 2.0
// Face is slightly higher than bottom, so let's position Y = 20
let cropY: CGFloat = 10
let cropRect = CGRect(x: cropX, y: cropY, width: cropSize, height: cropSize)
guard let faceCrop = cgImage.cropping(to: cropRect) else {
    fatalError("Failed to crop")
}

func savePNG(_ image: CGImage, to path: String) {
    let destUrl = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(destUrl as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("Failed destination")
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// -------------------------------------------------------------
// 1. Generate Header Avatar (Circular with Gold / Cyan ring)
// -------------------------------------------------------------
func generateAvatar(size: Int) -> CGImage {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let w = CGFloat(size)
    let center = CGPoint(x: w/2, y: w/2)
    let radius = (w - 4) / 2
    
    // Outer shadow / background ring
    ctx.saveGState()
    let circlePath = CGPath(ellipseIn: CGRect(x: 2, y: 2, width: w - 4, height: w - 4), transform: nil)
    
    // Background fill (dark)
    ctx.setFillColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
    ctx.addPath(circlePath)
    ctx.fillPath()
    
    // Clip to inner circle
    let innerPad: CGFloat = w * 0.03
    let innerRect = CGRect(x: innerPad, y: innerPad, width: w - 2*innerPad, height: w - 2*innerPad)
    let innerPath = CGPath(ellipseIn: innerRect, transform: nil)
    ctx.addPath(innerPath)
    ctx.clip()
    
    // Draw face crop
    ctx.draw(faceCrop, in: innerRect)
    ctx.restoreGState()
    
    // Outer stylish Gold/Cyan gradient ring
    ctx.saveGState()
    let ringRect = CGRect(x: 2, y: 2, width: w - 4, height: w - 4)
    ctx.setLineWidth(w * 0.045)
    ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.95) // Gold
    ctx.addEllipse(in: ringRect)
    ctx.strokePath()
    
    // Inner fine cyan hairline
    let fineRect = CGRect(x: innerPad, y: innerPad, width: w - 2*innerPad, height: w - 2*innerPad)
    ctx.setLineWidth(w * 0.015)
    ctx.setStrokeColor(red: 0.35, green: 0.75, blue: 0.98, alpha: 0.7) // Cyan
    ctx.addEllipse(in: fineRect)
    ctx.strokePath()
    ctx.restoreGState()
    
    return ctx.makeImage()!
}

// -------------------------------------------------------------
// 2. Generate macOS App Icon (Squircle conforming to macOS grid)
// -------------------------------------------------------------
func generateMacAppIcon(canvasSize: Int) -> CGImage {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: canvasSize, height: canvasSize, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let canvas = CGFloat(canvasSize)
    // macOS icon is 824pt inside 1024pt canvas (scale proportionally)
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
    
    // Draw dark gradient behind image in case of transparency
    let colors = [
        CGColor(red: 0.10, green: 0.13, blue: 0.20, alpha: 1.0),
        CGColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1.0)
    ] as CFArray
    let gradient = CGGradient(colorsSpace: cs, colors: colors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: margin, y: margin + iconSize), end: CGPoint(x: margin, y: margin), options: [])
    
    // Draw face
    ctx.draw(faceCrop, in: iconRect)
    
    // Add subtle vignette at bottom
    let vignetteColors = [
        CGColor(red: 0.04, green: 0.06, blue: 0.10, alpha: 0.0),
        CGColor(red: 0.04, green: 0.06, blue: 0.10, alpha: 0.65)
    ] as CFArray
    let vigGrad = CGGradient(colorsSpace: cs, colors: vignetteColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(vigGrad, start: CGPoint(x: margin, y: margin + iconSize * 0.4), end: CGPoint(x: margin, y: margin), options: [])
    
    // Subtle inner border (1.5 px)
    ctx.setLineWidth(canvas * 0.003)
    ctx.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25)
    ctx.addPath(squircle)
    ctx.strokePath()
    
    // Subtle Gold rim at border
    ctx.setLineWidth(canvas * 0.006)
    ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.6)
    ctx.addPath(squircle)
    ctx.strokePath()
    
    // Bottom badge: "GheguCraft" or crown emblem
    // Let's draw an elegant small VIP badge at the bottom
    let badgeW = iconSize * 0.65
    let badgeH = iconSize * 0.12
    let badgeRect = CGRect(x: (canvas - badgeW)/2, y: margin + iconSize * 0.05, width: badgeW, height: badgeH)
    let badgePath = CGPath(roundedRect: badgeRect, cornerWidth: badgeH/2, cornerHeight: badgeH/2, transform: nil)
    
    ctx.setFillColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 0.90)
    ctx.addPath(badgePath)
    ctx.fillPath()
    
    ctx.setLineWidth(canvas * 0.002)
    ctx.setStrokeColor(red: 0.98, green: 0.80, blue: 0.25, alpha: 0.8)
    ctx.addPath(badgePath)
    ctx.strokePath()
    
    // Text inside badge: "GHEGUCRAFT"
    let font = NSFont.systemFont(ofSize: badgeH * 0.48, weight: .black)
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0.98, green: 0.82, blue: 0.28, alpha: 1.0),
        .paragraphStyle: style,
        .kern: 1.5
    ]
    let str = NSAttributedString(string: "👑 GHEGUCRAFT", attributes: attrs)
    
    // Flip context coordinate for NSAttributedString draw
    let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = nsCtx
    let textRect = CGRect(x: badgeRect.origin.x, y: badgeRect.origin.y + (badgeH - badgeH * 0.55)/2, width: badgeW, height: badgeH * 0.6)
    str.draw(in: textRect)
    NSGraphicsContext.restoreGraphicsState()
    
    ctx.restoreGState()
    
    return ctx.makeImage()!
}

let artifactDir = "/Users/christianizzo/.gemini/antigravity-ide/brain/f081ac6e-7b5b-4d5c-bd6a-98d9a0658b54"

let avatar512 = generateAvatar(size: 512)
savePNG(avatar512, to: "\(artifactDir)/ghegu_avatar_preview.png")

let macIcon1024 = generateMacAppIcon(canvasSize: 1024)
savePNG(macIcon1024, to: "\(artifactDir)/ghegu_app_icon_preview.png")

print("Generated previews successfully!")
