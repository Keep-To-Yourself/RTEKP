//
//  EditorTextView.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

/// 主要的富文本显示和编辑视图
/// 需要公开访问以便在框架外使用
public class RichTextView: UITextView {

  // MARK: - 公开属性

  /// 控制是否允许插入图片,默认为true
  public var allowsImageInsertion: Bool = true

  /// 工具栏代理
  public weak var toolbarDelegate: FormattingToolbarDelegate?

  // MARK: - 初始化

  private let attributeApplier: AttributeApplier

  override public init(frame: CGRect, textContainer: NSTextContainer?) {
    self.attributeApplier = AttributeApplier(textStorage: nil)
    super.init(frame: frame, textContainer: textContainer)
    self.attributeApplier.textStorage = self.textStorage
    commonInit()
  }

  required public init?(coder: NSCoder) {
    self.attributeApplier = AttributeApplier(textStorage: nil)
    super.init(coder: coder)
    self.attributeApplier.textStorage = self.textStorage
    commonInit()
  }

  // MARK: - 设置

  /// 通用初始化配置
  private func commonInit() {
    // 基础视图设置
    self.backgroundColor = .systemBackground
    self.font = UIFont.preferredFont(forTextStyle: .body)  // 默认字体
    self.delegate = self // 如果需要在此类中处理代理

    // TODO: 添加富文本特性的具体设置
    // - 配置键盘辅助视图(工具栏)
    // - 设置文本存储代理(如果使用自定义存储)
    // - 注册通知(键盘等)
    print("RichTextView已初始化")
  }

  // MARK: - 公开方法

  /// 应用文本格式化属性
  /// - Parameters:
  ///   - attribute: 要应用的属性键
  ///   - value: 属性值
  public func applyFormatting(_ style: TextStyle) {
    // 获取当前活动的样式集合
    var currentStyles = activeTextStyles
    
    // 处理互斥样式
    if style.styleGroup == .heading || style.styleGroup == .list {
        // 移除所有同组的其他样式
        currentStyles = currentStyles.filter { !$0.isExclusiveWith(style) }
    }
    
    // 如果是标题样式
    if style.isHeading {
        // 自动添加加粗样式
        currentStyles.insert(.bold)
        // 移除其他格式化样式（除了加粗）
        currentStyles.remove(.italic)
        currentStyles.remove(.underline)
        currentStyles.remove(.strikethrough)
    }
    
    // 切换当前样式
    if currentStyles.contains(style) {
        // 如果已经包含该样式则移除
        currentStyles.remove(style)
        // 如果移除的是标题样式，同时移除加粗样式
        if style.isHeading {
            currentStyles.remove(.bold)
        }
    } else {
        // 添加新样式
        currentStyles.insert(style)
    }
    
    // 更新文本属性
    let range = selectedRange.length > 0 ? selectedRange : 
        NSRange(location: selectedRange.location, length: 0)
        
    // 应用新的样式集合
    attributeApplier.applyStyles(currentStyles, to: range)
    
    // 更新工具栏按钮状态
    toolbarDelegate?.toolbarDidUpdateActiveStyles(currentStyles)
  }

  /// 应用段落样式
  /// - Parameter style: 要应用的段落样式
  public func applyParagraphStyle(_ style: ParagraphType) {
    let range = selectedRange.length > 0 ? selectedRange : 
        (text as NSString).paragraphRange(for: selectedRange)
    attributeApplier.apply(paragraphStyle: style, to: range)
  }

  /// 插入图片到当前位置
  /// - Parameter image: 要插入的图片
  public func insertImage(_ image: UIImage) {
    // TODO: 使用NSTextAttachment实现图片插入逻辑
    print("正在插入图片...")
  }

  // MARK: - 样式检测

  /// 获取当前选中范围的文本样式
  /// - Returns: 当前选中范围的文本样式集合
  public var activeTextStyles: Set<TextStyle> {
    // 如果没有文本，返回空集合
    let textStorage = self.textStorage
    guard textStorage.length > 0 else { return [] }
    
    // 处理光标位置的特殊情况
    let location = max(0, min(selectedRange.location, textStorage.length - 1))
    let range = selectedRange.length > 0 ? selectedRange : NSRange(location: location, length: 1)
    
    var styles = Set<TextStyle>()
    
    // 检查字体特征
    if let font = textStorage.attribute(.font, at: location, effectiveRange: nil) as? UIFont {
        let traits = font.fontDescriptor.symbolicTraits
        if traits.contains(.traitBold) {
            styles.insert(.bold)
        }
        if traits.contains(.traitItalic) {
            styles.insert(.italic)
        }
    }
    
    // 检查下划线
    if textStorage.attribute(.underlineStyle, at: location, effectiveRange: nil) != nil {
        styles.insert(.underline)
    }

    // 检查删除线
    if textStorage.attribute(.strikethroughStyle, at: location, effectiveRange: nil) != nil {
        styles.insert(.strikethrough)
    }

    // 检查段落样式
    if let paragraph = textStorage.attribute(.paragraphStyle, at: location, effectiveRange: nil) as? NSMutableParagraphStyle {
        // 根据段落缩进和字体大小判断段落类型
        if paragraph.firstLineHeadIndent > 0 {
            if let font = textStorage.attribute(.font, at: location, effectiveRange: nil) as? UIFont {
                switch font.pointSize {
                case ParagraphType.h1.fontSize: styles.insert(.h1)
                case ParagraphType.h2.fontSize: styles.insert(.h2)
                case ParagraphType.h3.fontSize: styles.insert(.h3)
                default:
                    if paragraph.headIndent > 0 {
                        // 根据缩进判断是否为引用或列表
                        styles.insert(.quote)
                    }
                }
            }
        }
    }
    
    return styles
  }

  // MARK: - 重写方法示例

  /// 重写粘贴方法以处理富文本粘贴
  override public func paste(_ sender: Any?) {
    // TODO: 处理粘贴内容(例如,清除格式,处理HTML)
    super.paste(sender)
    print("内容已粘贴")
  }

  // MARK: - 析构
  deinit {
    // 清理观察者等资源
    print("RichTextView已释放")
  }
}

  // MARK: - 处理工具栏操作

/// 这里实现了工具栏的代理方法,用于处理格式化操作
extension RichTextView: FormattingToolbarDelegate {
  /// 工具栏选择了格式化操作
  /// - Parameter style: 选择的文本样式
  /// - Parameter paragraphStyle: 选择的段落样式
  public func toolbarDidSelectFormatting(_ style: TextStyle) {
    applyFormatting(style)
  }
  
  public func toolbarDidSelectParagraphStyle(_ style: ParagraphType) {
    applyParagraphStyle(style)
  }
  
  public func toolbarDidRequestInsertImage() {
    // TODO: 实现图片插入
  }
  
  public func toolbarDidUpdateActiveStyles(_ styles: Set<TextStyle>) {
    // 实现协议要求的方法
    // 因为 RichTextView 是样式的来源而不是接收者，所以这里可以留空
  }
}

  // MARK: - UITextViewDelegate
extension RichTextView: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        toolbarDelegate?.toolbarDidUpdateActiveStyles(activeTextStyles)
    }
}
