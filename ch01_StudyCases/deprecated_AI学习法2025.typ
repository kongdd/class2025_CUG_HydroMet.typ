#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "", header: "")

= 1 AI学习法

#h(2em)
抛弃word的原因：AI难以读取word内容，难以操作word插入内容。而typst作为纯文本标记语言，AI可以轻松读取和编辑内容，能够直接插入文本、代码和公式，同时支持版本控制，非常适合与AI协作编写技术文档。

#h(2em)
AI能看到我们在编辑器中选择了哪些内容，必要时可读取上下文，能理解typst语法，并生成typst公式和文本。
能帮我们解释我们看不懂的公式，能帮我补全相关章节的理论内容，....。

#figure(
  image("Figures/Claude_01.png", width: 70%),
  caption: [
    Claude交互编辑过程。
  ],
) <fig_>

== 1.1 安装方法

- Claude付费用户
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install nodejs
npm install -g @anthropic-ai/claude-code
```

- 国产大模型智普
```powershell
code $profile
# 请私信我索要API
$env:ANTHROPIC_AUTH_TOKEN = "78ebe840d4c24f1b8387b5a1384ed747.jVlWgUA2MsJrg"
$env:ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
$env:API_TIMEOUT_MS = "3000000"
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1
```
