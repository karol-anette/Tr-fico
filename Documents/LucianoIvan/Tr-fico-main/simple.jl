using Agents, Random
using StaticArrays: SVector

# Definir ambos tipos de agentes
@agent struct Car(ContinuousAgent{2,Float64})
    vel::SVector{2,Float64}
    max_speed::Float64
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
                        # Desacelerar hasta detenerse
                        agent.vel = SVector{2,Float64}(0.0, 0.0)
                        return
                    else
                        # Acelerar hasta velocidad máxima
                        if agent.vel[1] < agent.max_speed
                            agent.vel = SVector{2,Float64}(agent.max_speed, 0.0)
                        end
                    end
                end
            end
        else
            # Si no está cerca del semáforo, mantener velocidad máxima
            if agent.vel[1] < agent.max_speed
                agent.vel = SVector{2,Float64}(agent.max_speed, 0.0)
            end
        end
        
        # Moverse con la velocidad actual
        move_agent!(agent, model, 1.0)
        
    elseif agent isa TrafficLight
        # El semáforo no se mueve
        nothing
    end
end

function initialize_model(num_cars = 3, extent = (25, 10))
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    # Usar Union para ambos tipos de agentes
    model = StandardABM(Union{Car, TrafficLight}, space2d; rng, agent_step!, scheduler = Schedulers.ByType())

    # Agregar múltiples autos en posiciones aleatorias
    semaphore_area = (10.0, 15.0)  # Área a excluir alrededor del semáforo
    cars_added = 0
    
    while cars_added < num_cars
        px = rand(rng) * extent[1]
        # Excluir área del semáforo y asegurar espacio entre autos
        if (px < semaphore_area[1] - 2.0 || px > semaphore_area[2] + 2.0)
            max_speed = rand(rng) * 0.4 + 0.3  # Velocidad máxima entre 0.3 y 0.7
            initial_speed = rand(rng) * max_speed  # Velocidad inicial aleatoria
            add_agent!(SVector{2, Float64}(px, 5.0), model, 
                      vel=SVector{2, Float64}(initial_speed, 0.0),
                      max_speed=max_speed)
            cars_added += 1
        end
    end

    # Agregar el semáforo (posición fija en el centro)
    add_agent!(SVector{2, Float64}(12.5, 5.0), model, :green)  # Inicia en verde

    model
end

# Función para calcular velocidad promedio
function average_speed(model)
    cars = [a for a in allagents(model) if a isa Car]
    if isempty(cars)
        return 0.0
    end
    speeds = [abs(car.vel[1]) for car in cars]  # Usar valor absoluto de la velocidad
    return sum(speeds) / length(speeds)
end

# Función para monitorear el progreso
function run_simulation_with_monitoring(num_cars, steps = 100)
    model = initialize_model(num_cars)
    speeds = Float64[]
    
    println("Iniciando simulación con $num_cars autos")
    
    for step in 1:steps
        step!(model)
        avg_speed = average_speed(model)
        push!(speeds, avg_speed)
        
        if step % 20 == 0
            println("Paso $step: Velocidad promedio = $(round(avg_speed, digits=3))")
        end
    end
    
    final_avg = round(average_speed(model), digits=3)
    println("Simulación completada. Velocidad promedio final: $final_avg")
    return final_avg
end

# Ejecutar simulaciones para 3, 5 y 7 autos
println("=== REPORTE DE VELOCIDADES PROMEDIO ===")
speed_3 = run_simulation_with_monitoring(3)
speed_5 = run_simulation_with_monitoring(5) 
speed_7 = run_simulation_with_monitoring(7)

println("\nRESUMEN FINAL:")
println("3 autos: velocidad promedio = $speed_3")
println("5 autos: velocidad promedio = $speed_5")
println("7 autos: velocidad promedio = $speed_7")