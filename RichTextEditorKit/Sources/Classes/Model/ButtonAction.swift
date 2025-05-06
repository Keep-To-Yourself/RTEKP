import Foundation

public enum ButtonAction: Hashable {
    case format              // 格式按钮（触发浮窗）
    case todo               // TODO 按钮
    case table              // 表格按钮
    case attachment         // 附件按钮
    case textStyle(TextStyle)           // 文本样式
    case paragraphStyle(ParagraphType)  // 段落样式
    case heading(Int)                   // 标题级别 1-6
    case insertImage                    // 插入图片
    case quote                          // 引用块
    
    // 由于使用了关联值，需要手动实现 Hashable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .textStyle(let style):
            hasher.combine(0)  // 用于区分 case
            hasher.combine(style)
        case .paragraphStyle(let type):
            hasher.combine(1)
            hasher.combine(type)
        case .heading(let level):
            hasher.combine(2)
            hasher.combine(level)
        case .insertImage:
            hasher.combine(3)
        case .quote:
            hasher.combine(4)
        case .format:
            hasher.combine(5)
        case .todo:
            hasher.combine(6)
        case .table:
            hasher.combine(7)
        case .attachment:
            hasher.combine(8)
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .textStyle(let style):
            return style.systemImageName
        case .paragraphStyle(let type):
            switch type {
            case .bulletedList: return "list.bullet"
            case .numberedList: return "list.number"
            default: return "text.alignleft"
            }
        case .heading(let level):
            return "h.square.\(level)"
        case .insertImage:
            return "photo"
        case .quote:
            return "text.quote"
        case .format:
            return "textformat"
        case .todo:
            return "checklist"
        case .table:
            return "table"
        case .attachment:
            return "paperclip"
        }
    }
    
    public var title: String? {
        switch self {
        // 移除这些按钮的标题，返回nil
        case .format, .todo, .table, .attachment:
            return nil
        default:
            return nil
        }
    }
}
