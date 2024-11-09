#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/codly:1.0.0": *

#show: codly-init.with()
#codly(stroke: 1pt + blue)
#codly(display-icon: true)



#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "第一章. 地下水运动公式推导")


= 特殊标记

给文字上色：#text("Hello, World!", fill: red)

给背景调色：#btext("Hello, World!")。==yellow==这里是正常的。==中文字体也是支持的==，但是中间有特殊符号不行，例如：`==中文符号 ==`。


= 章节编号

== 二级标题

=== 三级标题

#lorem(50)

=== 公式定理

#highlight(fill: rgb("abcdef88"))[#text("君不见，黄河之水天上来，奔流到海不复回。", weight: "extrabold", fill: red)]

#highlight[#text("君不见，高堂明镜悲白发，朝如青丝暮成雪。", weight: "extrabold", fill: red)]

人生得意须尽欢，莫使金樽空对月。

$ 
y &= x + 1  \
  &= 2x + 1
$ <eq1>

$ sum_(k=1)^n k = (n(n+1)) / 2 $ <eq2>

如何引用公式呢？@eq1、@eq2。

- 列表
  - 二级列表
  - 二级列表

定理：

#pagebreak()

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
// // 接下来是如何插入图片。

#figure(
  image("images/三峡水库.png", width: 50%),
  caption: [This is the caption for the image.]
) <三峡>

这里his否生效了

这里我要引用图片了，@三峡。

#pagebreak()


// #set ref.figure: it => link(it.target.location(), set text(fill: blue)[it])
// #set ref.table: it => link(it.target.location(), set text(fill: blue)[it])


君不见，黄河之水天上来，奔流到海不复回。

君不见，高堂明镜悲白发，朝如青丝暮成雪。

人生得意须尽欢，莫使金樽空对月。

天生我材必有用，千金散尽还复来。

烹羊宰牛且为乐，会须一饮三百杯。

岑夫子，丹丘生，将进酒，君莫停。

与君歌一曲，请君为我侧耳听。

钟鼓馔玉不足贵，但愿长醉不愿醒。

古来圣贤皆寂寞，惟有饮者留其名。

陈王昔时宴平乐，斗酒十千恣欢谑。

主人何为言少钱，径须沽取对君酌。

五花马，千金裘，呼儿将出换美酒，与尔同销万古愁。
