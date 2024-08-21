import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))

# 嵌入式python的使用
# 1. python312._pth中加入Lib/site-packages
# 2. 自己的模块导入要手动加入搜索路径: 
sys.path.insert(0, current_dir)

msg = 'Hello from %s'%(os.path.abspath(__file__))
msg += "\n"

for path in sys.path:
    msg += f"> {path}\n"

print(msg)

from main import main
main()