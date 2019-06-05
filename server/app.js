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
        // device online 
        let topicStr = topic.replace('device/online/', '')
        let {pk, dn} = this.getDeviceInfo(topicStr)
        const status = {online: 1}
        that.updateStatus(pk, dn, status)
      } else if (topic.startsWith('device/receiveIR')) {
        // device receive ircode 
        let topicStr = topic.replace('device/receiveIR/', '')
        let {pk, dn} = this.getDeviceInfo(topicStr)
        that.publishIRCode2App(pk, dn, message)
      } else if (topic.startsWith('device/status')) {
        // device update status 
        let topicStr = topic.replace('device/status/', '')
        let {pk, dn} = getDeviceInfo(topicStr)
        const msgObj = JSON.parse(message)
        const key  = msgObj['name']
        const status = {key: msgObj['value']}
        that.updateStatus(pk, dn, status)
        that.publishStatus2App(pk, dn, JSON.stringify(status))   
      }
    })
  }

  getDeviceInfo(topicStr) {
    let array = topicStr.split('/')
    if (array.length != 2) {
      return;
    }
    const pk = array[0]
    const dn = array[1]
    return {pk, dn}
  }

  async updateStatus(pk, dn, status) {
    const ctx = await this.app.createAnonymousContext()
    ctx.service.device.updateStatus({key: pk + "/" + dn, status}); 
  }


  async publishIRCode2App(pk, dn, message) {
    const ctx = await this.app.createAnonymousContext()
    const topic = await ctx.service.device.getTopicByDevice(pk, dn)
    if (topic) {
      client.publish('user/' + topic + '/study', message)
    }
  }

  async publishStatus2App(pk, dn, message) {
    const ctx = await this.app.createAnonymousContext()
    const topic = await ctx.service.device.getTopicByDevice(pk, dn)
    if (topic) {
      client.publish('user/' + topic + 'property/update', message)
    }
  }

  subscribeTopic() {
    // console.log("subscribeTopic")
    client.subscribe('device/online/+/+', (err) => {
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

    client.subscribe('device/status/update', (err) => {
      if (err) {
        console.log(err)
      }
    })

    client.subscribe('')

  }

  async beforeClose() {
    console.log('beforeClose')
    // client.end()
  }

}

module.exports = AppBootHook