#import "config.typ": *
#import "@preview/showybox:2.0.2": showybox
#import "@preview/physica:0.9.3": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "第二章 地下水运动公式推导")

#show math.equation: format_eq
#counter(heading).update(1)

#let delta(x) = $Delta(#x)$

$
  delta(y + x) = 1
$

= 地下水模块

== 给水度（specific yield）

靠近地下水水位$z_{"wt"}$的土壤层，认为土壤水势达到均衡状态，即：

$ psi + z = psi_("sat") + z_("wt") $

通过积分推导（CoLM，公式12.30~12.34），可以得到，
#mitext(`
第i层土壤$layer_i$的产水率$s_{y,i}$（specific yield），$s_{y,i} = \theta_{sat,i} - \theta(\psi_{sat,i} + z_{wt})$。

$s_{y,i}$的物理意义为土壤表层（$z=0$）的空气体积百分比。这主要是因为地下水水位的上升，等价于土壤含水量曲线的整体向上平移，即最上层的干旱部分被地下水附近的饱和部分代替。

== 地下水的水位更新

=== 补给

补给只影响地下水水位，不影响土壤含水量。补给的计算公式为：

$$
z_{wt} = z_{wt} + \frac{ q_{recharge}  \Delta t}{s_{y}}
$$

其中，地下水的水位$z_{wt}$向下为负，地表为0。

`)

=== 排泄

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



