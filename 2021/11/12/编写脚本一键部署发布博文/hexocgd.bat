@echo off
cls
echo **********************************************
echo.
echo     一   键   布   署   发   布      
echo.
echo       安装请按任意键，退出直接关闭窗口
echo.
echo **********************************************
echo.
pause


:step1
cd /d d:\blog
echo Please wait
call hexo clean
echo  clean finished...

:step2
call hexo g
echo  generate finished...

:step3
set /p o=要部署到GitHub上吗? (YES NO):
if /i "%o%"=="yes" goto yes
if /i "%o%"=="no" goto no
goto step3
:yes
call hexo d
echo  deploy to GitHub finished...
pause
:no
echo 你选择了不部署！
pause


