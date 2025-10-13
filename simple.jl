using Agents, Random
using StaticArrays: SVector

@agent struct Car(ContinuousAgent{2,Float64})
end

function agent_step!(agent, model)
    move_agent!(agent, model, 1.0)
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    model = StandardABM(Car, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())

    for px in randperm(25)[1:4]
        velocidad= rand()
        add_agent!(SVector{2, Float64}(px, 0.0), model; vel=SVector{2, Float64}(velocidad, 0.0))
    end
    model
end