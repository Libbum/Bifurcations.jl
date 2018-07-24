module TestReparametrizedBautin
include("preamble.jl")

using Setfield: compose
using StaticArrays: SVector, SMatrix

using Bifurcations: Codim1, Codim2, resolved_points, reparametrize
using Bifurcations.Codim2LimitCycle: FoldLimitCycleProblem
using Bifurcations.Examples: Bautin
using Bifurcations.Examples.Reparametrization: orig_p

@testset for opts in [
        [],
        [:extra => SVector(-1.0)],
        [:extra => SVector(-1.0), :shift => 0.1, :seed => 1],
        ]

    prob = reparametrize(
        Bautin.make_prob(),
        ; opts...)
    solver1 = init(prob)
    solve!(solver1)

    codim1_points = resolved_points(solver1)
    @test length(codim1_points) == 1
    @test codim1_points[1].point_type === Codim1.PointTypes.hopf
    @test codim1_points[1].u[end] ≈ 0  atol=1e-6

    hopf_prob = BifurcationProblem(
        codim1_points[1],
        solver1,
        compose((@lens _.β₂), orig_p),
        (-2.0, 2.0),
    )
    hopf_solver = init(
        hopf_prob;
    )
    solve!(hopf_solver)

    hopf_β₁ = [u[end-1] for sweep in hopf_solver.super.sol.sweeps for u in sweep.u]
    hopf_β₂ = [u[end]   for sweep in hopf_solver.super.sol.sweeps for u in sweep.u]
    @test all(@. abs(hopf_β₁) < 1e-6)
    @test maximum(hopf_β₂) > 2
    @test minimum(hopf_β₂) < -2

    codim2_points = resolved_points(hopf_solver)
    @test length(codim2_points) == 1
    @test codim2_points[1].point_type === Codim2.PointTypes.bautin
    β_bautin = codim2_points[1].u[end-1:end]
    @test all(@. abs(β_bautin) < 1e-6)

    flc_prob = FoldLimitCycleProblem(
        codim2_points[1],
        hopf_solver;
        num_mesh = 20,
        degree = 3,
    )
    @test flc_prob.t_domain == ([-2.0, -2.0], [2.0, 2.0])
    flc_solver = init(
        flc_prob;
        start_from_nearest_root = true,
        max_branches = 0,  # TODO: stop manually doing this
    )
    solve!(flc_solver)

    flc_β₁ = [u[end-1] for sweep in flc_solver.super.sol.sweeps for u in sweep.u]
    flc_β₂ = [u[end]   for sweep in flc_solver.super.sol.sweeps for u in sweep.u]
    @test all(@. abs(4 * flc_β₁ + flc_β₂^2) < 5e-3)
    @test maximum(flc_β₂) > 2
    @test minimum(flc_β₂) > -1e-3
end

end  # module
