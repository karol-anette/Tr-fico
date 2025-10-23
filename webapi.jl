include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()

    model = initialize_model()
    id = string(uuid1())
    instances[id] = model

    cars = [Dict(
        "id" => a.id,
        "pos" => a.pos,
        "vel" => a.vel,
        "type" => "car"
    ) for a in allagents(model) if a isa Car]

    traffic_lights = []
    
    for agent in allagents(model)
        push!(traffic_lights, Dict(
            "id" => agent.id,
            "pos" => agent.pos,
            "state" => string(agent.state),
            "type" => "traffic_light"
        ))
    end

    println("🚦 Enviando $(length(traffic_lights)) semáforos al frontend")

    json(Dict(
        "Location" => "/simulations/$id", 
        "id" => id, 
        "cars" => cars, 
        "traffic_lights" => traffic_lights
    ))
end

route("/simulations/:id", method = GET) do
    id = Genie.params(:id)
    model = instances[id]
    Agents.step!(model, 1)

     cars = [Dict(
        "id" => a.id,
        "pos" => a.pos,
        "vel" => a.vel,
        "type" => "car"
    ) for a in allagents(model) if a isa Car]
    
    traffic_lights = []
    
    for agent in allagents(model)
        push!(traffic_lights, Dict(
            "id" => agent.id,
            "pos" => agent.pos,
            "state" => string(agent.state),
            "type" => "traffic_light"
        ))
    end

    json(Dict(
        "cars" => cars,  
        "traffic_lights" => traffic_lights
    ))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS" 
Genie.config.cors_allowed_origins = ["*"]

up()