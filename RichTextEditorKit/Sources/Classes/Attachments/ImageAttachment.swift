//
//  ImageAttachment.swift
//  RichTextEditorKit
//
//  Created by 易汉斌 on 2025/5/4.
//

import UIKit

/// 用于图片的自定义 NSTextAttachment 子类，可以保存元数据
/// 如果需要在外部使用则设为 public
public class ImageAttachment: NSTextAttachment {

  // 添加自定义属性，例如图片URL、标题等
  public var imageURL: URL?
  public var caption: String?

  // 重写 attachmentBounds 方法来控制文本流中图片的大小
  override public func attachmentBounds(
    for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect,
    glyphPosition position: CGPoint, characterIndex charIndex: Int
  ) -> CGRect {
    guard let image = self.image else {
      return super.attachmentBounds(
        for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position,
        characterIndex: charIndex)
    }

    // 示例：按比例缩放图片以适应容器宽度
    let maxWidth = lineFrag.width
    let imageSize = image.size
    let aspectRatio = imageSize.width / imageSize.height
    var newSize = CGSize()

    if imageSize.width > maxWidth {
      newSize.width = maxWidth
      newSize.height = maxWidth / aspectRatio
    } else {
      newSize = imageSize  // 如果小于最大宽度，则使用原始大小
    }

    // 可选：添加填充或根据需要调整位置
    // return CGRect(origin: .zero, size: newSize).offsetBy(dx: 0, dy: someVerticalOffset)

    return CGRect(origin: .zero, size: newSize)
  }
}
