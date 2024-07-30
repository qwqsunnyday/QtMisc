import re
import sys
# for view
from PySide6.QtWidgets import QApplication
from PySide6.QtQuick import QQuickView
from PySide6.QtCore import QUrl
# for ApplicationWindow, Window, ... 
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt, QCoreApplication


def check_regex_in_file(file_path, regex_pattern):
    pattern = re.compile(regex_pattern)
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            if pattern.search(line):
                return True
    return False

target_qml_file = sys.argv[1]

if check_regex_in_file(sys.argv[1], "^(ApplicationWindow|Window) {"):
    app = QApplication(sys.argv)
    # app = QApplication()

    # QApplication.setAttribute(#)
    # QCoreApplication.setAttribute(#)

    engine = QQmlApplicationEngine(target_qml_file)

    sys.exit(app.exec())
else :
    app = QApplication([])
    view = QQuickView()

    url = QUrl(target_qml_file)

    view.setSource(url)
    view.show()
    app.exec()

