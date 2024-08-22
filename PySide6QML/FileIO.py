# This Python file uses the following encoding: utf-8
import json
import os
import sys

from PySide6.QtQml import QmlElement, QmlSingleton
from PySide6.QtCore import QObject, Slot


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
