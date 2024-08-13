import QtQuick 2.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal

Container {
    id: swipeBannerContainer

    contentItem: RowLayout {

        Button {
            Layout.fillHeight: true
            Layout.minimumWidth: 20
            text: "<"
            onClicked: {
                textDisplayView.decrementCurrentIndex()
            }
        }

        Control {
            Layout.fillHeight: true
            Layout.fillWidth: true

            background: Rectangle {
                border.color: Qt.lighter("gray")
                border.width: 2
            }

            topPadding: 10
            leftPadding: 10
            rightPadding: 10
            contentItem: ColumnLayout {
                SwipeView {
                    id: textDisplayView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    Repeater {
                        model: swipeBannerContainer.contentModel
                    }
                }
                PageIndicator {
                    count: textDisplayView.count
                    currentIndex: textDisplayView.currentIndex
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Button {
            Layout.fillHeight: true
            Layout.minimumWidth: 20
            text: ">"
            onClicked: {
                textDisplayView.incrementCurrentIndex()
            }
        }
    }
}
