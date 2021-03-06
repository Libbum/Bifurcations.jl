#!/bin/bash
# -*- mode: julia -*-
#=
JULIA="${JULIA:-julia --color=yes --startup-file=no}"
export JULIA_PROJECT="$(dirname ${BASH_SOURCE[0]})"
exec ${JULIA} "${BASH_SOURCE[0]}" "$@"
=#

using Documenter

# https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables
if get(ENV, "TRAVIS", "") != "true"
    # Don't do anything outside Travis CI
elseif startswith(get(ENV, "TRAVIS_BRANCH", ""), "pre/")
    # For branches pre/*, deploy them into gh-pages.pre.
    branch = ENV["TRAVIS_BRANCH"]
    deploydocs(
        repo   = "github.com/tkf/Bifurcations.jl.git",
        branch = "gh-pages.pre",
        devbranch = branch,
        root   = @__DIR__,
    )
else
    deploydocs(
        repo   = "github.com/tkf/Bifurcations.jl.git",
        root   = @__DIR__,
    )
end
