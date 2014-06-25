sqlHelper = require('../lib/index')

dbConfig =
	host: '127.0.0.1',
	user: 'root',
	port: 3306,
	password: ' ',
	database: 'mockup'

###
    test if node unit work well
###
exports.testNodeUnitWork = (test)->
	test.ok(1 is 1)
	test.done()

###
    test mysql connection ok
###
exports.testCreateConnection = (test)->
	conn = sqlHelper.createConnection(dbConfig)
	conn.connect()
	sql = "select 1+1 as result;"
	conn.query sql, [], (err, result)->
		test.ok not err
		test.ok result.length > 0
		test.ok result[0].result is 2
		test.done()

exports.testExecute = (test)->
	conn = sqlHelper.createConnection(dbConfig)
	conn.connect()

	sql = "select 1+1 as result;"

	conn.execute sql, [], (err, result)->
		test.ok not err
		test.ok result.length > 0
		test.ok result[0].result is 2
		test.done()