import { useState, useRef } from 'react';

export default function App() {
  const [location, setLocation] = useState("");  
  const [cars, setCars] = useState([]);
  const [trafficLights, setTrafficLights] = useState([]);
  const running = useRef(null);

  // Inicializa la simulación (llama a Julia para crear el modelo)
  const setup = () => {
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
      setLocation(data["Location"]);
      setCars(data["cars"] || []);
      setTrafficLights(data["traffic_lights"] || []);
    });
  };

  // Empieza la simulación (actualiza autos y semáforos)
  const handleStart = () => {
    if (!location) {
      alert("Primero haz clic en Setup");
      return;
    }
    
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
        .then(res => res.json())
        .then(data => {
          setCars(data["cars"] || []);
          setTrafficLights(data["traffic_lights"] || []);
        });
    }, 500);
  };

  const handleStop = () => {
    clearInterval(running.current);
  };

  // Color del semáforo según el estado (Julia usa símbolos)
  const getTrafficLightColor = (color) => {
    switch(color) {
      case "green":
      case ":green": return "green";
      case "yellow":
      case ":yellow": return "yellow";
      case "red":
      case ":red": return "red";
      default: return "gray";
    }
  };

  return (
    <div style={{ textAlign: "center" }}>
      <div style={{ marginBottom: "10px" }}>
        <button onClick={setup}>Setup</button>
        <button onClick={handleStart}>Start</button>
        <button onClick={handleStop}>Stop</button>
      </div>

      <svg width="600" height="600" xmlns="http://www.w3.org/2000/svg" style={{ backgroundColor: "darkgreen" }}>
        {/* Carretera */}
        <rect x={0} y={140} width={800} height={40} fill="gray" />

        {/* Autos */}
        {cars.map((car, i) => (
          <rect
            key={i}
            x={car.pos[0] * 20}   // Escala la posición de Julia al SVG
            y={car.pos[1] * 20}
            width="20"
            height="10"
            fill="blue"
            stroke="black"
            strokeWidth="1"
          />
        ))}

        {/* Semáforos */}
        {trafficLights.map((light, i) => (
          <circle
            key={i}
            cx={light.pos[0] * 20}
            cy={light.pos[1] * 20}
            r="8"
            fill={getTrafficLightColor(light.color)}
            stroke="black"
            strokeWidth="1"
          />
        ))}
      </svg>
    </div>
  );
}