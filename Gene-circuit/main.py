# This Python file uses the following encoding: utf-8
import os
import sys
from pathlib import Path

from argparse import ArgumentParser
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, QQmlDebuggingEnabler

# from PySide6.QtWebEngineQuick import QtWebEngineQuick

import Emulator
import FileIO

def main():
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
    qml_file = os.getcwd() + "/CommonHolderWindow.qml"

    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

os.chdir("Qmls")
main()
