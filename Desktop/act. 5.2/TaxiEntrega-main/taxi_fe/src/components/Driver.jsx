import React, {useEffect, useState} from 'react';
import Button from '@mui/material/Button';

import socket from '../services/taxi_socket';
import { Card, CardContent, Typography } from '@mui/material';

function Driver(props) {
  let [message, setMessage] = useState();
  let [bookingId, setBookingId] = useState();
  let [visible, setVisible] = useState(false);
  useEffect(() => {
    let channel = socket.channel("driver:" + props.username, {token: "123"});
    channel.on("booking_request", data => {
      console.log("Received", data);
      setMessage(data.msg);
      setBookingId(data.bookingId);
      setVisible(true);
    });
    channel.join();
  },[props]);

  let reply = (decision) => {
    fetch(`http://localhost:4000/api/bookings/${bookingId}`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        action: "decision", 
        mensaje: decision,
        username: props.username, 
        id: bookingId
      })
    }).then(resp => setVisible(false));
  };

  return (
    <div style={{textAlign: "center", borderStyle: "solid"}}>
        Driver: {props.username}
        <div style={{backgroundColor: "lavender", height: "120px"}}>
          {
            visible ?
            <Card variant="outlined" style={{margin: "auto", width: "600px"}}>
              <CardContent>
                <Typography>
                {message}
                </Typography>
              </CardContent>
              {
                message === "Solicitud rechazada por inactividad" || message == "Solicitud tomada" || message == "Solicitud cancelada por el cliente" || message == "El cliente ha cancelado el viaje" ? (
                  <Button onClick={() => reply("ok")} variant="outlined" color="primary">Ok</Button>
                ) : (
                  <>
                    <Button onClick={() => reply("accept")} variant="outlined" color="primary">Accept</Button>
                    <Button onClick={() => reply("reject")} variant="outlined" color="secondary">Reject</Button>
                  </>
                )
              }
            </Card> :
            null
          }
        </div>
    </div>
  );
}

export default Driver;