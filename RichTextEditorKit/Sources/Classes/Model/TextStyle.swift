//
//  TextStyle.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit
import Foundation

/// 表示基本的文本样式。设为public以便宿主应用程序使用
public enum TextStyle: Hashable {
    case bold
    case italic
    case underline
    case strikethrough
    // 与 ParagraphType 对应的样式
    case h1
    case h2
    case h3
    case quote
    case bulletedList
    case numberedList
    
    // 添加样式分组
    var styleGroup: StyleGroup {
        switch self {
        case .h1, .h2, .h3:
            return .heading
        case .bulletedList, .numberedList:
            return .list
        case .bold, .italic, .underline, .strikethrough:
            return .format
        case .quote:
            return .blockquote
        }
    }
    
    // 判断样式是否互斥
    func isExclusiveWith(_ style: TextStyle) -> Bool {
        // 同组的标题类样式互斥
        if styleGroup == .heading && style.styleGroup == .heading {
            return true
        }
        // 同组的列表类样式互斥
        if styleGroup == .list && style.styleGroup == .list {
            return true
        }
        return false
    }
    
    // 样式分组枚举
    enum StyleGroup {
        case heading
        case list
        case format
        case blockquote
    }
    
    // 判断是否为标题样式
    var isHeading: Bool {
        return styleGroup == .heading
    }
}

public extension TextStyle {
  var systemImageName: String {
    switch self {
    case .bold: return "bold"
    case .italic: return "italic"
    case .underline: return "underline"
    case .strikethrough: return "strikethrough"
    case .h1: return "textformat.size.larger"
    case .h2: return "textformat.size.large"
    case .h3: return "textformat.size.medium"
    case .quote: return "text.quote"
    case .bulletedList: return "list.bullet"
    case .numberedList: return "list.number"
    }
  }
  
  var attributeKey: NSAttributedString.Key {
    switch self {
    case .bold, .italic, .h1, .h2, .h3:
        return .font
    case .underline:
        return .underlineStyle
    case .strikethrough:
        return .strikethroughStyle
    case .quote, .bulletedList, .numberedList:
        return .paragraphStyle
    }
  }
}

// TODO: 根据需要定义自定义属性或块类型的数据结构
