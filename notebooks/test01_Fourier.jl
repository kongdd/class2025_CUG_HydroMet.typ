using Plots, Test
gr(framestyle=:box)

function test_fourier(func; is_plot=true)
  N = 2^12 - 1
  P = 10.0 #
  Δt = P / N
  t = 0.0:Δt:(P-Δt)   # lenght(t) == N
  y = func.(t)
  ypred, info = Fourier(y, P)

  linewidth = 1
  if is_plot
    p = plot(t, y; legend=false, linewidth, xlim=(0, 0.1))
    plot!(p, t, ypred; linestyle=:dash, linewidth)
    display(p)
  end
  return info
end

# T = 2π / A
# f = 1 / T = A / 2π

# 三个高频信号：7Hz, 15Hz, 30Hz
func1(t) = sin(2π * 7 * t) + sin(2π * 15 * t) + sin(2π * 30 * t)

# 两个高频信号：60Hz, 120Hz
func2(t) = sin(2π * 60 * t) + 0.5 * sin(2π * 120 * t)

info = test_fourier(func2)
@test info.freq == [60.0, 120.0]  # 60Hz, 120Hz

info = test_fourier(func1)
@test info.freq == [15., 30., 7.0]  # 60Hz, 120Hz
