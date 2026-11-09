#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "水文气象学2026", header: "第1章 课程介绍")

#set par(
  leading: 1.24em,
  spacing: 1.20em,
  first-line-indent: (all: true, amount: 2em),
)

// =
// ==
#set page(footer: [#text("水文气象学2026", weight: "bold")])
#heading(level: 1, outlined: false)[第一章 《AI与水文气象》课程介绍]

#outline(title: [目录])
#pagebreak()
#counter(page).update(1)
#set page(footer: context [
  #text("水文气象学2026", weight: "bold")
  #h(1fr)
  #counter(page).display("1/1", both: true)
])

== 1.2 AI基础
#v(-0.6em)

=== 1.2.1 不同编程语言的优劣

TIOBE 编程语言排行榜（#link("https://www.tiobe.com/tiobe-index/")[TIOBE Index]）根据搜索引擎中与编程语言相关的搜索结果，估计各语言的流行程度，通常每月更新。排名反映的是关注度，而非语言的技术水平或实际使用量；选择语言时，还需考虑应用场景、生态和团队经验。

了解不同的场景，应该用什么编程语言。才能更好的指挥AI完成任务。

#let w1 = 3cm

#figure(
  caption: [常用编程语言的特点比较],
  {
    set par(leading: 0.5em, spacing: 0.65em, first-line-indent: 0em)
    table(
      columns: (2.5cm, w1, w1, w1, w1, 1.4cm),
      rows: (1cm, 1.4cm),
      // (2.0cm, 1.9cm, 1.55cm),
      // inset: (x: 4pt, y: 4pt),
      align: (horizon),
      [语言], [应用领域], [优点], [缺点], [应用场景], [编程效率],
      [*Python*], [通用编程], [生态丰富、易于上手], [纯语言代码运行较慢], [*深度学习*\ Torch/Jax], [高],
      [*MATLAB*], [科学计算、\ 工程仿真], [简单易用，矩阵运算], [商业授权费用较高], [科学计算], [高],
      [*Fortran*], [*科学计算*], [矩阵运算], [编程效率低], [老一代*陆面与气候模式*], [高],
      [*R*], [*统计分析*、\ 数据可视化], [统计生态丰富、绘图方便], [大规模计算受内存限制], [数据分析与\ 绘图], [高],
      [*Julia*], [高性能科学计算、*模型开发*], [运行速度快、适合数值计算], [生态弱、首次运行慢], [模型开发], [较高],
      [*Rust*], [*系统应用*、高性能计算], [性能高、内存安全], [开发门槛较高], [系统工具], [中],
      [*JavaScript*], [*前端与后端*\ 开发], [网络交互], [动态类型可能引入错误], [多系统兼容\ 程序、网页], [较高],
      [*TypeScript*], [*前端与后端*\ 开发], [JS的超集], [需要编译，配置较复杂], [同上], [较高],
    )
  },
) <table_>

*个人开发的一些软件包*

- `code-action`：*Rust*, 代码管理，https://github.com/kongdd/code-action
- `autossh-ui`：*Rust*, 端口管理，https://github.com/kongdd/autossh-ui
- `k380_fn`: k380键盘fn管理, https://github.com/kongdd/k380_fn.rs
- `ModernHydro-Web`: *Rust+Julia+TypeScript*，十堰山洪平台，https://github.com/kongdd/ModernHydro-Web
- `ai-quota`: *TypeScript*, 跨平台通用工具，AI quota查询, https://github.com/kongdd/ai-quota
- `vscode-rdata-view`：*TypeScript*, R语言数据表格可视化，https://github.com/kongdd/vscode-rdata-view
- `Zotero-AttachFlow`: ：*TypeScript*, Zotero文献管理附件工具，https://github.com/kongdd/Zotero-AttachFlow.git

- `My R packages`: 115 repository, https://github.com/rpkgs
- `My Julia packages`: 143 repository, https://github.com/jl-pkgs

- 专业相关包：见https://github.com/kongdd。

#v(1em)

*网络上Rust重写运动*

- `arfcraft`: https://github.com/storytold，Adobe全家桶Rust重写，跨平台，性能高，安全性好、开软免费。
- `craft-anything`： https://github.com/storytold/craft-anything
- `rea`: 反汇编，逆向解析软件，https://github.com/morluto/rea
- 

