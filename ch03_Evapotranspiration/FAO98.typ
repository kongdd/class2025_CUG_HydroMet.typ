#import "@local/modern-cug-report:0.1.3": *
#import "@preview/physica:0.9.7": *

#show: doc => template(doc, footer: "CUG水文气象学2025", header: "FAO98 Penman-Monteith 计算示例")
#set par(spacing: 1.2em, leading: 1em)

= Penman-Monteith 草地蒸发计算示例

== 1 Penman-Monteith 1965 原始公式

Monteith (1965) 在 Penman (1948) 的基础上，引入了表面阻力 $r_s$，得到 Penman-Monteith 公式：

$ lambda E = frac(Delta (R_n - G) + rho c_p "VPD" \/ r_H, Delta + gamma (1 + r_s \/ r_H)) $ <eq_pm1965>

其中：
- $lambda E$: 潜热通量，单位 $W\/m^2$
- $Delta$: 饱和水汽压曲线斜率，单位 $"kPa"\/℃$
- $R_n - G$: 可用能量，单位 $W\/m^2$
- $rho c_p$: 空气体积热容，$rho approx 1.2 "kg/m"^3$，$c_p = 1013 J\/("kg" ℃)$
- $"VPD" = e_s - e_a$: 饱和水汽压差，单位 $"kPa"$
- $gamma$: 湿度计常数，单位 $"kPa"\/℃$
- $r_H$: *空气动力学阻力*，单位 $s\/m$
- $r_s$: *表面阻力*（冠层阻力），单位 $s\/m$

== 2 空气动力学阻力 $r_H$ 的计算

=== 2.1 理论推导

空气动力学阻力描述了从蒸发表面到参考高度之间热量和水汽传递的阻力。根据 Monin-Obukhov 相似理论，在中性大气条件下：

$ r_H = frac(ln frac(z_m - d, z_"om") dot ln frac(z_h - d, z_"oh"), k^2 u_z) $ <eq_rH>

其中：
- $z_m$: 风速测量高度，通常为 2 m
- $z_h$: 温度和湿度测量高度，通常为 2 m
- $d$: 零平面位移，$d = 2\/3 h$（$h$ 为植被高度）
- $z_"om"$: 动量传递粗糙度长度，$z_"om" = 0.123 h$
- $z_"oh"$: 热量传递粗糙度长度，$z_"oh" = 0.1 z_"om"$
- $k$: von Kármán 常数，$k = 0.41$
- $u_z$: 测量高度处风速，单位 $m\/s$

=== 2.2 FAO-98 草地参数

对于 FAO-98 定义的参考作物（假想草地），参数如下：

#figure(
  table(
    columns: (2fr, 1.5fr, 2fr),
    align: (left, center, left),
    table.header([*参数*], [*数值*], [*说明*]),
    [植被高度 $h$], [0.12 m], [假想草地高度],
    [零平面位移 $d$], [$2\/3 times 0.12 = 0.08$ m], [$d = 2\/3 h$],
    [动量粗糙度 $z_"om"$], [$0.123 times 0.12 = 0.0148$ m], [$z_"om" = 0.123 h$],
    [热量粗糙度 $z_"oh"$], [$0.1 times 0.0148 = 0.00148$ m], [$z_"oh" = 0.1 z_"om"$],
    [表面阻力 $r_s$], [70 s/m], [固定值],
    [反射率], [0.23], [固定值],
  ),
  caption: [FAO-98 参考作物参数],
) <tbl_fao_param>

=== 2.3 $r_H$ 的计算示例

代入 FAO-98 草地参数到式 @eq_rH（$z_m = z_h = 2$ m）：

$
  r_H & = frac(ln frac(2 - 0.08, 0.0148) times ln frac(2 - 0.08, 0.00148), 0.41^2 times u_2) \
      & = frac(ln(129.7) times ln(1297), 0.168 times u_2) \
      & = frac(4.87 times 7.17, 0.168 times u_2) \
      & = frac(208, u_2) approx frac(208, u_2) " s/m"
$

#box-blue()[
  *关键结论*：对于 FAO-98 参考作物，$r_H approx 208 \/ u_2$ (s/m)
]

== 3 从 PM-1965 到 FAO-98 公式

=== 3.1 单位转换

将式 @eq_pm1965 转换为日蒸散发量 $"ET"_0$ (mm/day)：

$ "ET"_0 = frac(lambda E times 86400, lambda times 1000) = frac(lambda E times 86400, 2.45 times 10^6) $

其中 $lambda = 2.45 "MJ/kg"$ 为汽化潜热。

=== 3.2 代入 $r_H$ 与 $r_s$

将 $r_H = 208\/u_2$ 和 $r_s = 70$ 代入式 @eq_pm1965：

$
  1 + r_s / r_H = 1 + frac(70, 208\/u_2) = 1 + frac(70 u_2, 208) = 1 + 0.34 u_2
