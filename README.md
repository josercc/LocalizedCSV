
# CSV本地化读取软件

> 如果你觉得不错请Star
>
> 如果你觉得功能有问题可以提问题
>
> 如果你有新想法可以Fork推送
> 

## 新增了例子和详细使用说明文档
[详细使用说明文档](国际化工具使用详细说明.md)

## 未来计划

* ~~自动提取工程需要国际化文本 难度较大 有实现方法可以提给我 现在只能想到查找设置UILabel UIButton UIViewController标题 等代码处~~(技术实现有些难度)

## 现在支持的功能

* 支持从已经翻译的`CSV`文件读取已经翻译的内容一键保存到指定的`.Strings`文件里面
* 支持查看某种语言未翻译和已翻译部分
* 支持导出还未翻译的字段 支持查找相似已经翻译的 Key
* 支持读取源码NSLocalizeString()(或者其他自定义)读取键值保存到原语言包
* 支持一键保存到本地
* 支持配置多语言简码表
* 支持查找出翻译的多语言和开发母语占位符不匹配的问题

## 重要说明

* **因为读取CSV系统会自动用`,`分割，如果原生的字段存在 `，`请在导出为CSV文件用 `{R}`占位符替**

* **下载的 CSV 文件或者 Excel 文件请用Number 打开**

## 下载

* 直接前往最新的 Release下载Mac客户端: https://github.com/josercc/LocalizedCSV/releases
* 下载源码运行即可
* 最低支持 OSX10.10

## 使用说明

* 主界面

![image-20180727105546949](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-025548.png)

* 读取本地已经存在的`CSV`文件

![image-20180727105611394](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-025612.png)

* 读取工程基础语言包

  ![image-20180727105637147](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-025638.png)

* 已经翻译的语言列表

  ![image-20180727105818718](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-025821.png)

  > 一般第一个为基础语言包不需要处理

* 查看已经翻译语言包

  ![image-20180727105901231](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-025902.png)

* 翻译和未翻译 (红色为未翻译，绿色为已经翻译)

  ![765B7C73-DE4E-4E30-BC44-2EE4F5B0B648](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-63412.jpg)


## 操作演示

- 演示地址
![](https://github.com/josercc/LocalizedCSV/blob/master/2018-07-27%2011_38_14.gif?raw=true)

- 一些配置说明

  - 语言简码

    ![image-20180727111326519](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-063414.jpg)

    设置的公式 **语言标题:简码**

    - 语言标题为多语言表格的对应多语言的标题
    - 简码为工程对应多语言的文件夹简码

  - 查询字符串宏 默认为 NSLocalizedString 如果你和我们一样自定义了宏就可以设置一下

    ![image-20180727111552940](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-063415.jpg)

  - 读取本地多语言

    因为工程的多语言是作为数据的依赖，所以之后的任何操作都需要读取本地多语言之后才可以。

## 其他支持

* 提取代码里面的国际化可以使用`FauxPas`软件

  ![FE532CA2-41AA-4F81-9E07-F0C4F11B2CE1](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-063413.jpg)

* 查看和编辑国际化语言包可以使用`StringManager`

  https://github.com/Loongwoo/StringManager

  ![2ABE0FF5-1923-45DE-9FD8-41E41FAFFED6](http://ipicimage-1251019290.coscd.myqcloud.com/2018-07-27-063411.jpg)

  ​
