//
//  NSAttributedString+Extensions.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

// 根据宿主应用是否需要这些工具类决定是Internal还是Public
extension NSAttributedString {

  // 示例工具函数
  func containsAttribute(_ key: NSAttributedString.Key, in range: NSRange) -> Bool {
    guard length > 0 && range.location != NSNotFound && range.length > 0 else { return false }
    var found = false
    enumerateAttribute(key, in: range, options: []) { value, _, stop in
      if value != nil {
        found = true
        stop.pointee = true
      }
    }
    return found
  }
}

// 为 String、UIColor 等添加其他有用的扩展
