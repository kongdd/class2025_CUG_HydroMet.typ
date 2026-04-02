includet("main_XAJ.jl")
include("solver.jl")
using RTableTools


## 核心参数
FR = 0.4
SM_max = 100.0
EX = 0.4
S_max = SM_max / (1 + EX) # grid_max -> regional_max  
@show S_max

begin
  FRs = 0.0:0.05:1.0
  plot(FRs, cal_SM.(FRs; SM_max, EX))
end

# begin
AU = 10.0
separate_Rs(AU, FR; SM_max, EX)

SMs = cal_SM.(FRs; SM_max, EX) # 当前最大值, 超过则碰到挡板
Ss = separate_ΔS.(SMs, FRs; SM_max, EX) # 不同FR时，最大容量

## 接下来设计一个验证产流的方案
# 这个是标准答案
info = DataFrame(; FR=FRs, SM=SMs, full=FRs .* SMs, S=Ss)
info.Runoff = info.full .- info.S
info.dR = diff([0.0; info.Runoff])
info.dS = diff([0.0; info.S])
info

## 每次刚好蓄满
PE = diff(info.full) # 净雨


function separate_freeR_3S_Kong(S1::T, FR1::T, R::T, FR::T;
  SM_max, EX) where {T<:AbstractFloat}

  # AU1 = solve_AU_bisection(S1, FR1; SM_max, EX)
  AU1 = solve_AU_newton(S1, FR1; SM_max, EX)
  FR1 == 0.0 && (AU1 = 0.0)

  S_part1 = AU1 * (FR - FR1) # 先把右侧的补齐
  if R <= S_part1 # 补齐所需要的水量
    RS = 0.0
    dS = R
  else
    R -= S_part1  # 还剩余多少水需要分配
    a = AU1
    b = AU1 + R / FR

    RS = separate_Rs(a, b, FR; SM_max, EX)
    dS = separate_ΔS(a, b, FR; SM_max, EX) + S_part1
  end
  return RS, dS
end


## 传统方法是如何做的呢 
function separate_freeR_3S(S1::T, FR1::T, R::T, FR::T;
  SM_max, EX) where {T<:AbstractFloat}

  PE = R / FR # 单位产流面积的新增自由水量
  # S1 = S1 / FR # 从流域平均 转为 产流面积上的蓄水量，放到了新的产流面积上
  AU = solve_AU(S1 / FR, SM_max, EX) # 在产流面积上求解AU
  
  @show PE, S1, FR, AU

  if PE + AU < SM_max
    @show "k1"
    _RS = PE + S1 - S_max + S_max * (1 - (PE + AU) / SM_max)^(EX + 1) # Eq. 2-85, 产流量
    RS = FR * _RS # 产流面积 -> 流域面积
  else
    @show "k2"
    RS = FR * (PE + S1 - S_max)
  end
  dS = R - RS
  return RS, dS
end


function test_3S(info, func=separate_freeR_3S!; SM_max, EX)
  map(i -> begin
      FR1 = FRs[i]  # 上一时刻的产流面积
      FR = FRs[i+1] # 这一时刻的产流面积
      R = PE[i] # 新增了多少自由水
      S1 = info.S[i] # 上次蓄水量

      RS, dS = func(S1, FR1, R, FR; SM_max, EX)
      (; R, RS, dS)
    end, 1:20) |> DataFrame
end


## 这种方式计算通过
res_kong = test_3S(info, separate_freeR_3S_Kong; SM_max, EX)
sum(res_kong.RS), sum(res_kong.dS)

res_old = test_3S(info, separate_freeR_3S; SM_max, EX)
sum(res_old.RS), sum(res_old.dS)



res = DataFrame(res)
sum(res.RS), sum(res.dS)
sum(info.dR), sum(info.dS)

fwrite(info, "data-XAJ-runoff.csv")
