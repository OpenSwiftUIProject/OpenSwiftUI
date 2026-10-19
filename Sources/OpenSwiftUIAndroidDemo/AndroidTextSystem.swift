#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Foundation
import UIKit
@_spi(Private) import OpenSwiftUICore

struct AndroidTextSystem: PlatformTextSystem {
    func textStyleTraits(_ style: Font.TextStyle, size: DynamicTypeSize) -> Font.ResolvedTraits {
        // Android's initial typography policy, independent of CoreText descriptors.
        let points: Double = switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .subheadline: 15
        case .callout: 16
        case .footnote: 13
        case .caption: 12
        case .caption2, .caption3: 11
        case .extraLargeTitle: 36
        case .extraLargeTitle2: 28
        }
        let scale: Double = switch size {
        case .xSmall: 0.8
        case .small: 0.9
        case .medium: 0.95
        case .large: 1
        case .xLarge: 1.1
        case .xxLarge: 1.2
        case .xxxLarge: 1.3
        case .accessibility1: 1.6
        case .accessibility2: 1.9
        case .accessibility3: 2.2
        case .accessibility4: 2.5
        case .accessibility5: 2.8
        }
        return .init(pointSize: points * scale, weight: style == .headline ? 0.3 : 0)
    }

    func fontMetrics(_ string: Foundation.NSAttributedString) -> Foundation.NSAttributedString.EncodedFontMetrics {
        MainActor.assumeIsolated {
            var result = Foundation.NSAttributedString.EncodedFontMetrics()
            string.enumerateAttribute(.kitFont, in: NSRange(location: 0, length: string.length)) { value, _, _ in
                let font = Self.font(value as? CTFont)
                result.ascender = max(result.ascender, font.ascender)
                result.descender = min(result.descender, font.descender)
                result.capHeight = max(result.capHeight, font.capHeight)
                result.leading = max(result.leading, font.lineHeight - font.ascender + font.descender)
            }
            return result
        }
    }

    func measure(_ string: Foundation.NSAttributedString, in size: Foundation.CGSize, lineLimit: Int?) -> Foundation.NSAttributedString.Metrics {
        MainActor.assumeIsolated {
            let label = UILabel(frame: .zero)
            Self.configure(label, string: string, lineLimit: lineLimit)
            var intrinsicWidth = label.sizeThatFits(.zero).width
            if label.attributedText == nil && lineLimit != 1 && string.string.contains(where: \.isNewline) {
                // SDL's unwrapped size treats newlines as glyphs; measure each line separately.
                intrinsicWidth = string.string.components(separatedBy: .newlines).reduce(0) { width, line in
                    label.text = line
                    return max(width, label.sizeThatFits(.zero).width)
                }
                label.text = string.string
            }
            let width = max(0, min(Double(size.width), intrinsicWidth))
            label.bounds.size.width = width
            let measured = label.sizeThatFits(.zero)
            let font = label.font
            let scale = UIScreen.main?.scale ?? 1
            let lineStep = max(font.lineHeight, 1 / scale)
            let fullLines = max(1, Int((measured.height / lineStep).rounded()))
            let lines = min(fullLines, lineLimit.map { max(1, $0) } ?? fullLines)
            let height = lines == fullLines ? measured.height : lineStep * Double(lines)
            let metrics = fontMetrics(string)
            return UncheckedSendable(Foundation.NSAttributedString.Metrics(
                size: string.length == 0 ? .zero : .init(width: width, height: height),
                scale: 1,
                firstBaseline: metrics.ascender,
                lastBaseline: metrics.ascender + Double(lines - 1) * lineStep,
                baselineAdjustment: 0,
                requestedWidth: size.width,
                numberOfLines: UInt(string.length == 0 ? 0 : lines),
                hasTruncatedRanges: lines < fullLines || (lineLimit == 1 && intrinsicWidth > width)
            ))
        }.value
    }

    @MainActor
    static func font(_ font: CTFont?) -> UIFont {
        UIFont.systemFont(
            ofSize: Double(font?.pointSize ?? 17),
            weight: .init(rawValue: Double(font?.weight ?? 0)) ?? .regular
        )
    }

    @MainActor
    static func configure(_ label: UILabel, string: Foundation.NSAttributedString, lineLimit: Int?) {
        label.numberOfLines = lineLimit ?? 0
        label.text = string.string
        label.attributedText = nil
        guard string.length > 0 else { return }
        label.font = font(string.attribute(.kitFont, at: 0, effectiveRange: nil) as? CTFont)
        if let color = string.attribute(.kitForegroundColor, at: 0, effectiveRange: nil) as? NDColor {
            label.textColor = UIColor(red: Double(color.red), green: Double(color.green), blue: Double(color.blue), alpha: Double(color.alpha))
        } else {
            label.textColor = .black
        }
        let paragraph = string.attribute(.kitParagraphStyle, at: 0, effectiveRange: nil) as? OpenSwiftUICore.NSParagraphStyle
        label.textAlignment = switch paragraph?.horizontalAlignment {
        case .center: .center
        case .right: .right
        default: .left
        }
        var hasMixedFonts = false
        let converted = UIKit.NSMutableAttributedString(string: "")
        string.enumerateAttribute(.kitFont, in: NSRange(location: 0, length: string.length)) { value, range, _ in
            let runFont = font(value as? CTFont)
            hasMixedFonts = hasMixedFonts || runFont != label.font
            converted.append(UIKit.NSAttributedString(
                string: string.attributedSubstring(from: range).string,
                attributes: [.font: runFont]
            ))
        }
        if hasMixedFonts { label.attributedText = converted }
    }
}
#endif
