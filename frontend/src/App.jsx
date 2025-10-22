import { useState, useRef } from 'react';

export default function App() {
  let [location, setLocation] = useState("");  
  let [cars, setCars] = useState([]);
  let [trafficLights, setTrafficLights] = useState([]);
  const running = useRef(null);

  let setup = () => {
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).then(resp => resp.json())
    .then(data => {
      setLocation(data["Location"]);  
      setCars(data["cars"] || []);
      setTrafficLights(data["traffic_lights"] || []);
    });
  }

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
  }

  const getTrafficLightColor = (state) => {
    switch(state) {
      case "GREEN": return "green";
      case "YELLOW": return "yellow";
      case "RED": return "red";
      default: return "gray";
    }
  }

  return (
    <div>
      <div>
        <button onClick={setup}>
          Setup
        </button>
        <button onClick={handleStart}>
          Start
        </button>
        <button onClick={handleStop}>
          Stop
        </button>
      </div>
      
      <svg width="800" height="600" xmlns="http://www.w3.org/2000/svg" style={{backgroundColor:"darkgreen"}}>
        {/* Calles */}
        <rect x={0} y={250} width={800} height={100} style={{fill: "gray"}} />
        <rect x={350} y={0} width={100} height={600} style={{ fill: "gray" }} />
        
        {/* Semáforos */}
        {trafficLights.map(light =>
          <rect 
            key={light.id}
            x={light.pos[0] * 32 - 8} 
            y={light.pos[1] * 60 - 8} 
            width="16" 
            height="16" 
            fill={getTrafficLightColor(light.state)}
            stroke="black"
            strokeWidth="1"
          />
        )}
      </svg>
    </div>
  );
}