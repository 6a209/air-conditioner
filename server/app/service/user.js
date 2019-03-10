
const Service = require('egg').Service

class UserService extends Service {

    async findUser(openId) {
        const user = await this.app.mysql.get('user', {openId: openId})
        return user
    } 

    async createUser(user) {
        const result = await this.app.mysql.insert('user', user)
        const insertSuccess = result.affectedRows === 1
        return insertSuccess 
    }

    async updateUser(user) {
        await this.app.mysql.update('user', user)
        const insertSuccess = result.affectedRows === 1
        return insertSuccess 
    }
}

module.exports = UserService