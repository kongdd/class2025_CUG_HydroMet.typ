#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")


*之前版本*

这里水面蒸发指的是：从水面到参考高度（一般指2m）的潜热通量，图中从点W到Y的过程。

$ lambda E [W -> X] = -H[W -> X] = (rho c_p D) / r_H $
$ lambda E [X -> Y] = (Delta R_n) / (Delta + gamma^*) $
$ lambda E [Y -> Z] = -H[Y -> Z] = -(rho c_p D_0) / r_H $

$W -> Z$，对应的蒸发面水汽不饱和，该过程总的潜热和感热为：

$ lambda E [W -> Z] = (Delta R_n) / (Delta + gamma^*) + (rho c_p (D - D_0)) / r_H $

$
  H [W -> Z] = & R_n - lambda E [W -> Z] \
             = & (gamma^* R_n) / (Delta + gamma^*) - (rho c_p (D - D_0)) / r_H
$

若蒸发面水汽饱和（充分供水），则是$W -> Y$过程：

$ lambda E [W -> Y] = (Delta R_n) / (Delta + gamma^*) + (rho c_p D) / r_H $ <ch3_eq37>
