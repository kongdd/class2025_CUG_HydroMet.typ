#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "水文气象学2026", header: "第1章 编程基础")

#set par(
  leading: 1.24em,
  spacing: 1.20em,
  first-line-indent: (all: true, amount: 2em),
)

// =
#set page(footer: [#text("水文气象学2026", weight: "bold")])
// #heading(level: 1, outlined: false)[第一章 《AI与水文气象》课程介绍]

#outline(title: [目录])
#pagebreak()
#counter(page).update(1)
#set page(footer: context [
  #text("水文气象学2026", weight: "bold")
  #h(1fr)
  #counter(page).display("1/1", both: true)
])

#show "->": $->$

== 1.1 VSCode Profile配置

#figure(
  image("Figures/AI/import_snippets.png", width: 100%),
  caption: [
    VSCode导入个人配置。\
    设置 -> Profiles -> Import Profile -> 选择`vscode-profile.json`文件 -> Import。
  ],
) <fig_>

#h(-2em)
之后你就能拥有和我一样的快捷键（keyboard shortcuts）和代码片段补全（snippets）。

== 1.2 Typst入门

为何要学Typst？公式编写，章节、图、公式自动编号，交叉引用。*高效、美观。*

示例见：

- 知乎《Typst 能否帮助全球科研工作者摆脱 LaTeX 苦海？》：https://www.zhihu.com/question/1921284708328805594/answer/1930745503156541182
- *modern-cug-report*自然科学报告写作模版：https://github.com/CUG-hydro/modern-cug-report.typ

#figure(
  image("Figures/vscode/Tinymist.png", width: 80%),
  caption: [
    VSCode安装Typst插件。Typst安装这一个就可以了。
  ],
) <fig_>

#figure(
  image("Figures/vscode/Typst-Numbering.png", width: 80%),
  caption: [
    Typst章节自动编号。（本人开发，欢迎使用）
  ],
) <fig_>

=== 1.2.1 基础
- *标题*：`=`、`==`、`===`、`====`
- *代码*：行内代码用 #raw("`代码`")；代码块用三个反引号包围，首行指定语言。
- *公式*：`$$`
- *有序列表*：`1. 2. 3.`
- *无序列表*：`- * +`

=== 1.2.2 插入公式

```typst
$ y = a x + b $ <eq_1>
引用公式，如式#[@eq_1]。
```

=== 1.2.3 插入图片
```typst
#figure(
  image("Figures/AI/Figure1_管理代码.png", width: 100%),
  caption: [
    R语言代码管理示例。
  ],
) <fig_1>

引用图件，如图#[@fig_1]所示。
```

=== 1.2.4 插入表格

```typst
#figure(
  caption: [],
  table(
    columns: 7, // (2.0cm, 1.9cm, 1.55cm),
    rows: (0.8cm, 0.8cm),
    align: (horizon),
    
  ),
) <table_1>

引用表格，如表#[@table_1]所示。
```
// #pagebreak()

== 1.3 R语言代码管理

#figure(
  image("Figures/AI/Figure1_管理代码.png", width: 100%),
  caption: [
    R语言代码管理示例。
  ],
) <fig_>

// #v(1em)
=== 1.3.1 官方要求

具体细节参考Hadley Wickham编写的 R Packages一书，https://r-pkgs.org/。

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*文件或目录*], [*内容与用途*],
  [`data/`], [随包提供的数据集。],
  [`data-raw/`], [原始数据及数据整理脚本，通常不包含在构建后的包中。],
  table.cell(fill: luma(90%))[*`R/`*], table.cell(fill: luma(90%))[成熟R语言函数，*注意只能放函数*！],
  [`man/`], [帮助文档，通常由 roxygen2 生成。],
  table.cell(fill: luma(90%))[*`DESCRIPTION`*],
  table.cell(fill: luma(90%))[记录包名、版本、作者、依赖和许可证等元数据。],
  [`NAMESPACE`], [声明包导出的对象及从其他包导入的对象，通常由 roxygen2 生成。],
  [`tests/`], [测试代码，常使用 testthat 框架。],
  [`LICENSE`], [许可证文本或补充信息，具体内容取决于许可证类型。],
  [`README.md`], [介绍包的用途、安装方法和基本用法。],
  [`.github/`], [GitHub Actions 工作流、Issue 模板等配置。],
  [`.gitignore`], [指定 Git 不跟踪的文件和目录。],
  [`.Rbuildignore`], [指定构建 R 包时排除的文件和目录。],
)

