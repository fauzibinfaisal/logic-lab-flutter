import AVFoundation
import CoreGraphics
import CoreVideo
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 960
let height = 540
let framesPerSecond: Int32 = 24
let durationSeconds = 5
let frameCount = Int(framesPerSecond) * durationSeconds

let fileManager = FileManager.default
let outputDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
  .appendingPathComponent("assets/video", isDirectory: true)
try fileManager.createDirectory(
  at: outputDirectory,
  withIntermediateDirectories: true
)

let videoURL = outputDirectory.appendingPathComponent("hero-cinematic.mp4")
let posterURL = outputDirectory.appendingPathComponent("hero-cinematic-poster.jpg")
try? fileManager.removeItem(at: videoURL)
try? fileManager.removeItem(at: posterURL)

let writer = try AVAssetWriter(outputURL: videoURL, fileType: .mp4)
let input = AVAssetWriterInput(
  mediaType: .video,
  outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
      AVVideoAverageBitRateKey: 620_000,
      AVVideoExpectedSourceFrameRateKey: framesPerSecond,
      AVVideoMaxKeyFrameIntervalKey: framesPerSecond * 2,
      AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
    ],
  ]
)
input.expectsMediaDataInRealTime = false

let adaptor = AVAssetWriterInputPixelBufferAdaptor(
  assetWriterInput: input,
  sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height,
  ]
)

guard writer.canAdd(input) else {
  fatalError("Could not add video input")
}
writer.add(input)
guard writer.startWriting() else {
  fatalError(writer.error?.localizedDescription ?? "Could not start writer")
}
writer.startSession(atSourceTime: .zero)

let colorSpace = CGColorSpaceCreateDeviceRGB()

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(
    colorSpace: colorSpace,
    components: [red / 255, green / 255, blue / 255, alpha]
  )!
}

func drawGlow(
  _ context: CGContext,
  center: CGPoint,
  radius: CGFloat,
  tint: CGColor,
  alpha: CGFloat
) {
  let transparent = tint.copy(alpha: 0)!
  let visible = tint.copy(alpha: alpha)!
  let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [visible, transparent] as CFArray,
    locations: [0, 1]
  )!
  context.drawRadialGradient(
    gradient,
    startCenter: center,
    startRadius: 0,
    endCenter: center,
    endRadius: radius,
    options: [.drawsAfterEndLocation]
  )
}

func drawRoundedPanel(
  _ context: CGContext,
  center: CGPoint,
  size: CGSize,
  rotation: CGFloat,
  phase: CGFloat,
  cyan: Bool
) {
  context.saveGState()
  context.translateBy(x: center.x, y: center.y)
  context.rotate(by: rotation)

  let rect = CGRect(
    x: -size.width / 2,
    y: -size.height / 2,
    width: size.width,
    height: size.height
  )
  let path = CGPath(
    roundedRect: rect,
    cornerWidth: 28,
    cornerHeight: 28,
    transform: nil
  )
  context.addPath(path)
  context.setFillColor(color(13, 28, 54, 0.7))
  context.fillPath()
  context.addPath(path)
  context.setStrokeColor(cyan ? color(0, 212, 255, 0.45) : color(124, 92, 252, 0.42))
  context.setLineWidth(1.5)
  context.strokePath()

  for row in 0..<4 {
    let y = rect.minY + 35 + CGFloat(row) * 38
    let pulse = 0.45 + 0.3 * sin(phase + CGFloat(row) * 0.8)
    context.setStrokeColor(
      cyan ? color(0, 212, 255, pulse) : color(124, 92, 252, pulse)
    )
    context.setLineWidth(row == 0 ? 5 : 2)
    context.setLineCap(.round)
    context.move(to: CGPoint(x: rect.minX + 30, y: y))
    context.addLine(to: CGPoint(x: rect.maxX - 30 - CGFloat(row) * 12, y: y))
    context.strokePath()
  }

  let dotX = rect.maxX - 28
  let dotY = rect.minY + 24
  context.setFillColor(color(103, 232, 194, 0.9))
  context.fillEllipse(in: CGRect(x: dotX - 4, y: dotY - 4, width: 8, height: 8))
  context.restoreGState()
}

