"""
Transmissivity: T = d K, [m2/s]
"""
function cal_trans(wtd::FT, f::FT, klat) where {FT<:Real}
  f < 1e-6 && return FT(0)
  if wtd < -1.5
    T = f * klat * exp((wtd + 1.5) / f)
  else
    d1 = 1.5 + wtd
    T = klat * d1 + klat * f
  end
  return T
end



