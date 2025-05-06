//
//  AttributeApplier.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

/// 内部辅助类,用于应用文本属性
class AttributeApplier {
    weak var textStorage: NSTextStorage?

    init(textStorage: NSTextStorage?) {
        self.textStorage = textStorage
    }

    // MARK: - 应用文本样式

    /// 应用文本样式
    /// - Parameters:
    ///   - style: 要应用的文本样式
    ///   - range: 应用范围
    func apply(style: TextStyle, to range: NSRange) {
        guard let storage = textStorage else { return }
        
        storage.beginEditing()
        defer { storage.endEditing() }

        let attributes: [NSAttributedString.Key: Any] = {
            switch style {
            case .bold, .italic:
                return currentFontAttributes(with: trait(for: style))
            case .underline:
                return [.underlineStyle: NSUnderlineStyle.single.rawValue]
            case .strikethrough:
                return [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            case .h1:
                return [.font: UIFont.systemFont(ofSize: ParagraphType.h1.fontSize, weight: .bold)]
            case .h2:
                return [.font: UIFont.systemFont(ofSize: ParagraphType.h2.fontSize, weight: .bold)]
            case .h3:
                return [.font: UIFont.systemFont(ofSize: ParagraphType.h3.fontSize, weight: .bold)]
            case .quote, .bulletedList, .numberedList:
                let style = NSMutableParagraphStyle()
                style.firstLineHeadIndent = 20
                style.headIndent = 20
                return [.paragraphStyle: style]
            }
        }()

        storage.addAttributes(attributes, range: range)
    }

    /// 切换文本样式
    /// - Parameters:
    ///   - style: 要切换的文本样式
    ///   - range: 切换范围
    func toggle(style: TextStyle, at range: NSRange) {
        guard let storage = textStorage else { return }
        
        storage.beginEditing()
        defer { storage.endEditing() }

        var hasStyle = false
        
        // 修复1: 确保闭包返回Bool值
        _ = storage.enumerateAttribute(
            style.attributeKey,
            in: range,
            options: []
        ) { value, subRange, stop in
            switch style {
            case .bold, .italic:
                guard 
                    let font = value as? UIFont,
                    font.fontDescriptor.symbolicTraits.contains(self.trait(for: style))
                else { return }
                hasStyle = true
                stop.pointee = true
                
            case .underline, .strikethrough:
                guard (value as? NSNumber)?.intValue != 0 else { return }
                hasStyle = true
                stop.pointee = true
                
            case .h1, .h2, .h3:
                guard 
                    let font = value as? UIFont,
                    font.pointSize == self.getFontSize(for: style)
                else { return }
                hasStyle = true
                stop.pointee = true
                
            case .quote, .bulletedList, .numberedList:
                guard value != nil else { return }
                hasStyle = true
                stop.pointee = true
            }
        }

        hasStyle ? remove(style, from: range) : apply(style: style, to: range)
    }

    // MARK: - 应用段落样式

    /// 应用段落样式
    /// - Parameters:
    ///   - paragraphStyle: 要应用的段落样式
    ///   - range: 应用范围
    func apply(paragraphStyle: ParagraphType, to range: NSRange) {
        guard let storage = textStorage else { return }
        
        storage.beginEditing()
        defer { storage.endEditing() }
        
        let font = UIFont.systemFont(ofSize: paragraphStyle.fontSize, weight: paragraphStyle.fontWeight)
        var paragraphAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                switch paragraphStyle {
                case .bulletedList:
                    style.firstLineHeadIndent = 20
                    style.headIndent = 20
                case .numberedList:
                    style.firstLineHeadIndent = 20
                    style.headIndent = 20
                case .quote:
                    style.firstLineHeadIndent = 20
                    style.headIndent = 20
                default:
                    break
                }
                return style
            }()
        ]
        
        // 为引用样式添加背景色
        if case .quote = paragraphStyle {
            paragraphAttributes[.backgroundColor] = UIColor.systemGray6
        }
        
