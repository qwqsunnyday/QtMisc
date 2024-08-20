# This Python file uses the following encoding: utf-8

import json
from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement
from pd import evaluate_conditions

# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "Emulator"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class Emulator(QObject):

    @Slot(str, str, result=str)
    def evaluate(self, sequences_JSON_data: str, environment_variables_JSON_data: str):
        """_summary_

        Args:
            sequences_JSON_data (str): JSON of sequenceModel
                e.g.
                [
                    {"uuid":14,"droppedItemModel":[{"uuid":12,"modelData":"data: 0","posX":66.5,"posY":61,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"启动子","internalName":"9XUAS","name":"9XUAS"},"itemWidth":200,"itemHeight":100},{"uuid":13,"modelData":"data: 3","posX":-0.5,"posY":-44.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"蛋白质编码区","internalName":"GAL4","name":"GAL4"},"itemWidth":200,"itemHeight":100}],"posX":16,"posY":16.5},
                    {"uuid":17,"droppedItemModel":[{"uuid":15,"modelData":"data: 2","posX":52,"posY":141.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"启动子","internalName":"U6_P","name":"U6_P"},"itemWidth":200,"itemHeight":100},{"uuid":16,"modelData":"data: 9","posX":10.5,"posY":-48.5,"stateType":"inSequence","sourceData":{"objectName":"","description":"","fillColor":"orange","type":"蛋白质编码区","internalName":"LOV","name":"LOV"},"itemWidth":200,"itemHeight":100}],"posX":52,"posY":141.5}
                ]
            environment_variables_JSON_data (str): JSON of environment variables
                e.g.
                {
                    "blood_sugar": 50, 
                    "blueray": true
                }

        Returns:
            str: answer JSON
            
            {   
                "greenLight": raw_output=="绿光", 
                "sugar": raw_output=="血糖", 
                "rawOutput": raw_output 
            }
        
        """
        sequences: list = json.loads(sequences_JSON_data)
        environment_variables: dict = json.loads(environment_variables_JSON_data)
        
        conditions: list[str] = []
        for sequence in sequences:
            bio_devices: list = sequence["droppedItemModel"]
            condition: str = ""
            for bio_device in bio_devices:
                condition += bio_device["sourceData"]["name"] + "-"
            conditions.append(condition[:-1])
        raw_output: str = evaluate_conditions(conditions, environment_variables)
        result: dict = {
            "greenLight": ("绿光" in raw_output),
            "sugar": ("血糖" in raw_output),
            "noResult": raw_output == "无结果",
            "rawOutput": raw_output
        }
        return json.dumps(result)
