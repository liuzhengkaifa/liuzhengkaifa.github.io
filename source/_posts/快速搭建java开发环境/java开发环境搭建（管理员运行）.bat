@echo off
cls
echo **********************************************
echo.
echo     һ   ��   ��   ��   ��   ��   ��   ��
echo.
echo       ��װ�밴��������˳�ֱ�ӹرմ���
echo.
echo **********************************************
echo.
pause

:step1
cd /d %~dp0
set currentPATH=%PATH%
set currentDir=%cd%
::ֻ��Ҫ�޸���������������
set JdkFilePath=jdk1.8.0_162
set MavenFilePath=apache-maven-3.8.1

:step2
set developDir=%currentDir%
echo %developDir%
goto step4

:step4
wmic ENVIRONMENT where "name='JAVA_HOME'" delete
wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%developDir%\%JdkFilePath%"
wmic ENVIRONMENT where "name='MAVEN_HOME'" delete
wmic ENVIRONMENT create name="MAVEN_HOME",username="<system>",VariableValue="%developDir%\%MavenFilePath%"
wmic ENVIRONMENT where "name='CLASSPATH'" delete
wmic ENVIRONMENT create name="CLASSPATH",username="<system>",VariableValue=".;%%JAVA_HOME%%\lib\toos.jar;%%JAVA_HOME%%\lib\dt.jar"
echo JAVA_HOME:%developDir%\%JdkFilePath%
echo MAVEN_HOME:%developDir%\%MavenFilePath%
echo.
goto step7

:step7
wmic ENVIRONMENT where "name='Path'" get VariableValue|findstr /i /c:"%%JAVA_HOME%%\bin">nul&&(goto step5)  
echo PATH����������δ���: %JAVA_HOME%\bin 
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%currentPATH%;%%JAVA_HOME%%\bin"
set currentPATH=%currentPATH%;%%JAVA_HOME%%\bin
echo.

:step5
echo JAVA_HOME PATH�������
wmic ENVIRONMENT where "name='Path'" get VariableValue|findstr /i /c:"%%MAVEN_HOME%%\bin">nul&&(goto step6)  
echo PATH����������δ���: %MAVEN_HOME%\bin 
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%currentPATH%;%%MAVEN_HOME%%\bin"
echo.

:step6
echo MAVEN_HOME PATH�������

:step8
echo ���Խ���30���������������ñ��湤���������������...
echo.
pause

shutdown -r -t 30
:test

@echo.
:end
pause