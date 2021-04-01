![](https://ws1.sinaimg.cn/large/006tNc79ly1g2rkx8hhgij305k05kdgq.jpg)

# 应用简介

一个 e-hentai/exhentai 的iOS端阅读器 / a client for e-hentai/exhentai

![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)  [![release](https://img.shields.io/badge/release-v1.4.1-brightgreen.svg)](https://github.com/kayanouriko/E-HentaiViewer/releases)  ![support](https://img.shields.io/badge/support-11.0-blue.svg)

# 说明

新来的童鞋可以直接去下面的连接关注别人新维护的e绅士项目吧。  
推荐新晋App：https://github.com/tatsuz0u/EhPanda  

OC版本能用的情况下暂时停更
项目起初是我刚开始做开发的时候模仿老前辈写的，留下了许多问题和不成熟的地方
所以已下定决心swift重写了，这三个月基本在做底层基础的功课
加上最近现实也挺倒霉的，换了两个东家折腾了不少事情
莫急，新版真的有在做了

主要是自用应用,而且还是新手,更新周期可能会比较长,有刚性需求的同学可以用DaidoujiChen的成熟应用\
测试: Xcode10.2.1 / iPhone Xs Max / iOS 12.3 Beta\
要求: 推荐 iPhone 7 或更新机型使用 / 需要 iOS 11.0 或更高版本\
\
有问题先前往wiki查找和issue爬文，没有满意结果再提问，感恩=v=

# 更新内容
20190506 v1.4.0
* 支持检测系统粘贴板内的画廊url，操作方法：在应用外复制包含画廊链接的内容，进入应用即可自动检测解析画廊
* 列表支持Mytags高亮特性
* 完全支持网站Mytags和Watched功能，实现原生控件操作
* 修复无法评论画廊的问题，改进评论区功能，新增评论区画廊链接应用内跳转
* 修改应用图标和一些加载动画，让应用看上去更加可爱~
* 修正一些上版本和以前引入的bug

已知问题：
* 项目的代码已经是一坨shit了，各种耦合
* 未登录状态画廊缩略图解析不成功
* 列表可能存在卡顿现象
* 搜索标签库没做分组，数据不全
* 改动较大，可能存在其他未知bug
* 部分网站操作功能暂时失效

# 应用截图
![](https://ws3.sinaimg.cn/large/006tNc79gy1g2rmakblg1j32790u01ky.jpg)

# 感谢
应用借鉴和参考以下项目的部分代码和逻辑进行开发
* [Dai-Hentai](https://github.com/DaidoujiChen/Dai-Hentai)
* [EhViewer](https://github.com/seven332/EhViewer)

ehentai标签汉化项目
* [EhTagTranslator](https://github.com/Mapaler/EhTagTranslator)

诸多开源项目框架，详情参看应用-关于\
还有捉虫和提建议的e友们、拿这项目卖钱的js们

# 功能
- [x] 热门,列表画廊浏览
- [x] 画廊详细信息查看
- [x] 图片阅读
- [x] 里站切换
- [x] 搜索/高级搜索
- [x] 支持账号登录
- [x] 搜索功能智能标签提示

# TODO
界面
- [ ] 高级设置适配网站新版server设置页

功能
- [ ] 应用数据缓存支持
- [ ] 跳转画廊逻辑优化
- [ ] 评论功能强化,同步网站功能
