pacman::p_load(
  Ipaper, data.table, dplyr, lubridate, hydroTools, 
  ggplot2, patchwork
)

Ta = -40:40
es = cal_es(Ta)
slope = cal_slope(Ta)


d = data.table(Ta, es, slope)

theme_set(
  theme_bw(base_size = 14) + 
  theme(
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_line(linewidth = 0.3, linetype = 2),
    axis.title = element_text(size = 15, face = "bold"),
    plot.margin = margin(t = 2, b = 2, l = 4, r = 4)
  )
)

xlab = expression("Ta" ~ "("*degree*C*")")

p1 <- ggplot(d, aes(Ta, es)) + 
  geom_line() + 
  labs(y = expression(e[sat]~"(kPa)"), x = xlab)

p2 <- ggplot(d, aes(Ta, slope)) +
  geom_line() + 
  labs(y = expression(Delta ~ "(kPa" ~ degree * C^-1 * ")"), x = xlab)
p <- p1 + p2

write_fig(p, './ch02_HydroMet_Variables/Figures/Figure1_es_slope.pdf', 10, 4)
