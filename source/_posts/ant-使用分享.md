---
title: ant 使用分享
tags:
  - 教程
categories:
  - 脚本
abbrlink: 54086
date: 2021-11-11 09:34:39
---



# 一、概述、功能

1. Ant是Java的生成工具，是Apache的核心项目，并且是Ant是跨平台的
2. Ant的主要目的就是把你想做的事情自动化，不用你手动一步一步做，因为里面内置了javac、java、创建目录、复制文件等功能，所以可以直接点击Ant文件，即可编译生成你的项目
3. 可以实现件夹、文件新增、复制、删除，压缩等一系列操作；可以编译java文件，打jar包，实现项目的编译部署工作；通过ftp，可以与服务器建立连接，传文件，执行远程服务器脚本操作

<!--more-->

# 二、安装使用

## 1. Windows环境

1：下载ant包：http://ant.apache.org/bindownload.cgi

2：提前配置java环境变量，配置好JAVA_HOME为jdk主目录；

3：新建环境变量ANT_HOME：值为ANT的主目录；

4：在path中配置%ANT_HOME%/bin；

5：配置完成之后，打开命令行，输入ant，当出现“Buildfile: build.xml does not exist! Build failed”时说明配置完成；

## 2. Linux环境

1：下载ant包：http://ant.apache.org/bindownload.cgi  例如apache-ant-1.10.4-bin.tar.gz

2：复制到Linux /usr目录下 解压、改变权限

```
tar -zxvf  apac-ant-1.10.4-bin.tar.gz
chmod 777  apache-ant-1.10.4
```

3：修改系统环境变量

```
vi /etc/profile
```

4：在文件最后两行加上

```
#set Ant enviroment
export ANT_HOME=/usr/apache-ant-1.9.2
export PATH=$PATH:$ANT_HOME/bin
```

5：使环境变量生效

```
source /etc/profile
```

6：测试ant是否生效：

​     输入ant -version 即可，出现版本号，证明安装成功

# 三、入门使用

### 1. 执行

ant的默认生成文件为build.xml

Win+R 运行cmd 命令行输入ant后，ant会在当前目录搜索是否有build.xml,如果有则执行；也可以自定义xml文件，执行 ant -f test.xml 执行当前目录下 test.xml文件

### 2.执行文件架构

Ant可执行文件格式是xml,整体结构为

```
<project default="targetname">  
    <target name="name">  
    </target>  
</project>
```

project 是执行文件的根元素，表示一个项目

target是project的子元素，表示一个任务；一个project中可以定义多个target元素，表示多个任务；

default 属性 表示这个项目默认执行的任务是那个，对应target 的name属性

直接输入 ant targetname; 则会执行具体的target任务，从而忽略default设置的target，target 的name属性不能重复，是target任务的唯一属性

示例：

```
 <!-- 删除D:\project\targeet下的classes目录，完成后输出All Done! -->
<project default="deploy">
    <!-- 定义路径 -->
    <property name="path" location="D:\project"/>
    <property name="dir.path" location="${path}/target/classes" />
	<target name="clean" >
		<delete dir="${dir.path}"/>
	</target>
	<target name="deploy" depends="clean">
		<echo message="All Done !" />
	</target>
</project>
```

# 四、详细属性介绍



## 一、Xml元素详解



#### 1. project元素

Ant生成文件的根元素，一般形式如：

```
<project default="    "[ basedir="." ] [name="projectname"]>
```

default的值是默认执行的target名；
basedir是指定基准目录，一般都是basedir=”.”；
name是指工程名字。

#### 2. target元素

是project元素的子元素，在project元素中能够有多个target；一般形式如下：

```
<target name=" "  [ depends="A"]  [ if ="prop1"] [ unless="prop2"]>
</target>
```

name表示target的名称；
depends中填写其他target名称(可以有多个名称，用逗号分割)，表示只有targetA完成之后才能够做此target，如果执行此target，则会先执行A；
if的值表示一个属性名，只有设置了该属性名，才能执行此target；
unless的值表示一个属性名，只有没有设置该属性名，才能执行此target。

#### 3. property元素

project的子元素，用于定义属性，一般形如：
`<property name="pname" value="pvalue"/>`
如果要使用此property，则需要${pname}，类似于表达式语言；
\<property file="a.properties"/>通过此属性文件导入属性；
如果单纯想使用$，则通过$$表示。

##  二、Task详解

