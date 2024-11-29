using RTableTools, Plots, Dates, Ipaper, NaNStatistics
import NetCDFTools: approx
import Ipaper: movmean
# gr(framestyle=:box)
pyplot()

approx(x::AbstractVector{DateTime}, y::AbstractVector, xout::AbstractVector{DateTime}) =
  approx(datetime2unix.(x), y, datetime2unix.(xout))

includet("main_Fourier.jl")

f = "./notebooks/SM_2019_sample_2sp.csv"
df = fread(f)

# J1193
## 筛选数据
inds = @.(df.site == "J1193" && df.depth == 10)
d = df[inds, [:time, :SM]]
d.time = DateTime.(d.time, "yyyy-mm-ddTHH:MM:SSZ")

xlims = DateTime(2019, 9, 1), DateTime(2019, 10, 10, 23)
itime = DateTime(2019, 9, 1) .<= d.time .<= DateTime(2019, 10, 10, 23)

# dat = d[itime, :]
# fwrite(dat, "SM_small.csv")
x = collect(xlims[1]:Hour(1):xlims[2])
y = approx(d.time, d.SM, x)
by = Date.(x)

ymin = agg_time(y, by; fun=nanminimum)
ymax = agg_time(y, by; fun=nanmaximum)
ET = ymax - ymin

y2 = movmean(y, 12)
A = y .- repeat(ymin, inner=24)

# A = y - y2
P = length(x)/24
ypred, info = Fourier(A, P; threshold=0.7, m=1)

## 可能存在下渗的影响
begin
  p1 = plot() # title="(a) ET signals (mm/h) detected from Soil Moisture"
  # 信号过强，有可能是土壤
  plot!(p1, x, A; size=(800, 400), label="ET_empirical")
  plot!(p1, x, ypred, label="ET_fourier (m=1)")

  plot(
    plot(x, y2, label="movmean(SM, 12)"),
    plot(x, repeat(ymin, inner=24), label = "SM_min"), 
    plot(x, y, label="SM"),
    plot(x, y - y2, label="SM - movmean(SM, 12)"),
    plot(x, y - repeat(ymin, inner=24), label="SM - SM_min"),
    p1
  )
end
