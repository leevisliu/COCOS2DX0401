cd %~dp0
taskkill /IM gloryproject.exe
start %~dp0\build_win\bin\gloryproject\Debug\gloryproject.exe -workdir %~dp0 -writable-path %~dp0\client\