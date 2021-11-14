@echo off
cls
echo **********************************************
echo.
echo     一   键   配   置   开   发   环   境
echo.
echo       安装请按任意键，退出直接关闭窗口
echo.
echo **********************************************
echo.
pause

:step1
cd /d %~dp0
set currentPATH=%PATH%
set currentDir=%cd%
::只需要修改这两个参数即可
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
echo PATH环境变量中未添加: %JAVA_HOME%\bin 
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%currentPATH%;%%JAVA_HOME%%\bin"
set currentPATH=%currentPATH%;%%JAVA_HOME%%\bin
echo.

:step5
echo JAVA_HOME PATH中已添加
wmic ENVIRONMENT where "name='Path'" get VariableValue|findstr /i /c:"%%MAVEN_HOME%%\bin">nul&&(goto step6)  
echo PATH环境变量中未添加: %MAVEN_HOME%\bin 
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%currentPATH%;%%MAVEN_HOME%%\bin"
echo.

:step6
echo MAVEN_HOME PATH中已添加

:step8
echo 电脑将在30秒内重启，请做好保存工作，按任意键继续...
echo.
pause

shutdown -r -t 30
:test

@echo.
:end
pause