# This Python file uses the following encoding: utf-8
import json
import os
import sys
from pathlib import Path

from argparse import ArgumentParser
from webbrowser import get
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, QQmlDebuggingEnabler,  QmlElement

# from PySide6.QtWebEngineQuick import QtWebEngineQuick

from pd import evaluate_conditions

import Emulator
import FileIO

def get_path(relative_path):
    try:
        base_path = sys._MEIPASS # pyinstaller打包后的路径
    except AttributeError:
        base_path = os.path.abspath(".") # 当前工作目录的路径
 
    return os.path.normpath(os.path.join(base_path, relative_path)) # 返回实际路径

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
    qml_file = Path(__file__).resolve().parent / "CommonHolderWindow.qml"

    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

os.chdir(get_path("."))
main()
