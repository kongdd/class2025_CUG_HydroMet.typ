anim = @animate for i in 1:2:length(sol.t)
  T_prof = sol.u[i]

  p = plot(T_prof, -depths,
    xlabel="Temperature (°C)", ylabel="Depth (m)",
    title=@sprintf("Temperature Profile @ t=%.1fh", tm[i]),
    lw=3, c=:darkred, marker=:circle, ms=3, label="Tsoil",
    legend=:bottomright, size=(700, 600), xlims=(10, 35))

  scatter!(p, [ts_surf[i]], [0.0], label="Surface T", ms=10, c=:red, markershape=:star5)
  vline!(p, [t_air[i]], ls=:dash, c=:blue, lw=2.5, alpha=0.6,
    label=@sprintf("Air T=%.1f°C", t_air[i]))

  scatter!(p, [t_air[i]], [0.1],
    label="Ta", ms=8, c=:blue, markershape=:diamond)


  for d in [0.1, 0.2, 0.5, 1.0]
    d <= L_val && hline!(p, [-d], c=:gray, ls=:dot, lw=0.5, alpha=0.4, label="")
  end

  plot!(p, grid=true, gridstyle=:dot, gridalpha=0.3)
end

# 保存为MP4（每秒10帧）
mp4(anim, "Figures/Tsoil_animation.mp4", fps=6)