在Ant中task是target的子元素，即一个target中可以有多个task；Task可以分以下三类

（1）核心Task

（2）可选Task

（3）自定义task

##### 1:echo

用于单纯输出，例如

```
<echo>hello word</echo>
```

##### **2**: zip

压缩文件

```
<zip destfile="目标文件.zip">
   <zipfileset dir="要压缩的文件内容" prefix="citsb2b">   </zipfileset> --将要压缩的文件存放到citsb2b下
</zip>
```

##### 3: scp

示例代码

```
<scp todir="${weblogicUser}:${weblogicPwd}@${weblogicSvr}:${weblogicPath}" trust="true">
 <fileset dir="${outputDir}">
 <!-- 上传全量包-->
 <include name="**/*${DSTAMP}_${TSTAMP}*" />
 <exclude name="**/*${DSTAMP}_${TSTAMP}_Patch*" />
 </fileset>
</scp>
```

##### 4: sshexec

```
<sshexec host="${weblogicSvr}" username="${weblogicUser}" password="${weblogicPwd}" command="cd ${weblogicPath};cd ..; sh restart.sh ${citsonline_outputName} ${citsb2b_outputName}" trust="true"/>
```

##### 5: javac

 用来编译java文件，一般形式如下：

```
<javac srcdir="src" destdir="class" [classpath=" "]/>
```

srcdir是编译此文件夹下或子文件夹下的全部java文件;
destdir是编译后的class文件放置路径；
classpath指定第三方类库；

#####  6: java

运行java类，一般形式如下： 

```
<Java classname=" " fork="yes">
    【<arg line="param1   param2   param3"/>】
</java>
```

classname用于指定运行的类名称；
fork=”yes”表示另起一个JVM来执行java命令，而不是中断ANT命令，因此fork必须为yes；

#####  7: jar

将文件目录或者文件达成jar包，一般形式如下：

```
<jar basedir="citsonlineBase/classes"   destfile="citsonlineBase.jar" />
或者
<jar destfile="main.jar" basedir=" ">
    <manifest>
        <attribute name="Main-Class" value="classname"/>  <!--指定主类-->
    </manifest>
</jar>
```

destfiie的值为jar包的名称，一般为`${dest}/main.jar`；
basedir的值是需要打成jar包的目录，一般为${classes}；
manifest表示设置META-INF； 

##### 8: mkdir

创建目录，可以多层创建，比如a\b\c，则可以连续创建，一般形式如下：

```
<mkdir dir="a\b"/>
```

#####  9: delete

删除目录，一般形式如下：

```
<delete dir="a\b"/> 可以删除a目录下的b目录；
<delete file="1.txt"/>可以删除文件；
```

#####  10: tstamp

时间戳，一般形式如下：

```
<tstamp />
```

接下来可以使用${DSTAMP}进行调用当前时间；

##### 11: copy

 复制文件，一般形式如下：

```
<copy file="file1" tofile="file2"/>
```

file是源文件；
tofile是目标文件；

##### 12: move

 移动文件，一般形式如下：

```
<move file="file1" tofile="file2"/>
```

file是源文件；
tofile是目标文件；

#####   13: replace

用于替换字符串，类似于String的replace操作，一般形式如下：

file表示要执行替换的文件；
token表示被替换的字符串；
value表示替换的字符串。

# 五、示例代码

## 一、示例一：deploy_clean_windows.xml

