# Strategy Index — Layer 1 Knowledge Reuse

This file is consumed by the Explorer agent **before** starting any new proof attempt. The Explorer extracts problem features (algorithm type, function class, target quantity, setting, iterate type) from the problem statement, greps this index for matching feature combinations, and pulls the matched signature(s). It then attempts **slot-filling**: instantiating the matched `meta_template` and `technique_chain` against the new problem, treating the `key_insight` as a candidate proof skeleton. If multiple signatures match, the Explorer ranks by feature-overlap count and tries them in order. The `Vocabulary Index` at the end documents the controlled vocabulary so the Explorer knows the exact strings to grep for.

---

# Optimization / Convergence

## Strategy Signature: npg-softmax-tabular-convergence

### Problem Features (input)
- algorithm_type: NPG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: performance_difference_lemma → NPG_as_KL_mirror_descent → Bregman_three_point + Donsker_Varadhan → KL_terms_cancel → telescope + monotone_improvement
- key_insight: The +KL(π_{k+1}||π_k) term from Hoeffding/Donsker–Varadhan exactly cancels the −KL(π_{k+1}||π_k) term from the Bregman three-point identity, requiring both bounds be written in the same units.
- proof_length: medium

### Retrieval Tags
NPG, mirror-descent, KL-cancellation, Donsker-Varadhan, policy-gradient

---

## Strategy Signature: entropy-regularized-value-iteration

### Problem Features (input)
- algorithm_type: k-step-spectral
- function_class: contraction
- target_quantity: approximation_rate
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: fixed_point_contraction
- technique_chain: LSE_1_Lipschitz_in_ell_inf → Banach_fixed_point → variational_form_of_LSE → sandwich_T_tau_V_between_TV_and_TV+τlogA → monotonicity_sub/super_fixed_point
- key_insight: LSE is exactly 1-Lipschitz in ℓ∞ with the 1/τ inside scaling cancelling τ outside, preserving the γ-contraction modulus independent of τ.
- proof_length: short

### Retrieval Tags
LSE, contraction, MaxEnt-RL, fixed-point, soft-Bellman

---

## Strategy Signature: sgd-last-iterate-averaged-baseline

### Problem Features (input)
- algorithm_type: SGD
- function_class: smooth_convex
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: descent_lemma_telescope
- technique_chain: projection_nonexpansive → subgradient_inequality → martingale_decomposition g=s+ξ → telescope δ_t² → Jensen → constant_horizon_aware_step η=D/(G√T)
- key_insight: Switching from η_t=c/√t to constant η=D/(G√T) makes Σ η_t²=O(1) instead of O(log T), eliminating the spurious log-factor.
- proof_length: short

### Retrieval Tags
SGD, averaging, constant-step, harmonic-sum, baseline

---

## Strategy Signature: heavy-ball-instability

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: lower_bound
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: scheme_dependent_construction
- technique_chain: decoupled_diagonal_quadratics → 2x2_companion_matrix_eigenvalues → discriminant_zero_Jordan_block → ln_cosh_curvature_transition_construction → period_4_limit_cycle_Jacobian_verification
- key_insight: Construct f(x)=(L/2)x² − (L−μ)ln cosh(x) so f''(0)=μ and f''(∞)=L; momentum tuned to global κ overshoots the low-curvature center and enters a stable period-4 cycle.
- proof_length: long

### Retrieval Tags
heavy-ball, counterexample, ln-cosh, limit-cycle, curvature-transition

---

## Strategy Signature: sam-convergence-flat-minima

### Problem Features (input)
- algorithm_type: SAM
- function_class: non-convex
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: best

### Strategy Used (output)
- meta_template: descent_lemma_telescope
- technique_chain: descent_lemma_L_smoothness → Danskin_for_∇f^SAM → Young_on_inner_product → ‖g_t−∇f^SAM‖≤2Lρ → telescope → diminishing_radius ρ=ρ_0/√T
- key_insight: The SAM update uses ρ·∇f(x)/‖∇f(x)‖ as an O(2ρ)-approximation of the true δ*(x); L-smoothness translates this to ‖g_t − ∇f^SAM‖ ≤ 2Lρ, which bounds the bias.
- proof_length: medium

### Retrieval Tags
SAM, Danskin, flat-minima, biased-gradient, normalized-gradient

---

## Strategy Signature: lookahead-optimizer-convergence

### Problem Features (input)
- algorithm_type: Lookahead
- function_class: smooth_SC
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: spectral_eigenvalue
- technique_chain: diagonalize_quadratic → polynomial_in_symmetric_matrix → scalar_contraction_m(λ)=1−α(1−(1−ηλ)^k) → unroll_inner_loop_noise → equivalent_single_step_comparison
- key_insight: On quadratics the outer Lookahead step M=(1−α)I+α(I−ηA)^k is a polynomial in symmetric A, so spectral radius equals operator norm; variance reduction factors into α² (interpolation) × 1/k (step-splitting).
- proof_length: short

### Retrieval Tags
Lookahead, spectral-radius, variance-reduction, inner-loop, polynomial-in-matrix

---

## Strategy Signature: synchronous-q-learning-finite-time

### Problem Features (input)
- algorithm_type: Q-learning-tabular
- function_class: contraction
- target_quantity: sample_complexity
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: couple_track
- technique_chain: Bellman_γ_contraction → polynomial_lr α_t=(H+1)/(H+t) → bias/variance/coupling_decomposition → linearization Δ_t=L_t+R_t → Azuma_Hoeffding_entrywise + union_bound
- key_insight: Linearize Δ_t=L_t+R_t where L_t is a clean MDS (martingale concentrates entry-wise) and R_t is a deterministic coupling residual bounded by O(γ e_t) — decouples random part from nonlinear part.
- proof_length: long

### Retrieval Tags
Q-learning, linearize-couple, MDS, polynomial-step, entry-wise-Azuma

---

## Strategy Signature: ogda-bilinear-last-iterate

### Problem Features (input)
- algorithm_type: OGDA
- function_class: saddle-point
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: reformulate_as_skew_symmetric_fixed_point → expand ‖z_{t+1}‖² + skew_symmetry_zeros_⟨z,F(z)⟩ → polarization → telescope_identity_E → weighted_sum_to_last_iterate
- key_insight: Identity ‖z_{t+1}‖²=‖z_t‖²+‖δ_{t+1}−δ_t‖²−‖δ_t‖² emerges from substituting F(z_t)=−δ_{t+1}/η−F(δ_t) so the skew-symmetric cross term collapses into clean polarization.
- proof_length: medium

### Retrieval Tags
OGDA, bilinear, skew-symmetry, polarization, last-iterate

---

## Strategy Signature: td0-linear-function-approximation-convergence

