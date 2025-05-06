//
//  ViewController.swift
//  Example
//
//  Created by 易汉斌 on 2025/5/3.
//

import RichTextEditorKit
import UIKit

class RichTextEditorViewController: UIViewController {
    
    private let editorView = EditorView()
    private let toolbarView = FormattingToolbarView()
    
    // 切换按钮
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("切换工具栏", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 基础按钮栈视图
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // 保存基础按钮的引用
    private let basicButtons: [FormattingButton] = [
        FormattingButton(action: .textStyle(.bold)),
        FormattingButton(action: .textStyle(.italic)),
        FormattingButton(action: .paragraphStyle(.h1)),
        FormattingButton(action: .paragraphStyle(.quote))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("【调试】ViewController viewDidLoad")
        setupViews()
        configureDelegates()
        setupActions()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // 添加视图
        view.addSubview(toggleButton)
        view.addSubview(buttonStackView)
        view.addSubview(toolbarView)
        view.addSubview(editorView)
        
        // 配置工具栏
        toolbarView.isHidden = true
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        editorView.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加基础按钮到栈视图
        basicButtons.forEach { buttonStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            // 切换按钮约束
            toggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            toggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // 基础按钮栈视图约束
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // 工具栏约束
            toolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 编辑器视图约束
            editorView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 10),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDelegates() {
        print("【调试】开始配置代理")
        
        // 设置按钮代理
        basicButtons.forEach { button in
            button.delegate = self
            print("【调试】设置基础按钮代理")
        }
        
        // 设置工具栏代理
        toolbarView.delegate = self
        print("【调试】设置工具栏代理")
        
        // 设置编辑器代理
        editorView.richTextView.toolbarDelegate = self
        print("【调试】设置编辑器代理")
    }
    
    private func setupActions() {
        toggleButton.addTarget(self, action: #selector(toggleToolbarView), for: .touchUpInside)
    }
    
    @objc private func toggleToolbarView() {
        UIView.animate(withDuration: 0.3) {
            self.toolbarView.isHidden.toggle()
            self.buttonStackView.isHidden.toggle()
            self.toggleButton.setTitle(
                self.toolbarView.isHidden ? "切换工具栏" : "切换按钮",
                for: .normal
            )
        }
    }
}

// MARK: - 格式化工具栏代理
extension RichTextEditorViewController: FormattingToolbarDelegate {
    func toolbarDidSelectFormatting(_ style: TextStyle) {
        editorView.richTextView.applyFormatting(style)
    }
    
    func toolbarDidSelectParagraphStyle(_ style: ParagraphType) {
        editorView.richTextView.applyParagraphStyle(style)
        // 更新段落样式按钮状态
        basicButtons.forEach { button in
            if case .paragraphStyle(let buttonStyle) = button.action {
                button.updateState(isSelected: buttonStyle == style)
            }
        }
    }
    
    func toolbarDidRequestInsertImage() {
        // 实现图片选择逻辑
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func toolbarDidUpdateActiveStyles(_ styles: Set<TextStyle>) {
        // 更新文本样式按钮状态
        basicButtons.forEach { button in
            if case .textStyle(let style) = button.action {
                button.updateState(isSelected: styles.contains(style))
            }
        }
        toolbarView.updateButtonStates(activeStyles: styles, currentParagraph: nil)
    }
}

extension RichTextEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // TODO: 处理选中的图片
            print("选择了图片")
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension RichTextEditorViewController: UIPopoverPresentationControllerDelegate {
    // 强制使用 popover 样式
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // 可选：处理弹出窗口关闭事件
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("格式选择弹窗已关闭")
    }
}
