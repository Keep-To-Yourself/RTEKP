import UIKit

/// 表示标准段落样式
public enum ParagraphType: Hashable {
    case body
    case h1, h2, h3  // Up to H6
    case bulletedList
    case numberedList
    case quote
    
    var fontSize: CGFloat {
        switch self {
        case .h1: return 24
        case .h2: return 22
        case .h3: return 20
        case .body, .bulletedList, .numberedList, .quote: return 17
        }
    }
    
    var fontWeight: UIFont.Weight {
        switch self {
        case .h1, .h2, .h3: return .bold
        default: return .regular
        }
    }
}
