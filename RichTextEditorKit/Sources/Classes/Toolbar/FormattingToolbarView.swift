//
//  FormattingToolbarView.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

/// 工具栏与编辑器通信的协议
public protocol FormattingToolbarDelegate: AnyObject {
  // func toolbarDidSelectFormatting(_ attribute: NSAttributedString.Key, value: Any?)  // 简化版
  func toolbarDidSelectFormatting(_ style: TextStyle)
  func toolbarDidSelectParagraphStyle(_ style: ParagraphType)  // 简化版
  func toolbarDidRequestInsertImage()
  func toolbarDidUpdateActiveStyles(_ styles: Set<TextStyle>) // 新增状态同步
  // 根据需要添加更多代理方法
}

/// 格式化工具栏视图。设为public以便宿主应用程序创建/添加
/// 或集成到RichTextView中
public class FormattingToolbarView: UIView {

  public weak var delegate: FormattingToolbarDelegate?

  // 添加状态管理属性
  private var currentActiveStyles: Set<TextStyle> = []
  private var currentParagraphStyle: ParagraphType = .body
  private var formatButtons: [ButtonAction: FormattingButton] = [:]

  private var stackView: UIStackView!

  private let stateManager = FormattingButtonStateManager()

  // MARK: - 初始化
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  public init(actions: [ButtonAction]) {
    super.init(frame: .zero)
    setupView(with: actions)
  }

  // MARK: - 设置
  private func setupView(with actions: [ButtonAction] = [.textStyle(.bold), .textStyle(.italic), .textStyle(.underline), .textStyle(.strikethrough)]) {
    backgroundColor = .systemGray5

    // 创建按钮
    let buttons = actions.map { action -> FormattingButton in
      let button = FormattingButton(action: action)
      button.delegate = delegate
      button.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
      formatButtons[action] = button
      return button
    }

    // 设置堆叠视图
    stackView = UIStackView(arrangedSubviews: buttons)
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually  // 或者 .equalSpacing 等
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stackView)

