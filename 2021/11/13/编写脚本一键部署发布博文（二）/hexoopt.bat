@echo off
cls
echo **********************************************
echo.
echo       hexo  ��  �� - Ԥ  �� - ��   ��       
echo.
echo       ��װ�밴��������˳�ֱ�ӹرմ���
echo.
echo **********************************************
echo.
pause

::�˴����ñ�����·�����Զ������
set idePath="D:\installsoftware\Typora\Typora"
::�˴����ñ��������ƣ�������һ������
set ideName="Typora.exe"

::���͸�Ŀ¼
set blogRootPath="D:\blog"
::��������Ŀ¼
set blogSrcPath="%blogRootPath%\source\_posts"

::�л������͸�Ŀ¼
cd /d %blogRootPath%

:step1
echo.
echo C:�½����Ĳ��༭
echo R:����clean������
echo S:����Ԥ��
echo D:����GitHub
echo E:����ִ��
echo A:����GitHub��������Ԥ��
echo.
set /p o=��ѡ�����²���?(C R S D E A):
if /i "%o%"=="c" goto c
if /i "%o%"=="r" goto r
if /i "%o%"=="s" goto s
if /i "%o%"=="d" goto d
if /i "%o%"=="e" goto e
if /i "%o%"=="a" goto a

goto step1
:d
call hexo d	
echo  ����GitHub�����...
pause
exit
:e
echo �ű�ִ�н�����
pause
exit
:s
call hexo s
echo  �����������...Ԥ����ַ��http://localhost:4000/
pause
exit
:A
call hexo d
echo ����GitHub�����...
call hexo s
echo �����������...Ԥ����ַ��http://localhost:4000/
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
echo clean������...

::generate
:step3
call hexo g
echo generate �������...
goto step1

::�½����Ĳ��༭
:step4
set /p name=input name:
echo name:%name%
echo please wait
call hexo new post %name%
call start /d "%idePath%" %ideName% "%blogSrcPath%\%name%.md"
pause
















