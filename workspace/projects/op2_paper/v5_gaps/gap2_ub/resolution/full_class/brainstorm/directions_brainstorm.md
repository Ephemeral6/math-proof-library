# Fixed-β SHB Last-Iterate: 15 方向发散思考

**问题回顾**：Fixed-β SHB 在 L-smooth convex non-SC 上的 last-iterate rate 数值上是 O(σD/√T)（18 cases T^{-0.50} rock solid），但所有 elementary route 失败，核心障碍是 r_{t-1} = f(y_{t-1}) - f* 的跨 iterate 耦合。

**本笔记目标**：纯方向性判断。对 15 个数学方向各做 connection / leverage / obstacle / prior work 评估，最后排序并推荐 top 3。

**关键 prior work 锚点**（贯穿后文引用）：
- **Li-Liu-Orabona 2022 (ALT, arXiv 2102.07002)**：Non-smooth Lipschitz convex 下 fixed-β SGDM 有 lower bound Ω(ln T/√T)，optimal 必须用 increasing momentum + FTRL。⚠️ 这是 non-smooth；L-smooth 情形 lower bound 是否仍然成立尚未明确。
- **arXiv 2510.02951 (2025-10)**："Long-Time Analysis of Stochastic Heavy Ball Dynamics for Convex Optimization and Monotone Equations" —— 最近、最相关。
- **Aujol-Dossal-Labarrière-Rondepierre 2024 (arXiv 2403.06930)**：HB on non-SC 需要 quadratic growth condition；纯 convex 不在覆盖范围。
- **arXiv 2307.11291**："Provable non-accelerations of HB" —— 在 non-SC convex 上 HB **不能**加速过 GD，即 O(1/√T) 是 best achievable，没有更好的目标。
- **Sebbouh-Gower-Defazio 2021**：almost sure o(1/√k)，但要 time-varying β（已被列入 failed routes）。
- **Liu-Yuan**：fixed-β SHB 在 convex 仅得 o(t^{-1/3+ε})，远差于 t^{-1/2}。

---

## 方向 1：控制论 / IQC（Integral Quadratic Constraints）

**Connection**：SHB 是二阶 LTI 系统 + memoryless nonlinear feedback（gradient）。Lessard-Recht-Packard 2016 的 IQC 框架已经把 GD/HB/Nesterov 全部 cast 成 robust control 问题，convergence rate 由 SDP/LMI 给出。

**Leverage**：Fazlyab-Ribeiro-Morari-Preciado 2018 (arXiv 1705.03615) 已经把 IQC 框架扩展到 **non-strongly-convex**，用 parameter-dependent non-quadratic Lyapunov + LMI 给出 subexponential rates。框架直接覆盖 SHB on smooth convex non-SC。

**Obstacle**：(a) IQC 给的是数值 LMI 解，不是 closed-form constant；要 closed-form O(σD/√T) 需要解析地解 LMI 族。(b) Stochastic 噪声进入 IQC 是另一道难题：标准 IQC 处理 deterministic feedback，stochastic SHB 需要把噪声作为 IQC multiplier 编码。(c) r_{t-1} 耦合在 IQC 框架下变成 lifted state，但 lifted Lyapunov 本质上还是 Lyapunov，不绕开根本矛盾。

**Prior work**：Lessard-Recht-Packard 2016 (SIOPT)、Fazlyab et al 2018 (SIOPT, non-SC 扩展)。**没有**找到针对 stochastic SHB last-iterate 的 IQC 工作。

**Verdict**：方向已开发，但 closed-form rate 提取困难，且 stochastic 维度未做。**优先级 = 中**。

---

## 方向 2：马尔可夫链 / Foster-Lyapunov

**Connection**：(y_t, y_{t-1}) 是 R^{2d} 上的 Markov chain。Foster-Lyapunov drift 给 geometric / subgeometric ergodicity。

**Leverage**：State-dependent Foster-Lyapunov criteria for **subgeometric** convergence（Douc-Fort-Moulines-Soulier 2009）能处理"不指数收敛"的情形，对应 non-SC（无谱隙）的情况。

