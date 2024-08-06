# coding=utf-8

# Genochemy
from enum import Enum
from pprint import pprint, pformat
from typing import Any, Optional, TypeAlias, Union, override
from typing import List, Dict, Set, Tuple

class StatePool:
    class Scope(Enum):
        """作用域
        SEQUENCE: 每一个Sequence实例的局部变量, 暂时使用Sequence实例的self表示, 暂时只包括expression
        EMULATION: 模拟中的全局量
        ENVIRONMENT: drug_A blue_light red_light
        """
        EMULATION = 0
        ENVIRONMENT = 1
    KeyType: TypeAlias = Optional[Union['Sequence', Scope]]
    
    states: Dict[KeyType, Dict[str, float]] = {}

    def add_state(self, name: str, state: float, scope: KeyType = Scope.EMULATION):
        if scope not in self.states:
            self.states[scope] = {}
        self.states[scope][name] = state

    def get_state(self, name: str, default_if_not_exists: float = 0.0, scope: KeyType = Scope.EMULATION) -> float:
        if scope not in self.states:
            self.states[scope] = {}
        if name not in self.states[scope]:
            self.add_state(name, default_if_not_exists, scope)
        return self.states[scope][name]
    def __repr__(self) -> str:
        return self.__str__()
    def __str__(self) -> str:
        return pformat(self.states)

class Sequence:
    # 此时尚未定义Bio_Device类
    _statements: List['Bio_Device'] = []
    _dependency: List[Any] = []
    def __init__(self, statements: List['Bio_Device'] = [], state_pool: StatePool = StatePool()) -> None:
        self._statements = statements
        self.resolve_state_pool(state_pool)
    def resolve_state_pool(self, state_pool: StatePool):
        for statement in self._statements:
            statement._state_pool = state_pool
            statement._sequence = self
    def run(self):
        for statement in self._statements:
            if isinstance(statement, Promoter):
                statement.express()
            if isinstance(statement, Coding_Region):
                statement.execute()
            # 终止子... 
        pass
    def __repr__(self) -> str:
        """调试器使用的字符串
        """
        return self.__str__()
    def __str__(self) -> str:
        """str()使用的字符串
        """
        return str([f"{str(statement)}" for statement in self._statements])

class Emulation:
    sequences: List[Sequence] = []
    _state_pool: StatePool
    def __init__(self, state_pool: StatePool) -> None:
        self._state_pool = state_pool
        self.resolve_state_pool()
    def resolve_dependency(self):
        """处理依赖关系
        
        TODO 使用拓扑排序处理依赖关系AOV
        """
    def resolve_state_pool(self):
        for sequence in self.sequences:
            sequence.resolve_state_pool(self._state_pool)
    def add(self, statements: List['Bio_Device']):
        self.sequences.append(Sequence(statements, self._state_pool))
        self.resolve_dependency()
        self.resolve_state_pool()
    def set_args(self, envs: Dict[str, float]):
        for env_name, env_value in envs.items():
            self._state_pool.add_state(env_name, env_value, StatePool.Scope.ENVIRONMENT)
    def run(self):
        """进行一次模拟
        """
        self.resolve_state_pool()
        for sequence in self.sequences:
            sequence.run()
    def get_result(self):
        print(self._state_pool.get_state("mCherry_value", -1))
        print(self._state_pool)

class Bio_Device:
    _state_pool: StatePool
    _sequence: Sequence
    def __init__(self, state_pool: StatePool = StatePool(), sequence: Sequence = Sequence()) -> None:
        """初始化Bio_Device
        
        依赖注入: StatePool和Sequence对象
        """        
        self._state_pool = state_pool
        self._sequence = sequence
        pass
    def get_dependency_info(self) -> List[Tuple[str, str]]:
        return [("","")]
    def __str__(self) -> str:
        return self.__class__.__name__

class Promoter(Bio_Device):
    def express(self):
        """
        out: expression
        """
        self._state_pool.add_state("expression", 1.0, self._sequence)
    pass