=== 1.2.2 AI工具的选择

*（a）Providers*

想要让AI提升自己的工作学习效率，需舍得投资，购买coding plan。仅仅使用网页版的deepseek、chatgpt是远远不够的。网页版的主要瓶颈在于：（1）缺乏对本地代码、数据的访问能力，*无法跑大型的project*；（2）缺乏可执行的软件环境，*无法验证代码的正确性*；


#{
  set par(leading: 0.5em, spacing: 0.5em, first-line-indent: 0em)
  graph-table(
    caption: [常用 AI 服务订阅指南 #v(1em)],
    table(
      columns: (2.6cm, 2.5cm, 1fr, 2.2cm, 2.8cm),
      rows: (1.1cm, 1.1cm),
      inset: (x: 4pt, y: 6pt),
      align: horizon,
      [服务], [使用与订阅入口], [API 入口], [月费参考], [推荐等级\ (10分制)],
      [ChatGPT],
      [#link("https://chatgpt.com/")[ChatGPT]],
      [#link("https://platform.openai.com/")[OpenAI 平台]],
      [Plus 20\$],
      [*9*],

      [Claude],
      [#link("https://claude.ai/")[Claude]],
      [#link("https://console.anthropic.com/")[Anthropic 控制台]],
      [Pro 20\$],
      [10\ #highlight[封号大师]],

      [Gemini],
      [#link("https://gemini.google.com/")[Gemini]],
      [#link("https://aistudio.google.com/")[Google AI Studio]],
      [Pro 20\$],
      [7\ 不够智能],

      [Grok],
      [#link("https://grok.com/")[Grok]],
      [#link("https://console.x.ai/")[xAI 控制台]],
      [Premium 30\$],
      [7\ 不够智能],

      [DeepSeek],
      [#link("https://chat.deepseek.com/")[DeepSeek 对话]],
      [#link("https://platform.deepseek.com/")[DeepSeek 开放平台]],
      [网页免费],
      [*8*\ *国产之光*],

      [智谱 GLM],
      [#link("https://chatglm.cn/")[智谱清言]],
      [#link("https://open.bigmodel.cn/")[智谱开放平台]],
      [Lite 94.4￥],
      [7\ #highlight[费用高]],

      [MiniMax],
      [#link("https://www.minimaxi.com/")[MiniMax]],
      [#link("https://platform.minimaxi.com/")[MiniMax 开放平台]],
      [Go 49￥],
      [3\ #highlight[弱智]],

      [Kimi],
      [#link("https://kimi.com/")[Kimi]],
      [#link("https://platform.moonshot.cn/")[月之暗面开放平台]],
      [Go 39￥],
      [5\ 费用高],

      [通义千问],
      [#link("https://www.qianwen.com/")[千问]],
      [#link("https://bailian.console.aliyun.com/")[阿里云百炼]],
      [39.50￥],
      [5\ 不够智能],

      [OpenCode], [#link("https://opencode.ai/")[OpenCode]], [由所选服务商提供], [10\$], [*8\ 国产集合*],
    ),
  )
}

*（b）Harness*

Harness 是连接大模型与本地工具的智能体运行环境，可辅助阅读、修改代码和执行命令。不同工具的特点如下：

#figure(
  caption: [常用 AI 编程工具的特点比较],
  {
    set par(leading: 0.65em, spacing: 0.65em, first-line-indent: 0em)
    table(
      columns: (3.5cm, 6.5cm, 6cm),
      inset: (x: 4pt, y: 6pt),
      align: horizon,
      [*工具*], [*优点*], [*缺点*],
      [`claude-code`], [行业顶尖], [2w token起步\ 封号大师，1,400万被封],
      [`codex`], [功能完善性强于pi], [权限审批复杂，\ 领先性不如claude-code],
      [`pi agent`], [起步1k，节省token，\ 支持全平台模型，功能灵活定制], [安全性差],
    )
  },
)

#beamer-block()[
  推荐使用pi agent，支持几乎所有的模型，支持自己定制功能。
  有些比较坏的、非开源的harness，例如claude-code、grok、以及某个国产软件，偷偷作恶，偷数据。
]

#figure(
  image("Figures/AI/pi-agent.png", width: 70%),
  caption: [
    私人定制的pi-agent。可图片交互，显示AI auota、Token Speed、上下文消耗。\
    ↑：上传的token数，↓：下载的token数，R：缓存。
  ],
) <fig_>



*安装方法*如下：
```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
npm install -g @openai/codex
npm install -g @anthropic-ai/claude-code
```

#box-red()[
  AI时代，要学会自主学习。如果教师花了大量的时间教软件怎么安装，那教学效率是极低的。
  *教师的定位是：引导哪些方面是有价值的、值得学习的。*
]

#pagebreak()
=== 1.2.3 必备的工具软件

- *`Git`*          : #highlight[必备的]，版本控制，一定要掌握，否则AI会把你的文件搞乱
  ```bash
  git clone $repo_url
  git push # push lcoal to remote
  git pull # pull remote to local
  ```
  #h(-2em)*几个基本概念*：
  + branch（分支）：独立的开发线，便于并行开发和管理不同版本。
  + commit（提交）：记录一次修改的快照，并附有提交说明。
  + staged/unstaged（已暂存/未暂存）：修改是否已加入暂存区；提交时仅记录已暂存的修改。
  + local/remote（本地/远程）：本地仓库位于个人电脑，远程仓库位于服务器；可通过推送和拉取同步。

- *`sublime merge`*: git管理工具，UI操作，避免写git命令

  #figure(
    image("Figures/AI/sublime_merge_V2.png", width: 90%),
    caption: [
      Sublime Merge界面。
    ],
  ) <fig_>

- *`VSCode`*       : #highlight[推荐的]，代码编辑器
- *`Zed`*       : 可选的，代码编辑器（高性能，可以阅读和修改代码，可以当git 使用，但功能不如VSCode，直接运行代码的体验不如VSCode）
  #figure(
    image("Figures/AI/zed.png", width: 90%),
    caption: [
      Zed主界面。\
      Zed采用Rust语言开发，具有高性能和低延迟的特点，适合处理大型代码库和复杂项目。
    ],
  ) <fig_>

- *`Markdown`*  : 必备的，文档编写，2min入门，*不支持复杂排版*。可以不关心排版，专注于内容的编写。
  + `标题`: `# 一级标题`, `## 二级标题`, `### 三级标题`
  + `列表`: `- 无序列表`, `1. 有序列表`
  + `代码块`: \`\`\`
    ```python
    def hello_world():
        print("Hello, World!")
    ```

- *`Typst`*     : 推荐的，文档排版，支持类似word的复杂排版
  https://github.com/CUG-hydro/modern-cug-report.typ

- *`sheprg`*: #highlight[必备的]，多窗口终端管理器。背后使用的是`Herdr`。

=== 1.2.4 计算机基础知识

==== 1.2.4.1 操作系统

操作系统是运行代码与工具软件的基础环境，三大主流系统的特点如下：

#figure(
  caption: [常用操作系统的特点比较],
  {
    set par(leading: 0.5em, spacing: 0.5em, first-line-indent: 0em)
    table(
      columns: (2cm, 1fr, 1fr),
      rows: (0.8cm, 1.15cm),
      inset: (x: 4pt, y: 6pt),
      align: horizon,
      [*系统*], [*优点*], [*缺点*],
      [Windows], [图形界面友好], [软件安装困难，AI不擅长powershell],
      [macOS], [办公软件齐全，兼具Linux优点], [系统不开源，软件更新不如linux及时，计算效率不如linux],
      [Linux], [免费、稳定，工具链完善], [缺乏办公软件],
    )
  },
)

==== 1.2.4.2 基本的命令行操作

- `ls`    : 列出当前目录下的文件与子目录，`ls -l` 显示详细信息
- `cd`    : 切换目录，`cd ../data` 进入上一级的 data 目录
- `mkdir` : 创建目录，`mkdir -p a/b/c` 逐级创建
- `touch` : 创建空文件或更新时间戳
- `rm`    : 删除文件或目录，`rm -rf dir_name` 递归删除目录
- `cp`    : 复制文件或目录，`cp -r src dest`
- `mv`    : 移动或重命名文件或目录，`mv old_name new_name`
- `cat`   : 查看文件内容，`cat file.txt`

注意：Linux和Windows的命令存在不同。

==== 1.2.4.3 环境变量与路径

- *环境变量PATH*：安装的软件如何添加到环境变量PATH。否则terminal中，无法找到该软件。教程：https://zhuanlan.zhihu.com/p/671349063。建议添加到用户变量Path，系统变量Path可能需要重启。

- *路径*：#highlight[*知道路径在哪，才能知道自己的文件在哪。*]\
  （1）了解绝对路径与相对路径的区别；（2）了解Windows和Linux（macOS）的路径写法区分。pathcopycopy可辅助快速复制路径，https://github.com/clechasseur/pathcopycopy/releases/tag/v20.0。


==== 1.2.4.4 网络

网络是远程访问服务器与调用云端 API 的基础，需掌握以下概念：

#figure(
  caption: [网络基础概念],
  {
    set par(leading: 0.5em, spacing: 0.5em, first-line-indent: 0em)
    table(
      columns: (2.2cm, 1fr, 1fr),
      inset: (x: 4pt, y: 6pt),
      align: horizon,
      [概念], [说明], [常用命令或应用],
      [局域网],
      [同一路由器或交换机下的主机互访，用于内网共享与计算],
      [#`ping 192.168.1.1` 检测连通性，#`ip addr` 查看本机地址],

      [公网 IP],
      [运营商或云厂商分配的全球唯一地址，用于对外提供服务；家用多为动态、云服务器固定],
      [云服务器需在安全组放行端口，固定 IP 便于远程登录与建站],

      [端口],
      [主机上进程的编号（0–65535），区分同一 IP 上的不同服务],
      [SSH 22、HTTP 80、HTTPS 443；自定义端口需在防火墙放行],

      [端口映射],
      [把公网端口的请求转发到内网主机与端口，是暴露本地服务的常用手段],
      [路由器配置“虚拟服务器”，或用 #`ssh -p 端口`、frp 转发],
    )
  },
)

一个网页服务：公网ip（阿里云、腾讯云服务器，200￥/年），域名（100-200￥/十年），本地服务器（5000\~10000￥，小型程序直接部署在云服务器即可）。

*可能用到的软件：*

- `rathole`：https://github.com/rathole-org/rathole。将本地服务映射到公网，方便远程访问，部署软件服务。

- `autossh-ui`: https://github.com/kongdd/autossh-ui。端口映射管理。\
  服务器: `192.168.31.84`，本地：`192.168.31.100`。
  + `Local`: 服务器的端口，拉到本地使用。
  + `Remote`: 本地的端口，拉到服务器使用，Friday语音助手。
  + `Dynamic`: 服务器的网络给本地使用，类似于VPN网络代理。使用场景：例如，服务器断网，服务器需要登陆CUG的网络，Dynamic映射到本地端口后，可以帮其登陆。
  #figure(
    image("Figures/AI/autossh-ui.png", width: 90%),
    caption: [
      autossh-ui多个服务器端口管理。
    ],
  ) <fig_>

  #figure(
    image("Figures/AI/autossh-connections.png", width: 90%),
    caption: [
      autossh-ui 端口管理。
    ],
  ) <fig_>

- `rustdesk`: https://rustdesk.com/。远程桌面，国产之光，远程控制电脑。
  linux, mac, windows均可使用。

- `mstsc`: Windows自带远程桌面，随时随地访问自己的电脑。

- `termius`: https://www.termius.com/。手机访问电脑。

  #figure(
    image("Figures/AI/termius.png", width: 100%),
    caption: [
      Termius手机访问电脑。
    ],
  ) <fig_>

==== 1.2.4.5 SSH

SSH（Secure Shell）是加密的远程登录协议，用于安全地访问服务器、传输文件与执行命令。
有了ssh + sheprd + VSCode，使用服务器就像使用自己的电脑一样简单。

#figure(
  image("Figures/AI/sheprd.png", width: 100%),
  caption: [
    sheprd ssh连接服务器。多窗口管理，进程常驻。
  ],
) <fig_>

#figure(
  image("Figures/AI/case01_zed.png", width: 93%),
  caption: [
    Zed的工作界面。`remote-editor --host amd --zed`。\
    remote-editor命令见：https://github.com/kongdd/code-action/tree/master/crates/cli-remote。
  ],
) <fig_>

#figure(
  image("Figures/AI/case01_code.png", width: 93%),
  caption: [
    VSCode的工作界面。`remote-editor --host amd --code`
  ],
) <fig_>

// 我个人的服务器
// Atmos
// DuYu
// amd
// p520
// mac

==== 1.2.4.6 课程推荐使用的编程语言

课程推荐使用的如下编程语言和工具：*因为简单，所以推荐。*

1. *R语言负责统计与绘图。*（统计分析与绘图，代码量为Python的1/3）
  - R语言：https://cran.r-project.org/bin/windows/base/
  - arf: https://github.com/eitsupi/arf，下载丢到环境变量PATH。
  - VSCode安装R语言插件：R Extension for Visual Studio Code，https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r。

  #figure(
    image("Figures/vscode/R.png", width: 100%),
    caption: [
      VSCode安装R语言插件。
    ],
  ) <fig_>

2. *Julia负责模型开发与高性能计算。*（土壤水运动、土壤热通量模拟、水文模型）
  - Julia语言：https://julialang.org/downloads/。\
  - VScode安装Julia插件：Julia，https://marketplace.visualstudio.com/items?itemName=julialang.language-julia。

  #figure(
    image("Figures/vscode/Julia.png", width: 100%),
    caption: [
      VSCode安装Julia语言插件。
    ],
  ) <fig_>

3. *Typst负责文档排版与公式编辑。*

为何要学：公式编写，章节、图、公式自动编号，交叉引用。高效、美观。

示例见：

- 知乎《Typst 能否帮助全球科研工作者摆脱 LaTeX 苦海？》：https://www.zhihu.com/question/1921284708328805594/answer/1930745503156541182
- *modern-cug-report*自然科学报告写作模版：https://github.com/CUG-hydro/modern-cug-report.typ

#figure(
  image("Figures/vscode/Tinymist.png", width: 100%),
  caption: [
    VSCode安装Typst插件。Typst安装这一个就可以了。
  ],
) <fig_>

#figure(
  image("Figures/vscode/Typst-Numbering.png", width: 100%),
  caption: [
    Typst章节自动编号。（本人开发，欢迎使用）
  ],
) <fig_>


#pagebreak()
=== 1.2.5 需要掌握和训练的

==== 1.2.5.1 数据处理、分析与绘图

R语言可极大的提高数据处理效率、绘图效率。代码简短，仅为Python的1/3。
// R语言是统计学家、数据科学家最常用的工具。

  - 1行代码读取、写入csv、xlsx数据
  - 3行代码绘图
  - 5行代码数据清洗：dplyr + magrittr
  
  #box-red()[
    `magrittr`: 管道符，https://magrittr.tidyverse.org/reference/index.html \
    `dplyr`   : 数据清洗神器，https://dplyr.tidyverse.org/reference/index.html \
    `ggplot2` : 绘图神器，https://ggplot2.tidyverse.org/reference/index.html
  ]
  
==== 1.2.5.2 Pi Agent的使用

靠谱的AI工具，能帮你解决99%的学习上的问题。

==== 1.2.5.3 Typst编写文档

研究方案写的好，AI才能理解你想做什么。

笔记做的好，才能学会先进、复杂的方法。

文档写的好，才能出论文、专利、项目申请书，实现成果积累，收益转化。

#box-red[
  这个步骤不要指望AI帮你完成。如果连做什么AI都帮你想好了，那你可以完全被AI取代了。
]

==== 1.2.5.4 必要专业知识积累

有专业知识积累，才能解决专业相关的问题，增加自身竞争力和不可替代性。

==== 1.2.5.5 科学严谨的思维

如何系统性的解决一个问题。以解决问题为导向。

做不出来，做不好、不会做，多是问题想的不够清楚、不够深刻。

科学需要严谨和深刻的思考。而具体解决方案，则追求“大道至简”。采用极简的思维解决问题，极简的思维编写代码，指挥AI。