**Obstacle**：(a) Convex non-SC 的 minimum 是平直的（无 strict drift towards center），Foster-Lyapunov 通常需要 small set 概念，但平直 objective 上 small set 不存在或非紧致，链可能 null recurrent。(b) Markov chain ergodicity 给的是分布收敛，不是 function value last-iterate；从 invariant measure 到 E[f(y_T) - f*] 需要额外 argument，且非 SC 下 invariant measure 可能不唯一或不存在。(c) σ²η 决定 stationary spread，与 last-iterate optimization gap 是不同的量。

**Prior work**：Hairer 2021 lecture notes; 没有专门把 SHB 当 Markov chain 来推 last-iterate optimization rate 的工作。

**Verdict**：理论框架不匹配（需要 SC 等价物），且 distributional convergence ≠ optimization gap。**优先级 = 低**。

---

## 方向 3：随机近似 / Two-timescale SA

**Connection**：SHB 可改写为 (y_t, m_t) 联合 update，其中 m_t = β m_{t-1} + (1-β)(-∇f(y_{t-1}) + noise)（适当 reparametrize）。两个变量在不同 timescale 上演化时，Borkar-Meyn 的 two-timescale SA 给 fast variable 跟踪 slow variable 的 quasi-static manifold。

**Leverage**：Karmakar-Bhatnagar 2018+ 在 GTD-with-momentum 上做了 three-timescale 分析（动量自身 = 第三 timescale）。如果 m_t 在 fast timescale 上 mix 到 quasi-stationary 分布 ≈ E[-∇f(y)] + noise，则 y_t 就退化为带 effective noise 的 SGD on slow timescale，套 SGD last-iterate（Jain-Nagaraj-Netrapalli 已知，已被 user 试过失败）就完事。

**Obstacle**：(a) 致命问题：SHB 是 **single-timescale**——fixed-β、fixed-η 下 m_t 和 y_t 在同一 timescale，没有 timescale 分离。要伪造 separation 需要让 β 极接近 1，但 β fixed 不能调整。(b) Even if separation work，two-timescale SA 通常给 asymptotic 收敛或 ODE limit，**rate 是 o(1) 而非 explicit constant**。(c) Liu-Yuan 已经走 SA 路线得到 o(t^{-1/3+ε})，差很多——这暗示纯 SA 视角不够 tight。

**Prior work**：Borkar-Meyn 2000；Karmakar-Bhatnagar 2018+；Liu-Yuan（SHB convex）。

**Verdict**：fixed-β 没有真正 timescale 分离，无法直接套；扩展到 explicit rate 难。**优先级 = 低**。

---

## 方向 4：ODE method（Su-Boyd-Candes / Wibisono-Wilson-Jordan）

**Connection**：SHB 离散迭代的 ODE 极限是 ẍ + (1-β)/η · ẋ + ∇f(x) = ξ(t)（damped driven oscillator + stochastic forcing）。Polyak ODE 在 SC 下是指数收敛，convex non-SC 下 ergodic O(1/t)。

**Leverage**：(a) 连续时间 Lyapunov 通常更干净，能告诉我们 last-iterate 在 ODE 上是什么 rate；(b) Discretization error analysis（Shi-Du-Jordan-Su，Wilson-Recht-Jordan）能把 ODE rate 转回 discrete。

**Obstacle**：(a) **致命**：deterministic HB ODE 在 convex non-SC 下 last-iterate 已知是 **non-monotone**——能量 V(x, ẋ) ergodic 衰减但 f(x(t)) 本身震荡（这是 inertial 系统的本质）。所以连续时间也没有 monotone Lyapunov，与离散面临同样矛盾，ODE 视角不解决根本矛盾。(b) 加 stochastic forcing 后变成 underdamped Langevin，rate 性质改变（见 #10）。(c) Discretization error 在 stochastic 下额外引入 σ²/T 项，可能掩盖真 rate。

**Prior work**：Aujol-Dossal-Rondepierre 2017+ 系列 deterministic HB ODE last-iterate；Su-Boyd-Candes 2014 (Nesterov)；arXiv 2403.06930 用 ODE Lyapunov 转 discrete（要 QG）。

**Verdict**：连续时间面临同样的 r_{t-1} 同构问题（速度耦合），不是 leverage 而是同构难题。**优先级 = 中-低**。

---

## 方向 5：Operator splitting / proximal point

**Connection**：尝试把 SHB 写成某种 splitting 的组合。

