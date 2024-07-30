import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    
    Rectangle {
        id: myRectangle
        width: 200
        height: 200
        color: "lightblue"
        radius: 10
        border.color: "black"
        border.width: 2

        MouseArea {
            anchors.fill: parent
            onClicked: {
                printAllProperties(myRectangle)
            }
        }
    }

    function printAllProperties(item) {
        console.log("Properties of item:", item);
        for (var property in item) {
            if (item.hasOwnProperty(property) && typeof item[property] !== 'function') {
                debugger;
                console.log(property + ": " + item[property]);
            }
        }
    }
}