### Problem Features (input)
- algorithm_type: TD(0)
- function_class: non-symmetric-linear
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: decompose A=A_s+A_anti → stationary_Cauchy_Schwarz → MSE_recursion v_{t+1}≤(1−2αμ+α²L²)v_t+α²σ² → Lyapunov w_t=(c+t)v_t with invariant W=4c²σ²/ρ
- key_insight: A=E[φ(s)(φ(s)−γφ(s'))^T] has positive symmetric part A_s≥(1−γ)Φ^T D_π Φ via stationary-distribution Cauchy-Schwarz, giving a contractive direction even though A is non-symmetric.
- proof_length: medium

### Retrieval Tags
TD-learning, symmetric-part, semi-gradient, MSE-Lyapunov, stochastic-approximation

---

## Strategy Signature: entropy-regularized-npg-linear-convergence

### Problem Features (input)
- algorithm_type: NPG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: NPG_as_mirror_descent → soft_Bellman_γ_contraction → centered_seminorm ‖ξ‖_c gauge_invariant → Lyapunov Φ=‖Δ‖_∞+C‖ξ‖_c → small_error_regime_induction
- key_insight: Replace ‖logπ−logπ*‖_∞ with the gauge-invariant centered seminorm ‖ξ‖_c=½ sup_s(max_a−min_a) so the state-only normalizer term G^k(s) cancels automatically.
- proof_length: medium

### Retrieval Tags
entropy-NPG, gauge-invariance, centered-seminorm, soft-Bellman, Lyapunov

---

## Strategy Signature: gda-nonconvex-strongly-concave-convergence

### Problem Features (input)
- algorithm_type: GDA
- function_class: non-convex-strongly-concave
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: Danskin_for_envelope_Φ → κ_Lipschitz_y* → Φ_smoothness=2κL → Nesterov_co_coercivity_y_step → Lyapunov V_t=Φ(x_t)+cδ_t with c=L/(4κ)
- key_insight: Two-time-scale Lyapunov V=Φ+cδ pays for y-tracking error; weight c=L/(4κ) is small enough x-descent dominates yet large enough y-contraction kills tracking error.
- proof_length: medium

### Retrieval Tags
GDA, two-time-scale, Danskin, envelope, minimax

---

## Strategy Signature: softmax-pg-sublinear-convergence

### Problem Features (input)
- algorithm_type: NPG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: policy_gradient_theorem → performance_difference_lemma → smoothness β=8/(1−γ)³ → sign_robust_Cauchy_Schwarz_NU_Lojasiewicz → finite_hitting_time c_∞>0 → harmonic_recursion
- key_insight: Non-uniform Łojasiewicz inequality with constant c*=min_s π(a*(s)|s) requires standing hypothesis c_∞=inf_t c*^(t)>0, proved via finite-hitting-time argument that softmax cannot collapse the optimal-action probability.
- proof_length: long

### Retrieval Tags
softmax-PG, non-uniform-Lojasiewicz, harmonic-decay, sign-robust, hitting-time

---

## Strategy Signature: q-learning-ucb-hoeffding-regret

### Problem Features (input)
- algorithm_type: Q-learning-UCB
- function_class: contraction
- target_quantity: regret_bound
- setting: online_adversarial
- iterate_type: N/A

### Strategy Used (output)
- meta_template: descent_lemma_telescope
- technique_chain: recursive_Q_error_expansion → Azuma_Hoeffding_weighted_MDS → UCB_bonus b_t=cH^{3/2}√(ι/t) → per_episode_decomposition δ_h^k≤φ+ξ+δ_{h+1}^k → learning_rate_identities_L1_to_L4 → visit_count_exchange
- key_insight: Step size α_t=(H+1)/(H+t) gives Σ_t α^i_t=1+1/H exactly, so layer-wise contraction (1+1/H) exponentiates to e — visit-count exchange yields √(H^4 SAT).
- proof_length: long

### Retrieval Tags
Q-learning-UCB, learning-rate-identity, visit-count-exchange, layer-wise, regret

---

## Strategy Signature: svrg-non-sc-last-iterate-gap

### Problem Features (input)
- algorithm_type: SVRG
- function_class: smooth_convex
- target_quantity: lower_bound
- setting: stochastic_finite_sum
- iterate_type: last

### Strategy Used (output)
- meta_template: scheme_dependent_construction
- technique_chain: SVRG_variance_bound_Reddi → epoch_inequality → snapshot_rate_reference → HLL_R_last_iterate_vs_average_blackbox → Huber_with_decoupled_c_i_hard_instance
- key_insight: Inside an epoch, SVRG's inner loop is exactly non-SC SGD with bounded variance; hard instance f_i(x)=(L/2)(x−b_i)_+²+(L/2)(c_i−x)_+² adds persistent variance independent of x_t−x̃_s so HLL-R log m gap activates.
- proof_length: medium

### Retrieval Tags
SVRG, last-iterate-gap, log-m, Huber, variance-reduction-resistant

---

## Strategy Signature: polyak-ruppert-shb-defeats-cycling

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_convex
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: Polyak_Ruppert

### Strategy Used (output)
- meta_template: spectral_eigenvalue
- technique_chain: complexify ℝ²≅ℂ → arithmetico_geometric_sum Σ t·ω^t → triangle_inequality_on_closed_form → L_smoothness_quadratic_bound → numerical_sharpness
- key_insight: For 2D K-gon cycling instance, complexification e_t↔ω^t turns Σ t·e_t into Σ t·ω^t with closed-form |Σ|=O(T) while denominator W_T=Θ(T²), giving ‖x̃_T‖=O(1/T) and f-gap=O(1/T²).
- proof_length: medium

### Retrieval Tags
SHB, Polyak-Ruppert, complexification, Fourier-cancellation, K-gon

---

# Optimization / Stochastic

## Strategy Signature: sps-sgd-convergence

### Problem Features (input)
- algorithm_type: SGD
- function_class: interpolation
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: squared_distance_expansion → convexity_inner_product + interpolation_f_i*=0 → smoothness_‖∇f_i‖²≤2Lf_i → SPS_substitution_makes_γ²‖g‖²=γ·f_i/c → telescope + Jensen
- key_insight: SPS step γ_k=f_i(x_k)/(c‖∇f_i‖²) self-tunes so γ_k²‖g‖²=γ_k·f_i/c, automatically cancelling the quadratic penalty against the descent term — no a-priori smoothness needed.
- proof_length: short

### Retrieval Tags
SPS, Polyak-step, interpolation, self-tuning, automatic-cancellation

---

## Strategy Signature: clipped-sgd-heavy-tail

### Problem Features (input)
- algorithm_type: SGD
- function_class: non-convex
- target_quantity: convergence_rate
- setting: heavy_tailed
- iterate_type: best

### Strategy Used (output)
- meta_template: OTHER:surrogate_then_recover
- technique_chain: smoothness_descent → clipping_bias_decomposition → surrogate φ_t=min(‖∇‖²,τ‖∇‖) + Young + case_split → two_stage_telescope → tune τ=σT^{1/p−1/2}, η=√(Δ/L)/(τ√T)
- key_insight: Replace target ‖∇_t‖² with truncated surrogate φ_t that the clipped-step controls for free; recover the excess ‖∇_t‖(‖∇_t‖−τ)_+ via separate telescope which only fires when τ≥2σ.
- proof_length: long

### Retrieval Tags
clipping, heavy-tail, p-th-moment, surrogate, two-stage-telescope

---

## Strategy Signature: sgd-pl-interpolation-averaging

### Problem Features (input)
- algorithm_type: SGD
- function_class: PL
- target_quantity: convergence_rate
- setting: interpolation
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: smoothness_descent + strong_growth → PL ‖∇f‖²≥2μ(f−f*) → one_step α_t=1−2μγ_t+ρLμγ_t² → quadratic_induction e_t≤t_0²/(t+t_0)²·e_0 → integral_comparison Σ1/(t+t_0)²≤2/t_0
- key_insight: Under interpolation+strong-growth+PL with γ_t=2/(μ(t+t_0)), variance is multiplicative (∝‖∇f‖²) so the recursion supports the quadratic ansatz e_t≤C/(t+t_0)² instead of the usual O(1/t).
- proof_length: medium

### Retrieval Tags
PL, interpolation, quadratic-induction, multiplicative-noise, averaging

---

## Strategy Signature: momentum-sgd-interpolation-perron-frobenius

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: convergence_rate
- setting: interpolation
- iterate_type: last

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: per_component_co_coercivity + interpolation → squared_distance + 2x2_matrix_recursion (E[‖x−x*‖²], E[‖γv‖²]) → Young_with_p1=γμ/β,p2=1 → Perron_Frobenius_positive_eigenvector (1, 1/κ²) → tune β=1/(4κ²),γ=1/(2Lκ)
- key_insight: Set up 2×2 recursion in scaled coordinates s=γv, certify spectral radius<1 via positive Lyapunov vector (1, c=1/κ²) — Perron-Frobenius avoids explicit eigenvalue computation.
- proof_length: medium

### Retrieval Tags
heavy-ball-momentum, interpolation, Perron-Frobenius, joint-Lyapunov, scaled-coords

---

## Strategy Signature: momentum-sgd-interpolation-alpha-split-quarter-L

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: convergence_rate
- setting: interpolation
- iterate_type: last

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: per_component_co_coercivity → α_split (1−α)·co_coercivity + α·strong_convexity → joint_Lyapunov ‖e‖²+γ²‖v‖² → variance_term_A_S=4γ²−γ/L=0 at γ=1/(4L),α=1/2 → tune β=μ/(8L)
- key_insight: With γ=1/(4L) and α=1/2 the variance coefficient A_S=4γ²−γ/L vanishes identically — interpolation gives free SVRG, no control variate needed.
- proof_length: medium

### Retrieval Tags
alpha-split, co-coercivity, exact-cancellation, interpolation, momentum

---

## Strategy Signature: momentum-sgd-interpolation-alpha-split-one-over-L

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: convergence_rate
- setting: interpolation
- iterate_type: last

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: split_co_coercivity α=1/2 → joint_Lyapunov Φ=‖e‖²+a‖m‖² → γ=1/L makes −γ/L·S_t cancel γ²S_t exactly → budget_allocation μ/(8L) per perturbation → tune a=μ/(4L), β=μ²/(16L²)
- key_insight: Same α=1/2 cancellation at the larger GD step γ=1/L, with the joint Lyapunov scaled to track ‖m‖²=γ²‖v‖² instead of ‖v‖².
- proof_length: medium

### Retrieval Tags
alpha-split, GD-step, budget-allocation, interpolation, momentum

---

## Strategy Signature: momentum-sgd-interpolation-spectral

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: convergence_rate
- setting: interpolation
- iterate_type: last

### Strategy Used (output)
- meta_template: spectral_eigenvalue
- technique_chain: integral_Hessian_linearization ∇f_i=H_i·e → Markov_jump_linear_systems_Costa_Fragoso_Marques → second_moment_operator (1/n)Σ A_i⊗A_i → diagonal_Lyapunov P=I+a·vv^T → H_i²≼LH_i → tune γ=1/(2L), β=1/κ
- key_insight: Linearize via integral Hessian H_i so iteration becomes z_{t+1}=A_i(x_t)z_t; the second-moment operator's spectral radius certifies convergence — diagonal P + H_i²≼LH_i gives rate 1−5/(16κ).
- proof_length: long

### Retrieval Tags
integral-Hessian, Markov-jump, second-moment, Kronecker, momentum

---

# Optimization / Variance Reduction + Adaptive

## Strategy Signature: spider-nonconvex-gradient-complexity

### Problem Features (input)
- algorithm_type: SVRG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_finite_sum
- iterate_type: best

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: SARAH_recursive_estimator → polarization ⟨∇f,v⟩=½(‖v‖²+‖∇f‖²−‖e‖²) → martingale_variance_recursion → epoch_telescoping → tune η=1/(2L), b=q=√n
- key_insight: Use polarization (not Young) on the descent cross term to expose the −‖v‖²/2 absorber; the martingale recursive estimator's displacement variance is exactly absorbed by this free negative term.
- proof_length: medium

### Retrieval Tags
SPIDER, polarization, recursive-estimator, martingale, root-n

---

## Strategy Signature: spider-sarah-variance-reduction-nonconvex

### Problem Features (input)
- algorithm_type: SVRG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_finite_sum
- iterate_type: best

### Strategy Used (output)
- meta_template: OTHER:self_bounding
- technique_chain: SARAH_recursive_estimator → Young + ‖a+b‖²≤2(‖a‖²+‖b‖²) → self_bounding V≤2L²η²q(G+V) → rearrange when 2L²η²q≤1/2 → epoch_telescope_with_tower
- key_insight: The variance bound V≤2L²η²q(G+V) is self-bounding: when 2L²η²q≤1/2, isolate-and-divide gives V≤4L²η²qG so variance becomes a constant multiple of gradient sum.
- proof_length: medium

### Retrieval Tags
SARAH, self-bounding, isolate-and-divide, root-n, variance-reduction

---

## Strategy Signature: storm-nonconvex-convergence

### Problem Features (input)
- algorithm_type: SGD
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: momentum_form_VR d_t=(1−a)d_{t−1}+∇f(x_t;ξ_t)−(1−a)∇f(x_{t−1};ξ_t) → polarization → Lyapunov Φ_t=f(x_t)+(η/(2a))‖e_t‖² with c=η/(2a) exactly cancels error coefficient → mini_batch_warmup B=σ/ε
- key_insight: Soft EMA reset gives variance recursion with contraction (1−a) and noise floor 2a²σ²; Lyapunov coupling constant c=η/(2a) is engineered to exactly zero the error coefficient ca−η/2.
- proof_length: medium

### Retrieval Tags
STORM, EMA-momentum, single-loop, exact-cancellation-Lyapunov, parameter-free

---

## Strategy Signature: page-optimal-gradient-complexity

### Problem Features (input)
- algorithm_type: SVRG
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_finite_sum
- iterate_type: best

### Strategy Used (output)
- meta_template: cancellation_pair
- technique_chain: probabilistic_Bernoulli(p)_reset → V_{t+1}≤(1−p)V_t+(L²η²/b')E‖g_t‖² → geometric_unrolling V≤(L²η²/(pb'))H → polarization_absorption → tune p=1/√n
- key_insight: Replace SPIDER's deterministic epochs with Bernoulli(p) reset; expected error has clean geometric recursion, unrolling gives effective horizon 1/p=√n with no boundary terms.
- proof_length: short

### Retrieval Tags
PAGE, probabilistic-reset, geometric-recursion, randomization-as-simplification, root-n

---

## Strategy Signature: adam-nonconvex-convergence

### Problem Features (input)
- algorithm_type: Adam
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: descent_lemma_telescope
- technique_chain: EMA_weight_comparison_β1²≤β2 → Jensen ⇒ [m̂]_i²≤[v̂]_i ⇒ |[D_t]_i|≤1, ‖D_t‖²≤d → polarization ⟨g_t,D_t⟩ → momentum_path_length_bound → horizon_dependent_step α=α_0 T^{−1/4}
- key_insight: Under β1²≤β2, Jensen gives [m̂]²≤[v̂] coordinate-wise, bounding ‖D_t‖²≤d; horizon-dependent step α=α_0 T^{−1/4} forces momentum-bias to vanish, giving O(d log T/√T).
- proof_length: medium

### Retrieval Tags
Adam, EMA-weight-domination, beta1-squared-leq-beta2, dimension-d, horizon-step

---

## Strategy Signature: amsgrad-nonconvex-convergence

### Problem Features (input)
- algorithm_type: AMSGrad
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: descent_lemma_telescope
- technique_chain: coordinate_descent_lemma → decompose m_t into grad+noise+momentum → predictable_surrogate v̂_{t−1} in cross_term → √(a+c)−√a≤√c → monotonicity v̂_t≥v̂_{t−1}
- key_insight: Replace v̂_t with v̂_{t−1} (predictable) in the noise cross-term so it becomes zero-mean MDS; AMSGrad's monotonicity bounds the correction √(v̂_t)−√(v̂_{t−1})≤√((1−β2)G²).
- proof_length: medium

### Retrieval Tags
AMSGrad, predictable-surrogate, monotone-denominator, sqrt-subadditivity, MDS

---

## Strategy Signature: adagrad-norm-nonconvex-convergence

### Problem Features (input)
- algorithm_type: AdaGrad-Norm
- function_class: non-convex
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: OTHER:algebraic_index_shift
- technique_chain: adaptive_descent_lemma η/b_k → log_accumulator Σa_k²/B_{k+1}²≤log(B_T²/B_0²) → algebraic_decoupling 1/b_k²−1/b_{k+1}²=‖g_k‖²/(b_k²b_{k+1}²) → as_envelope b_T≤b_0+M√T → Cauchy_Schwarz/Jensen
- key_insight: Identity 1/b_k²−1/b_{k+1}²=‖g_k‖²/(b_k²b_{k+1}²) shifts the index by one for free, converting un-summable Σ‖g_k‖²/b_k² (b_k not predictable for g_k) into summable Σ‖g_k‖²/b_{k+1}² plus controllable correction.
- proof_length: medium

### Retrieval Tags
AdaGrad-Norm, index-shift, log-accumulator, predictable-scalar, almost-sure-envelope

---

# Optimization / Lower Bounds + Splitting + Sampling

## Strategy Signature: shb-no-acceleration-restricted

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: lower_bound
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: polytope_construction
- technique_chain: GPT_polytope_Moreau_function ψ → spatial_rescaling f_0(x)=D²ψ(x/D) → coordinate_decoupling ℝ²⊕ℝ → Le_Cam_two_point + Pinsker on noise coord → SC_floor μD²/4
- key_insight: Restrict quantifier to algebraic feasibility region F where Goujaud cycling holds; split D-budget across 2D cycling subspace and orthogonal 1D Le-Cam noise so bias O(LD²/T) and variance O(σD/√T) live on disjoint coordinates.
- proof_length: long

### Retrieval Tags
SHB, lower-bound, Goujaud, polytope-Moreau, Le-Cam, restricted-quantifier

---

## Strategy Signature: shb-cycling-critical-momentum

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: lower_bound
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: OTHER:polynomial_threshold
- technique_chain: substitute_c_K=cos(2π/K) → factor_GPT_inequality (1+c_K)·Q_K(β)=β²+2(1−c_K)β−1 → quadratic_formula → conjugate_rationalization for monotonicity → discrete_optimization K≥3
- key_insight: Cycling inequality factors as (1+c_K)·Q_K(β) with Q_K purely quadratic in β; threshold β*=(√13−3)/2 from Q_3, attained at K=3 because φ(u)=√(u²+1)−u is monotone via conjugate rationalization.
- proof_length: short

### Retrieval Tags
SHB, critical-momentum, polynomial-factorization, conjugate-rationalization, threshold

---

## Strategy Signature: shb-interpolation-regime-lb

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: lower_bound
- setting: interpolation
- iterate_type: last

### Strategy Used (output)
- meta_template: OTHER:algorithm_existential_refutation
- technique_chain: noiseless_oracle_admissible_under_interp → reuse_OP-2_Goujaud_for_bias → quadratic + multiplicative_noise ξ_t=σ‖x_t‖ε_t → second_moment_recursion ρ=(1+σ²/L²)/4 → exponential_decay refutes_polynomial_LB
- key_insight: Bias term Ω(κLD²/T) survives via noiseless-oracle reduction; variance term refuted by exhibiting one (quadratic + multiplicative noise + GD) tuple achieving exponential decay, proving no algorithm-uniform polynomial LB exists.
- proof_length: medium

### Retrieval Tags
interpolation-LB, multiplicative-noise, algorithm-existential, exponential-decay, asymmetric

---

## Strategy Signature: shb-no-acceleration-best-iterate

### Problem Features (input)
- algorithm_type: SHB
- function_class: smooth_SC
- target_quantity: lower_bound
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: OTHER:test-asymmetry-refutation
- technique_chain: reuse_OP-2_cycling_for_bias → cycle_uniformity_⇒_min=last_for_bias → Le_Cam_test_chooses_iterate → ŝ=−sign(y_{t*}) near_perfectly_recovers s → empirical_T^{−2}_decay_disproof
- key_insight: Bias transfers via cycle uniformity (all iterates equidistant from optimum); variance term fails because Le Cam test on best-iterate ŝ=−sign(y_{t*}) recovers s near-perfectly, voiding the test.
- proof_length: medium

### Retrieval Tags
best-iterate, Le-Cam-test-asymmetry, cycle-uniformity, random-walk-floor, refutation

---

## Strategy Signature: douglas-rachford-splitting-rate

### Problem Features (input)
- algorithm_type: DR-splitting
- function_class: monotone-inclusion
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: fixed_point_contraction
- technique_chain: resolvent_FNE_Minty → reflected_resolvent R=2J−Id → algebraic T_DR=(Id+R_A R_B)/2 → Krasnoselskii_Mann → telescoping_Fejer + monotone_residuals → Opial + demiclosedness_Browder
- key_insight: T_DR=(Id+R_A R_B)/2 is averaged of identity and nonexpansive R_A R_B, hence FNE for free; Fejér inequality gives ‖T(z)−z‖²+‖T(z)−z*‖²≤‖z−z*‖² without effort.
- proof_length: medium

### Retrieval Tags
Douglas-Rachford, averaged-operator, reflected-resolvent, Fejer-monotone, splitting

---

## Strategy Signature: chambolle-pock-pdhg-ergodic-convergence

### Problem Features (input)
- algorithm_type: PDHG
- function_class: saddle-point
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: saddle_point_to_monotone_inclusion (skew B + max-monotone A) → preconditioned_proximal_point → Schur_complement τσL²<1 → three_point_identity → Young_with_σ → telescope + Jensen on Lagrangian
- key_insight: Step-size condition τσL²<1 is exactly the Schur-complement positive-definiteness of preconditioner M and exactly cancels the cross term from extrapolation x̄=2x^n−x^{n−1}; one condition plays both roles.
- proof_length: medium

### Retrieval Tags
PDHG, preconditioned-proximal-point, extrapolation, Schur-complement, ergodic

---

## Strategy Signature: davis-yin-three-operator-splitting-ergodic-variant

### Problem Features (input)
- algorithm_type: DY-splitting
- function_class: monotone-inclusion
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: three_convexity_inequalities (f,g,h) → β_smooth_descent_for_h → primal_dual_identity u^k+v^k+∇h(y^k)=−r^k/γ → polarization at x*-anchor → telescope + Jensen on split F̃
- key_insight: One-step inequality factors as F̃^k−F(x*)≤(1/2γ)(‖z^k−x*‖²−‖z^{k+1}−x*‖²)−((α−1)/2γ)‖r^k‖² with α=2−γβ; residual non-positive iff γ≤1/β.
- proof_length: medium

### Retrieval Tags
Davis-Yin, three-operator, primal-dual-identity, anchor-shift, honest-variant

---

## Strategy Signature: admm-ergodic-convergence

### Problem Features (input)
- algorithm_type: ADMM
- function_class: saddle-point
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: averaged_uniform

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: augmented_Lagrangian_optimality → subgradient_inequalities → lagged_dual λ̄_T=(1/T)Σ_{k=0}^{T−1}λ^k → residual_decomposition A(x^{k+1}−x̃)=r^{k+1}−d−B(z^{k+1}−z̃) → two_polarizations → perfect_square_absorption -(β/2)‖s^{k+1}‖²
- key_insight: Lagged dual averaging λ̄_T=(1/T)Σ_{k=0}^{T−1}λ^k is the off-by-one trick that pairs primal-step (k+1) with dual-step (k) for clean Jensen; cross terms combine into perfect square absorbed as ≤0.
- proof_length: medium

### Retrieval Tags
ADMM, lagged-dual, perfect-square, B-seminorm, Lyapunov-energy

---

## Strategy Signature: ula-kl-convergence-lsi

### Problem Features (input)
- algorithm_type: ULA
- function_class: smooth_LSI
- target_quantity: mixing_time
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: drift_diffusion
- technique_chain: synchronous_coupling shared_BM → Girsanov_path_KL → data_processing_to_marginal → de_Bruijn + LSI 2αKL ⇒ Grönwall e^{−2αh}KL → Stein E_π‖∇f‖²≤Ld → LSI_to_gradient → choose h≤α/(4L²) so contraction absorbs discretization
- key_insight: Couple ULA and Langevin via shared Brownian motion so KL between paths is a clean Girsanov integral; LSI contraction e^{−2αh} absorbs the (αh/2)·KL part of discretization, giving recursion KL(ρ_{(k+1)h}‖π)≤e^{−αh}KL(ρ_kh‖π)+2L²dh².
- proof_length: long

### Retrieval Tags
ULA, Langevin, Girsanov, LSI, synchronous-coupling, KL-mixing

---

# Learning Theory / Generalization (NTK + Approximation + Implicit Bias)

## Strategy Signature: ntk-gram-positive-definiteness

### Problem Features (input)
- algorithm_type: N/A
- function_class: kernel
- target_quantity: structural-characterization
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:integral_representation_combinatorics
- technique_chain: Stein_integral c^T H^∞ c=E_w[‖Σc_i 1{w^T x_i≥0}x_i‖²] → hyperplane_arrangement_cell_partition → adjacent_cell_subtraction (one-coordinate-flip) → c_k x_k=0 ⇒ x_i≠±x_j sufficient
- key_insight: Quadratic form is E[‖·‖²] over hyperplane-arrangement cells; adjacency between cells differing in one coordinate forces c_k x_k=0, reducing PD to incidence geometry: no two x_i define the same hyperplane.
- proof_length: medium

### Retrieval Tags
NTK, Gram-PD, hyperplane-arrangement, adjacent-cell, antipodal

---

## Strategy Signature: transformer-self-attention-lipschitz

### Problem Features (input)
- algorithm_type: N/A
- function_class: Lipschitz
- target_quantity: structural-characterization
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:product_rule_decomposition
- technique_chain: product_rule split (value, score) → softmax_Jacobian=diag(σ)−σσ^T → variance_of_prob_vector ≤1/2 → bilinear_score (2√n‖M‖R/√d_k) → (a+b)²≤2(a²+b²)
- key_insight: Softmax Jacobian's spectral norm is exactly 1/2 (tight at σ=(½,½,0,…)); bilinear score makes attention Lipschitz constant scale as R², requiring LayerNorm.
- proof_length: medium

### Retrieval Tags
Transformer, attention, softmax-Jacobian, bilinear, R-squared

---

## Strategy Signature: denoising-score-matching-equivalence

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:expand_then_match
- technique_chain: quadratic_expansion ‖a−b‖² → score_of_mixture_identity ∇log q_σ=E_{p(y|x)}[∇log p(x|y)] → Bayes_swap → closed_form_Gaussian_score −ε/σ
- key_insight: Both DSM and ESM expand into identical quadratic-in-s_θ term; cross terms agree via single Bayes-rule swap (score of mixture = posterior expectation of conditional score), making the equivalence exact at the gradient level.
- proof_length: short

### Retrieval Tags
DSM, score-matching, Bayes-swap, mixture-score, Tweedie-related

---

## Strategy Signature: ntk-infinite-width-convergence

### Problem Features (input)
- algorithm_type: N/A
- function_class: kernel
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:matrix_concentration
- technique_chain: decompose Θ̂_m−Θ^∞=(1/m)ΣZ_k → Schur_Hadamard_lemma ‖M∘G‖≤‖M‖ for unit-diag PSD G → matrix_Bernstein_Tropp → variance_vs_subexp_regime
- key_insight: Schur product lemma absorbs G entirely (‖M∘G‖_op≤‖M‖_op for unit-diagonal PSD G), reducing to matrix Bernstein on rank-one fluctuations — gives log n instead of log n² and saves a √n factor.
- proof_length: medium

### Retrieval Tags
NTK, matrix-Bernstein, Hadamard-peeloff, Schur, infinite-width

---

## Strategy Signature: relu-quantitative-universal-approximation

### Problem Features (input)
- algorithm_type: N/A
- function_class: Lipschitz
- target_quantity: approximation_rate
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:structured_mesh_construction
- technique_chain: Kuhn_Freudenthal_triangulation → barycentric_interpolation_error → conformality_via_shared_subtriangulation → CPL_to_ReLU_Arora_Basu_Mianjy_Mukherjee → region_count d!·M^d
- key_insight: Kuhn triangulation makes both conformality across cube faces and exact piece-count d!·M^d trivial; combined with CPL→ReLU representation, gives N≤d!(L/ε)^d neurons for ε-approximation.
- proof_length: medium

### Retrieval Tags
ReLU, universal-approximation, Kuhn-triangulation, CPL, conforming-mesh

---

## Strategy Signature: gd-implicit-bias-max-margin

### Problem Features (input)
- algorithm_type: SGD
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: deterministic
- iterate_type: last

### Strategy Used (output)
- meta_template: OTHER:divergence_direction_analysis
- technique_chain: descent_lemma + smoothness ⇒ ‖∇L‖→0 → conic_hull_contradiction ‖w_t‖→∞ → sigmoid_asymptotic σ(−m)≈e^{−m} → telescope w_T=Σβ_i z_i+r_T → self_bounding L_{t+1}≤L_t−cL_t² ⇒ O(1/t) → KKT_identification
- key_insight: Loss has no minimizer (separable case), so study limit of w_t/‖w_t‖; exponential-tail logistic loss makes gradient an exponentially-weighted combination of data, self-bootstrapping selects support vectors of hard-margin SVM.
- proof_length: long

### Retrieval Tags
implicit-bias, max-margin, logistic, self-bounding, KKT-fixed-point

---

## Strategy Signature: depth-separation-exponential-width-radial

### Problem Features (input)
- algorithm_type: N/A
- function_class: non-smooth-convex
- target_quantity: lower_bound
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:frequency_basis_bottleneck
- technique_chain: Hermite_Gaussian_orthogonal_expansion → Funk_Hecke_radial_projection → Laguerre_coefficient_LB_for_1[χ²_d≤d] → Cauchy_Schwarz_bottleneck m≥N(d,2k)·β² → ReLU_Hermite_decay c_k(b)=O(1/k)
- key_insight: Ball indicator has Ω(1) energy at degree 2k=Θ(√d) (slow Laguerre decay); each ReLU spreads its degree-2k energy over N(d,2k)=Θ((d/2k)^{2k}) directions but target lives in just one — Funk-Hecke gives 1/√N attenuation per neuron, forcing exp(d) width.
- proof_length: long

### Retrieval Tags
depth-separation, Funk-Hecke, Hermite, radial, exponential-width

---

# Learning Theory / Bandits + PAC-Bayes + Information-Theoretic

## Strategy Signature: exp3-adversarial-bandit-regret

### Problem Features (input)
- algorithm_type: bandit-EXP3
- function_class: non-smooth-convex
- target_quantity: regret_bound
- setting: online_adversarial
- iterate_type: N/A

### Strategy Used (output)
- meta_template: exp_supermartingale
- technique_chain: exponential_weights_potential Φ_t=ln W_t → importance_weighted_unbiased_estimator ℓ̂(i)=ℓ(i)1{I=i}/p(i) → e^{−x}≤1−x+x²/2 → γ-mixture_uniform_exploration → balance η=√(ln K/(KT)), γ=Kη
- key_insight: Hedge potential argument is deterministic; replace unobserved ℓ_t with importance-weighted estimator, and force-explore γ/K-mixture so 1/p_t(i)≤1/(1−γ) keeps variance bounded.
- proof_length: medium

### Retrieval Tags
EXP3, importance-weighting, forced-exploration, Hedge, multiplicative-weights

---

## Strategy Signature: tweedies-formula-gaussian

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:expand_then_match
- technique_chain: differentiate_under_integral → Gaussian_score_identity ∇log φ_σ(x−y)=−(x−y)/σ² → Bayes_rule_reinterpretation → tower_property + complete_square
- key_insight: Gradient of Gaussian-convolved p_σ(x) pulls onto the Gaussian factor giving linear −(x−y)/σ²; the integrand p_data(y)φ_σ(x−y)/p_σ(x) is the posterior of Y|X, turning the integral into a conditional expectation.
- proof_length: short

### Retrieval Tags
Tweedie, Gaussian-score, Bayes-rule, denoising, empirical-Bayes

---

## Strategy Signature: oful-linear-bandit-regret

### Problem Features (input)
- algorithm_type: bandit-EXP3
- function_class: smooth_convex
- target_quantity: regret_bound
- setting: online_adversarial
- iterate_type: N/A

### Strategy Used (output)
- meta_template: exp_supermartingale
- technique_chain: exponential_supermartingale L_t(θ)=exp(⟨θ,S_t⟩/R²−‖θ‖²_{A_t}/(2R²)) → Gaussian_mixture_method (Pinelis) → Ville's_inequality → matrix_determinant_lemma → elliptical_potential x≤2ln(1+x) → OFU_confidence_ellipsoid
- key_insight: Method of mixtures: integrate exponential supermartingale against Gaussian prior on θ, the integral evaluates to det(V_t)^{−1/2}exp(‖S_t‖²_{V_t^{−1}}/(2R²)) — self-normalized deviation uniform in θ for free.
- proof_length: long

### Retrieval Tags
OFUL, method-of-mixtures, self-normalized, elliptical-potential, linear-bandit

---

## Strategy Signature: catoni-pac-bayes-bound

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: exp_supermartingale
- technique_chain: sub_Bernoulli_cumulant ψ(u)=u−1+e^{−u} → tensorize_iid_MGF → engineered φ_S(h)=λ(R−R̂)−nRψ(λ/n) ⇒ E_S e^φ ≤1 → Fubini_then_Markov → Donsker_Varadhan
- key_insight: Engineer test function φ_S(h) with sub-Bernoulli correction −nRψ(λ/n) so E_S e^{φ_S}≤1 exactly; averaging under prior P first (Fubini-then-Markov) gives uniform-in-Q bound for arbitrary posterior.
- proof_length: medium

### Retrieval Tags
PAC-Bayes, Catoni, Donsker-Varadhan, sub-Bernoulli, Fubini-Markov

---

## Strategy Signature: thompson-sampling-bernoulli-regret

### Problem Features (input)
- algorithm_type: bandit-EXP3
- function_class: smooth_convex
- target_quantity: regret_bound
- setting: Bayesian
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:posterior_dominance
- technique_chain: Beta_Binomial_duality → Hoeffding_on_Bernoulli_sums → good_event G_k(t)=E_k^μ∩E_k^θ → posterior_dominance Pr(I=k,θ_k<y_k)≤(1−p_t)/p_t·Pr(I=1,θ_k<y_k) → moment_bound_1/p_(n) → optional_skipping → gap_balancing
- key_insight: Inflation lemma relates "pull bad arm k" to "pull optimal arm 1" via the random posterior probability p_t=Pr(θ_1>y_k|F_{t−1}), exploiting conditional independence of θ_k given F_{t−1}; pivot y_k=μ_k+Δ_k/2 and Beta-moment bound on 1/p_(n) close the argument.
- proof_length: long

### Retrieval Tags
Thompson-sampling, posterior-dominance, Beta-Binomial, optional-skipping, inflation

---

## Strategy Signature: xu-raginsky-mi-generalization-bound

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: exp_supermartingale
- technique_chain: Donsker_Varadhan → sub_Gaussian_transport |E_P f−E_Q f|≤√(2σ²KL(P‖Q)) → per_sample_decomposition + ghost Z_i'~D → chain_rule + joint_convexity_of_KL → Jensen_on_sqrt
- key_insight: Generalization gap = expectation difference between joint P_{W,Z_i} and product P_W⊗D laws; DV+sub-Gaussian transport gives √(2σ² I(W;Z_i)); per-sample Jensen tightens vs whole-sample I(W;S).
- proof_length: medium

### Retrieval Tags
XR, mutual-information, sub-Gaussian-transport, per-sample, Jensen

---

## Strategy Signature: matrix-ce-vs-standard-ce-generalization

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: high_dim_proportional
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:matrix_concentration
- technique_chain: operator_Lipschitz_log via_resolvent → trace_operator_Holder → matrix_Bernstein_intrinsic_dim r_eff(Σ) → Tikhonov εI for spectral floor → standard_symmetrization_covering → Berry_Esseen for CE_lower_bound
- key_insight: MCE is smooth functional of empirical Σ̂ so matrix Bernstein with intrinsic-dim r_eff(Σ)=tr(Σ)/‖Σ‖_op replaces dimension; price is that log is operator-Lipschitz only with constant 1/μ (need Tikhonov spectral floor).
- proof_length: long

### Retrieval Tags
Matrix-CE, intrinsic-dimension, matrix-Bernstein, Tikhonov, operator-Lipschitz-log

---

# Learning Theory / SSL

## Strategy Signature: spectral-gap-infonce-downstream

### Problem Features (input)
- algorithm_type: SSL-InfoNCE
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:closed_form_block_minimization
- technique_chain: spectral_contrastive_surrogate (Tan 2024 / HaoChen 2021) → coercivity_via_SVD + power_mean → block_parameterization F=U_k A+U_⊥ B → analytic_A_minimization closed-form quadratic → quadratic_growth ⇒ projection_error
- key_insight: Spectral contrastive loss is quartic in F; gauge-fix the top-k block by analytically minimizing over A at fixed B, exposing the sharp 2δ sharpness constant (vs naive 4δ from bare Hessian).
- proof_length: long

### Retrieval Tags
spectral-contrastive, InfoNCE, gauge-fix, block-minimization, sharpness

---

## Strategy Signature: ssl-augmentation-phase-transition

### Problem Features (input)
- algorithm_type: SSL-spectral
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: conjecture_rescue
- technique_chain: Gaussian_convolution_identity τ_eff²=τ²+2σ²_aug → equicorrelated_kernel (1−ρ)I+ρJ → block_eigenvector decomposition → real_analyticity_argument refutes_first_order → σ_aug·√d~Δ_min heuristic
- key_insight: For Dirac-on-simplex+Gaussian-augmentation model the gap g(σ_aug)=n(1−exp(−Δ²/(2dτ_eff²))) is real-analytic, refuting first-order phase-transition; rescue: state second-order replacement under explicit hypotheses.
- proof_length: medium

### Retrieval Tags
SSL, augmentation, phase-transition, conjecture-refutation, real-analytic

---

## Strategy Signature: matrix-renyi-collapse-detection

### Problem Features (input)
- algorithm_type: SSL-spectral
- function_class: PL
- target_quantity: structural-characterization
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: lyapunov_potential
- technique_chain: spectral_functional_calculus_PSD → Jensen_on_x^α → Frobenius_gradient tr(K^α) → trace_free_projection R(K)=∇_K S_α−(α/(1−α))I → local_Taylor_expansion δ_i=0 → PL_framework
- key_insight: dS_α/dt=−(2/τ)⟨R(K)F,∇_F L⟩ where R(K) is the trace-free part of the gradient; trace-free correction is what makes entropy-PL inequality G(K)≤c_α(ε)‖R(K)K^{1/2}‖² hold with leading constant 1/(2α).
- proof_length: medium

### Retrieval Tags
matrix-Renyi, collapse, trace-free, entropy-PL, gradient-flow

---

## Strategy Signature: ssl-infonce-minimax-lower-bound

### Problem Features (input)
- algorithm_type: SSL-InfoNCE
- function_class: smooth_convex
- target_quantity: minimax_rate
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: le_cam_testing
- technique_chain: σ_link_to_squared_loss → Schur_complement_amplification → DPI + chain_rule_MI → metric_entropy_packing_SO(d) log M=Θ(d²) → Fano → hypothesis_testing
- key_insight: d² rate = packing entropy of SO(d) (Riemannian dim d(d−1)/2) for the f* component, plus √d-amplification by aligning worst-case w*=√d·V·e_1 with the rotated representation via Schur-complement gap.
- proof_length: long

### Retrieval Tags
InfoNCE, minimax-LB, SO(d)-packing, Fano, joint-adversary

---

## Strategy Signature: ot-contrastive-representation-characterization

### Problem Features (input)
- algorithm_type: SSL-spectral
- function_class: kernel
- target_quantity: structural-characterization
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: conjecture_rescue
- technique_chain: Brenier_identity_for_OT_to_Dirac → HaoChen_spectral_contrastive_identity → Eckart_Young → Perron_Frobenius_per_block → explicit_4_vertex_counterexample with ε=0.3 cross_edge → state (H1)+(H2)+(H3) hypotheses
- key_insight: Conjecture true iff (H1) block-diagonal W + (H2) spectral gap + (H3) regular blocks + uniform prior; counterexample 2-clique+ε=0.3 cross edge has L_spec(F^spec)=1.26<1.93=L_spec(F^alt) but J_OT(F^spec)=0.65>0.
- proof_length: medium

### Retrieval Tags
OT-contrastive, conjecture-refutation, block-diagonal, Perron-Frobenius, hypothesis-tightening

---

# Learning Theory / Stability + High-Dimensional Statistics

## Strategy Signature: hardt-recht-singer-sgd-stability

### Problem Features (input)
- algorithm_type: SGD
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: couple_track
- technique_chain: algorithmic_stability_Bousquet_Elisseeff → couple_under_shared_index_sequence → co_coercivity_Baillon_Haddad ⇒ I−α∇L_S non_expansive when α≤2/β → telescope + linearity_of_expectation
- key_insight: Share noise between two SGD trajectories on neighboring datasets so (n−1)/n of steps process the same gradient operator; co-coercivity makes that operator non-expansive, isolating the 1/n shock events.
- proof_length: medium

### Retrieval Tags
HRS, stability, co-coercivity, coupling, leave-one-out

---

## Strategy Signature: dp-implies-generalization

### Problem Features (input)
- algorithm_type: SGD
- function_class: Lipschitz
- target_quantity: generalization_bound
- setting: DP
- iterate_type: last

### Strategy Used (output)
- meta_template: OTHER:divergence_stability
- technique_chain: hockey_stick_decomposition dμ=min(dμ,e^ε dν)+(dμ−e^ε dν)_+ → DP_post_processing on bounded test functions → Bousquet_Elisseeff_LOO_symmetrization
- key_insight: Hockey-stick decomposition splits the (ε,δ)-DP guarantee into a bounded-likelihood-ratio piece (controlled by e^ε) and a rare-event leakage piece (controlled by δ), letting DP apply to expectations of bounded test functions.
- proof_length: short

### Retrieval Tags
differential-privacy, hockey-stick, generalization, leave-one-out, divergence

---

## Strategy Signature: sgd-signal-noise-generalization-decomposition

### Problem Features (input)
- algorithm_type: SGD
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: stochastic_iid
- iterate_type: last

### Strategy Used (output)
- meta_template: couple_track
- technique_chain: HRS_coupling_scaffold → Doob_decomposition_gradient ∇ℓ=∇L_S+∇L_N → quadratic_recursion Δ_{t+1}=Δ_t+a√Δ_t+b → power_law_ansatz_induction → Cauchy_Schwarz_cross_term
- key_insight: Decompose gradient as signal+zero-mean-noise INSIDE the per-step recursion: signal annihilated by non-expansiveness, only noise η(∇L_N−∇L_N') perturbs trajectory — converts L² bound into (G_S²+σ_N²) bound.
- proof_length: medium

### Retrieval Tags
HRS-extension, signal-noise, push-decomp-inside, variance-vs-supremum

---

## Strategy Signature: adversarial-trajectory-tradeoff

### Problem Features (input)
- algorithm_type: internal-conjecture-Problem-7.10
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: stochastic_iid
- iterate_type: best

### Strategy Used (output)
- meta_template: conjecture_rescue
- technique_chain: trajectory_length ‖θ_T−θ_0‖≤G√(Tη) → mixed_Hessian H=sup‖∇_θ∇_x L‖_op as bridge → adv_penalty=r·H·√(Tη) strictly_increasing → argmin_shift_lemma → honest_2/3_exponent vs literal 1/(1+r²H²η)
- key_insight: Mixed Hessian H bridges parameter-motion and data-gradient growth; adversarial penalty is linear in r·H·√(Tη), and any strictly-increasing penalty added to a U-shaped loss shifts argmin strictly left.
- proof_length: medium

### Retrieval Tags
adversarial, mixed-Hessian, argmin-shift, early-stopping, structural-shape

---

## Strategy Signature: heavy-tailed-trajectory-decomposition

### Problem Features (input)
- algorithm_type: SGD
- function_class: smooth_convex
- target_quantity: generalization_bound
- setting: heavy_tailed
- iterate_type: last

### Strategy Used (output)
- meta_template: couple_track
- technique_chain: HRS_at_p_th_moment + (a+b)^p≤2^{p−1}(a^p+b^p) → Marcinkiewicz_Zygmund for p∈(1,2) E‖ΣN‖^p≤C_p ΣE‖N‖^p → gradient_clipping τ=G·T^{1/p−1/2} → bias_variance_balance → optional_PR_averaging
- key_insight: Lift HRS recursion to L^p; replace classical BDG with Marcinkiewicz-Zygmund (sub-additive in p∈(1,2)); clipping at τ=G·T^{1/p−1/2} balances truncation bias G^p/τ^{p−1} vs truncated variance G^p τ^{2−p}.
- proof_length: long

### Retrieval Tags
heavy-tail, p-th-moment, Marcinkiewicz-Zygmund, clipping, HRS-extension

---

## Strategy Signature: double-descent-interpolation-threshold

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: structural-characterization
- setting: high_dim_proportional
- iterate_type: N/A

### Strategy Used (output)
- meta_template: spectral_eigenvalue
- technique_chain: bias_variance_decomposition with X^+ → inverse_Wishart_first_moment E[(Z^T Z)^{−1}]=I/(n−d−1) → Haar_invariance E[I−P_X]=(d−n)/d·I → Marchenko_Pastur_edge (1−√γ)²→0 at γ=1
- key_insight: Peak at γ=d/n=1 is a conditioning catastrophe of empirical Gram (smallest singular value collapses via Marchenko-Pastur edge); inverse-Wishart trace 1/(n−d−1) and 1/(d−n−1) both have a pole at n=d, giving variance divergence from both sides.
- proof_length: medium

### Retrieval Tags
double-descent, inverse-Wishart, Marchenko-Pastur, Haar-invariance, interpolation-threshold

---

## Strategy Signature: lasso-restricted-eigenvalue-prediction-error

### Problem Features (input)
- algorithm_type: N/A
- function_class: smooth_convex
- target_quantity: convergence_rate
- setting: high_dim_proportional
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:cone_constraint
- technique_chain: KKT_basic_inequality + λ_dual_norm → cone_constraint Δ̂∈C(S,3)={Δ:‖Δ_{S^c}‖_1≤3‖Δ_S‖_1} → restricted_eigenvalue κ on cone → sub_Gaussian_tail for ‖X^T w‖_∞ + union_bound λ≥2σ√(2log p/n)
- key_insight: ℓ_1 regularization automatically generates a cone constraint C(S,3) on the error so X only needs Restricted Eigenvalue (PD on the cone), not full eigenvalue lower bound (impossible in p>n).
- proof_length: medium

### Retrieval Tags
LASSO, restricted-eigenvalue, cone-constraint, dual-norm, high-dim-sparse

---

# Multi-Agent Verification (Self-Referential)

## Strategy Signature: multi-agent-verification-error-propagation

### Problem Features (input)
- algorithm_type: multi-agent-CR
- function_class: probabilistic
- target_quantity: convergence_rate
- setting: stochastic_iid
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:product_amplification
- technique_chain: Bernoulli_independence + product_rule → monotonicity_of_probability for {no_error}⊂{chain_correct} → tightness_via_honest_proposer + false_reject_only construction → SymPy + Monte_Carlo verification
- key_insight: Replacing one Bernoulli(ε) per round with logical-AND of k independent Bernoulli(ε) trials drives per-round residual error to ε^k; (1−ε^k)^T amplification beats union bound 1−Tε.
- proof_length: short

### Retrieval Tags
multi-agent, product-amplification, auditor-fixer, retry, error-propagation

---

## Strategy Signature: categorical-functorial-error-propagation

### Problem Features (input)
- algorithm_type: multi-agent-CR
- function_class: contraction
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: fixed_point_contraction
- technique_chain: Lawvere_M_enrichment M=([0,∞],≥,+,0) → sup_distance_on_functor_categories → Banach_fixed_point_in_enriched_setting → Kleisli_over_distribution_monad → reduction_to_TV_metric ⇒ recovers_Problem_4.1
- key_insight: Choose Lawvere [0,∞]-enrichment so ‖η‖_∞=d_{[C,D]}(F,G) becomes definitional; Banach contraction in functor space gives α^k decay automatically and Kleisli-over-distribution-monad recovers Problem 4.1 verbatim.
- proof_length: short

### Retrieval Tags
categorical, Lawvere, Banach, Kleisli, decorative-formalism

---

## Strategy Signature: cumulative-reasoning-compositional-reuse

### Problem Features (input)
- algorithm_type: multi-agent-CR
- function_class: probabilistic
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:product_amplification
- technique_chain: Weierstrass_product_inequality ∏(1−x_i)≥1−Σx_i → induction_on_DAG_depth_with_Δ → tree_unfolding_count N(d,Δ)=(Δ^{d+1}−1)/(Δ−1) → per_lemma_retry δ→δ^k
- key_insight: Tree-unfolded DAG count is N(d,Δ)=(Δ^{d+1}−1)/(Δ−1), strictly larger than the Δ^d the user originally claimed; per-lemma retries shrink δ to δ^k BEFORE composition, beating brute-force composition by ~700×.
- proof_length: short

### Retrieval Tags
CR, library-reuse, DAG-depth, Weierstrass, tree-unfolding

---

## Strategy Signature: cumulative-reasoning-depth-lower-bound

### Problem Features (input)
- algorithm_type: multi-agent-CR
- function_class: probabilistic
- target_quantity: lower_bound
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: le_cam_testing
- technique_chain: Yao_minimax_principle → adversarial_alternative_construction (Hypothesis 1) at each level → Bayes_optimal_binary_test all-tail ½·min(ε,1−ε)^{T_ℓ} → worst_level vs union_bound → Brent_critical_path under_transcript_dependency_assumption (Hypothesis 2)
- key_insight: Reduce per-level error analysis to Bernoulli hypothesis testing between two candidates indistinguishable under verifier; Yao's minimax converts deterministic-algorithm Bayes-error bound into randomized-algorithm lower bound.
- proof_length: medium

### Retrieval Tags
CR, depth-LB, Yao-minimax, Bayes-error, hypothesis-testing

---

## Strategy Signature: cumulative-reasoning-non-stationary-verifier

### Problem Features (input)
- algorithm_type: multi-agent-CR
- function_class: probabilistic
- target_quantity: convergence_rate
- setting: deterministic
- iterate_type: N/A

### Strategy Used (output)
- meta_template: OTHER:integrability_phase_transition
- technique_chain: log_product → integral_test → log(1−x)≥−x−x² → Bernoulli_closed_form ∫(1+s/T_0)^α ds → optimal_stopping_FOC on Φ(T)=β log T−∫ε_s ds → phase_transition at α=1
- key_insight: Convert log P_T=Σ log(1−ε_t) into a continuous integral via integral test; polynomial decay ε_t=ε_0(1+t/T_0)^α gives a phase transition at α=1 (sub-linear/linear/super-linear) determined by integrability of t^α.
- proof_length: medium

### Retrieval Tags
non-stationary-verifier, integrability, phase-transition, log-product, optimal-stopping

---

# Vocabulary Index

This section enumerates every distinct value used across the 69 signatures so the Explorer knows the exact strings to grep for.

### algorithm_type
- SGD
- SHB
- NPG
- TD(0)
- GDA
- OGDA
- SAM
- Lookahead
- SVRG
- Adam
- AMSGrad
- AdaGrad-Norm
- Q-learning-tabular
- Q-learning-UCB
- DR-splitting
- DY-splitting
- PDHG
- ADMM
- ULA
- bandit-EXP3
- SSL-InfoNCE
- SSL-spectral
- multi-agent-CR
- k-step-spectral
- internal-conjecture-Problem-7.10
- N/A

### function_class
- smooth_convex
- smooth_SC
- non-convex
- non-smooth-convex
- interpolation
- Lipschitz
- PL
- saddle-point
- non-convex-strongly-concave
- contraction
- monotone-inclusion
- non-symmetric-linear
- smooth_LSI
- kernel
- probabilistic

### target_quantity
- convergence_rate
- lower_bound
- generalization_bound
- regret_bound
- minimax_rate
- mixing_time
- sample_complexity
- approximation_rate
- structural-characterization

### setting
- deterministic
- stochastic_iid
- stochastic_finite_sum
- online_adversarial
- Bayesian
- heavy_tailed
- interpolation
- DP
- high_dim_proportional

### iterate_type
- last
- averaged_uniform
- best
- Polyak_Ruppert
- N/A

### meta_template
- cancellation_pair
- exp_supermartingale
- couple_track
- polytope_construction
- le_cam_testing
- lyapunov_potential
- descent_lemma_telescope
- fixed_point_contraction
- spectral_eigenvalue
- drift_diffusion
- scheme_dependent_construction
- conjecture_rescue
- OTHER:surrogate_then_recover
- OTHER:self_bounding
- OTHER:algebraic_index_shift
- OTHER:polynomial_threshold
- OTHER:algorithm_existential_refutation
- OTHER:test-asymmetry-refutation
- OTHER:integral_representation_combinatorics
- OTHER:product_rule_decomposition
- OTHER:expand_then_match
- OTHER:matrix_concentration
- OTHER:structured_mesh_construction
- OTHER:divergence_direction_analysis
- OTHER:frequency_basis_bottleneck
- OTHER:posterior_dominance
- OTHER:closed_form_block_minimization
- OTHER:divergence_stability
- OTHER:cone_constraint
- OTHER:product_amplification
- OTHER:integrability_phase_transition

---

**Total signatures: 69**