        storage.addAttributes(paragraphAttributes, range: range)
    }

    // MARK: - 私有方法

    /// 获取当前字体属性
    /// - Parameter trait: 要应用的字体特征
    private func currentFontAttributes(with trait: UIFontDescriptor.SymbolicTraits) -> [NSAttributedString.Key: Any] {
        guard let storage = textStorage else {
            let baseFont = UIFont.systemFont(ofSize: 17)
            return [.font: baseFont.with(traits: trait) ?? baseFont]
        }
        
        // 获取当前字体及其特征
        let currentFont = storage.length > 0 ? 
            (storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont) ?? UIFont.systemFont(ofSize: 17) :
            UIFont.systemFont(ofSize: 17)
            
        // 合并现有特征和新特征
        let currentTraits = currentFont.fontDescriptor.symbolicTraits
        let combinedTraits = currentTraits.union(trait)
        
        // 尝试应用组合特征，如果失败则返回原始字体
        if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(combinedTraits) {
            let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            return [.font: newFont]
        }
        
        return [.font: currentFont]
    }

    /// 获取字体特征
    /// - Parameter style: 文本样式
    private func trait(for style: TextStyle) -> UIFontDescriptor.SymbolicTraits {
        switch style {
        case .bold: return .traitBold
        case .italic: return .traitItalic
        case .h1, .h2, .h3: return [.traitBold]
        case .underline, .strikethrough, .quote, .bulletedList, .numberedList:
            return []
        }
    }

    /// 移除文本样式
    /// - Parameters:
    ///   - style: 要移除的文本样式
    ///   - range: 移除范围
    func remove(_ style: TextStyle, from range: NSRange) {
        switch style {
        case .bold, .italic, .h1, .h2, .h3:
            // 修复4: 使用正确的字体特征移除方式
            let currentFont = textStorage?.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont
            
            guard var descriptor = currentFont?.fontDescriptor else { return }
            
            descriptor = descriptor.withSymbolicTraits(descriptor.symbolicTraits.subtracting(trait(for: style))) ?? descriptor
            
            textStorage?.addAttribute(
                .font,
                value: UIFont(descriptor: descriptor, size: 0),
                range: range
            )
            
        case .underline:
            textStorage?.removeAttribute(.underlineStyle, range: range)
        case .strikethrough:
            textStorage?.removeAttribute(.strikethroughStyle, range: range)
        case .quote, .bulletedList, .numberedList:
            textStorage?.removeAttribute(.paragraphStyle, range: range)
        }
    }

    /// 获取指定样式集合的typing attributes
    func currentTypingAttributes(with styles: Set<TextStyle>) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        // 合并所有字体特征
        var traits = UIFontDescriptor.SymbolicTraits()
        if styles.contains(.bold) {
            traits.insert(.traitBold)
        }
        if styles.contains(.italic) {
            traits.insert(.traitItalic)
        }
        
        // 应用字体
        let baseFont = UIFont.systemFont(ofSize: 17)
        attributes[.font] = baseFont.with(traits: traits) ?? baseFont
        
        // 应用其他样式
        if styles.contains(.underline) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        if styles.contains(.strikethrough) {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        return attributes
    }

    // 添加辅助方法来获取标题字体大小
    private func getFontSize(for style: TextStyle) -> CGFloat {
        switch style {
        case .h1: return ParagraphType.h1.fontSize
        case .h2: return ParagraphType.h2.fontSize
        case .h3: return ParagraphType.h3.fontSize
        default: return 17
        }
    }

    // 添加批量应用样式的方法
    func applyStyles(_ styles: Set<TextStyle>, to range: NSRange) {
        guard let storage = textStorage else { return }
        
        storage.beginEditing()
        defer { storage.endEditing() }
        
        // 组合所有字体特征并清除现有样式
        var combinedTraits = UIFontDescriptor.SymbolicTraits()
        var hasUnderline = false
        var hasStrikethrough = false
        var fontSize: CGFloat = 17
        
        // 首先清除所有已有的样式
        let attributes: [NSAttributedString.Key] = [
            .font,
            .underlineStyle,
            .strikethroughStyle,
            .paragraphStyle
        ]
        attributes.forEach { storage.removeAttribute($0, range: range) }
        
        // 收集所有样式特征
        for style in styles {
            switch style {
            case .bold:
                combinedTraits.insert(.traitBold)
            case .italic:
                combinedTraits.insert(.traitItalic)
            case .underline:
                hasUnderline = true
            case .strikethrough:
                hasStrikethrough = true
            case .h1:
                fontSize = 24.0
                combinedTraits.insert(.traitBold)
            case .h2:
                fontSize = 22.0
                combinedTraits.insert(.traitBold)
            case .h3:
                fontSize = 20.0
                combinedTraits.insert(.traitBold)
            default:
                break
            }
        }
        
        // 应用字体和特征
        let baseFont = UIFont.systemFont(ofSize: fontSize)
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(combinedTraits) {
            let newFont = UIFont(descriptor: descriptor, size: fontSize)
            storage.addAttribute(.font, value: newFont, range: range)
        } else {
            storage.addAttribute(.font, value: baseFont, range: range)
        }
        
        // 应用下划线和删除线
        if hasUnderline {
            storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        if hasStrikethrough {
            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
}

// MARK: - 扩展: 字体特征处理
private extension UIFont {
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard 
            let descriptor = fontDescriptor.withSymbolicTraits(traits)
        else { return nil }
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
