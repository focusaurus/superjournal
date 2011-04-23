exports.port = 9500
exports.appName = "SuperJournal"
exports.enableTests = false
exports.db =
  URL: 'mongodb://localhost:' + (exports.port + 1) + '/superjournal_dev'
exports.env =
  production: false
  staging: false
  test: false
  development: false
