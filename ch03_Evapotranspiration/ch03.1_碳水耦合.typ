#import "@local/modern-cug-report:0.1.3": *

#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸散发的基本原理")

= 蒸散发的基本原理

#mitex(`$$
A_g=\frac{A_m \alpha \ln C_a}{A_m \alpha I+A_m \eta C_a+\alpha \ln C_a}
$$`) <eq_Ag>

$
 A_g = (A_m alpha ln C_a) /  (A_m alpha I + A_m eta C_a + alpha ln C_a)
$

$
  "GPP" = integral_0^"LAI" d l
$

如式#[@eq_Ag]，
