#import "./typst/lib.typ": *

// #show math.equation: format_eq
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸发信号分离")


= 分离ET周期性信号

== 傅里叶变换

基于傅里叶变换，对于长度为$N$的序列，可用m个谐波去拟合原始序列$X_t$。

- 当$m < "floor"(N\/2)$时，为拟合；
- $m="floor"(N\/2)$时，拟合的时间序列可穿过所有点，因此此时叫做插值。

#showybox(frame: (
    title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(95%) ), 
  title: [*欧拉公式*])[
  $ e ^ (i x) = cos(x) + i sin(x) $
  // $ e ^ (-i x) = cos(x) - i sin(x) $
  $ e^(i (2 pi k)/P t ) = cos( (2pi k)/P t ) + i sin( (2pi k)/P t ) $  
]

$ X_t &= sum_(k=0)^(N-1) c_k e ^( i (2 pi  k)/P t) \ 
      &= sum_(k=0)^(N-1) c_k [cos( (2pi k)/P t) + i sin( (2pi k)/P t)] \
$

- $N$ : $"length"(X_t)$，数据长度
- $P$ : 数据的时段长度（duration of signal），用于计算频率
- $k$ : 第k个谐波
// - $m$: 谐波的总数
- $c_k$: 简谐波的系数，#highlight()[*虚数向量*]，基于快速傅里叶变换得到，$c_k = "fft"(X)$
- $t$  : 时间

== 功率谱分析

量化每个简谐波具有的能量：

$
  "power"_k = |c_k|^2 = "real"(c_k)^2 + "image"(c_k)^2
$

== 拟合

采用m个简谐波，拟合原始时间序列$X$，拟合得到：

// $ hat(X_k) = a_0/2 + sum_(k=1)^m [a_k cos((2pi  k)/N t) + b_k sin((2 pi k)/N t)] $ <eq_fourier1>
$ hat(X) = sum_(k=0)^(m-1) [a_k cos((2pi  k)/P t) + b_k sin((2 pi k)/P t)] $ <eq_fourier1>

$
  a_k &= (2 "real"(c_n)) / N , a_1 = a_1 /2 \
  b_k &= (-2 "image"(c_n) ) / N
$

// - $t$: $t = (0:N-1)\/F_s$，
// - $F_s$: 频率，单位时间内出现的数据个数；比如，1天24个观测值。

// #pagebreak()
// == 快速傅里叶变化

== 代码示例
```julia
function Fourier(y::AbstractVector{FT}, P::FT=length(y); 
  threshold=0.95) where {FT<:Real}
  N = length(y)
  Δt = P / N
  t = 0.0:Δt:(P-Δt)   # lenght(t) == N
  # freq = 1 ./ t
  freq = fftfreq(N, 1 / Δt)
  ## 快速傅里叶变化
  len = N ÷ 2
  Fy = fft(y)[1:len]
  ak = 2 / N * real.(Fy)
  bk = -2 / N * imag.(Fy)  # fft sign convention
  ak[1] = ak[1] / 2

  ## 识别功率谱
  power = abs.(Fy) .^ 2
  inds = sortperm(power, rev=true)
  explain = power[inds] / sum(power)
  accu_explain = cumsum(explain)

  ## 挑选谐波数
  m = findfirst(accu_explain .>= threshold)  # 95% explained
  info = DataFrame(; k=1:len, freq=freq[1:len][inds], 
    explain, accu_explain)[1:m, :] # index=inds
  ## 重建信号
  yr = zeros(N, 1)
  for i in 1:m
    k = inds[i]
    yr .+= ak[k] * cos.(2π * (k - 1) / P * t) .+ 
           bk[k] * sin.(2π * (k - 1) / P * t)
  end
  (; ypred = yr, info)
end
```

= 参考文献

1. 黄嘉佑，气象统计分析与预报方法，*气象出版社*，第四版，p222-p227。
