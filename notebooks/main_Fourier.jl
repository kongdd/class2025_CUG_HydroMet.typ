using FFTW, DataFrames

"""
ypred, info = Fourier(y, P)

## Arguments
- P: period of the signal

## 要求
- 均匀步长
- 不能存在缺失值NaN
"""
function Fourier(y::AbstractVector{FT}, P=length(y); threshold=0.95, m=nothing) where {FT<:Real}
  N = length(y)
  Δt = P / N
  t = 0.0:Δt:(P-Δt)   # lenght(t) == N

  # freq = 1 ./ t
  freq = fftfreq(N, 1 / Δt)

  ## 快速傅里叶变化
  len = N ÷ 2
  Fy = fft(y)[1:len]
  ak = 2 / N * real.(Fy[2:end])
  bk = -2 / N * imag.(Fy[2:end])  # fft sign convention
  ak[1] = ak[1] / 2

  a0 = real.(Fy[1]) / N
  
  ## 识别功率谱
  power = abs.(Fy[2:end]) .^ 2
  inds = sortperm(power, rev=true)
  explain = power[inds] / sum(power)
  accu_explain = cumsum(explain)

  ## 挑选谐波数
  isnothing(m) && (m = findfirst(accu_explain .> threshold))  # 95% explained
  info = DataFrame(; k=2:len, index=inds, freq=freq[2:len][inds], explain, accu_explain)[1:m, :]

  ## 重建信号
  yr = fill(a0, N)

  for i in 1:m
    k = inds[i]
    yr .+= ak[k] * cos.(2π * k / P * t) .+ bk[k] * sin.(2π * k / P * t)
  end
  (; ypred=yr, info)
end
