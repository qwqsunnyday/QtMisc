@echo off
chcp 65001

set "PROJECT_FOLDER=%cd%"
set "DEPLOY_FOLDER=%cd%\build\Deploy"

REM 进入 build\Deploy\ 文件夹
if not exist "build" (
    mkdir build
)
cd build
if not exist "Deploy" (
    mkdir Deploy
)
cd Deploy
if not exist "runtime" (
    echo 创建虚拟环境
    python -m venv runtime || pause, exit
)
call .\runtime\Scripts\activate.bat
echo "pip install pyinstaller PySide6"
pip install pyinstaller PySide6 -i https://pypi.tuna.tsinghua.edu.cn/simple
call .\runtime\Scripts\deactivate.bat

echo 开始精简PySide6

cd runtime\Lib\site-packages\PySide6

REM 保留的DLLs
@REM pyinstaller打包后解压出来只有 plugins qml translations 目录; 使用到的dll如下:
set "keep_dlls=MSVCP140.dll MSVCP140_1.dll MSVCP140_2.dll pyside6.abi3.dll pyside6qml.abi3.dll Qt6Core.dll Qt6Gui.dll Qt6Network.dll Qt6OpenGL.dll Qt6Qml.dll Qt6QmlCore.dll Qt6QmlModels.dll Qt6QmlWorkerScript.dll Qt6Quick.dll Qt6QuickControls2.dll Qt6QuickControls2Basic.dll Qt6QuickControls2Fusion.dll Qt6QuickControls2Impl.dll Qt6QuickControls2Universal.dll Qt6QuickControls2UniversalStyleImpl.dll Qt6QuickLayouts.dll Qt6QuickTemplates2.dll Qt6ShaderTools.dll Qt6Svg.dll"

echo 保留所需的DLLs
for %%f in (*.dll) do (
    REM 检查是否是保留的文件
    echo %keep_dlls% | findstr /i /c:"%%~nxf" >nul
    if errorlevel 1 (
        echo Deleting %%f
        @REM del /q "%%f"
        move "%%f" "..\bin"
    ) else (
        echo Keeping %%f
    )
)

echo 删除translations
@REM rmdir /s /q translations
move "translations" "..\bin"

cd "%PROJECT_FOLDER%"