**Obstacle**：(a) SHB 是纯 forward gradient，不含任何 implicit/proximal 步；强行写成 forward-backward splitting 会让 backward 部分 = identity，退化。(b) Inertial proximal point (Alvarez-Attouch 2001) 跟 SHB 形式接近但是 proximal 不是 gradient——两者不等价。(c) Ryu-Boyd 2016 等 splitting last-iterate 工作通常要求 averaged 性质，gradient step 在 L-smooth 下 averaged 但 inertia 破坏 averagedness。

**Prior work**：Alvarez-Attouch 2001 (inertial PPA)；Ryu-Boyd 2016；与 #7 重叠。

**Verdict**：SHB 不是 splitting 形式，强行 cast 不自然。**优先级 = 低**。

---

## 方向 6：信息论 / 统计力学（Gibbs measure）

**Connection**：SHB + noise 长时间分布 = stationary distribution；类比 Langevin 收敛到 Gibbs measure ∝ exp(-f/T)。Last-iterate function value 和 temperature 有关。

**Obstacle**：(a) **致命**：convex non-SC 的 ∫ exp(-f/T) dx 可能 = ∞（无限远处 f 不增长足够），Gibbs measure **不存在**。(b) Even if exists（如加 box constraint），Gibbs measure 的 mode 在 minimizer，但 last-iterate value E[f(y_T)] 在 stationary state 下是 D · T（D 维），与 D · σ²η 量级匹配但不同——这给 floor，不给 rate。(c) Mixing rate ≠ optimization rate。

**Prior work**：Raginsky-Rakhlin-Telgarsky 2017 (SGLD non-convex)；Gao-Gürbüzbalaban-Zhu 2020（symmetric breaking SHB-Langevin）。

**Verdict**：non-SC 下 Gibbs measure 缺失，框架失灵。**优先级 = 低**。

---

## 方向 7：Krasnoselskii-Mann / 不动点理论

**Connection**：当 η ≤ 1/L 时，T_η(x) = x - η∇f(x) 是 **(1/2-)averaged operator**。SHB 形如 inertial fixed-point iteration：y_{t+1} = T_η(y_t) + β(y_t - y_{t-1})。这正是 inertial Krasnoselskii-Mann (iKM) 的标准形式。

**Leverage**：Mainge 2008、Bot-Csetnek 2015、Iutzeler-Hendrickx 2019、Maulen-Cisneros-Peypouquet 2024 (arXiv 2210.03791) 都给 iKM 的 fixed-point residual rate ‖y_{t+1} - T_η(y_t)‖² = o(1/k)。Maulen 2024 还给 weak convergence + non-asymptotic residual rate。Fast KM (SIAM J Numer Anal) 给 o(1/k) for fixed-point residual。

**Obstacle**：(a) 关键问题：fixed-point residual ‖y_{t+1} - T_η(y_t)‖² = o(1/k) 给的是 **gradient 范数**衰减（通过 ∇f(y_t) ≈ (y_t - y_{t+1})/η），不是 function value gap。从 ‖∇f(y_T)‖² → f(y_T) - f* 在 non-SC 下需要额外 PŁ 或 Bregman growth 假设——而这正好是 user 没有。(b) iKM 文献的 inertial 是 non-stationary（依赖 t 的 inertia），fixed-β 是 KM 的 **stationary inertia** 特例，rate 可能更松。(c) Stochastic iKM 的 last-iterate 文献稀少。

**Prior work**：Mainge 2008；Bot-Csetnek 2015；Maulen-Cisneros-Peypouquet 2024 (arXiv 2210.03791)；Fast KM (SIAM JNA, arXiv 22M1504305)；都是 deterministic。**没有**直接 stochastic + last-iterate function gap 的 iKM 工作。

**Verdict**：框架对，但残差 → function gap 的 conversion 在 non-SC 下需要额外 leverage。可能要配合 #15 supermartingale 或 smoothness 桥接。**优先级 = 高**。

---

## 方向 8：Bregman divergence / mirror descent

**Connection**：把分析中的 ‖y_t - x*‖² 换成 V(y_t, x*) Bregman，希望 r_{t-1} 项能通过适当 kernel 自然吸收到 V(y_t) - V(y_{t-1}) 的 telescope 中。

