# This Python file uses the following encoding: utf-8
import json
import sys
from pathlib import Path

from argparse import ArgumentParser
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, QQmlDebuggingEnabler,  QmlElement

# from PySide6.QtWebEngineQuick import QtWebEngineQuick

from pd import evaluate_conditions

import Emulator
import FileIO


if __name__ == "__main__":
    argument_parser = ArgumentParser()
    argument_parser.add_argument("-qmljsdebugger", action="store",
    help="Enable QML debugging")
    options = argument_parser.parse_args()
    if options.qmljsdebugger:
        QQmlDebuggingEnabler.enableDebugging(True)

    # for WebEngineView
    # QtWebEngineQuick.initialize()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("Gene-circuit")
    app.setOrganizationName(" ")
    app.setOrganizationDomain(" ")
    # app.setFont(QFont("Consolas, 微软雅黑"))
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "CommonHolderWindow.qml"

    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
