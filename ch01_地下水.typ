#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox


#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "第一章. 地下水运动公式推导")

= 章节编号

== 二级标题

=== 三级标题

#block(
  [*测试英文字体* \
  #lorem(50)]
)

- 列表
  - 二级列表
  - 二级列表

== 使用体验

=== 缺点

- 加粗、倾斜，不太方便
- 中文加粗无法生效。
- 无block
- 模型配置不优好，学习门槛较高，教程不详细。碰到问题，gpt无法解决。

总结，没有markdown简单、方便。

=== 优点

- 排版控制比markdown精准。


= 特殊标记

给文字上色：#text("Hello, World!", fill: red)

给背景调色：#btext("Hello, World!")。==yellow==这里是正常的。==中文字体也是支持的==，但是中间有特殊符号不行，例如：`==中文符号 ==`。


#highlight(fill: rgb("abcdef88"))[#text("君不见，黄河之水天上来，奔流到海不复回。", weight: "extrabold", fill: red)]

#highlight[#text("君不见，高堂明镜悲白发，朝如青丝暮成雪。", weight: "extrabold", fill: red)]

// // 接下来是如何插入图片。

= 图片

#figure(
  image("images/三峡水库.png", width: 50%),
  caption: [This is the caption for the image.]
) <三峡>

引用图片。

这里我要引用图片了，@三峡。

= 表格



= 公式定理

$ 
y &= x + 1  \
  &= 2x + 1
$ <eq1>

$ sum_(k=1)^n k = (n(n+1)) / 2 $ <eq2>

如何引用公式呢？@eq1、@eq2。

定理：

#pagebreak()

= 表格

#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: figure.caption(position: top, [Caption.]),
)

= 代码

// #set text(size: 11pt, font: ("consolas", "Microsoft Yahei", "SimSun"))
```julia
# sy = 0.02 # 给水度
function GW_update!(θ::Vector{T}, zwt::T, ∑::T, sy::T=0.2) where {T<:Real}
  uex = 0.0 # exceed water to soil surface
  if ∑ > 0 # 补给，水位上升
    ## 从地下水所在的水位开始补给
    jwt = find_jwt(z₊ₕ, zwt)
    for j in jwt+1:-1:1
      z0 = j == 1 ? 0.0 : z₊ₕ[j-1]
      _layer = clamp(∑, 0, sy * (zwt - z0)) # 剩余补给空间

      θ[j] += _layer / Δz[j]   # TODO: 土壤不能超饱和
      zwt -= _layer / sy       # 补给，水位上升
      ∑ -= _layer
      ∑ <= 0 && break
    end
    ∑ > 0 && (uex = ∑) # excess water to soil surface, [m]
  else # 排泄，水位下降
    for j = jwt+1:N
      z1 = z₊ₕ[j]
      _layer = clamp(∑, sy * (zwt - z1), 0) # 剩余排泄空间, Note: ∑ < 0

      θ[j] += _layer / Δz[j]   # 可能存在亏损
      zwt -= _layer / sy       # 需要注意单位转换
      ∑ -= _layer
      ∑ >= 0 && break
    end
    ∑ < 0 && (zwt -= ∑ / sy)
  end
end
```
// #set ref.figure: it => link(it.target.location(), set text(fill: blue)[it])
// #set ref.table: it => link(it.target.location(), set text(fill: blue)[it])



