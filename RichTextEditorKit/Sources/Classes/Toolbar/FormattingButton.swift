import UIKit

public class FormattingButton: UIButton {
    public let action: ButtonAction
    public weak var delegate: FormattingToolbarDelegate?
    
    public init(action: ButtonAction) {
        self.action = action
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.cornerRadius = 5
        clipsToBounds = true
        
        // 区分标题类按钮和其他按钮
        if case .paragraphStyle(let style) = action,
           [.h1, .h2, .h3, .body].contains(style) {
            // 标题类按钮使用深色文字
            tintColor = .label
            setTitleColor(.label, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            contentMode = .center
        } else {
            // 其他按钮设置图标
            tintColor = .label
            setImage(UIImage(systemName: action.systemImageName), for: .normal)
        }
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        // 如果是标题类按钮，确保正确的样式
        if case .paragraphStyle(let style) = action,
           [.h1, .h2, .h3, .body].contains(style) {
            titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            contentMode = .center
            titleEdgeInsets = .zero
            imageEdgeInsets = .zero
        }
    }
    
    // MARK: - 动作
    /// 按钮点击事件
    /// - Parameter sender: 触发的按钮
    @objc private func buttonTapped() {
        // 切换按钮状态
        updateState(isSelected: !isSelected)
        
        // 触发对应的动作
        switch action {
        case .textStyle(let style):
            delegate?.toolbarDidSelectFormatting(style)
        case .paragraphStyle(let type):
            delegate?.toolbarDidSelectParagraphStyle(type)
        case .heading(let level):
            delegate?.toolbarDidSelectParagraphStyle(.h1) // 根据级别选择对应的标题样式
        case .insertImage:
            delegate?.toolbarDidRequestInsertImage()
        case .quote:
            delegate?.toolbarDidSelectParagraphStyle(.quote)
        case .format, .todo, .table, .attachment:
            // 这些按钮的动作会在 FormattingToolbarView 中处理
            break
        }
    }
    
    /// 更新按钮状态
    /// - Parameter isSelected: 是否选中
    public func updateState(isSelected: Bool) {
        self.isSelected = isSelected
        
        // 简化的动画效果
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.2) : .clear
            self.tintColor = isSelected ? .systemBlue : .label
        }
    }
}
