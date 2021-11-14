@echo off
cls
echo **********************************************
echo.
echo       hexo  新  增 - 预  览 - 发   布       
echo.
echo       安装请按任意键，退出直接关闭窗口
echo.
echo **********************************************
echo.
pause

::此处配置编译器路径，自定义调整
set idePath="D:\installsoftware\Typora\Typora"
::此处配置编译器名称，搭配上一条调整
set ideName="Typora.exe"

::博客根目录
set blogRootPath="D:\blog"
::博文所在目录
set blogSrcPath="%blogRootPath%\source\_posts"

::切换到博客根目录
cd /d %blogRootPath%

:step1
echo.
echo C:新建博文并编辑
echo R:重新clean并构建
echo S:本地预览
echo D:部署到GitHub
echo E:结束执行
echo A:部署到GitHub后开启本地预览
echo.
set /p o=请选择以下操作?(C R S D E A):
if /i "%o%"=="c" goto c
if /i "%o%"=="r" goto r
if /i "%o%"=="s" goto s
if /i "%o%"=="d" goto d
if /i "%o%"=="e" goto e
if /i "%o%"=="a" goto a

goto step1
:d
call hexo d	
echo  部署到GitHub上完成...
pause
exit
:e
echo 脚本执行结束！
pause
exit
:s
call hexo s
echo  本地启动完成...预览地址：http://localhost:4000/
pause
exit
:A
call hexo d
echo 部署到GitHub上完成...
call hexo s
echo 本地启动完成...预览地址：http://localhost:4000/
pause
exit
:C
goto step4
pause
exit
:R
goto step2

::clean
:step2
echo Please wait
call hexo clean
echo clean清除完成...

::generate
:step3
call hexo g
echo generate 构建完成...
goto step1

::新建博文并编辑
:step4
set /p name=input name:
echo name:%name%
echo please wait
call hexo new post %name%
call start /d "%idePath%" %ideName% "%blogSrcPath%\%name%.md"
pause
















