# This Python file uses the following encoding: utf-8
import json
import os
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlDebuggingEnabler,  QmlElement, QmlSingleton, qmlRegisterType
from argparse import ArgumentParser

# from PySide6.QtWebEngineQuick import QtWebEngineQuick

from PySide6.QtCore import QObject, Slot

from pd import evaluate_conditions

# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "io.emulator"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class Emulator(QObject):

    @Slot(str, result=str)
    def evaluate(self, sequences_JSON_data: str):
        """_summary_

        Args:
            s (str): JSON of sequenceModel

        Returns:
            str: answer
        
        e.g. JSON
        [
            {"uuid":14,"droppedItemModel":[{"uuid":12,"modelData":"data: 0","posX":66.5,"posY":61,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"启动子","internalName":"9XUAS","name":"9XUAS"},"itemWidth":200,"itemHeight":100},{"uuid":13,"modelData":"data: 3","posX":-0.5,"posY":-44.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"蛋白质编码区","internalName":"GAL4","name":"GAL4"},"itemWidth":200,"itemHeight":100}],"posX":16,"posY":16.5},
            {"uuid":17,"droppedItemModel":[{"uuid":15,"modelData":"data: 2","posX":52,"posY":141.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"启动子","internalName":"U6_P","name":"U6_P"},"itemWidth":200,"itemHeight":100},{"uuid":16,"modelData":"data: 9","posX":10.5,"posY":-48.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"蛋白质编码区","internalName":"LOV","name":"LOV"},"itemWidth":200,"itemHeight":100}],"posX":52,"posY":141.5}
        ]
        """
        sequences: list = json.loads(sequences_JSON_data)
        conditions: list[str] = []
        for sequence in sequences:
            bio_devices: list = sequence["droppedItemModel"]
            condition: str = ""
            for bio_device in bio_devices:
                condition += bio_device["sourceData"]["name"] + "-"
            conditions.append(condition[:-1])
        return evaluate_conditions(conditions)


QML_IMPORT_NAME = "FileIO"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0 # Optional

@QmlElement
@QmlSingleton
class FileIO(QObject):
    
    # @staticmethod
    # def create(engine):
    #     print("created")
    #     return FileIO()
    
    @Slot(str, result=str)
    def read(self, file_path: str):
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as file:
                return file.read()
        return ""
    
    @Slot(str, str, result=str)
    def write(self, file_path: str, content: str):
        # 打开文件并写入
        with open(file_path, 'w') as file:
            file.write(content)


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
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "CommonHolderWindow.qml"

    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
