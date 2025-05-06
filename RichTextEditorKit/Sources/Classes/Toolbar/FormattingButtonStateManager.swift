import UIKit

/// 按钮状态管理器：负责管理工具栏中格式化按钮的状态
class FormattingButtonStateManager {
    private var currentActiveStyles: Set<TextStyle> = []
    private var currentParagraphStyle: ParagraphType = .body
    
    func updateStates(activeStyles: Set<TextStyle>, 
                     currentParagraph: ParagraphType?, 
                     forButtons buttons: [FormattingButton]) {
        if let paragraphStyle = currentParagraph {
            self.currentParagraphStyle = paragraphStyle
        }
        self.currentActiveStyles = activeStyles
        
        buttons.forEach { button in
            switch button.action {
            case .textStyle(let style):
                // 所有文本样式按钮都根据当前样式集合更新状态
                button.updateState(isSelected: activeStyles.contains(style))
                
            case .paragraphStyle(let style):
                // 段落样式按钮互斥
                button.updateState(isSelected: style == self.currentParagraphStyle)
                
            case .format, .todo, .table, .attachment:
                // 这些按钮不需要高亮状态
                button.updateState(isSelected: false)
            default:
                break
            }
        }
    }
    
    func handleStyleSelection(_ style: TextStyle) -> Set<TextStyle> {
        var updatedStyles = currentActiveStyles
        
        if updatedStyles.contains(style) {
            updatedStyles.remove(style)
        } else {
            updatedStyles.insert(style)
        }
        
        return updatedStyles
    }
    
    func handleParagraphSelection(_ style: ParagraphType) -> (styles: Set<TextStyle>, paragraph: ParagraphType) {
        var updatedStyles = currentActiveStyles
        
        if style == currentParagraphStyle {
            // 如果点击当前段落样式，恢复为正文并清除所有样式
            updatedStyles.removeAll()
            return (updatedStyles, .body)
        }
        
        // 切换到新的段落样式
        if [.h1, .h2, .h3].contains(style) {
            if !currentActiveStyles.isEmpty && [.h1, .h2, .h3].contains(currentParagraphStyle) {
                // 如果当前是标题且有样式，保持这些样式并添加加粗
                updatedStyles.insert(.bold)
            } else {
                // 如果从非标题切换到标题，清除所有样式并添加加粗
                updatedStyles = [.bold]
            }
        } else if style == .body {
            if !currentActiveStyles.isEmpty && [.h1, .h2, .h3].contains(currentParagraphStyle) {
                // 如果从标题切换到正文，保持除加粗外的其他样式
                if updatedStyles.contains(.bold) && updatedStyles.count > 1 {
                    updatedStyles.remove(.bold)
                }
            } else {
                // 切换到正文时清除所有样式
                updatedStyles.removeAll()
            }
        }
        
        return (updatedStyles, style)
    }
}
