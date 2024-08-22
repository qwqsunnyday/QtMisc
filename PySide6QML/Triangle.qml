import QtQuick 2.15

Canvas {
    width: parent.width
    height: parent.height
    required property int centerX
    required property int centerY
    required property int triWidth
    required property int triHeight
    required property color fillColor
    required property color strokeColor

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        // 设置线条属性
        ctx.strokeStyle = strokeColor // 边框颜色
        ctx.fillStyle = fillColor;
        ctx.lineJoin = "round"; // 圆角处理
        ctx.lineCap = "round";  // 圆角线帽

        ctx.lineWidth = 10;

        // 开始绘制路径
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(centerX, centerY - triHeight/2);
        ctx.lineTo(centerX + triWidth, centerY);
        ctx.lineTo(centerX, centerY + triHeight/2);
        ctx.lineTo(centerX, centerY);
        ctx.closePath();
        ctx.stroke()
        ctx.fill();
    }
}
