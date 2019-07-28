const Service = require('egg').Service


class ProductService extends Service {

  async getUserProduct(uid) {
    const result = await this.app.mysql.select('userproduct', {where: { uid }})
    const productIds = []
    console.log(result)
    for (const item of result) {
      productIds.push(item.pid)
    }
    const userProduct = await this.app.mysql.select('product', {where: { id: productIds }})
    console.log(userProduct)
    return userProduct
  }

  async createProduct(uid, product) {
    let result = await this.app.mysql.insert('product', product)
    const pid = result.insertId
    result = await this.app.mysql.insert('userproduct', {uid, pid})
    return {pid} 
  }

  async updateProduct(product) {
    const result = await this.app.mysql.update('product', product)
    return result
  }

  async getProduct(pid) {
    const result = await this.app.mysql.get('product', { id: pid })
    return result;
  }

  async hasProduct(uid, pid) {
    const result = await this.app.mysql.get('userproduct', { uid, pid })
    return result
  }


  async createCommands({ productId, commands }) {
    // const conn = await app.mysql.beginTransaction(); 
    console.log(productId)
    console.log(commands)
    console.log(typeof commands)
    const rows = []
    try {
      for (let command of commands) {
        let item = {}
        item['name'] = command.name 
        item['value'] = command.value 
        item['irdata'] = command.irdata
        item['productId'] = productId
        rows.push(item)
      }
      console.log(rows)
      return await this.app.mysql.insert('command', rows)
    } catch (err) {
      console.log(err)
    }
  }

  async updateCommands({commands}) {
    try {
      console.log("commands")
      console.log(commands)
      return await this.app.mysql.updateRows('command', commands)
    } catch(err) {
      console.log(err)
    }
  }

  async getProductDetail(productId) {
    const commands = await this.app.mysql.select('command', {where: { 'productId': productId }})
    return commands
  }
}

module.exports = ProductService 
