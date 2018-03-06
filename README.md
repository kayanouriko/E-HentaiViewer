### EHenTaiViewer
![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)  [![release](https://img.shields.io/badge/release-v1.1.1-brightgreen.svg)](https://github.com/kayanouriko/E-HentaiViewer/releases)  ![support](https://img.shields.io/badge/support-8.0-blue.svg)

一个EHentai的iOS端阅读器 / a client for e-hentai/exhentai

### 注意
网站设置页面(uconfig.php)更新了...

所以app上的高级设置暂时全部失效了,不用再邮件我啦,我已经知道这事了...

#### 非越狱手机安装方法
* Xcode编译
* 参考: [#20 (comment)](https://github.com/kayanouriko/E-HentaiViewer/issues/20#issuecomment-356925389)

#### 登录失败
由于我没有深入研究cookie部分,采用的是iOS自带的cookie管理机制,请尝试不同的网络场景或者科学姿势进行登录操作

#### 说明
主要是自用应用,而且还是新手,更新周期可能会比较长,有刚性需求的同学可以用DaidoujiChen的成熟应用

测试: Xcode9.2 / iPhone 7 plus / iOS 11.2.6

要求: 推荐 iPhone 5s 或更新机型使用 / 需要 iOS 8.0 或更高版本

### 更新内容
2018.01.05 1.1.1
* 补充完整收藏流程
* 添加toplist界面,分享功能
* 看图界面部分bug修复,中文标签重新加入
* 未登录状态缩略图无法获取依旧没有修复

### Screenshot
8M流量

[https://ws2.sinaimg.cn/large/006tKfTcgy1fgqcuhbs4kg309n0h9qvb.gif](https://ws2.sinaimg.cn/large/006tKfTcgy1fgqcuhbs4kg309n0h9qvb.gif)

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fgqcuhbs4kg309n0h9qvb.gif)

### 感谢
这个客户端参考和借鉴了很多开源项目的思路和代码,如果这些作者觉得不合适,请私信我,我立马删除该项目QAQ

新手开发,如果有代码方面的优化请多多指教OvO

[@DaidoujiChen](https://github.com/DaidoujiChen)

[https://github.com/DaidoujiChen/Dai-Hentai](https://github.com/DaidoujiChen/Dai-Hentai)

还有该项目的老前辈,上面链接有我就不贴了

[@seven332](https://github.com/seven332)

[https://github.com/seven332/EhViewer](https://github.com/seven332/EhViewer)

另外还有感谢诸多开源框架,pod文件我也上传了,这里就不贴出来了.

### 功能

- [x] 热门,列表画廊浏览
- [x] 画廊详细信息查看
- [x] 图片阅读
- [x] 里站切换
- [x] 搜索/高级搜索
- [x] 支持账号登录

### TODO
1. 界面
- [ ] TopList界面
- [ ] 高级设置适配网站新版server设置页
- [ ] 看图界面重构

2. 功能
- [ ] 列表支持跳页
- [ ] 搜索功能智能标签提示
- [ ] 标签快速搜索
- [ ] 应用数据缓存支持
- [ ] 跳转画廊逻辑优化
- [ ] 图片沙盒下载,iTunes支持导出
- [ ] 评论功能强化,同步网站功能
- [ ] 看图相关功能强化(图片缓存,看图方向,横竖屏,续看记录,翻页方式)
