using NetCDFTools, Ipaper
using MakieLayers, GLMakie
using NaNStatistics

b = bbox(-180, -90, 180, 90)
lon, lat = bbox2dims(b; cellsize=1/120)
_dims_high = [
  NcDim("lon", lon), 
  NcDim("lat", lat)
]

lon, lat = bbox2dims(b; cellsize=1/10) # 重采样之后
A = Array{Float64}(undef, 43200, 21600); # create a container for reading data
obj_size(A)

var = "frac_sand"
prefix = "Dai2019_$var"

RES = []
for i = 1:6
  # f = "data/log_k_s_l$i"
  f = "X:/vf_sand_s_l$i"
  fout = "data/$(prefix)_l$i.nc"  

  @show f
  @time read!(f, A) # read data
  replace!(A, -1.0e36 => NaN) # replace NaN with 0
  # A = @. A # log10 -> value
  nc_write(fout, var, A, _dims_high)
  
  @time A2 = agg(A[:, :, 1:1]; fact=12, fun=nanmean)
  push!(RES, Float32.(A2[:, :, 1]))
end

x = 1:3
R = cat(RES..., dims=3);
imagesc(lon, lat, R)

# SoilGrids (0 - 0.05 m, 0.05 - 0.15 m, 0.15 - 0.30 m, 0.30 - 0.60 m, 0.60 - 1.00 m, and 1.00 - 2.00 m)
depths = [0.05, 0.15, 0.30, 0.60, 1.0, 2.0]
_dims = [
  NcDim("lon", lon),
  NcDim("lat", lat),
  NcDim("depth", depths),
]
nc_write("$prefix.nc", var, R, _dims)
