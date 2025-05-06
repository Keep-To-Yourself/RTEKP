//
//  RichTextStorage.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

/// 自定义NSTextStorage子类,用于高级属性处理和解析
/// 如果需要在外部访问或继承,需要设为public
public class RichTextStorage: NSTextStorage {

  /// 内部存储实现使用NSMutableAttributedString
  private let backingStore = NSMutableAttributedString()

  // MARK: - 文本读取

  /// 获取存储的文本内容
  override public var string: String {
    return backingStore.string
  }

  /// 获取指定位置的属性
  override public func attributes(at location: Int, effectiveRange range: NSRangePointer?)
    -> [NSAttributedString.Key: Any]
  {
    return backingStore.attributes(at: location, effectiveRange: range)
  }

  // MARK: - 文本编辑

  /// 替换指定范围的文本
  override public func replaceCharacters(in range: NSRange, with str: String) {
    beginEditing()
    backingStore.replaceCharacters(in: range, with: str)
    edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    endEditing()
  }

  /// 设置文本属性
  override public func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.editedAttributes, range: range, changeInLength: 0)
    endEditing()
  }

  // MARK: - 编辑处理(核心功能)

  /// 处理文本编辑后的操作
  override public func processEditing() {
    // 在编辑后调用此方法
    // TODO: 在这里实现自定义处理逻辑,例如:
    // - 应用语法高亮
    // - 检测并格式化Markdown模式
    // - 修复属性一致性问题

    // 示例:为新文本设置默认字体(基础示例)
    // let paragraphRange = (string as NSString).paragraphRange(for: editedRange)
    // self.addAttributes([.font: UIFont.systemFont(ofSize: 15)], range: paragraphRange)

    super.processEditing()  // 重要:最后调用super
  }
}
