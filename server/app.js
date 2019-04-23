var mqtt = require('mqtt')

console.log("connect!!!!!")
let client = mqtt.connect('mqtt://192.168.4.92:1883', {
  clientId: "egg" + Date.now() 
})

class AppBootHook {
  constructor(app) {
    this.app = app
    this.app.client = client
  }

  async serverDidReady() {
    console.log('serverDidReady')
    // init mqtt 
    this.subscribeTopic()
    client.on('connect', () => {
      console.log('connect')
      this.subscribeTopic()
    })
    client.on('close', () => {
      console.log('close')
    })
    client.on('error', (error) => {
      console.log('error')
      console.log(error)
    })
    client.on('reconnect', () => {
      console.log('reconnect')
    })

    let that = this
    client.on('message', (topic, message) => {
      console.log('message')
      console.log(topic)
      console.log(message)
      if (topic.startsWith('device/online')) {


      } else if (topic.startsWith('device/receiveIR')) {
        let topicStr = topic.replace('device/receiveIR/', '')
        let array = topicStr.split('/')
        if (array.length != 2) {
          return;
        }
        const pk = array[0]
        const dn = array[1]
        that.publishIRCode2App(pk, dn, message)
      }
    })
  }

  async publishIRCode2App(pk, dn, message) {
    const ctx = await this.app.createAnonymousContext()
    const topic = await ctx.service.device.getTopicByDevice(pk, dn)
    console.log("the topic -> ")
    console.log(topic)
    if (topic) {
      client.publish('user/' + topic + '/study', message)
    }
  }

  subscribeTopic() {
    // console.log("subscribeTopic")
    client.subscribe('device/online', (err) => {
      //  
      if (err) {
        console.log(err)
        // client.publish('presence', 'Hello mqtt')
      }
    })
    client.subscribe('device/receiveIR/+/+', (err) => {
      // receive device ir code 
      if (err) {
        console.log(err)
      }
    })

  }

  async beforeClose() {
    console.log('beforeClose')
    // client.end()
  }

}

module.exports = AppBootHook