-- Util
import OptExt.Util.SpanRestricted
import OptExt.Util.ExpectationInner

-- Layer 1: stochastic methods
import OptExt.StochasticOracle
import OptExt.SGD
import OptExt.HeavyBall

-- Layer 2: lower bounds
import OptExt.OracleModel
import OptExt.NesterovLowerBound
import OptExt.StrongConvexLowerBound
import OptExt.SHBLowerBound

-- Layer 3: algorithm extensions
import OptExt.MirrorDescent
import OptExt.FrankWolfe
import OptExt.AcceleratedStronglyConvex
