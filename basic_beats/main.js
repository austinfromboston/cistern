import osc from "osc";

function main() {
  const oscPort = new osc.UDPPort({
    remoteAddress: "127.0.0.1",
    remotePort: "8765"
    // url: "ws://127.0.0.1:8765",
    // metadata: true,
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
            {type: "i",
              value: 1
            }]
        },
        {
          address: "/tempo/setBPM",
          args: [{
            type: "f",
            value: 120.0
          }]
        }
      ]
    })
  }

  setInterval(sendStatus, 3000)
}

main()
