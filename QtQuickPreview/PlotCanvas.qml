import QtQuick 2.15

Rectangle {
    property alias prisugar: plotCanvas.prisugar
    property alias type: plotCanvas.type
    property alias scale: plotCanvas.scale
    Canvas {
        id: plotCanvas

        width: 400
        height: 400
        anchors.centerIn: parent

        required property int prisugar
        required property string type // ["Sugar" | "Insulin"]

        function plotSugar() {
            var ctx = plotCanvas.getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var x = []
            var y = []

            ctx.beginPath()
            ctx.strokeStyle = prisugar <= 40 ? "blue" : "red"
            ctx.lineWidth = 2

            if (prisugar <= 40) {
                for (var i = 1; i < 100; i++) {
                    x.push(i)
                    var yVal = Math.sin(i) + prisugar
                    ctx.lineTo(i * 4, height - yVal * 4)
                }
            } else {
                for (var i = 1; i < 20; i++) {
                    x.push(i)
                    y.push(Math.sin(i) + prisugar)
                }
                for (var i = 20; i < 80; i++) {
                    x.push(i)
                    y.push((1 / 90 - prisugar / 3600) * Math.pow((i - 20), 2) + prisugar)
                }
                for (var i = 80; i < 100; i++) {
                    x.push(i)
                    y.push(Math.sin(i) + 40)
                }
                for (var j = 0; j < x.length; j++) {
                    ctx.lineTo(x[j] * 4, height - y[j] * 4)
                }
            }

            ctx.stroke()
        }

        function plotInsulin() {
            var ctx = plotCanvas.getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var x = []
            var y = []

            ctx.beginPath()
            ctx.strokeStyle = "red"
            ctx.lineWidth = 2

            if (prisugar <= 40) {
                for (var i = 1; i < 100; i++) {
                    x.push(i)
                }
                for (var j = 0; j < x.length; j++) {
                    var yVal = Math.sin(x[j]) + 20
                    ctx.lineTo(x[j] * 4, height - yVal * 4)
                }
            } else {
                for (var i = 1; i < 20; i++) {
                    x.push(i)
                    y.push(Math.sin(i) + 20)
                }
                for (var i = 20; i < 80; i++) {
                    x.push(i)
                    y.push((2 / 45 - prisugar / 900) * Math.pow((i - 50), 2) + prisugar - 20)
                }
                for (var i = 80; i < 100; i++) {
                    x.push(i)
                    y.push(Math.sin(i) + 20)
                }
                for (var j = 0; j < x.length; j++) {
                    ctx.lineTo(x[j] * 4, height - y[j] * 4)
                }
            }

            ctx.stroke()
        }

        Component.onCompleted: {
            plotCanvas.requestPaint()
        }

        onPrisugarChanged: {
            plotCanvas.requestPaint()
        }

        onTypeChanged: {
            plotCanvas.requestPaint()
        }

        onPaint: {
            switch(plotCanvas.type) {
                case "Sugar":
                    plotCanvas.plotSugar()
                    break
                case "Insulin":
                    plotCanvas.plotInsulin()
                    break
            }
        }
    }
}
