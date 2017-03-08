# ExReadViewer
一个EHentai的iOS端阅读器

[https://github.com/kayanouriko/EHentaiViewer/releases](https://github.com/kayanouriko/EHentaiViewer/releases)

#更新内容
2017.03.8 v1.3.9

1 废弃本地存储,改用官方账号的收藏夹存储,建议导出本地存储文件后删除应用重装(只测试自己的收藏夹,希望有常用官方收藏夹并收藏夹收藏数量多的同学反馈情况)

2 添加tag收藏和快速搜索,这个为本地存储

3 fix bug (一些特殊内容的提醒不再影响解析啦,快速退出画廊不再造成卡顿了)

4 UI逻辑调整

基本上常用功能已完善,下载功能由于自己测试,账号被封啦,工程里有半成品,打开备注代码就好,下载的画廊只能通过itunes导出,我推荐使用脚本或者Python来完成下载需求,第三方的客户端下载还是少用吧,支持官方会更好.

有更加刚性需求的同学请关注DaidoujiChen的项目,感恩

这个项目自用基本更新速度会慢很多

2017.03.05 v1.3

调整UI更加符合iOS逻辑

2017.03.04 v1.21

1 更新爬虫逻辑

2 浏览图添加进度滑块,现在可以随意跳转页数啦

2017.02.08 v1.2

1 添加登录账号(来自DaidoujiChen,感恩)和里站功能

2 调整缩略图解析逻辑

3 支持iTunes导出收藏配置文件

2017.01.11 v1.1 

1 列表添加语种显示(来源Seven,感谢)和评分模块显示

2 侧边栏完善,添加设置界面功能-隐私功能(密码和TouchID),关于界面完善

3 详情界面评论列表添加评论人跳转

4 热门,收藏功能添加

5 改为通用应用,ipad兼容,但是布局不完美

# Screenshot
4M流量

[https://ww2.sinaimg.cn/large/006tNbRwgy1fdc9mfkfo0g308l0fwx6r.gif](https://ww2.sinaimg.cn/large/006tNbRwgy1fdc9mfkfo0g308l0fwx6r.gif)

![](https://ww2.sinaimg.cn/large/006tNbRwgy1fdc9mfkfo0g308l0fwx6r.gif)

# 感谢
这个客户端参考和借鉴了很多开源项目的思路和代码,如果这些作者觉得不合适,请私信我,我立马删除该项目QAQ

新手开发,如果有代码方面的优化请多多指教OvO

[@DaidoujiChen](https://github.com/DaidoujiChen)

[https://github.com/DaidoujiChen/Dai-Hentai](https://github.com/DaidoujiChen/Dai-Hentai)

还有该项目的老前辈,上面链接有我就不贴了

[@seven332](https://github.com/seven332)

[https://github.com/seven332/EhViewer](https://github.com/seven332/EhViewer)

主要借鉴这个安卓项目的界面布局

另外还有感谢诸多开源框架,pod文件我也上传了,这里就不贴出来了.

#说明
主要是自用应用,而且还是新手,更新周期可能会比较长,有刚性需求的同学可以用DaidoujiChen的成熟应用

测试:xcode8 ip7p iOS 10

推荐ip5 iOS 8以上

#TODO
* 添加拥有账号的可操作的可能性(收藏功能已完成)
* 下载功能
* iPhone和iPad布局适配
* 现在的看图界面可能不是很好用,不能调页加载也不太能可控,如果是施法过程可能体验不佳,现开源框架暂时还没有比较好支持看漫画专用的,打算后面自己写一个(待优化)
* 详情页的请求逻辑有点傻,所以页面多的可能加载会比较久,请耐心等待(待优化)


