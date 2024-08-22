import QtQuick

Canvas {
    id: gridCanvas
    anchors.fill: parent
    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        // 设置小格的颜色
        ctx.strokeStyle = "#808080"; // 灰色
        // ctx.strokeStyle = "#e0e0e0"; // 浅灰色
        ctx.lineWidth = 1;
        // 绘制小格
        for (var x = 0; x <= width; x += 10) {
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, height);
            ctx.stroke();
        }
        for (var y = 0; y <= height; y += 10) {
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(width, y);
            ctx.stroke();
        }

        // 设置大格的颜色
        ctx.strokeStyle = "#808080"; // 灰色
        ctx.lineWidth = 2;
        // 绘制大格
        for (var x = 0; x <= width; x += 100) {
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, height);
            ctx.stroke();
        }
        for (var y = 0; y <= height; y += 100) {
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(width, y);
            ctx.stroke();
        }


    }
    onWidthChanged: gridCanvas.requestPaint()
    onHeightChanged: gridCanvas.requestPaint()
    Component.onCompleted: {
    }
}
