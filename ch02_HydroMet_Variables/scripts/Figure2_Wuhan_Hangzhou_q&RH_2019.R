library(data.table)
library(magrittr)
library(ggplot2)
library(dplyr)

df <- fread('met_OBS_Wuhan_Hangzhou_1951-2020.csv')

df_plot <- 
  df %>% 
  .[year(date) == 2019] %>% 
  .[, .(site, name, date, RH, q)] %>% 
  melt(c('site', 'name', 'date')) %>% 
  mutate(
    longname = ifelse(variable == 'RH', 'Relative humidity (%)', 'Specific humidity (g/g)')
  )

for (var in unique(df_plot$variable)) {
  p <- df_plot %>% 
    .[variable == var] %>% 
    ggplot(aes(date, value)) +
    theme_bw() +
    geom_line() +
    ggh4x::facet_grid2(longname~name, scales = 'free', axes = 'y') +
    labs(x = 'Date', y = NULL)

  fout <- paste0('time_series_Wuhan_Hangzhou_', var, '_2019.jpg')
  ggsave(plot = p, filename = fout, dpi = 600, width = 10, height = 3)
}



# 双变量同时绘制
p <- df_plot  %>% 
  ggplot(aes(date, value)) +
  theme_bw() +
  geom_line() +
  ggh4x::facet_grid2(longname~name, scales = 'free', axes = 'y') +
  labs(x = 'Date', y = NULL)

fout <- 'time_series_Wuhan_Hangzhou_q&RH_2019.jpg'
ggsave(plot = p, filename = fout, dpi = 600, width = 10, height = 6)