**Leverage**：理论上，正确选择 kernel 可让 momentum 项 = ⟨∇h(y_t) - ∇h(y_{t-1}), x*⟩ 这样的 dual 表达，可能 telescope。

**Obstacle**：(a) **致命**：SHB 的 update 是 **Euclidean** 形式 y_{t+1} = y_t - η∇f + β(y_t - y_{t-1})；换 Bregman 距离不改变 algorithm，只改变 analysis 中的距离度量。但 SHB 的 update 在 Bregman 几何下不是 mirror descent step，所以 Bregman 距离的 telescope 不天然成立。(b) 要让 Bregman 自然适应 SHB，本质上是改 algorithm（变成 mirror SHB），那是另一个问题。(c) 即便可行，r_{t-1} 来自 function value 而非 distance，换距离不改变 function 耦合。

**Prior work**：Tseng's APG with Bregman；mirror descent + heavy ball 工作存在但都是改 algorithm。

**Verdict**：换距离不解决 function 耦合。**优先级 = 低**。

---

## 方向 9：变分不等式 / 单调算子（Inertial monotone VI）

**Connection**：∇f 对 convex f 是 monotone operator。Convex optimization ⊂ monotone VI（用 ⟨∇f(y), y - x*⟩ ≥ f(y) - f*）。Inertial VI 方法（Csetnek-Malitsky-Tam, Bot-Csetnek-Hendrich 等）有完整 last-iterate rate 理论。

**Leverage**：(a) **arXiv 2510.02951 (2025-10) "Long-Time Analysis of Stochastic Heavy Ball Dynamics for Convex Optimization and Monotone Equations"** —— 标题直接命中 SHB on monotone equations，**最新工作**。这是 2025 年 10 月的论文，几乎肯定包含直接相关技术。需要立即读。(b) Cai-Daskalakis 2022 (arXiv 2204.09228)：tight last-iterate for extragradient/optimistic on monotone VI——给 last-iterate proof template。(c) Bot-Csetnek 系列工作处理 inertial forward-backward for monotone inclusions，给 last-iterate ‖y_t - y_{t+1}‖ 衰减率。(d) Malitsky-Tam reflected gradient 有 last-iterate 分析。

**Obstacle**：(a) Monotone VI 的 last-iterate 通常用 "operator residual" 而非 function value gap；从 residual 到 f-gap 在 non-SC 下需要桥接（同 #7）。(b) Stochastic monotone VI last-iterate 是更难的问题；deterministic 框架转 stochastic 通常额外 σ²/T 项，未必 tight。(c) Optimization 是 cocoercive monotone（特殊情况），inertial stochastic cocoercive 的 last-iterate 可能比 user 当前需要的更具体——arXiv 2510.02951 应该正好处理这个。

**Prior work**：**arXiv 2510.02951 (highest priority)**；Bot-Csetnek-Hendrich 2015+（inertial forward-backward）；Malitsky-Tam 2020 (reflected gradient)；Cai-Daskalakis 2022 (extragradient last-iterate)；Csetnek 系列。

**Verdict**：**最相关、最近、最有潜力**。arXiv 2510.02951 几乎肯定给出可直接用的 SHB monotone-equation last-iterate 技术。**优先级 = 最高**。

---

## 方向 10：SDE / Underdamped Langevin

**Connection**：SHB + Gaussian noise → underdamped Langevin dx = vdt, dv = -∇f(x)dt - γvdt + σdW。Cheng-Chatterji-Bartlett-Jordan 2018 给 underdamped Langevin O(1/√t) Wasserstein mixing。

**Leverage**：Underdamped Langevin 的 rate 已知，能否通过 (a) Euler-Maruyama discretization error analysis (b) Wasserstein → function value 的 transfer，把 mixing rate 转成 SHB last-iterate？

**Obstacle**：(a) **mixing rate ≠ optimization rate**：mixing 衡量 distribution 收敛到 stationary，stationary 是 Gibbs 不是 Dirac at minimum——所以 mixing rate O(1/√t) 不等于 E[f(y_T)] - f* 的 rate。(b) Non-SC 下 Gibbs measure 可能不存在（同 #6）。(c) Underdamped Langevin 通常要 SC（W2 contraction）。(d) Discretization error 在 non-SC 下 blow up。

