# Trajectory Decomposition Under Heavy-Tailed Gradients

## Source
- Self-generated research problem extending the SGD signal-noise trajectory decomposition framework (Hardt–Recht–Singer 2016; Bassily–Feldman–Guzman–Talwar 2020; Lei–Ying 2020) to heavy-tailed gradient settings (E ||grad L||^p < infty for p in (1,2), no second moment).
- Connections: Wang–Mao 2021, Vural et al. 2022 (heavy-tailed SGD minimax rate).
- Context: heavy-tailed gradients arise in robust regression, large-batch training of neural nets, and MDP-based RL with heavy-tailed reward.

## Statement

Let L(theta; z) be convex and differentiable in theta. Assume

  E_z [ ||grad L(theta; z)||^p ] <= G^p  for all theta, where p in (1, 2).

Run T-step SGD on the empirical loss L_S = (1/m) sum_i L(.; z_i) with sample-with-replacement and step size eta. Let theta_T be the (Polyak-Ruppert-averaged) iterate. Then there exist absolute constants C_p, C_p' depending only on p such that

  E[ |L(theta_T) - L_S(theta_T)| ]^p  <=  G_S^{(p)}(T)  +  G_N^{(p)}(T)

where

  G_S^{(p)}(T) = C_p  * ||grad L_S||_*^p * eta^p     * T^{p-1}     / m,
  G_N^{(p)}(T) = C_p' * G^p             * eta^{p/2} * T^{(p-2)/2} / m^{(2-p)/2}.

Furthermore, gradient clipping at threshold tau = G * T^{1/p - 1/2} balances the two terms (under Polyak-Ruppert averaging together with step size eta = c_p T^{(p-2)/(2p)} m^{(2-p)/(2p)}) and yields

  E[ |L(theta_T) - L_S(theta_T)| ]  <=  C_p'' * G * T^{1 - 1/p} / sqrt(m),

matching the known minimax rate.

## Difficulty
Research.
