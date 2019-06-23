var mqtt = require('mqtt')

console.log("connect!!!!!")

class AppBootHook {
  constructor(app) {
    this.app = app
    this.client = mqtt.connect('mqtt://192.168.4.92:1883', {
      clientId: "egg" + Date.now()
    })

    this.app.client = this.client
  }

  async serverDidReady() {
    console.log('serverDidReady')
    // init mqtt 
    this.subscribeTopic()
    this.client.on('connect', () => {
      console.log('connect')
      this.subscribeTopic()
    })
    this.client.on('close', () => {
      console.log('close')
    })
    this.client.on('error', (error) => {
      console.log('error')
      console.log(error)
    })
    this.client.on('reconnect', () => {
      console.log('reconnect')
    })

    let that = this
    this.client.on('message', (topic, message) => {
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
        console.log('*(*(*(*(*(*(*(*(*((*')
        const obj = JSON.parse(message)
        console.log("length " + obj.data.length)
        that.publishIRCode2App(pk, dn, message)
      } else if (topic.startsWith('device/status')) {
        // device update status 
        let topicStr = topic.replace('device/status/', '')
        let {pk, dn} = this.getDeviceInfo(topicStr)
        const msgObj = JSON.parse(message)
        const name  = msgObj['name']
        const status = {} 
        status[name] = msgObj['value']
        console.log(status)
        that.updateStatus(pk, dn, status)
        that.publishStatus2App(pk, dn, message)   
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
    let topic = await ctx.service.device.getTopicByDevice(pk, dn)
    topic = "user/" + topic + "/study"
    if (topic) {
      console.log("publishIRCode2App")
      console.log(topic)
      console.log(message)
      this.client.publish(topic, message)
    }
  }

  async publishStatus2App(pk, dn, message) {
    console.log("publishStatus2App")
    console.log(message)
    const ctx = await this.app.createAnonymousContext()
    let topic = await ctx.service.device.getTopicByDevice(pk, dn)
    topic = 'user/' + topic + '/property/update'; 
    console.log(topic)
    if (topic) {
      this.client.publish(topic, message)
    }
  }

  subscribeTopic() {
    // console.log("subscribeTopic")
    this.client.subscribe('device/online/+/+', (err) => {
      //  
      if (err) {
        console.log(err)
        // client.publish('presence', 'Hello mqtt')
      }
    })
    this.client.subscribe('device/receiveIR/+/+', (err) => {
      // receive device ir code 
      if (err) {
        console.log(err)
      }
    })

    this.client.subscribe('device/status/+/+', (err) => {
      if (err) {
        console.log(err)
      }
    })

    // client.subscribe('')

  }

  async beforeClose() {
    console.log('beforeClose')
    // client.end()
  }

}

module.exports = AppBootHook