@echo off
cls
echo **********************************************
echo.
echo     һ   ��   ��   ��   ��   ��      
echo.
echo       ��װ�밴��������˳�ֱ�ӹرմ���
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
set /p o=Ҫ����GitHub����? (YES NO):
if /i "%o%"=="yes" goto yes
if /i "%o%"=="no" goto no
goto step3
:yes
call hexo d
echo  deploy to GitHub finished...
pause
:no
echo ��ѡ���˲�����
pause


