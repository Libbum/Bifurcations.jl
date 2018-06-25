module TestSmoke
include("preamble_plots.jl")

using Bifurcations.Codim1: resolved_points, SpecialPoint
using Bifurcations.Examples: PROBLEMS

@testset "smoke PROBLEMS[$i]" for (i, prob) in enumerate(PROBLEMS)
    solver = init(prob)
    solve!(solver)
    points = resolved_points(solver)
    @test all(isa.(points, SpecialPoint))

    @testset "show" begin
        smoke_test_solver_show(solver)
    end

    @testset "plot" begin
        sol = solve(prob)
        @test_nothrow nullshow(plot(sol))
        @test_nothrow nullshow(plot(sol; include_points=true))
        @test_nothrow nullshow(plot(sol; bif_style=Dict()))

        @test_nothrow nullshow(plot(solver))
        @test_nothrow nullshow(plot(solver; include_points=false))

        for p in points
            @test_nothrow nullshow(plot(p))
        end
    end
end

@testset "warn" begin
    plot = Plots.plot
    solver = init(Bifurcations.Examples.Calcium.prob)
    solve!(solver)
    sol = solver.sol

    msg = "include_points = true"
    @test_warn msg nullshow(plot(sol.sweeps[1]; include_points=true))
    @test_warn msg nullshow(plot(sol; include_points=true))
    @test_warn msg nullshow(plot(solver))
end

end  # module