```
<!-- 将服务器目录下文件删除，将重新生成的编译文件以指定格式传到服务器指定目录下 -->
<?xml version="1.0" encoding="UTF-8"?>
<project name="citsonlinePJ" default="deploy">

	<!-- 配置信息 Start-->
	<property name="projectHome"  value="D:\project\citsb2b\workspace" />
	<property name="outputDir"    value="D:\project\citsb2b\tools\wls1036_dev\user_projects\domains\base_domain\applications" />
	<property name="citsonline_appHome"  value="${outputDir}\citsonline" />
	<property name="citsb2b_appHome"  value="${outputDir}\citsb2b" />
	<!-- 配置信息 End -->
	
	<target name="clean">
		<echo message="clean citsonline and citsb2b directory start !" />
		<delete dir="${citsonline_appHome}" includeemptydirs="yes" />
		<delete dir="${citsb2b_appHome}" includeemptydirs="yes" />
		<echo message="clean citsonline and citsb2b directory end !" />
	</target>
	
    <target name="citsb2b_build" depends="clean">
    	<echo message="build citsb2b project start !" />
        <copy todir="${citsb2b_appHome}">
            <fileset dir="${projectHome}/citsb2b/EarContent" />
        </copy>
        
        <copy todir="${citsb2b_appHome}/citsb2bWeb/WEB-INF/lib">
            <fileset dir="${projectHome}/citsb2b/EarContent/APP-INF/lib">
                <include name="spring-*.jar" />
                <include name="standard.jar" />
                <include name="jstl.jar" />
            </fileset>
        </copy>

        <copy todir="${citsb2b_appHome}/citsb2bWeb/WEB-INF/classes">
            <fileset dir="${projectHome}/citsb2bWeb/classes" />
        </copy>

        <copy todir="${citsb2b_appHome}/citsb2bWeb">
            <fileset dir="${projectHome}/citsb2bWeb/WebContent" />
        </copy>
    	<echo message="build citsb2b project end !" />
    </target>
	
	<target name="citsonline_build" depends="citsb2b_build">
		<echo message="build citsonline project start !" />
		<jar basedir="${projectHome}/citsonlineBase/classes"     destfile="${citsonline_appHome}/lib/citsonlineBase.jar" />
		<jar basedir="${projectHome}/citsonlineBuzLogic/classes" destfile="${citsonline_appHome}/lib/citsonlineBuzLogic.jar" />
		<jar basedir="${projectHome}/citsonlineCommon/classes"   destfile="${citsonline_appHome}/lib/citsonlineCommon.jar" />
		<jar basedir="${projectHome}/simplemapping/classes"      destfile="${citsonline_appHome}/lib/simplemapping.jar" />

		<copy todir="${citsonline_appHome}">
			<fileset dir="${projectHome}/citsonline/EarContent" />
		</copy>
		
		<copy todir="${citsonline_appHome}/citsonlineEJB">
			<fileset dir="${projectHome}/citsonlineEJB/classes" />
		</copy>

		<copy todir="${citsonline_appHome}/citsonlineWeb/WEB-INF/classes">
			<fileset dir="${projectHome}/citsonlineWeb/classes" />
		</copy>

		<copy todir="${citsonline_appHome}/citsonlineWeb">
			<fileset dir="${projectHome}/citsonlineWeb/WebRoot" />
		</copy>

		<copy todir="${citsonline_appHome}/citsonlineWeb">
			<fileset dir="${projectHome}/citsonlineWeb/WebRoot" />
		</copy>
		<echo message="build citsonline project end !" />
	</target>
	
	<target name="deploy" depends="citsonline_build">
		<echo message="All Done !" />
	</target>
</project>
```

## 二、示例二: build_zip_upload_full.xml

