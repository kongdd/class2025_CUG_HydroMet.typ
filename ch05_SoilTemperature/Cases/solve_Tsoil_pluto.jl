### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ a80a11a2-de01-4af8-a245-38952b98506a
begin
  using Pkg
  Pkg.activate("~")

  using OrdinaryDiffEq
  using Plots
  using PlutoUI
  using Printf
  gr(framestyle=:box, fmt=:png)
end


# ╔═╡ 851dbe9f-0754-4e73-a89a-5988b39c86dc
begin
	const σ = 5.67e-8  # Stefan-Boltzmann constant (W m⁻² K⁻⁴)
	ρa = 1.225   # Air density (kg m⁻³)
	cp = 1005.0  # Specific heat of air (J kg⁻¹ K⁻¹)

  include("./main_Tsoil.jl")
  ε_val = 0.98
end

# ╔═╡ 0f449991-4cb5-42fe-8f3d-c831d5fde6fb
html"""
<style>
	main {
		max-width: 1100px;
		margin: 0 auto;
	}
</style>
"""

# ╔═╡ c7d531b3-4d2a-459e-a5f7-b9fe0c542a02
md"""
# 土壤温度模拟：交互式教学演示

本笔记本模拟土壤温度随深度和时间的变化，基于热传导方程和地表能量平衡。
"""

# ╔═╡ 916076a3-91f2-42ac-b782-bae82f5b871f
md"""
## 模型原理

**控制方程**：
- 地表能量平衡：$R_n - H - G = 0$

- 土壤热传导：$\frac{\partial T}{\partial t} = \frac{\kappa}{C_v} \frac{\partial^2 T}{\partial z^2}$

**边界条件**：
- 地表：通过能量平衡求解表面温度
- 底部：绝热边界条件

| 符号 | 说明 |
|------|------|
| $\kappa$ | 土壤热导率 (W m⁻¹ K⁻¹) |
| $C_v$ | 土壤体积热容 (J m⁻³ K⁻¹) |
| $\alpha$ | 地表反照率 |
| $\varepsilon$ | 地表发射率 |
| $r_a$ | 空气动力学阻抗 (s m⁻¹) |
"""

# ╔═╡ 6be9d345-3066-4d1d-bfb1-c1eed8808332
md"""
**参数设定**

| 参数   |   说明 | 滑块 |
|:------|:------|:------|
| 热导率 κ (W m⁻¹ K⁻¹) | 控制热量传递速度 | $(@bind κ_val Slider(0.5:0.1:3.0, default=1.5, show_value=true)) |
| 体积热容 Cv (×10⁶ J m⁻³ K⁻¹) | 控制土壤储热能力 | $(@bind Cv_val Slider(1.0:0.2:4.0, default=2.0, show_value=true)) |
| 反照率 α | 地表反射太阳辐射比例 | $(@bind α_val Slider(0.1:0.05:0.5, default=0.25, show_value=true)) |
| 空气动力学阻抗 rₐ (s m⁻¹) | 地表与大气热量交换 | $(@bind ra_val Slider(20.0:5.0:100.0, default=50.0, show_value=true)) |
| 入射长波辐射 Rₗₙ (W m⁻²) | 大气向下长波辐射 | $(@bind Rln_val Slider(200.0:20.0:400.0, default=300.0, show_value=true)) |
| 土壤深度 L (m) | 模拟的土壤柱深度 | $(@bind L_val Slider(0.5:0.1:2.0, default=1.0, show_value=true)) |
| 土壤层数 N | 垂直离散层数（影响精度） | $(@bind N_val Slider(20:5:100, default=50, show_value=true)) |
| 模拟天数 days | 模拟的总时间 | $(@bind days_val Slider(1:1:7, default=2, show_value=true)) |
"""

# ╔═╡ 1b0020b4-b6b8-4c6d-b0f8-7fe31620410e
begin
  # 构建参数
  param = (
    κ=κ_val,
    Cv=Cv_val * 1e6,
    N=N_val,
    L=L_val,
    α=α_val,
    ε=ε_val,
    ra=ra_val,
    Rln=Rln_val,
    Δz=L_val / N_val
  )

  # 初始条件：均匀20°C
  u0 = fill(20.0, N_val)

  # 模拟时间
  tspan = (0.0, days_val * 86400.0)

  # 求解ODE
  prob = ODEProblem(heat_eq!, u0, tspan, param)
  sol = solve(prob, Tsit5(), saveat=1800)  # 每30分钟保存一次

  # 计算地表温度
  ts_surf = [solve_ts(u[1], t, param, param.Δz) for (u, t) in zip(sol.u, sol.t)]

  # 时间转换为小时
  tm = sol.t ./ 3600

  # 气温
  t_air = [cal_Tair(t) for t in sol.t]

  # 深度坐标（只依赖param，不依赖time_idx）
  depths = [(i - 0.5) * param.Δz for i in 1:N_val]
  nothing
