@echo off
chcp 65001

@REM 1. 创建虚拟环境; 2. 精简PySide6
call ensure_runtime.bat

echo 创建目标目录
set DEPLOY_DIR=.\build\Deploy
if not exist "%DEPLOY_DIR%" (
    mkdir "%DEPLOY_DIR%"
)

echo 删除__pycache__文件夹:
for /d /r %%i in (__pycache__) do (
    if exist "%%i" (
        echo Deleting %%i
        rmdir /s /q "%%i"
    )
)

REM 复制 Assets 文件夹，排除 qmls.json 文件
robocopy "Assets" "%DEPLOY_DIR%\Assets" /E /XD /XF "qmls.json"
REM 手动写入qmls.json
(
    echo [
    echo    "main.qml"
    echo ]
) > "%DEPLOY_DIR%\Assets\qmls.json"

REM 复制指定文件至 Deploy 目录
copy /Y "deploy.bat" "%DEPLOY_DIR%\"
copy /Y "start.py" "%DEPLOY_DIR%\"
copy /Y "main.py" "%DEPLOY_DIR%\"
copy /Y "Emulator.py" "%DEPLOY_DIR%\"
copy /Y "FileIO.py" "%DEPLOY_DIR%\"
copy /Y "pd.py" "%DEPLOY_DIR%\"
copy /Y "Utils.js" "%DEPLOY_DIR%\"
copy /Y "CommonHolderWindow.qml" "%DEPLOY_DIR%\"
copy /Y "main.qml" "%DEPLOY_DIR%\"
copy /Y "GeneticElementComponent.qml" "%DEPLOY_DIR%\"
copy /Y "PlotCanvas.qml" "%DEPLOY_DIR%\"
copy /Y "GridLayer.qml" "%DEPLOY_DIR%\"
copy /Y "JSConsole.qml" "%DEPLOY_DIR%\"
copy /Y "JSConsoleButton.qml" "%DEPLOY_DIR%\"
copy /Y "SwipeBanner.qml" "%DEPLOY_DIR%\"
copy /Y "WindowFrameRate.qml" "%DEPLOY_DIR%\"

echo 复制完成.

echo 开始pyinstaller打包.

cd build\Deploy
@REM 注意 \build\Deploy\runtime\Lib\site-packages\ 下的PySide6是精简过的(不然会将PySide6目录全部dll包括100多MB的WebEngine也打包进去)
@REM 这样可以得到35MB的包(相较140MB), 并且启动速度只有1~2s

call .\runtime\Scripts\activate.bat
@REM 使用call激活, 防止父进程退出
@REM pyinstaller -F -c start.py --distpath=.\build --name "Gene-circuit.exe" --upx-dir=upx.exe --add-data=".\\Assets;.\\Assets" --add-data=".\*.qml;." --add-data=".\*.py;."  --add-data=".\*.js;."
pyinstaller -F -w start.py^
    --distpath=.\dist^
    --name="Gene-circuit.exe"^
    --add-data=".\\Assets;.\\Assets"^
    --add-data=".\*.qml;."^
    --add-data=".\*.py;."^
    --add-data=".\*.js;."^
    --upx-dir=runtime\Scripts\upx.exe
    @REM --noupx^
call .\runtime\Scripts\deactivate.bat

copy /Y .\dist\Gene-circuit.exe ..
rmdir /s /q .\dist
rmdir /s /q .\build
echo 输出exe: \build\Gene-circuit.exe
cd ..\..
    
@REM pip freeze > requirements.txt
@REM pip install -r requirements.txt