```
<!--将项目编译处的文件以压缩包方式通过ftp上传到服务器，并执行服务器脚本来重启项目-->
<?xml version="1.0" encoding="UTF-8"?>
<project name="citsonlinePJ" default="deploy">

	<tstamp>
		<format property="now" pattern="yyyy-MM-dd HH:mm" />
	</tstamp>
	
	<property file="./servermsg.properties" />
	<!--服务器连接 只需改前缀 例如改为90服务器只需把20改为90即可。目前支持20、24、90服务器-->
	
	<property name="weblogicSvr"  value="${ip}" />
	<property name="weblogicUser" value="${username}" />
	<property name="weblogicPwd"  value="${pwd}" />
	<property name="weblogicPath" value="${path}" />
	
	<property name="projectHome"  value="D:\project\citsb2b\workspace" />
	<property name="outputDir"    value="${projectHome}/[output]/${weblogicSvr}" />
	<property name="citsonline_outputName"   value="citsonline_release16_${DSTAMP}_${TSTAMP}.zip" />
	<property name="citsonline_outputFile"   value="${projectHome}/[output]/${weblogicSvr}/${citsonline_outputName}" />
	
	<property name="citsb2b_outputName"   value="citsb2b_release_${DSTAMP}_${TSTAMP}.zip" />
	<property name="citsb2b_outputFile"   value="${projectHome}/[output]/${weblogicSvr}/${citsb2b_outputName}" />
	
	<!--编译 citsb2b项目-->
	<target name="citsb2b_bild">
		
		<zip destfile="${citsb2b_outputFile}">
			<zipfileset dir="${projectHome}/citsb2b/EarContent" prefix="citsb2b"></zipfileset>
			<zipfileset dir="${projectHome}/citsb2b/EarContent/APP-INF/lib" prefix="citsb2b/citsb2bWeb/WEB-INF/lib">
				<include name="spring-*.jar" />
				<include name="standard.jar" />
				<include name="jstl.jar" />
			</zipfileset>
			<zipfileset dir="${projectHome}/citsb2bWeb/classes" prefix="citsb2b/citsb2bWeb/WEB-INF/classes"></zipfileset>
			<zipfileset dir="${projectHome}/citsb2bWeb/WebContent" prefix="citsb2b/citsb2bWeb"></zipfileset>
		</zip>
	</target>
	
	<!--编译 citsonline项目-->
	<target name="build" depends="citsb2b_bild">
		<jar basedir="${projectHome}/citsonlineBase/classes"     destfile="${outputDir}/tmp/lib/citsonlineBase.jar" />
		<jar basedir="${projectHome}/citsonlineBuzLogic/classes" destfile="${outputDir}/tmp/lib/citsonlineBuzLogic.jar" />
		<jar basedir="${projectHome}/citsonlineCommon/classes"   destfile="${outputDir}/tmp/lib/citsonlineCommon.jar" />
		<jar basedir="${projectHome}/simplemapping/classes"      destfile="${outputDir}/tmp/lib/simplemapping.jar" />
		
		<zip destfile="${citsonline_outputFile}">
			<zipfileset dir="${projectHome}/citsonline/EarContent" prefix="citsonline"></zipfileset>
			<zipfileset dir="${projectHome}/citsonlineEJB/classes" prefix="citsonline/citsonlineEJB" ></zipfileset>
			<zipfileset dir="${projectHome}/citsonlineWeb/classes" prefix="citsonline/citsonlineWeb/WEB-INF/classes"></zipfileset>
			<zipfileset dir="${projectHome}/citsonlineWeb/WebRoot" prefix="citsonline/citsonlineWeb"></zipfileset>
			<zipfileset dir="${outputDir}/tmp/lib" prefix="citsonline/lib"></zipfileset>
		</zip>
	</target>

	<!--打增量包 -->
	<target name="patch" depends="build">
		<!--citsb2b -->
		<java fork="true" classname="com.cits.online.common.BuildPatch">
			<classpath path="${projectHome}/citsonlineBase/classes"></classpath>
			<classpath path="${projectHome}/citsonline/build/lib/ant.jar"></classpath>
			
			<arg value="${outputDir}" />
			<arg value="${citsb2b_outputName}" />
		</java>
		
		<!--citsonline -->
		<java fork="true" classname="com.cits.online.common.BuildPatch">
			<classpath path="${projectHome}/citsonlineBase/classes"></classpath>
			<classpath path="${projectHome}/citsonline/build/lib/ant.jar"></classpath>

			<arg value="${outputDir}" />
			<arg value="${citsonline_outputName}" />
		</java>
		
	</target>
	
	<!--同步到服务器 -->
	<target name="ftp" depends="patch">
		<echo message="FTP Transferring weblogicSvr, Upload to Weblogic start..." />
		<scp todir="${weblogicUser}:${weblogicPwd}@${weblogicSvr}:${weblogicPath}" trust="true">
			<fileset dir="${outputDir}">
				<!-- 上传全量包-->
				<include name="**/*${DSTAMP}_${TSTAMP}*" />
				<exclude name="**/*${DSTAMP}_${TSTAMP}_Patch*" />
			</fileset>
		</scp>
		<echo message="FTP Transfer weblogicSvr Done!" />
	</target>
	
	
	<target name="clean" depends="ftp">
		<delete dir="${outputDir}" verbose="true" includeemptydirs="true" >
			<exclude name="**/*[Base]*" />
			<exclude name="**/*${DSTAMP}_${TSTAMP}*" />
		</delete>
	</target>
	
	<target name="run" depends="ftp">
		<echo message="start run restart script... !" />
		<echo message=" restart.sh ${citsonline_outputName} ${citsb2b_outputName}" />
		<sshexec host="${weblogicSvr}" username="${weblogicUser}" password="${weblogicPwd}" command="cd ${weblogicPath};cd ..; sh restart.sh ${citsonline_outputName} ${citsb2b_outputName}" trust="true"/>
	</target>
	
	<target name="deploy" depends="run">
		<echo message="All Done !" />
	</target>

</project>
```





