**Prior work**：Cheng et al 2018；Dalalyan-Riou-Durand 2020；Gao-Gürbüzbalaban-Zhu 2020；arXiv 1805.01648 (Langevin nonconvex)。

**Verdict**：mixing 框架与 optimization rate 量纲不匹配。**优先级 = 低**。

---

## 方向 11：Chebyshev 加速

**Connection**：HB 最优 β = ((1-√(μ/L))/(1+√(μ/L)))² 来自 Chebyshev 多项式 minimax over [μ, L]。Chebyshev 在 operator spectrum 上有自然表述。

**Obstacle**：(a) **致命**：μ = 0 时（non-SC）Chebyshev 退化——区间 [0, L] 上 Chebyshev 多项式不能让 0 处的值为 0（恒过原点 = 0），且 √(μ/L) = 0 给 β = 1，与 fixed β < 1 不一致。(b) Chebyshev 加速本质上需要 spectral gap（μ > 0），non-SC 下没有。(c) 对 stochastic 噪声，Chebyshev 是 worst-case 加速，noise 项不在 framework 内。

**Prior work**：Heavy ball Chebyshev origin; arXiv 2307.11291 直接说 "Provable non-accelerations of HB" 在 non-SC 下——这正是 Chebyshev 退化的体现。

**Verdict**：理论上对，但 non-SC = Chebyshev 退化，框架失效。**优先级 = 低**。

---

## 方向 12：Online learning / Regret

**Connection**：SHB 对应 online gradient with momentum。online-to-batch conversion 把 regret bound 转 average iterate。

**Leverage**：Optimistic online gradient (Rakhlin-Sridharan 2013) 用 "predicted next gradient" 等价于 momentum——理论上 SHB ≈ optimistic OGD with constant prediction = 0。Optimistic OGD 在 monotone game 上有 last-iterate 收敛（Daskalakis-Panageas, Mokhtari-Ozdaglar-Pattathil）。

**Obstacle**：(a) **Li-Liu-Orabona 2022 已经走了这条路**：他们证明 fixed-β SGDM 在 non-smooth Lipschitz convex 下 last-iterate **必有** Ω(ln T/√T) lower bound，optimal 必须用 increasing momentum + FTRL。这强烈暗示 fixed-β 在 non-smooth case 下根本就 **suboptimal**。(b) ⚠️ **关键不确定性**：Li 2019 是 non-smooth Lipschitz convex；user 是 **L-smooth convex**——smooth 情形 lower bound 是否成立未知。如果 smooth 下 fixed-β 仍 suboptimal，那 user 数值看到的 T^{-0.50} 可能是有限-T 的 transient 或 hidden log factor。(c) Online-to-batch 给的是 average iterate，不是 last iterate。

**Prior work**：Li-Liu-Orabona 2022 (ALT)；Rakhlin-Sridharan 2013 (optimistic)；Daskalakis-Panageas 2018+；Cesa-Bianchi-Lugosi 2006 (online-to-batch)。

**Verdict**：(a) 此方向 partially explored 且给出 **lower bound 警示**——可能 fixed-β SHB 在 non-smooth case 下根本达不到 O(1/√T)，而 user 数值的 T^{-0.50} 在 smooth case 下成立但 elementary proof 失败可能是因为 **proof 方法本身需要利用 smoothness 突破 non-smooth lower bound**。(b) 该警示非常重要：**应该首先确认 Li 2019 lower bound 是否 transfer 到 L-smooth case**——如果 transfer，user 的 conjecture 错了；如果不 transfer，则 smoothness 本身是 essential leverage。**优先级 = 高（作为 sanity check）**。

---

## 方向 13：Hardy-Littlewood / 离散积分不等式

**Connection**：Cesàro O(1/√T) 给 (1/T) Σ_{t=1}^T (f(y_t) - f*)；离散 Hardy-Littlewood 不等式形如 max_t a_t ≤ C · max_t (1/t) Σ_{s≤t} a_s for monotone-like sequences。

**Leverage**：如果能证明 (f(y_t) - f*) 序列具有某种 quasi-monotonic 结构（例如 suffix average ≤ C · running gap），就能从 Cesàro 直接得到 last-iterate 同 rate。

