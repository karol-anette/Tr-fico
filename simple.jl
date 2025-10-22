using Agents, Random
using StaticArrays: SVector
using Distributions  

@enum TrafficLightState begin
    GREEN
    YELLOW
    RED
end

@agent struct TrafficLight(GridAgent{2})
    state::TrafficLightState = GREEN
    timer::Int = 0
end

# Funcion solo para semaforos
function agent_step!(light::TrafficLight, model)
    light.timer += 1
    
    # Cambiar estados del semáforo segun tiempos
    if light.state == GREEN && light.timer >= 10
        light.state = YELLOW
        light.timer = 0
    elseif light.state == YELLOW && light.timer >= 4
        light.state = RED
        light.timer = 0
    elseif light.state == RED && light.timer >= 14
        light.state = GREEN
        light.timer = 0
    end
end

function initialize_model(extent = (25, 10))
    space2d = GridSpace(extent; periodic = true)
    rng = Random.MersenneTwister()

    model = StandardABM(TrafficLight, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())

    # Semaforo 1 
    add_agent!((20, 5), model, GREEN, 0)
    
    # Semaforo 2 
    # Iniciar en rojo
    add_agent!((12, 2), model, RED, 0)

    for light in allagents(model)
        println("   - Semáforo $(light.id): $(light.state) en posición $(light.pos)")
    end
    
    return model
end