func renderFrame(_ context: CGContext, frame: Int) {
  let progress = CGFloat(frame) / CGFloat(frameCount)
  let phase = progress * .pi * 2
  let canvas = CGRect(x: 0, y: 0, width: width, height: height)

  let background = CGGradient(
    colorsSpace: colorSpace,
    colors: [
      color(5, 10, 24),
      color(11, 24, 48),
      color(8, 13, 30),
    ] as CFArray,
    locations: [0, 0.62, 1]
  )!
  context.drawLinearGradient(
    background,
    start: CGPoint(x: 0, y: height),
    end: CGPoint(x: width, y: 0),
    options: []
  )

  drawGlow(
    context,
    center: CGPoint(
      x: 740 + 42 * cos(phase),
      y: 310 + 26 * sin(phase)
    ),
    radius: 330,
    tint: color(0, 212, 255),
    alpha: 0.16
  )
  drawGlow(
    context,
    center: CGPoint(
      x: 860 + 28 * sin(phase),
      y: 110 + 20 * cos(phase)
    ),
    radius: 250,
    tint: color(124, 92, 252),
    alpha: 0.18
  )

  // A slowly drifting perspective grid creates the far parallax layer.
  context.saveGState()
  context.setStrokeColor(color(0, 212, 255, 0.08))
  context.setLineWidth(1)
  let horizon = CGFloat(height) * 0.52
  let vanishingX = CGFloat(width) * 0.72 + 14 * sin(phase)
  for index in -9...9 {
    context.move(to: CGPoint(x: vanishingX + CGFloat(index) * 8, y: horizon))
    context.addLine(
      to: CGPoint(
        x: vanishingX + CGFloat(index) * 86,
        y: CGFloat(height) + 30
      )
    )
    context.strokePath()
  }
  let gridShift = progress * 9
  for index in 0..<11 {
    let normalized = (CGFloat(index) + gridShift).truncatingRemainder(dividingBy: 11) / 11
    let curved = normalized * normalized
    let y = horizon + curved * (CGFloat(height) - horizon + 40)
    context.move(to: CGPoint(x: 280, y: y))
    context.addLine(to: CGPoint(x: CGFloat(width), y: y))
    context.strokePath()
  }
  context.restoreGState()

  // Mid layer: floating app surfaces, moving on different amplitudes.
  drawRoundedPanel(
    context,
    center: CGPoint(x: 715 + 24 * sin(phase), y: 255 + 14 * cos(phase)),
    size: CGSize(width: 250, height: 350),
    rotation: -0.10 + 0.018 * sin(phase),
    phase: phase,
    cyan: true
  )
  drawRoundedPanel(
    context,
    center: CGPoint(x: 880 + 15 * cos(phase), y: 310 + 20 * sin(phase)),
    size: CGSize(width: 190, height: 270),
    rotation: 0.13 + 0.014 * cos(phase),
    phase: phase + 1.4,
    cyan: false
  )

  // Foreground light ribbons.
  for ribbon in 0..<3 {
    let offset = CGFloat(ribbon) * 0.7
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 380, y: 430 + CGFloat(ribbon) * 22))
    path.addCurve(
      to: CGPoint(x: 1010, y: 160 + CGFloat(ribbon) * 18),
      control1: CGPoint(x: 560, y: 520 + 26 * sin(phase + offset)),
      control2: CGPoint(x: 770, y: 90 + 34 * cos(phase + offset))
    )
    context.addPath(path)
    context.setStrokeColor(
      ribbon.isMultiple(of: 2)
        ? color(0, 212, 255, 0.18)
        : color(124, 92, 252, 0.2)
    )
    context.setLineWidth(CGFloat(2 + ribbon))
    context.setLineCap(.round)
    context.strokePath()
  }

  // Near particles move fastest and complete a seamless circular path.
  for index in 0..<42 {
    let seed = CGFloat(index) * 1.618
    let orbit = phase + seed
    let baseX = 390 + CGFloat((index * 71) % 570)
    let baseY = 30 + CGFloat((index * 47) % 470)
    let x = baseX + (12 + CGFloat(index % 5) * 3) * cos(orbit)
    let y = baseY + (7 + CGFloat(index % 4) * 2) * sin(orbit * 1.0)
    let radius = CGFloat(1 + index % 3)
    context.setFillColor(
      index.isMultiple(of: 3)
        ? color(103, 232, 194, 0.48)
        : color(0, 212, 255, 0.35)
    )
    context.fillEllipse(
      in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
    )
  }

  // Keep the left content zone calm and readable.
  let shade = CGGradient(
    colorsSpace: colorSpace,
    colors: [color(5, 10, 24, 0.92), color(5, 10, 24, 0)] as CFArray,
    locations: [0.15, 1]
  )!
  context.drawLinearGradient(
    shade,
    start: CGPoint(x: 0, y: 0),
    end: CGPoint(x: 620, y: 0),
    options: []
  )
  context.setFillColor(color(2, 6, 15, 0.12))
  context.fill(canvas)
}

func savePoster(_ image: CGImage) {
  guard let destination = CGImageDestinationCreateWithURL(
    posterURL as CFURL,
    UTType.jpeg.identifier as CFString,
    1,
    nil
  ) else {
    return
  }
  CGImageDestinationAddImage(
    destination,
    image,
    [kCGImageDestinationLossyCompressionQuality: 0.76] as CFDictionary
  )
  CGImageDestinationFinalize(destination)
}

for frame in 0..<frameCount {
  while !input.isReadyForMoreMediaData {
    Thread.sleep(forTimeInterval: 0.002)
  }

  guard let pool = adaptor.pixelBufferPool else {
    fatalError("Pixel buffer pool was not created")
  }
  var optionalBuffer: CVPixelBuffer?
  guard CVPixelBufferPoolCreatePixelBuffer(nil, pool, &optionalBuffer) == kCVReturnSuccess,
        let buffer = optionalBuffer else {
    fatalError("Could not allocate frame buffer")
  }

  CVPixelBufferLockBaseAddress(buffer, [])
  let context = CGContext(
    data: CVPixelBufferGetBaseAddress(buffer),
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
      | CGBitmapInfo.byteOrder32Little.rawValue
  )!
  renderFrame(context, frame: frame)
  if frame == 0, let image = context.makeImage() {
    savePoster(image)
  }
  CVPixelBufferUnlockBaseAddress(buffer, [])

  let presentationTime = CMTime(value: Int64(frame), timescale: framesPerSecond)
  guard adaptor.append(buffer, withPresentationTime: presentationTime) else {
    fatalError(writer.error?.localizedDescription ?? "Could not append frame")
  }
}

input.markAsFinished()
let semaphore = DispatchSemaphore(value: 0)
writer.finishWriting {
  semaphore.signal()
}
semaphore.wait()

guard writer.status == .completed else {
  fatalError(writer.error?.localizedDescription ?? "Video export failed")
}

let attributes = try fileManager.attributesOfItem(atPath: videoURL.path)
let byteCount = (attributes[.size] as? NSNumber)?.intValue ?? 0
print("Generated \(videoURL.path) (\(byteCount) bytes)")
print("Generated \(posterURL.path)")
