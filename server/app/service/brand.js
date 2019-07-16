
const Service = require('egg').Service


class BrandService extends Service {
  
  async getBrandList() {
    const brandList = await this.app.mysql.select('brand') 
    return brandList
  }

  async getBrandMode(brandId) {
    console.log("brandId" + brandId)
    let mode = await this.app.mysql.select('brand_mode', {where: { brand_id: brandId }})
    return mode
  } 


}

module.exports = BrandService 