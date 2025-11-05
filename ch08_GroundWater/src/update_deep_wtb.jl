function update_deep_wtb(imax, jmax, js, je, nzg, slz, dz, soiltxt, wtd, Q_bot, rech, qslat, qlat, landmask, dt, smoi, smoieq, θ_wtd, qsprings)
  deeprech = zeros(size(wtd))

  for j in js+1:je-1
    for i in 1:imax
      if landmask[i, j] == 1
        if wtd[i, j] < slz[1] - dz[1]
          nsoil = soiltxt[1, i, j]

          θ_mid = 0.5 * (θ_wtd[i, j] + θ_sat[nsoil])

          K = Ksat(nsoil) * (θ_mid / θ_sat[nsoil])^(2 * B(nsoil) + 3)
          ψ = ψsat[nsoil] * (θ_sat[nsoil] / θ_wtd[i, j])^B(nsoil)

          # 这里有错误，
          deeprech[i, j] = dt * K * ((ψsat[nsoil] - ψ) / (slz[1] - wtd[i, j]) - 1) # 漏了少了水

          newwgp = θ_wtd[i, j] + (deeprech[i, j] - Q_bot[i, j]) / (slz[1] - wtd[i, j])

          if newwgp < θ_cp(nsoil)
            deeprech[i, j] += (θ_cp(nsoil) - newwgp) * (slz[1] - wtd[i, j])
            newwgp = θ_cp(nsoil)
          end

          if newwgp > θ_sat[nsoil]
            deeprech[i, j] -= (θ_sat[nsoil] - newwgp) * (slz[1] - wtd[i, j])
            newwgp = θ_sat[nsoil]
          end
          θ_wtd[i, j] = newwgp
          rech[i, j] += deeprech[i, j] * 1e3
        end
      end
    end
  end

  Q_bot .= 0

  for j in js+1:je-1
    for i in 1:imax
      if landmask[i, j] == 1
        # if i == 300 && j == 300
        #   println("mirar qlat", qlat[i, j], qslat[i, j], wtd[i, j])
        # end
        totwater = qlat[i, j] - qslat[i, j] - deeprech[i, j]
        qspring = 0.0
        update_wtd(nzg, slz, dz, wtd[i, j], qspring, totwater, smoi[:, i, j], smoieq[:, i, j], soiltxt[:, i, j], θ_wtd[i, j])
        qsprings[i, j] += qspring * 1e3
      end
    end
  end

end
