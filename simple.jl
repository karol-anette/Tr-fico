using Agents, Random
using StaticArrays: SVector

# Definir ambos tipos de agentes
@agent struct Car(ContinuousAgent{2,Float64})
    vel::SVector{2,Float64}
    max_speed::Float64
    accel::Float64
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

        semaphore_color = :green
        for a in allagents(model)
            if a isa TrafficLight
                semaphore_color = a.color
                break
            end
        end
        
        # Verificar si está cerca del semáforo y debe detenerse
        distance_to_semaphore = abs(agent.pos[1] - semaphore_pos[1])
        
        ahead = filter(a -> a isa Car && a.pos[1] > agent.pos[1], allagents(model))
        dist_ahead = minimum([a.pos[1] - agent.pos[1] for a in ahead]; init=Inf)

        # Decidir frenar o acelerar
        should_brake = false
        if (semaphore_color in [:red, :yellow]) && (distance_to_semaphore > 0) && (distance_to_semaphore < stop_distance)
            should_brake = true
        elseif dist_ahead < 1.5   # si hay un auto demasiado cerca
            should_brake = true
        end
        
        # Magnitud de la velocidad actual
        speed = norm(agent.vel)

        if should_brake
            # Frenar (no negativo)
            speed = max(0.0, speed - agent.accel)
        else
            # Acelerar hasta max_speed
            speed = min(agent.max_speed, speed + agent.accel)
        end

        # Actualizar vector de velocidad (mantenemos solo movimiento en x)
        agent.vel = SVector(speed, 0.0)

        # Si no debe detenerse, moverse normalmente
        move_agent!(agent, model, speed)
        
    elseif agent isa TrafficLight
        # El semáforo no se mueve, solo está ahí
        nothing
    end
end

function average_speed(model)
    cars = [a for a in allagents(model) if a isa Car]
    if isempty(cars)
        return 0.0
    end
    mean(norm(a.vel) for a in cars)
end

function initialize_model(extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    # Usar Union para ambos tipos de agentes
    model = StandardABM(Union{Car, TrafficLight}, space2d; rng, agent_step!, scheduler = Schedulers.ByType())

    semaphore_area = (10.0, 15.0)  # Área a excluir alrededor del semáforo

    num_cars = 5
    base_y = 5.0
    placed = 0
    tries = 0
    while placed < num_cars && tries < 200
        px = rand(rng) * extent[1]
        tries += 1
        if px < semaphore_area[1] || px > semaphore_area[2]
            velocidad = rand(rng) * 0.5 + 0.3  # Velocidad inicial entre 0.3 y 0.8
            max_speed = velocidad + 0.6        # tope razonable
            accel = 0.05                       # aceleración pequeña y constante
            add_agent!(SVector{2, Float64}(px, base_y), model,
                       vel=SVector{2, Float64}(velocidad, 0.0),
                       max_speed=max_speed,
                       accel=accel)
            placed += 1
        end
    end

    # Agregar el semáforo (posición fija en el centro)
    add_agent!(SVector{2, Float64}(12.5, 5.0), model, :red)  # Inicia en rojo

    model
end