    // 布局（示例约束）
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
      heightAnchor.constraint(equalToConstant: 44),  // 示例高度
    ])
  }

  private func createToolbarButton(systemName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: systemName), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    // 基本样式
    button.tintColor = .label
    button.backgroundColor = .clear
    button.layer.cornerRadius = 5
    return button
  }

  // MARK: - 公共方法

  /// 根据当前选择的属性更新工具栏按钮的视觉状态
  public func updateButtonStates(activeStyles: Set<TextStyle>, currentParagraph: ParagraphType?) {
    let buttons = formatButtons.values.map { $0 }
    stateManager.updateStates(activeStyles: activeStyles, 
                              currentParagraph: currentParagraph, 
                              forButtons: buttons)
  }

  // MARK: - 动作处理

  // 获取指定动作的按钮
  public func button(for action: ButtonAction) -> FormattingButton? {
    return formatButtons[action]
  }

  private func setupView() {
    backgroundColor = .systemGray5

    // 创建主要按钮
    let mainButtons = [
        createMainButton(action: .format),
        createMainButton(action: .todo),
        createMainButton(action: .table),
        createMainButton(action: .attachment)
    ]
    
    // 设置堆叠视图
    stackView = UIStackView(arrangedSubviews: mainButtons)
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stackView)

    NSLayoutConstraint.activate([
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  private func createMainButton(action: ButtonAction) -> FormattingButton {
    let button = FormattingButton(action: action)
    button.delegate = delegate
    formatButtons[action] = button
    
    // 根据按钮类型设置外观
    switch action {
    case .paragraphStyle(let style):
      setupParagraphButton(button, style: style)
    case .textStyle(let style):
      setupTextStyleButton(button, style: style)
    default:
      setupDefaultButton(button)
    }
    
    // 添加事件处理
    button.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
    
    return button
  }

  private func setupParagraphButton(_ button: FormattingButton, style: ParagraphType) {
    switch style {
    case .h1: button.setTitle("标题", for: .normal)
    case .h2: button.setTitle("小标题", for: .normal)
    case .h3: button.setTitle("副标题", for: .normal)
    case .body: button.setTitle("正文", for: .normal)
    case .bulletedList: button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
    case .numberedList: button.setImage(UIImage(systemName: "list.number"), for: .normal)
    case .quote: button.setImage(UIImage(systemName: "text.quote"), for: .normal)
    }
  }

  private func setupTextStyleButton(_ button: FormattingButton, style: TextStyle) {
    button.setImage(UIImage(systemName: style.systemImageName), for: .normal)
  }

  private func setupDefaultButton(_ button: FormattingButton) {
    // 只设置图标，不设置标题
    button.setImage(UIImage(systemName: button.action.systemImageName), for: .normal)
    
    // 调整图片内容模式和大小
    button.imageView?.contentMode = .scaleAspectFit
    button.contentVerticalAlignment = .center
    button.contentHorizontalAlignment = .center
    
    // 移除任何内边距，让图标居中显示
    button.imageEdgeInsets = .zero
    button.contentEdgeInsets = .zero
  }

  @objc private func mainButtonTapped(_ sender: UIButton) {
    guard let formattingButton = sender as? FormattingButton else { return }
    
    switch formattingButton.action {
    case .textStyle(let style):
      handleTextStyleSelection(style)
      
    case .paragraphStyle(let style):
      handleParagraphStyleSelection(style)
      
    case .format:
      showFormatPopover(from: sender)
      
    case .attachment:
      delegate?.toolbarDidRequestInsertImage()
      
    default:
      break
    }
  }

  private func handleTextStyleSelection(_ style: TextStyle) {
    let updatedStyles = stateManager.handleStyleSelection(style)
    delegate?.toolbarDidSelectFormatting(style)
    updateButtonStates(activeStyles: updatedStyles, currentParagraph: currentParagraphStyle)
  }

  private func handleParagraphStyleSelection(_ style: ParagraphType) {
    let (updatedStyles, newParagraph) = stateManager.handleParagraphSelection(style)
    delegate?.toolbarDidSelectParagraphStyle(style)
    updateButtonStates(activeStyles: updatedStyles, currentParagraph: newParagraph)
  }

  private func showFormatPopover(from button: UIButton) {
    print("【调试】showFormatPopover 开始执行")
    dismissPopover()
    
    let popoverView = PopoverFormatView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
    popoverView.delegate = self.delegate
    popoverView.backgroundColor = .systemBackground // 确保背景色可见
    
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first,
          let buttonFrame = button.superview?.convert(button.frame, to: window) else {
        print("【调试】获取窗口失败")
        return
    }
    
    print("【调试】成功获取窗口和按钮位置")
    
    // 调整位置计算
    let screenWidth = UIScreen.main.bounds.width
    var x = buttonFrame.minX
    if x + 300 > screenWidth {
        x = screenWidth - 300 - 16
    }
    let y = buttonFrame.maxY + 8
    
    print("【调试】计算的浮窗位置: x=\(x), y=\(y)")
    
    // 创建容器视图
    let containerView = UIView(frame: CGRect(x: x, y: y, width: 300, height: 150))
    containerView.backgroundColor = .clear
    containerView.tag = 999
    
    // 设置阴影和圆角
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowRadius = 6
    containerView.layer.shadowOpacity = 0.2
    
    // 添加内容视图
    popoverView.frame = containerView.bounds
    popoverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(popoverView)
    
    // 将容器视图添加到主窗口
    window.addSubview(containerView)
    containerView.alpha = 0
    
    // 创建背景遮罩视图来处理点击
    let backgroundView = UIView(frame: window.bounds)
    backgroundView.backgroundColor = .clear
    backgroundView.tag = 998  // 用不同的tag标记背景视图
    window.insertSubview(backgroundView, belowSubview: containerView)
    
    // 添加点击外部关闭手势到背景视图
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
    backgroundView.addGestureRecognizer(tapGesture)
    
    UIView.animate(withDuration: 0.25) {
        containerView.alpha = 1
    }
    
    print("【调试】浮窗显示流程完成，已添加背景遮罩和手势")
  }

  @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
    print("【调试】检测到外部点击")
    
    // 获取点击位置
    let location = gesture.location(in: gesture.view?.superview)
    
    // 获取容器视图
    guard let window = UIApplication.shared.windows.first,
          let containerView = window.viewWithTag(999) else {
        print("【调试】未找到浮窗容器")
        return
    }
    
    // 检查点击是否在容器视图区域外
    if !containerView.frame.contains(location) {
        print("【调试】点击在浮窗外部，准备关闭")
        dismissPopover()
    } else {
        print("【调试】点击在浮窗内部，不关闭")
    }
  }

  @objc private func dismissPopover() {
    print("【调试】开始关闭浮窗")
    guard let window = UIApplication.shared.windows.first else { return }
    
    // 同时移除容器视图和背景遮罩
    if let containerView = window.viewWithTag(999),
       let backgroundView = window.viewWithTag(998) {
        UIView.animate(withDuration: 0.2, animations: {
            containerView.alpha = 0
            backgroundView.alpha = 0
        }) { _ in
            containerView.removeFromSuperview()
            backgroundView.removeFromSuperview()
            print("【调试】浮窗和背景遮罩已移除")
        }
    }
  }

  private func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let nextResponder = responder?.next {
        if let viewController = nextResponder as? UIViewController {
            return viewController
        }
        responder = nextResponder
    }
    return nil
  }

  private func getAction(from button: FormattingButton) -> ButtonAction {
    return button.action
  }
}
