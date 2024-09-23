import osc from "osc";

function main() {
  const oscPort = new osc.UDPPort({
    remoteAddress: "localhost",
    remotePort: "8765"
    // url: "ws://127.0.0.1:8765",
    // metadata: true,
  })
  oscPort.open();

  let timer = 1;


  function sendStatus() {
    console.log(`sending ${timer}`)
    oscPort.send({
      timeTag: osc.timeTag(0),
      packets: [
        {
          address: "/lx/tempo/beat",
          args: [
            {type: "i",
              value: timer
            }]
        },
        {
          address: "/lx/tempo/setBPM",
          args: [{
            type: "d",
            value: 120.0
          }]
        }
      ]
    })
    timer = timer % 4 + 1
  }

  setInterval(sendStatus, 500)
}

main()
