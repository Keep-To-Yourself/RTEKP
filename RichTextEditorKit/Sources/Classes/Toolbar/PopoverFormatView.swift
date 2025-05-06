import UIKit

class PopoverFormatView: UIView {
    
    private let stackView = UIStackView()
    weak var delegate: FormattingToolbarDelegate?
    
    private var currentActiveStyles: Set<TextStyle> = []
    private var currentParagraphStyle: ParagraphType = .body
    private var buttonGroups: [[FormattingButton]] = []
    
    private let stateManager = FormattingButtonStateManager()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        stackView.axis = .vertical
        stackView.spacing = 1  // 减小行间距
        stackView.distribution = .fillEqually  // 确保每行高度相等
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // 添加三行按钮
        stackView.addArrangedSubview(createHeaderRow())
        stackView.addArrangedSubview(createStyleRow())
        stackView.addArrangedSubview(createListRow())
        
        // 更新约束以填充整个视图
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createHeaderRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 1
        
        let buttonConfigs: [(type: ParagraphType, title: String)] = [
            (.h1, "标题"),
            (.h2, "小标题"),
            (.h3, "副标题"),
            (.body, "正文")
        ]
        
        let headerButtons = buttonConfigs.map { config in
            let button = FormattingButton(action: .paragraphStyle(config.type))
            button.setTitle(config.title, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.delegate = delegate
            button.addTarget(self, action: #selector(headerButtonTapped(_:)), for: .touchUpInside)
            return button
        }
        
        buttonGroups.append(headerButtons)
        headerButtons.forEach { row.addArrangedSubview($0) }
        return row
    }
    
    private func createStyleRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 1
        
        let buttonConfigs = [
            (style: TextStyle.bold, imageName: "bold"),
            (style: TextStyle.italic, imageName: "italic"),
            (style: TextStyle.underline, imageName: "underline"),
            (style: TextStyle.strikethrough, imageName: "strikethrough")
        ]
        
        let styleButtons = buttonConfigs.map { config in
            let button = FormattingButton(action: .textStyle(config.style))
            button.setImage(UIImage(systemName: config.imageName), for: .normal)
            button.delegate = delegate
            button.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .touchUpInside)
            return button
        }
        
        buttonGroups.append(styleButtons)
        styleButtons.forEach { row.addArrangedSubview($0) }
        return row
    }
    
    private func createListRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 1
        
        let listButtons = [
            FormattingButton(action: .paragraphStyle(.numberedList)),
            FormattingButton(action: .paragraphStyle(.bulletedList)),
            FormattingButton(action: .paragraphStyle(.quote))
        ]
        
        listButtons.forEach {
            $0.delegate = delegate
            $0.addTarget(self, action: #selector(listButtonTapped(_:)), for: .touchUpInside)
        }
        
        buttonGroups.append(listButtons)
        listButtons.forEach { row.addArrangedSubview($0) }
        return row
    }
    
    @objc private func headerButtonTapped(_ sender: FormattingButton) {
        if case .paragraphStyle(let style) = sender.action {
            let (updatedStyles, newParagraph) = stateManager.handleParagraphSelection(style)
            delegate?.toolbarDidSelectParagraphStyle(style)
            updateButtonStates(activeStyles: updatedStyles, currentParagraph: newParagraph)
        }
    }
    
    @objc private func styleButtonTapped(_ sender: FormattingButton) {
        if case .textStyle(let style) = sender.action {
            let updatedStyles = stateManager.handleStyleSelection(style)
            delegate?.toolbarDidSelectFormatting(style)
            updateButtonStates(activeStyles: updatedStyles, currentParagraph: currentParagraphStyle)
        }
    }
    
    @objc private func listButtonTapped(_ sender: FormattingButton) {
        if case .paragraphStyle(let style) = sender.action {
            let (updatedStyles, newParagraph) = stateManager.handleParagraphSelection(style)
            delegate?.toolbarDidSelectParagraphStyle(style)
            updateButtonStates(activeStyles: updatedStyles, currentParagraph: newParagraph)
        }
    }
    
    // 添加更新状态方法
    public func updateButtonStates(activeStyles: Set<TextStyle>, currentParagraph: ParagraphType?) {
        // 将所有按钮组合成一个数组
        let allButtons = buttonGroups.flatMap { $0 }
        stateManager.updateStates(activeStyles: activeStyles, 
                                currentParagraph: currentParagraph, 
                                forButtons: allButtons)
    }
}
