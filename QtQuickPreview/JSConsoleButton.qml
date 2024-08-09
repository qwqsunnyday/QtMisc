import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal

Button {
    property alias predefinedCommands: jsConsole.predefinedCommands
    property alias windowWidth: jsConsoleWindow.width
    property alias windowHeight: jsConsoleWindow.height

    Window {
        id: jsConsoleWindow
        width: 600
        height: 500
        JSConsole {
            id: jsConsole
        }
    }

    width: 70
    height: 28
    text: "Console"
    onClicked: {
        jsConsoleWindow.show()
    }
}
