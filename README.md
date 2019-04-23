### EHenTaiViewer
![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)  [![release](https://img.shields.io/badge/release-v1.3.1-brightgreen.svg)](https://github.com/kayanouriko/E-HentaiViewer/releases)  ![support](https://img.shields.io/badge/support-11.0-blue.svg)

一个EHentai的iOS端阅读器 / a client for e-hentai/exhentai

### 注意
网站设置页面(uconfig.php)更新了...

所以app上的高级设置暂时全部失效了

请前往网站配置页配置你的图片分辨率相关，客户端的看图用的是你账号的看图额度【虽然一般用不完
同理，请暂时在网站配置设置你的语言排除

个人能力问题，配置除去上面说到的可以自定义以外，其他的请暂时使用默认配置，避免造成解析错误，特别是列表显示样式

#### 非越狱手机安装方法
* Xcode编译
* 参考: [#20 (comment)](https://github.com/kayanouriko/E-HentaiViewer/issues/20#issuecomment-356925389)

#### 登录失败
由于我没有深入研究cookie部分,采用的是iOS自带的cookie管理机制,请尝试不同的网络场景，删除cookie或者科学姿势进行登录操作

#### 说明
主要是自用应用,而且还是新手,更新周期可能会比较长,有刚性需求的同学可以用DaidoujiChen的成熟应用

测试: Xcode10.2.1 / iPhone Xs Max / iOS 12.3 Beta

要求: 推荐 iPhone 7 或更新机型使用 / 需要 iOS 11.0 或更高版本

### 更新内容
20190423 v1.3.1
* 应用最低版本提升至iOS11.0
* 列表样式调整
* 全新的搜索功能，添加高级筛选
* 跟进网站改进做出的解析调整
* 修正BUG：[Issue #51](https://github.com/kayanouriko/E-HentaiViewer/issues/51) ，[Issue #50](https://github.com/kayanouriko/E-HentaiViewer/issues/50)
* 改进优化：[Issue #37](https://github.com/kayanouriko/E-HentaiViewer/issues/37#issuecomment-436643594)

已知问题：
- 项目的代码已经是一坨shit了，各种耦合
- 未登录状态画廊缩略图解析不成功
- 列表可能存在卡顿现象
- 搜索标签库没做分组，数据不全
- 改动较大，可能存在其他未知bug
- 部分网站操作功能暂时失效

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
- [x] 搜索功能智能标签提示

### TODO
1. 界面
- [ ] 高级设置适配网站新版server设置页

2. 功能
- [ ] 应用数据缓存支持
- [ ] 跳转画廊逻辑优化
- [ ] 评论功能强化,同步网站功能
