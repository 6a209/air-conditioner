var mqtt = require('mqtt')

console.log("connect!!!!!")

class AppBootHook {
  constructor(app) {
    this.app = app
    this.client = mqtt.connect(this.app.config.mqtt.host)

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
        const obj = JSON.parse(message)
        console.log("length " + obj.data.length)
        that.publishIRCode2App(pk, dn, message)

      } else if (topic.startsWith('device/status')) {
        // device update status 
        let topicStr = topic.replace('device/status/', '')
        let {pk, dn} = this.getDeviceInfo(topicStr)
        const status = JSON.parse(message)
        console.log(status)
        that.updateStatus(pk, dn, status)
        that.publishStatus2App(pk, dn, message)   
      } else if (topic.startsWith('$SYS/brokers') && topic.endsWith("/disconnected")) {
        // device offline
        console.log("--- offline ---")
        console.log(topic) 
        let array = topic.split("/")
        if (array.length > 2 ) {
          array = array[2].split("_")
          pk = array[0]
          dn = array[1]
          const status = {online: 0}
          that.updateStatus(pk, dn, status)
        }
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
    await ctx.service.device.updateStatus({key: pk + "/" + dn, status}); 
  }


  async publishIRCode2App(pk, dn, message) {
    const ctx = await this.app.createAnonymousContext()
    let topic = await ctx.service.device.getTopicByDevice(pk, dn)
    if (topic) {
      topic = "user/" + topic + "/study"
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
    console.log(topic)
    if (topic) {
      topic = 'user/' + topic + '/property/update'; 
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

    this.client.subscribe("$SYS/brokers/+/clients/+/disconnected", (err) => {
      if (err) {
        console.log(err)
      }
    })

    // this.client.subscribe("$SYS/brokers/#", (err) => {
    //   if (err) {
    //     console.log(err)
    //   }
    // })
    // client.subscribe('')

  }

  async beforeClose() {
    console.log('beforeClose')
    // client.end()
  }

}

module.exports = AppBootHook