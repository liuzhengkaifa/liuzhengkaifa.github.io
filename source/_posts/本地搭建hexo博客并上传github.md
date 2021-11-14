---
title: 本地搭建hexo博客并上传github
tags:
  - 博客
  - hexo
categories:
  - 博客
abbrlink: 55835
date: 2021-11-09 23:22:43
---

一、下载安装Nodejs

[官网下载地址](https://nodejs.org/en/)

![此图片的alt属性为空；文件名为image-1024x331.png](本地搭建hexo博客并上传github/image-1024x331.png)

<!-- more -->

<p>安装 下一步下一步正常安装即可</p>

<img src="本地搭建hexo博客并上传github/image-1.png" alt="此图片的alt属性为空；文件名为image-1.png" style="zoom:50%;" />

<p> 二、配置环境变量</p>
<ol><li>找到nodejs安装路径，我本地安装路径：D:\installsoftware\nodejs</li><li>将安装路径配置到path： 计算机-属性-高级系统设置-环境变量-系统变量-path </li><li>校验，win+r 输入cmd，在命令窗户输入 node -v查看nodejs版本，正常输出则安装成功</li></ol>

![此图片的alt属性为空；文件名为image-2.png](本地搭建hexo博客并上传github/image-2.png)

<p>三、安装hexo是借助npm安装，由于国内安装镜像源速度很慢，可以借助淘宝cnpm安装</p>

<p>1、命令行输入：npm install -g cnpm --registry=https://registry.npm.taobao.org</p>

<img src="本地搭建hexo博客并上传github/image-4-1024x467.png" alt="此图片的alt属性为空；文件名为image-4-1024x467.png" style="zoom:67%;" />

<p>2、 命令行输入：cnpm install -g hexo-cli 安装hexo</p>

<img src="本地搭建hexo博客并上传github/image-5-1024x467.png" alt="此图片的alt属性为空；文件名为image-5-1024x467.png" style="zoom:67%;" />

<p> 3、 新建blog目录，存放博客</p>

![此图片的alt属性为空；文件名为image-6.png](本地搭建hexo博客并上传github/image-6.png)

<p>4、 命令行输入 hexo init 初始化hexo</p>

![此图片的alt属性为空；文件名为image-7.png](本地搭建hexo博客并上传github/image-7.png)

<p>5、 此时hexo安装已经完成，我们通过输入 ls -l会发现hexo初始化会生成以下文件</p>

<img src="本地搭建hexo博客并上传github/image-8.png" alt="此图片的alt属性为空；文件名为image-8.png" style="zoom:67%;" />

<p>6、安装完成，输入命令：hexo s  来启动hexo , 启动完成，浏览器输入http://localhost:4000/ 即可访问hexo博客</p>

![此图片的alt属性为空；文件名为image-9.png](本地搭建hexo博客并上传github/image-9.png)

<img src="本地搭建hexo博客并上传github/image-10-1024x597.png" alt="此图片的alt属性为空；文件名为image-10-1024x597.png" style="zoom:50%;" />

<p> 四、使用hexo编写博客</p>

<p>1、写一篇新文章</p>

<p>命令行输入： hexo n "我的第一篇博客文章" </p>

![此图片的alt属性为空；文件名为image-11.png](本地搭建hexo博客并上传github/image-11.png)

<p>使用编辑器或者其他工具修改博客文章</p>
<p>然后命令行输入：hexo clean 先清理一下</p>
<p>然后命令行输入：hexo g 重新生成一下博客</p>
<p>最后命令行输入：hexo s 启动一下，启动完成浏览器输入localhost:4000即可访问博客</p>

<img src="本地搭建hexo博客并上传github/image-12-1024x705.png" alt="此图片的alt属性为空；文件名为image-12-1024x705.png" style="zoom:67%;" />

<img src="本地搭建hexo博客并上传github/image-13-1024x660.png" alt="此图片的alt属性为空；文件名为image-13-1024x660.png" style="zoom:67%;" />

<p>至此hexo博客的搭建和编写已经完成</p>

<p> 五、将hexo博客部署到远端（github）,通过github即可访问博客 </p>

<p>1、github 新建一个仓库</p>

![此图片的alt属性为空；文件名为image-14.png](本地搭建hexo博客并上传github/image-14.png)

<p>2、注意仓库命名，然后点击create创建仓库即可</p>

![此图片的alt属性为空；文件名为image-15-1024x479.png](本地搭建hexo博客并上传github/image-15-1024x479.png)

<p> 3、需要在我们间的blog博客文件夹下装一个git部署插件</p>

<p>通过命令行输入：cnpm install --save hexo-deployer-git</p>

![此图片的alt属性为空；文件名为image-16-1024x99.png](本地搭建hexo博客并上传github/image-16-1024x99.png)

<p>4、需要设置blog目录下的_config.yml，注意yml格式使用空格缩进</p>

![此图片的alt属性为空；文件名为image-17-1024x164.png](本地搭建hexo博客并上传github/image-17-1024x164.png)

<p>5、保存后，命令行输入：hexo -d 即可部署远程博客，github登录方式调整可能有问题，解决方案看文章下方</p>

![此图片的alt属性为空；文件名为image-19-1024x419.png](本地搭建hexo博客并上传github/image-19-1024x419.png)

<p>6、部署完成，通过访问 https://liuzhengkaifa.github.io/ 查看博客内容。 </p>

<p>六、问题</p>
<p>  在命令行 hexo d 部署博客时出现错误</p>
<p>remote: Support for password authentication was removed on August 13, 2021. Please use a personal access token instead.</p>
<p>原因时：GitHub不再支持密码验证解决方案：SSH免密与Token登录配置，基于方便我采用了ssh免密方式登录，可参考以下步骤</p>
<p>1、本地生成公钥</p>
<pre class="wp-block-preformatted">ssh-keygen -t rsa -b 4096 -C "uestchan@sina.com"</pre>
<p>接着会提示这个公钥私钥的保存路径-建议直接回车就好（默认目录里)</p>
<p>接着提示输入私钥密码passphrase - 如果不想使用私钥登录的话，私钥密码为空，直接回车</p>

<p> 2、将公钥配置到github中，用编辑器打开 C:\Users\test.ssh 目录下的 id_rsa.pub</p>

<p>将内容粘贴到githun配置处</p>

![此图片的alt属性为空；文件名为image-20-1024x440.png](本地搭建hexo博客并上传github/image-20-1024x440.png)

![此图片的alt属性为空；文件名为image-21-1024x448.png](本地搭建hexo博客并上传github/image-21-1024x448.png)

<p>3、将_config.yml文件的repo地址改为 ssh方式地址，即可完成正常操作</p>

![此图片的alt属性为空；文件名为image-22.png](本地搭建hexo博客并上传github/image-22.png)