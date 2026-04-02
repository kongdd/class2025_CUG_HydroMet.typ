# includet("main_XAJ.jl")
using Statistics
using Plots
using Roots
using DataFrames

info = fread("./data-XAJ-runoff.csv")


# function cal_Rs(S1, FR1, FR, PE; SM_max, EX)
#   S_max = SM_max / (1 + EX)   # grid_max -> regional_max  
#   S1_new = S1 * FR1 / FR # 重新计算新的蓄水量，产流面积上的
#   RS = FR * (PE + S1_new - S_max * (1 - (1 - (S1_new / S_max))^(EX + 1)))
#   return RS
# end
# function cal_dS(S1, FR1, FR, PE; SM_max, EX)
#   S_max = SM_max / (1 + EX)   # grid_max -> regional_max  
#   S1_new = S1 * FR1 / FR # 重新计算新的蓄水量，产流面积上的

#   S_new = S1 * FR1 / FR + (R - RS) / FR # 新的产流面积上的蓄水量
#   return S_new
# end


## 核心参数
begin
  FR = 0.4
  SM_max = 100.0
  EX = 0.4
  S_max = SM_max / (1 + EX) # grid_max -> regional_max

  FRs = 0.0:0.05:1.0
  SMs = cal_SM.(FRs; SM_max, EX) # 当前最大值, 超过则碰到挡板
  Ss = separate_ΔS.(SMs, FRs; SM_max, EX) # 不同FR时，最大容量
end


function solve_AU(W::T, WM::T, WMM::T, B::T) where {T<:AbstractFloat}
  W_frac = clamp(W / WM, 0.0, 1.0)
  AU = WMM * (1 - (1 - W_frac)^(1 / (1 + B))) # Eq. 2-58, 根据W反推AU
  return 1 - (1 - AU / WMM)^B                 # Eq. 2-55, 产流面积α0
end


PEs = diff(info.full) # 净雨

res = map(i -> begin
  R = PEs[i] # 新增了多少自由水
  FR1 = FRs[i]  # 上一时刻的产流面积
  FR = FRs[i+1] # 这一时刻的产流面积
  PE = R / FR   # 单位产流面积的新增自由水量

  ## 将上一个时空的水，进行分配，重新求解得到AU
  S1 = info.S[i] # 上次蓄水量
  S1 = S1 * FR1 / FR  # 重新计算新的蓄水量，产流面积上的
  
  AU = solve_AU(S1, S_max, SM_max, EX)
  
  if PE + AU < SM_max
    RS = FR * (PE + S1 - S_max + S_max * (1 - (PE + AU) / SM_max)^(EX + 1)) # Eq. 2-85, 产流量
    # S = S_max * (1 - (1 - (PE + AU) / SM_max)^(EX + 1))
    S = S1 + (R - RS) / FR
  else
    RS = FR * (PE + S1 - S_max)
    S = S_max
  end
  (; RS, S)
end, 1:20)

# res = DataFrame(res)
# sum(res.RS), sum(res.dS)
# sum(info.dR), sum(info.dS)
