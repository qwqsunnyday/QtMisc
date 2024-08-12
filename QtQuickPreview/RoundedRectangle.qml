import QtQuick 2.15

Canvas {
    width: parent.width
    height: parent.height
    required property int posX
    required property int posY
    required property int rectWidth
    required property int rectHeight
    required property int borderRadius
    required property color fillColor
    required property color strokeColor

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var rect = Qt.rect(posX, posY, rectWidth, rectHeight)
        var left = rect.left
        var right = rect.right
        var top = rect.top
        var bottom = rect.bottom

        // 设置阴影
        // ctx.shadowColor = "gray" // 阴影颜色
        // ctx.shadowBlur = 4 // 阴影模糊程度
        // ctx.shadowOffsetX = 2 // 阴影的水平偏移
        // ctx.shadowOffsetY = 2 // 阴影的垂直偏移

        // 绘制边框
        ctx.lineWidth = 5 // 边框宽度
        ctx.strokeStyle = strokeColor // 边框颜色
        ctx.fillStyle = fillColor;

        // 绘制圆角矩形路径
        ctx.beginPath()
        ctx.moveTo(left + borderRadius, top) // 起点
        ctx.lineTo(right - borderRadius, top) // 上边线
        ctx.arcTo(right, top, right,
                  top + borderRadius, borderRadius) // 右上角
        ctx.lineTo(right, bottom - borderRadius) // 右边线
        ctx.arcTo(right, bottom,
                  right - borderRadius, bottom,
                  borderRadius) // 右下角
        ctx.lineTo(left + borderRadius, bottom) // 下边线
        ctx.arcTo(left, bottom, left,
                  bottom - borderRadius, borderRadius) // 左下角
        ctx.lineTo(left, top + borderRadius) // 左边线
        ctx.arcTo(left, top, left + borderRadius, top,
                  borderRadius) // 左上角
        // ctx.stroke()
        ctx.fill()

    }
}