$

空气动力学项：
$
  frac(rho c_p "VPD", r_H) & = frac(1.2 times 1013 times "VPD", 208\/u_2) \
                           & = frac(1216 times u_2 times "VPD", 208) = 5.85 u_2 "VPD"
$

=== 3.3 最终形式

经过单位转换和整理，得到 FAO-98 公式：

$
  "ET"_0 = frac(0.408 Delta (R_n - G) + gamma frac(900, T + 273) u_2 (e_s - e_a), Delta + gamma (1 + 0.34 u_2))
$ <eq_fao98>

#box-red()[
  *关键系数来源*：
  - *0.408*：能量转换因子，$1\/lambda = 1\/2.45 approx 0.408$
  - *900*：$frac(rho c_p times 86400, lambda) times frac(1, 208) approx 900$ (考虑理想气体定律的温度修正)
  - *0.34*：$r_s \/ 208 = 70\/208 approx 0.34$
]

== 4 计算示例

=== 4.1 给定气象数据

#figure(
  table(
    columns: (2fr, 1.5fr, 1fr),
    align: (left, center, center),
    table.header([*参数*], [*数值*], [*单位*]),
    [日平均气温 $T$], [25], [$℃$],
    [最高气温 $T_"max"$], [32], [$℃$],
    [最低气温 $T_"min"$], [18], [$℃$],
    [相对湿度 $"RH"$], [60], [$%$],
    [净辐射 $R_n$], [15], [$"MJ" m^(-2) d^(-1)$],
    [2m风速 $u_2$], [2.0], [$m\/s$],
    [海拔高度 $z$], [100], [$m$],
  ),
  caption: [气象观测数据],
) <tbl_data>

=== 4.2 计算 $r_H$

$ r_H = frac(208, u_2) = frac(208, 2.0) = 104 " s/m" $

=== 4.3 中间变量

$
      P & = 101.3 lr((frac(293 - 0.0065 times 100, 293)))^5.26 = 100.1 " kPa" \
  gamma & = 0.665 times 10^(-3) times 100.1 = 0.0666 " kPa/℃" \
    e_s & = frac(4.76 + 2.06, 2) = 3.41 " kPa", quad e_a = 3.41 times 0.6 = 2.05 " kPa" \
  Delta & = frac(4098 times 3.17, (25 + 237.3)^2) = 0.189 " kPa/℃"
$

=== 4.4 代入 FAO-98 公式

$
  "ET"_0 &= frac(0.408 times 0.189 times 15 + 0.0666 times frac(900, 298) times 2.0 times 1.36, 0.189 + 0.0666 times (1 + 0.34 times 2.0)) \
  &= frac(1.158 + 0.547, 0.301) = 5.66 " mm/day"
$

== 5 课堂思考

#beamer-block()[
  1. 为什么 $r_H$ 与风速 $u_2$ 成反比？
  2. 如果植被高度从 0.12 m 变为 1 m（如玉米），$r_H$ 会如何变化？
  3. 表面阻力 $r_s = 70 " s/m"$ 是如何确定的？与气孔导度有何关系？
]

== 6 Python 验证代码

```python
import numpy as np

# 植被参数 (FAO-98 草地)
h = 0.12       # 植被高度 (m)
d = 2/3 * h    # 零平面位移
z_om = 0.123 * h  # 动量粗糙度
z_oh = 0.1 * z_om  # 热量粗糙度
rs = 70        # 表面阻力 (s/m)
k = 0.41       # von Kármán 常数

# 气象参数
T, Tmax, Tmin = 25, 32, 18
RH, Rn, u2, z = 60, 15, 2.0, 100

# 计算 rH
z_m = z_h = 2  # 测量高度
rH = np.log((z_m - d) / z_om) * np.log((z_h - d) / z_oh) / (k**2 * u2)
print(f"rH = {rH:.1f} s/m")  # rH ≈ 104 s/m

# 验证 FAO-98 系数
print(f"1 + rs/rH = {1 + rs/rH:.2f}")  # ≈ 1.67 = 1 + 0.34*2

# 完整 ET0 计算
P = 101.3 * ((293 - 0.0065 * z) / 293) ** 5.26
gamma = 0.665e-3 * P
es = (0.6108 * np.exp(17.27*Tmax/(Tmax+237.3)) +
      0.6108 * np.exp(17.27*Tmin/(Tmin+237.3))) / 2
ea = es * RH / 100
delta = 4098 * 0.6108 * np.exp(17.27*T/(T+237.3)) / (T+237.3)**2

ET0 = (0.408*delta*Rn + gamma*900/(T+273)*u2*(es-ea)) / \
      (delta + gamma*(1 + 0.34*u2))
print(f"ET0 = {ET0:.2f} mm/day")  # ET0 = 5.66 mm/day
```