class Coding_Region(Bio_Device):
    def execute(self):
        pass
    pass

class Constitutive(Promoter):
    """等价json

    {
        "name": "Constitutive",
        "type": "Promoter",
        "data_flow": {
            "EMULATION": {
                "expression": {
                    "default": 1.0
                }
            }
        }
    }
    """
    pass
class Repressed(Promoter):
    pass
class Activated(Promoter):
    pass

class Blue_light_sensor_dimer(Activated):
    @override
    def express(self):
        """
        in:  blue_light_dimer_value = 1.0
        out: expression
        """
        expression_tmp = self._state_pool.get_state("blue_light_dimer_value", 0.0)
        self._state_pool.add_state("expression", expression_tmp, self._sequence)
    pass
class Repressor_A(Repressed):
    @override
    def express(self):
        """
        in:  Repressor_A_value = 0.0
        out: expression
        """
        expression_tmp = self._state_pool.get_state("Repressor_A_value", 0.0)
        self._state_pool.add_state("expression", 1 - expression_tmp, self._sequence)
    pass

class Fluorescence_Protein_gene(Coding_Region):
    pass
class Repressor_gene(Coding_Region):
    pass
class Activator_gene(Coding_Region):
    pass

class mCherry_gene(Fluorescence_Protein_gene):
    @override
    def execute(self):
        """
        in:  expression = 1.0
        out: mCherry_value
        """
        expression_tmp = self._state_pool.get_state("expression", 1.0, self._sequence)
        self._state_pool.add_state("mCherry_value", expression_tmp)
    pass
class Blue_light_sensor_gene(Activator_gene):
    """可以从下面的json构造这个类
    
    {
        "name": "Blue_light_sensor_gene",
        "type": "Coding_Region",
        "data_flow": {
            "ENVIRONMENT": {
                "blue_light": {
                    "default": 0.0
                }
            },
            "EMULATION": {
                "expression": {
                    "default": 0.0
                },
                "blue_light_dimer_value": {
                    "default": null,
                    "depends_on": [
                        "blue_light",
                        "expression"
                    ],
                    "formula": "blue_light * expression"
                }
            }
        }
    }
    """
    @override
    def execute(self):
        """
        env: blue_light = 0.0
        in:  expression = 0.0
        out: blue_light_dimer_value
        """
        blue_light_tmp = self._state_pool.get_state("blue_light", 0.0, StatePool.Scope.ENVIRONMENT)
        expression_tmp = self._state_pool.get_state("expression", 0.0, self._sequence)
        self._state_pool.add_state("blue_light_dimer_value", blue_light_tmp * expression_tmp)
    pass


class Repressor_A_gene(Repressor_gene):
    @override
    def execute(self):
        """
        env: drug_A = 0.0
        in:  expression = 0.0
        out: Repressor_A_value
        """
        drug_A_tmp = self._state_pool.get_state("drug_A", 0.0, StatePool.Scope.ENVIRONMENT)
        expression_tmp = self._state_pool.get_state("expression", 0.0, self._sequence)
        self._state_pool.add_state("Repressor_A_value", drug_A_tmp * expression_tmp)
    pass


def demo():
    state_pool = StatePool()
    emulation = Emulation(state_pool)
    emulation.add([Constitutive(), Blue_light_sensor_gene()])
    emulation.add([Blue_light_sensor_dimer(), Repressor_A_gene()])
    emulation.add([Repressor_A(), mCherry_gene()])
    
    emulation.set_args({
        "blue_light": 1,
        "drug_A": 0.8
    })
    emulation.run()
    emulation.get_result()
    
    emulation.set_args({
        "blue_light": 1,
        "drug_A": 0.2
    })
    emulation.run()
    emulation.get_result()
    
    emulation.set_args({
        "blue_light": 0,
        "drug_A": 0.8
    })
    emulation.run()
    emulation.get_result()
    
    emulation.set_args({
        "blue_light": 0,
        "drug_A": 0.2
    })
    emulation.run()
    emulation.get_result()
    
demo()

