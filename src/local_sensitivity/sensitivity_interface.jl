## Direct calls

function adjoint_sensitivities(sol,args...;
                                  sensealg=InterpolatingAdjoint(),
                                  kwargs...)
  _adjoint_sensitivities(sol,sensealg,args...;kwargs...)
end

function _adjoint_sensitivities(sol,sensealg,alg,g,t=nothing,dg=nothing;
                                   abstol=1e-6,reltol=1e-3,
                                   checkpoints=sol.t,
                                   corfunc_analytical=nothing,
                                   kwargs...)
  if sol.prob isa SDEProblem
    adj_prob = SDEAdjointProblem(sol,sensealg,g,t,dg,checkpoints=checkpoints,
                               abstol=abstol,reltol=reltol,corfunc_analytical=corfunc_analytical)
  else
    adj_prob = ODEAdjointProblem(sol,sensealg,g,t,dg,checkpoints=checkpoints,
                               abstol=abstol,reltol=reltol)
  end

  tstops = ischeckpointing(sensealg, sol) ? checkpoints : similar(sol.t, 0)
  adj_sol = solve(adj_prob,alg;
                  save_everystep=false,save_start=false,saveat=eltype(sol[1])[],
                  tstops=tstops,abstol=abstol,reltol=reltol,kwargs...)

  p = sol.prob.p
  l = p === nothing || p === DiffEqBase.NullParameters() ? 0 : length(sol.prob.p)
  -adj_sol[end][1:length(sol.prob.u0)],
    adj_sol[end][(1:l) .+ length(sol.prob.u0)]'
end

function _adjoint_sensitivities(sol,sensealg::SteadyStateAdjoint,alg,g,dg=nothing;
                                   abstol=1e-6,reltol=1e-3,
                                   kwargs...)
  SteadyStateAdjointProblem(sol,sensealg,g,dg;kwargs...)
end

function _adjoint_sensitivities(sol,sensealg::SteadyStateAdjoint,alg;
                                   g=nothing,dg=nothing,
                                   abstol=1e-6,reltol=1e-3,
                                   kwargs...)
  SteadyStateAdjointProblem(sol,sensealg,g,dg;kwargs...)
end

function second_order_sensitivities(loss,prob,alg,args...;
                                    sensealg=ForwardDiffOverAdjoint(InterpolatingAdjoint(autojacvec=ReverseDiffVJP())),
                                    kwargs...)
  _second_order_sensitivities(loss,prob,alg,sensealg,args...;kwargs...)
end

function second_order_sensitivity_product(loss,v,prob,alg,args...;
                                          sensealg=ForwardDiffOverAdjoint(InterpolatingAdjoint(autojacvec=ReverseDiffVJP())),
                                          kwargs...)
  _second_order_sensitivity_product(loss,v,prob,alg,sensealg,args...;kwargs...)
end
