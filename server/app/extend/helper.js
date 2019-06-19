

module.exports = {
  successRes(code, data) {
    const res = {}
    res.code = code
    res.msg = 'ok'
    res.data = data
    return res
  },

  failRes(code, msg) {
    console.log(msg)
    if (!msg) {
      msg = "unknow error"
    }
    const res = {}
    res.code = code
    res.msg = msg
    return res
  },
}