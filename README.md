# RichTextEditorKit

一个用于iOS的可重用富文本编辑器组件库,基于Swift和UIKit构建,灵感来自AztecEditor-iOS。

## 安装配置

### CocoaPods

在Podfile中添加:

```ruby
pod 'RichTextEditorKit', :git => 'https://github.com/YOUR_USERNAME/RichTextEditorKit.git'
```

然后执行:

```bash
pod install
```

### 手动集成

1. 克隆此仓库
2. 将RichTextEditorKit目录拖入你的项目
3. 在项目设置的General面板中添加framework

### 系统要求
- iOS 13.0+
- Xcode 11.0+
- Swift 5.0+

## 架构设计

本项目采用模块化设计，以下是主要源代码结构：

```
Sources/
└── Classes/
    ├── Attachments/
    │   └── ImageAttachment.swift       // 图片附件处理
    │
    ├── Formatting/
    │   └── AttributeApplier.swift      // 文本属性应用工具
    │
    ├── Model/
    │   ├── TextStyle.swift             // 文本样式定义
    │   ├── ParagraphType.swift         // 段落类型定义
    │   └── ButtonAction.swift          // 按钮动作类型定义
    │
    ├── Storage/
    │   └── RichTextStorage.swift       // 自定义文本存储实现
    │
    ├── TextView/
    │   ├── RichTextView.swift          // 富文本编辑核心组件
    │   └── EditorView.swift            // 复合编辑器视图
    │
    ├── Toolbar/
    │   ├── FormattingToolbarView.swift     // 主工具栏视图
    │   ├── FormattingButton.swift          // 格式化按钮组件
    │   ├── FormattingButtonStateManager.swift // 按钮状态管理器
    │   └── PopoverFormatView.swift         // 弹出式格式工具栏
    │
    └── Utils/
        └── NSAttributedString+Extensions.swift  // 工具类扩展
```

每个模块的主要职责：

- **Attachments**: 处理图片、视频等媒体附件的插入和显示
- **Formatting**: 文本格式化相关的核心逻辑
  - AttributeApplier: 处理文本属性的应用和移除
- **Model**: 定义核心数据模型和行为
  - TextStyle: 文本样式枚举（粗体、斜体等）
  - ParagraphType: 段落类型定义（标题、列表等）
  - ButtonAction: 按钮动作类型（统一的按钮行为定义）
- **Storage**: 提供自定义的文本存储实现，支持富文本特性
- **TextView**: 提供编辑器的核心UI组件
  - RichTextView: 基础富文本编辑组件
  - EditorView: 复合编辑器视图
- **Toolbar**: 提供可自定义的格式化工具栏组件
  - FormattingToolbarView: 主工具栏视图
  - FormattingButton: 独立可复用的格式化按钮
  - FormattingButtonStateManager: 管理按钮状态和样式切换逻辑
  - PopoverFormatView: 提供更多格式化选项的弹出式工具栏
- **Utils**: 提供常用工具类和扩展方法

## 使用场景

### 场景一：使用完整工具栏
```swift
let editorView = EditorView()
let toolbar = FormattingToolbarView(actions: [
    .textStyle(.bold),
    .textStyle(.italic),
    .heading(1),
    .quote,
    .insertImage
])
toolbar.delegate = editorView.richTextView

// 添加视图和设置约束
view.addSubview(toolbar)
view.addSubview(editorView)
```

### 场景二：使用单个格式化按钮
```swift
let editorView = EditorView()
let boldButton = FormattingButton(action: .textStyle(.bold))
boldButton.delegate = editorView.richTextView

// 添加视图和设置约束
view.addSubview(boldButton)
view.addSubview(editorView)
```

### 场景三：自定义按钮组合
```swift
let editorView = EditorView()
let buttonStack = UIStackView()
buttonStack.axis = .horizontal
buttonStack.spacing = 8

// 创建需要的按钮
let buttons = [
    FormattingButton(action: .textStyle(.bold)),
    FormattingButton(action: .heading(1)),
    FormattingButton(action: .quote)
]

// 添加到堆栈视图
buttons.forEach { button in
    buttonStack.addArrangedSubview(button)
    button.delegate = editorView.richTextView
}

// 添加视图和设置约束
view.addSubview(buttonStack)
view.addSubview(editorView)
```

## 主要功能

- [x] 基础文本格式化 (粗体、斜体、下划线、删除线)
- [x] 标题样式 (H1-H3)
- [ ] 列表 (有序、无序)
- [x] 引用块
- [ ] 图片插入与管理
- [ ] Markdown 快捷输入
- [ ] iPad 键盘快捷键支持
- [ ] 数据持久化
- [ ] iCloud 同步 (规划中)

## API 文档

### RichTextView

主要编辑器视图类

```swift
public class RichTextView: UITextView {
    // 配置项
    var allowsImageInsertion: Bool
    
    // 格式化方法
    func applyFormatting(_ style: TextStyle)
    func insertImage(_ image: UIImage)
    
    // 代理
    weak var richTextDelegate: RichTextViewDelegate?
}
```

### FormattingToolbar

格式工具栏

```swift
public class FormattingToolbar: UIView {
    // 工具栏项配置
    var enabledItems: [FormattingItem]
    
    // 代理
    weak var delegate: FormattingToolbarDelegate?
}
```

更多API文档正在完善中...

## 贡献指南

欢迎提交Issue和Pull Request。具体贡献指南请参考CONTRIBUTING.md文件。

## 开源协议

本项目基于MIT协议开源。详见LICENSE文件。