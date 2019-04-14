const Service = require('egg').Service


class ProductService extends Service {

  async getUserProduct(uid) {
    const result = await this.app.mysql.select('userproduct', { uid })
    const productIds = []
    for (const item of result) {
      productIds.push(item.pid)
    }
    const userProduct = await this.app.mysql.select('product', { id: productIds })
    return userProduct
  }

  async createProduct(product) {
    const result = await this.app.mysql.insert('product', product)
    return result
  }

  async updateProduct(product) {
    const result = await this.app.mysql.update('product', product)
    return result
  }

  async hasProduct(uid, pid) {
    const result = await this.app.mysql.get('userproduct', { uid, pid })
    return result
  }
}

module.exports = ProductService 