**Obstacle**：(a) Hardy-Littlewood 离散版要求 sequence 是 maximal-function-like 的；SHB 的 f-gap 序列在 non-SC + momentum 下震荡严重（last-iterate 可能时大时小），quasi-monotone 不成立。(b) 这是 **战术工具**而非 **战略框架**——只能作为 "如果 X 性质成立，HL 给 last-iterate" 的 lemma，提供不了 X 性质本身。(c) 现有文献中 HL 与 optimization last-iterate 直接关联的工作几乎没有。

**Prior work**：Hardy-Littlewood 1934（Cesàro convergence in Hardy spaces）；现代版本散见于 ergodic theory；optimization 应用罕见。

**Verdict**：作为 tactical lemma 有用，但需要先解决 quasi-monotonicity；不是独立解决方向。**优先级 = 低（作为辅助工具）**。

---

## 方向 14：复分析 / z-transform

**Connection**：Linearized SHB transfer function H(z) = η/((1-z)(1-βz))；frequency response 给 convergence 行为。

**Obstacle**：(a) **致命**：z-transform 需要 LTI（linear time-invariant），但 SHB 的 ∇f 是 nonlinear gradient feedback——只在 quadratic f 下 z-transform 严格适用。(b) Quadratic 情形已经被 Anisotropic noise 论文 (OpenReview CIqjp9yTDq) 处理；general L-smooth convex 下 z-transform 给的是 local linearization rate，不是 global。(c) Stochastic noise 进入 H(z) 后变成 noise spectral density × |H(jω)|²，给 floor 而非 rate。

**Prior work**：Polyak 1964 原始 HB 分析（quadratic + spectral）；Lessard-Recht-Packard 2016 部分用了 frequency domain 概念。

**Verdict**：仅适用 quadratic，对 general convex 不行。**优先级 = 低**。

---

## 方向 15：Supermartingale-Lyapunov hybrid

**Connection**：定义 M_t = V(y_t, y_{t-1}) + UB_t；要求 E[M_{t+1} | F_t] ≤ M_t（条件 supermartingale）而非每步 deterministic 下降。Optional stopping → E[M_T] ≤ E[M_0]，倒推 E[V(y_T)] ≤ E[M_0] - UB_T。

**Leverage**：(a) Supermartingale 比 Lyapunov **更宽松**——允许某些步上升，只要条件期望不上升。这正好匹配 SHB momentum 引入的"短期 overshoot"。(b) Doob 不等式 + 选择 UB_t = c · √(σ²η · t) 形式可能容纳 r_{t-1} 项：让 r_{t-1} 进入 V 的二次项而非 UB 的累加项，避免 telescope 失败。(c) 已有 Sebbouh-Gower-Defazio 2021 用类似思想（但 time-varying β）；将其 supermartingale 结构抽取出来用 fixed-β 可能成立。(d) 已有 stopping rules for SGD via supermartingale (arXiv 2512.13123) 等先例。

**Obstacle**：(a) 找到正确的 V 仍然难——本质上还是 design Lyapunov 的工作。(b) 如果 V 选错，supermartingale 条件不成立，就回到 Lyapunov 失败。(c) Stochastic 部分的 cross term（r_{t-1} · noise）需要 careful conditional expectation handling。

**Prior work**：Stopping Rules for SGD via Anytime-Valid Confidence Sequences (arXiv 2512.13123)；Sebbouh-Gower-Defazio 2021；Liu-Yuan 2020 (a.s. SHB)；Robbins-Siegmund supermartingale convergence theorem (1971) —— 经典工具，常用于 SA 但很少直接用于 explicit rate。

**Verdict**：放宽 Lyapunov 是正确直觉；技术上要 design 正确的 V。**优先级 = 高**。

---

## 综合排序与 Top 3 推荐

### 排序原则

衡量四个维度：
1. **针对性**：是否直击 r_{t-1} 耦合根因
2. **可达性**：现有文献是否提供可直接 leverage 的工具
3. **新颖性**：是否为未尝试过的 angle
4. **风险**：是否有已知失败信号（如 Li 2019 lower bound）

### 完整排序