#table-note[
  R包的最小结构：R文件夹与DESCRIPTION文件，表中灰色底色的两行。
  `devtools`、`usethis`、`roxygen2`、`testthat`等R包可以帮助创建和管理R包。
]

#box-blue[
  *R包的好处：*
  - 函数与脚本分离
  - 管理复杂包、函数依赖关系
  - `devtools::load_all()`自动加载R文件夹下的所有函数
  - 便于分享他人使用
]

#box-red[
  *你可以不会写代码，但是你必须会管理代码！*
]

我经常用到的提示词，可有效提升代码的质量，供参考：
#beamer-block[
  #v(0.2em)
  - R tidyverse专家
  - 遵循 Linux 极简主义，函数式编程思维，一次做好一件事
  - 不要交付低质量的代码，我会逐行审阅，要符合一个资深程序员的审美
]

=== 1.3.2 个人习惯

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*目录*], [*内容*],
  [`docs`], [Markdown 或 Typst 编写的说明文档、技术笔记等。],
  [`scripts`], [数据处理、分析和绘图等任务的脚本。],
  [`Figures`], [分析结果、示意图等图表文件。],
  [`Project_**`], [按项目组织的代码、数据与文档等。],
  [`INPUT`], [分析所需的输入数据和配置文件。],
  [`OUTPUT`], [运行生成的数据、结果和报告等。],
)

== 1.4 环境设置

=== 1.4.1 GitHub
#box-red()[
  #highlight[*注意一定要切换到自己的目录！才能执行下面的配置！*]
]
```
cd /data/user/046241_$name # 切换到工作目录
```

```bash
# 编辑 .envrc 文件，添加以下内容，*路径改成自己的*：
export dir_root="/data/users/046242_**"
export GH_CONFIG_DIR="$dir_root/.gh"
export PI_CODING_AGENT_DIR="$dir_root/.pi"
export GIT_CONFIG_GLOBAL="$dir_root/.gitconfig"
```

*git配置*

```bash
# 配置git用户名和邮箱
git config --global user.name "Dongdong Kong"
git config --global user.email "你的GitHub邮箱"
```

*github账号登录*
```bash
gh auth login
gh auth status # 查看登录状态
```
登录成功后授权文件将保存到`GH_CONFIG_DIR`文件件。

=== 1.4.2 Pi + VSCode

#figure(
  image("Figures/AI/Figure3_pi_bridge.png", width: 80%),
  caption: [
    安装vscode-pi-bridge插件。
  ],
) <fig_>

*步骤1*：安装vscode-pi-bridge插件，`code --install-extension zenyui.vscode-pi-bridge`；或者Extension搜索安装。

*步骤2*：切换到自己的目录。将`pi-vscode-context.ts`文件复制到`$PI_CODING_AGENT_DIR/extensions/`目录下，重启vscode即可。`pi-vscode-context.ts`见：https://github.com/kongdd/kong-pi-extension/blob/master/extensions/pi-vscode-context.ts。

*步骤3*: VSCode中选中一些行，pi中就能看到了。


=== 1.4.3 使用模版

#figure(
  image("Figures/AI/Figure2_use_template.png", width: 70%),
  caption: [
    使用模版创建R包。模版见https://github.com/rpkgs/rpkg.template。\
    依次点击`Use this template` $->$ `Create a new repository`。
  ],
) <fig_>

之后，`git clone repo_url`，将模版克隆到本地（注意填写上自己的repo路径，格式如https://github.com/rpkgs/rpkg.template）。

// #pagebreak()
#pagebreak()
== 1.5 实战

1. 将https://github.com/rpkgs/rpkg.template 克隆到本地，作为R包的模板；

2. 添加函数，https://github.com/rpkgs/RHtests/blob/master/R/Component.R；

3. 编写文档docs、测试tests；

  #box-red()[
    让AI读代码，用typst编写文档，生成测试代码，push to github。
  ]

4. 推到github，2-3min即可看到测试结果；

== 1.6 作业

#box-red()[
  总结你的操作步骤、存在的问题，采用typst编写笔记，上传到github，编译好的pdf作为作业上交。
  *pdf命名格式：`046241_姓名.pdf`*。

  学委帮忙收齐，周六晚22点之前发给我。
]