end

# ╔═╡ f471b870-dc7c-430b-8408-e92889cfed10
md"""
**手动模式**：拖动滑块查看不同时刻

$(@bind time_idx Slider(1:length(sol.t), default=1, show_value=true))
"""

# ╔═╡ 13a45809-8648-4ff5-a3a3-271d9d8fc167
md"""
**自动播放**：勾选启动动画 $(@bind auto_play CheckBox(default=false))

$(@bind tick Clock(0.15, auto_play))
"""

# ╔═╡ c1b3ba10-d8ef-11f0-1fc6-5578e851560f
# 根据模式选择时间索引
final_idx = auto_play ? mod1(tick, length(sol.t)) : time_idx

# ╔═╡ 1ea137ba-ef8d-4ee8-b0bd-5432ba4ebda9
begin
   # 绘制时间序列：多个深度的温度演化
  depths_to_plot = [0.0, 0.1, 0.2, 0.5, 1.0]  # Depths to plot (m)

  p1 = plot(tm, t_air, label="Air T", ls=:dash, c=:blue, lw=2,
    xlabel="Time (h)", ylabel="Temperature (°C)",
    title="Soil Temperature Time Series", legend=:topright)
  plot!(p1, tm, ts_surf, label="Surface T", lw=2.5, c=:red)

  # Plot temperature at different depths
  colors = [:orange, :green, :purple, :brown]
  for (depth, color) in zip(depths_to_plot[2:end], colors)
    # Find the closest layer to target depth
    layer_idx = round(Int, depth / param.Δz + 0.5)
    layer_idx = clamp(layer_idx, 1, N_val)
    actual_depth = (layer_idx - 0.5) * param.Δz

    plot!(p1, tm, [u[layer_idx] for u in sol.u],
      label=@sprintf("z=%.2fm", actual_depth), lw=1.8, c=color, alpha=0.8)
  end

  # Add vertical line for current time
  vline!(p1, [tm[final_idx]], c=:gray, ls=:dot, lw=2, label="Current time")

  # 当前时刻的温度剖面
  T_profile = sol.u[final_idx]
  # xlims=(minimum(T_profile)-2, maximum([maximum(T_profile), ts_surf[time_idx]])+2)
  xlims = [10, 35]

  # 绘制温度剖面（深度向下为正，y轴取负值使得向下）
  p2 = plot(T_profile, -depths;
    xlabel="Temperature (°C)", ylabel="Depth (m)",
    label="Tsoil",
    title=@sprintf("Temperature Profile @ t=%.1fh", tm[final_idx]),
    lw=3, c=:darkred, marker=:circle, ms=3,
    legend=:bottomright, xlims)

  # 添加地表温度点（深度=0）
  scatter!(p2, [ts_surf[final_idx]], [0.0],
    label="Surface T", ms=10, c=:red, markershape=:star5)

  # 添加气温参考线
  vline!(p2, [t_air[final_idx]], ls=:dash, c=:blue,
    lw=2.5, alpha=0.6, label=@sprintf("Air T=%.1f°C", t_air[final_idx]))

  # 添加关键深度的参考线
  for depth in [0.1, 0.2, 0.5, 1.0]
    if depth <= L_val
      hline!(p1, [-depth], c=:gray, ls=:dot, lw=0.5, alpha=0.4, label="")
    end
  end

  # 网格
  plot!(p2, grid=true, gridstyle=:dot, gridalpha=0.3)

  plot(p1, p2, layout=(1, 2), size=(800, 350), left_margin=3Plots.mm, bottom_margin=3Plots.mm)
end

# ╔═╡ Cell order:
# ╟─a80a11a2-de01-4af8-a245-38952b98506a
# ╠═851dbe9f-0754-4e73-a89a-5988b39c86dc
# ╠═0f449991-4cb5-42fe-8f3d-c831d5fde6fb
# ╟─c7d531b3-4d2a-459e-a5f7-b9fe0c542a02
# ╟─916076a3-91f2-42ac-b782-bae82f5b871f
# ╠═1b0020b4-b6b8-4c6d-b0f8-7fe31620410e
# ╟─6be9d345-3066-4d1d-bfb1-c1eed8808332
# ╟─1ea137ba-ef8d-4ee8-b0bd-5432ba4ebda9
# ╟─f471b870-dc7c-430b-8408-e92889cfed10
# ╟─13a45809-8648-4ff5-a3a3-271d9d8fc167
# ╠═c1b3ba10-d8ef-11f0-1fc6-5578e851560f
