import QtQuick 2.15

Canvas {
    width: parent.width
    height: parent.height
    required property int centerX
    required property int centerY
    required property int radius
    required property color fillColor
    required property color strokeColor

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        // 设置阴影
        // ctx.shadowColor = "gray" // 阴影颜色
        // ctx.shadowBlur = 4 // 阴影模糊程度
        // ctx.shadowOffsetX = 2 // 阴影的水平偏移
        // ctx.shadowOffsetY = 2 // 阴影的垂直偏移

        // 绘制边框
        ctx.lineWidth = 5 // 边框宽度
        ctx.strokeStyle = strokeColor // 边框颜色
        ctx.fillStyle = fillColor;

        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
        ctx.fill()
    }
}
