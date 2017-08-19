---
typora-copy-images-to: ./images
---



# CSV本地化读取软件

> 如果你觉得不错请Star
>
> 如果你觉得功能有问题可以提问题
>
> 如果你有新想法可以Fork推送

## 未来计划

* 自动提取工程需要国际化文本 难度较大 有实现方法可以提给我 现在只能想到查找设置UILabel UIButton UIViewController标题 等代码处

## 现在支持的功能

* 支持从已经翻译的`CSV`文件读取已经翻译的内容一键保存到指定的`.Strings`文件里面
* 支持查看某种语言未翻译和已翻译部分
* 支持导出还未翻译的字段
* 支持读取源码NSLocalizeString()读取键值保存到原语言包

## 重要说明

* **因为读取CSV系统会自动用`,`分割，如果原生的字段存在 `，`请在导出为CSV文件用 `{R}`占位符替换**
* **导出未翻译部分请全部替换`{R}`为`,`**

## 下载

* 直接下载Mac客户端: [下载](https://github.com/josercc/LocalizedCSV/blob/master/LocalizedCSV/Release/v2.zip?raw=true)
* 下载源码运行即可

## 使用说明

* 主界面

![AD494F20-E554-409C-ABE5-D6CF1D327647](images/AD494F20-E554-409C-ABE5-D6CF1D327647.png)

* 读取本地已经存在的`CSV`文件(名字叫做SVG是打错了，懒得改了)

![BD96D5A5-77D7-40AE-9E7A-B9C131F492E5](images/BD96D5A5-77D7-40AE-9E7A-B9C131F492E5.png)

* 读取工程基础语言包

  ![AD1B416F-9B78-43DF-A255-0D9031C85016](images/AD1B416F-9B78-43DF-A255-0D9031C85016.png)

* 已经翻译的语言列表

  ![0728171C-4B91-46AC-8804-7E93A24CA1EB](images/0728171C-4B91-46AC-8804-7E93A24CA1EB.png)

  > 一般第一个为基础语言包不需要处理

* 查看已经翻译语言包

  ![78BCDF4F-9863-4EBF-84CE-BA5FC5C87BAA](images/78BCDF4F-9863-4EBF-84CE-BA5FC5C87BAA.png)

* 翻译和未翻译 (红色为未翻译，绿色为已经翻译)

  ![765B7C73-DE4E-4E30-BC44-2EE4F5B0B648](images/765B7C73-DE4E-4E30-BC44-2EE4F5B0B648.png)

* 保存到对应的语言路径

  ![9B8CFF95-751F-4DEB-9777-37E02CFC4311](images/9B8CFF95-751F-4DEB-9777-37E02CFC4311.png)

  > 如果存在还未翻译部分不能保存

* 导出未翻译部分CSV

  ![4A5862EA-6ED6-498D-80A5-C41083D19238](images/4A5862EA-6ED6-498D-80A5-C41083D19238.png)

  > 导出的CSV需要全局把`{R}`替换成`,`

* 查询工程使用NSLocalizeString()的字符串 

  ![ACC3551F-1767-48FF-AA7E-692C0209F6DD](images/ACC3551F-1767-48FF-AA7E-692C0209F6DD.png)

  ![74B0B83A-E715-4EEC-A5C1-F0D954BD9EDD](images/74B0B83A-E715-4EEC-A5C1-F0D954BD9EDD.png)

  点击保存到指定目录即可。

## 其他支持

* 提取代码里面的国际化可以使用`FauxPas`软件

  ![FE532CA2-41AA-4F81-9E07-F0C4F11B2CE1](images/FE532CA2-41AA-4F81-9E07-F0C4F11B2CE1.png)

* 查看和编辑国际化语言包可以使用`StringManager`

  https://github.com/Loongwoo/StringManager

  ![2ABE0FF5-1923-45DE-9FD8-41E41FAFFED6](images/2ABE0FF5-1923-45DE-9FD8-41E41FAFFED6.png)

  ​