| 优先级 | 方向 | 一句话理由 |
|---|---|---|
| ★★★ | **#9 VI / Inertial monotone operator** | arXiv 2510.02951 (2025-10) 直接命中 SHB on monotone equations，最新最相关 |
| ★★★ | **#15 Supermartingale-Lyapunov** | 放宽 strict Lyapunov 是正确的直觉，匹配 SHB 的"震荡但条件下降" |
| ★★★ | **#7 Inertial Krasnoselskii-Mann** | 现成 iKM 框架给 fixed-point residual rate，需配 smoothness 桥接到 f-gap |
| ★★ | **#12 Online learning / Regret (作为 sanity check)** | Li-Orabona 2022 lower bound 给重要警示——必须先确认 smooth case 不被 lower bound 排除 |
| ★★ | **#1 Control / IQC** | 框架完备但 closed-form rate 提取困难，stochastic 维度未做 |
| ★★ | **#13 Hardy-Littlewood** | 战术工具，可作为辅助 lemma |
| ★ | **#3 Two-timescale SA** | fixed-β 没有真实 timescale 分离 |
| ★ | **#4 ODE method** | 连续时间面临同构问题 |
| ★ | **#10 SDE / Langevin** | mixing rate ≠ optimization rate |
| ★ | **#2 Markov chain** | non-SC 下 ergodicity 失效 |
| ✗ | #5 Operator splitting | SHB 不是 splitting 形式 |
| ✗ | #6 Statistical mechanics | non-SC 下 Gibbs measure 缺失 |
| ✗ | #8 Bregman | 换距离不解决 function 耦合 |
| ✗ | #11 Chebyshev | non-SC = Chebyshev 退化 |
| ✗ | #14 z-transform | 仅适用 quadratic |

### Top 3 推荐（值得深入的方向）

**🥇 第一推荐：#9 VI / Inertial monotone operator（arXiv 2510.02951 主攻）**

- **下一步**：立即获取 arXiv 2510.02951 全文。这是 2025-10 的论文，标题"Long-Time Analysis of Stochastic Heavy Ball Dynamics for Convex Optimization and Monotone Equations" 与 user 问题几乎完全吻合。
- **关键问题**：(a) 该论文是否处理 fixed-β？(b) 是否覆盖 last-iterate（不止 ergodic）？(c) 是否给 explicit O(σD/√T) rate？(d) 如果给 average，其技术能否 lift 到 last-iterate？
- **如果该论文已经解决问题**：直接 cite 并适配证明。
- **如果该论文未直接解决**：以其技术（forward-backward inertial for monotone equations）为基础 + cocoercivity (smooth convex 的等价物)，构造 last-iterate 论证。
- **风险**：未读不知道论文具体内容；但 standalone 的 Bot-Csetnek + Cai-Daskalakis 工具组合已足够强。

**🥈 第二推荐：#15 Supermartingale-Lyapunov hybrid**

- **下一步**：放弃寻找 strict deterministic Lyapunov，改为 design V(y_t, y_{t-1}, t) 使 M_t = V_t + ψ(t) 满足 E[M_{t+1} | F_t] ≤ M_t。允许 V_t 本身震荡。
- **关键 leverage**：(a) Robbins-Siegmund supermartingale convergence 可给 a.s. 收敛，配 Doob 给 rate；(b) 用 r_{t-1} 项进入 V 的 quadratic part（不进入 telescope sum），避免 ZG/Garrigos 风格的 weighted telescope 失败；(c) 把 noise term 作为 martingale increment，用 quadratic variation bound 控制累积。
- **具体试**：V_t = α‖y_t - x*‖² + β‖y_t - y_{t-1}‖² + γ(f(y_t) - f*)，调三个参数让 E[V_{t+1} | F_t] ≤ V_t - δ_t·[正项] + σ²η²·[bounded]，然后 sum 起来。
- **风险**：仍需设计 V；如果 V 形式不对又回到 Lyapunov 失败。但比 strict Lyapunov 多了一个自由度。

**🥉 第三推荐：#7 Inertial Krasnoselskii-Mann + smoothness 桥接**

