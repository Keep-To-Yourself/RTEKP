import UIKit

/// 包含RichTextView的复合视图，用于可视化编辑
public class EditorView: UIView {

  // MARK: - 公开属性

  /// 内部的富文本编辑视图
  public let richTextView: RichTextView

  /// 控制是否允许插入图片的代理属性
  public var allowsImageInsertion: Bool {
    get { return richTextView.allowsImageInsertion }
    set { richTextView.allowsImageInsertion = newValue }
  }

  // MARK: - 初始化

  public override init(frame: CGRect) {
    self.richTextView = RichTextView(frame: .zero)
    super.init(frame: frame)
    initialSetup()
  }

  public required init?(coder: NSCoder) {
    self.richTextView = RichTextView(frame: .zero)
    super.init(coder: coder)
    initialSetup()
  }

  // MARK: - 视图设置

  /// 初始化设置
  private func initialSetup() {
    addSubviews()
    setupConstraints()
  }

  /// 添加子视图
  private func addSubviews() {
    addSubview(richTextView)
  }

  /// 设置约束 - Auto Layout布局
  private func setupConstraints() {
    richTextView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      richTextView.topAnchor.constraint(equalTo: topAnchor),
      richTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
      richTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
      richTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}

// MARK: - UIResponder扩展
extension EditorView {
  /// 判断是否是第一响应者
  public override var isFirstResponder: Bool {
    return richTextView.isFirstResponder
  }

  /// 成为第一响应者
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    return richTextView.becomeFirstResponder()
  }

  /// 放弃第一响应者
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return richTextView.resignFirstResponder()
  }
}

// MARK: - 属性转发
extension EditorView {
  /// 内容边距
  public var contentInset: UIEdgeInsets {
    get { return richTextView.contentInset }
    set { richTextView.contentInset = newValue }
  }

  /// 富文本内容
  public var attributedText: NSAttributedString! {
    get { return richTextView.attributedText }
    set { richTextView.attributedText = newValue }
  }
}
