import osc from "osc";

function main() {
  const oscPort = new osc.WebSocketPort({
    url: "ws://localhost:7766",
    metadata: true,
  })
  oscPort.open();


  function sendStatus() {
    console.log("sending")
    oscPort.send({
      timeTag: osc.timeTag(0),
      packets: [
        {
          address: "/tempo/beat",
          args: [
            {type: "beat",
              value: 1
            }]
        },
        {
          address: "/tempo/setBPM",
          args: [{
            type: "setBPM",
            value: 120
          }]
        }
      ]
    })
  }

  setInterval(sendStatus, 3000)
}

main()