- **下一步**：将 SHB 写成 iKM 形式 y_{t+1} = T_η(y_t) + β(y_t - y_{t-1})，其中 T_η = id - η∇f 是 averaged operator (η ≤ 1/L)。引用 Maulen-Cisneros-Peypouquet 2024 (arXiv 2210.03791) 给 ‖y_{t+1} - T_η(y_t)‖² ≤ C/t 的 fixed-point residual rate。
- **桥接 step**：在 L-smooth convex 下，f(y_t) - f* ≤ (L/2)‖y_t - x*‖² 是错的（需要 SC）；但有 f(y_t) - f* ≤ ⟨∇f(y_t), y_t - x*⟩ 和 ‖∇f(y_t)‖² ≤ 2L(f(y_t) - f*)。Residual 控制 ‖∇f(y_t)‖²，配合 ‖y_t - x*‖² 的独立 bound（来自 standard SGD-like 分析）就能 cross-bound f-gap。
- **关键**：smoothness 是必须 leverage 的元素；deterministic iKM 给的是几何性质 (averaged)，转 stochastic 加 σ² 项。
- **风险**：deterministic iKM → stochastic 的转化可能 lose 1/2 的 rate；fixed-β iKM 是 stationary inertia 的特例，rate 可能不 tight。

### 🛑 Critical sanity check（在投入任何 top 3 之前先做）

**先确认 Li-Liu-Orabona 2022 (arXiv 2102.07002) 的 Ω(ln T/√T) lower bound 是否 transfer 到 L-smooth case**：

- 如果 transfer：user 的 conjecture O(σD/√T) 在 worst case 是 **错的**（应该是 O(σD log T/√T)），数值 T^{-0.50} 是 transient。届时所有 elementary proof 失败可解释——根本就没有 fixed-β 的 O(σD/√T)。
- 如果不 transfer：smoothness 是 essential leverage，proof 必须显式用 ‖∇f‖² ≤ 2L(f - f*) 等 smooth-only 不等式。这指引应该先于其他方向。

具体怎么 check：阅读 Li-Liu-Orabona 2022 的 lower bound construction，看其反例是否 L-smooth 的。如果反例非 smooth，则 lower bound 不 transfer，user 的目标 rate 在 smooth case 仍可能是 O(σD/√T)。

---

## Sources

- [arXiv 2102.07002 — Li-Liu-Orabona, On the Last Iterate Convergence of Momentum Methods](https://arxiv.org/abs/2102.07002)
- [arXiv 2510.02951 — Long-Time Analysis of Stochastic Heavy Ball Dynamics for Convex Optimization and Monotone Equations](https://arxiv.org/html/2510.02951)
- [arXiv 2403.06930 — Aujol-Dossal-Labarrière-Rondepierre, Heavy Ball Momentum for Non-Strongly Convex Optimization](https://arxiv.org/abs/2403.06930)
- [arXiv 2307.11291 — Provable non-accelerations of the heavy-ball method](https://arxiv.org/html/2307.11291)
- [arXiv 1408.3595 — Lessard-Recht-Packard, Analysis and Design of Optimization Algorithms via IQC](https://arxiv.org/abs/1408.3595)
- [arXiv 1705.03615 — Fazlyab et al, IQC for non-strongly convex problems](https://arxiv.org/pdf/1705.03615)
- [arXiv 2210.03791 — Maulen-Cisneros-Peypouquet, Inertial Krasnoselskii-Mann Iterations](https://arxiv.org/abs/2210.03791)
- [arXiv 2204.09228 — Cai-Daskalakis, Tight Last-Iterate Convergence of Extragradient and Optimistic GDA](https://arxiv.org/abs/2204.09228)
- [arXiv 2006.07867 — Sebbouh-Gower-Defazio, Almost sure convergence rates for SGD and SHB](https://arxiv.org/abs/2006.07867)
- [arXiv 2312.08531 — Revisiting the Last-Iterate Convergence of Stochastic Gradient Methods](https://arxiv.org/abs/2312.08531)
- [arXiv 2512.13123 — Stopping Rules for SGD via Anytime-Valid Confidence Sequences](https://arxiv.org/html/2512.13123)
- [Cheng-Chatterji-Bartlett-Jordan, Underdamped Langevin MCMC convergence](https://proceedings.neurips.cc/paper/2020/file/cebd648f9146a6345d604ab093b02c73-Paper.pdf)
- [Convergence Rates of HB Method for Quasi-strongly Convex (SIAM J Opt)](https://epubs.siam.org/doi/10.1137/21M1403990)
- [Hairer 2021 — Convergence of Markov Processes lecture notes](https://www.hairer.org/notes/Convergence.pdf)
