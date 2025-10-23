using Agents, Random
using StaticArrays: SVector

# Definir ambos tipos de agentes
@agent struct Car(ContinuousAgent{2,Float64})
    vel::SVector{2,Float64}
end

@agent struct TrafficLight(ContinuousAgent{2,Float64})
    color::Symbol
end

# Función agent_step! para ambos tipos de agentes
function agent_step!(agent, model)
    if agent isa Car
        # Posición del semáforo (asumimos que hay solo uno en posición fija)
        semaphore_pos = (12.5, 5.0)
        stop_distance = 3.0
        
        # Verificar si está cerca del semáforo y debe detenerse
        distance_to_semaphore = abs(agent.pos[1] - semaphore_pos[1])
        
        if distance_to_semaphore < stop_distance
            # Buscar el semáforo para ver su color
            for a in allagents(model)
                if a isa TrafficLight
                    if a.color in [:red, :yellow]
                        return  # No moverse - auto se detiene
                    end
                end
            end
        end
        
        # Si no debe detenerse, moverse normalmente
        move_agent!(agent, model, 1.0)
        
    elseif agent isa TrafficLight
        # El semáforo no se mueve, solo está ahí
        nothing
    end
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    # Usar Union para ambos tipos de agentes
    model = StandardABM(Union{Car, TrafficLight}, space2d; rng, agent_step!, scheduler = Schedulers.ByType())

    # Agregar UN solo auto en posición aleatoria excluyendo área del semáforo
    semaphore_area = (10.0, 15.0)  # Área a excluir alrededor del semáforo
    
    # Generar posición aleatoria fuera del área del semáforo
    while true
        px = rand(rng) * extent[1]
        if px < semaphore_area[1] || px > semaphore_area[2]
            velocidad = rand(rng) * 0.5 + 0.3  # Velocidad entre 0.3 y 0.8
            add_agent!(SVector{2, Float64}(px, 5.0), model, vel=SVector{2, Float64}(velocidad, 0.0))
            break
        end
    end

    # Agregar el semáforo (posición fija en el centro)
    add_agent!(SVector{2, Float64}(12.5, 5.0), model, :red)  # Inicia en rojo

    model
end