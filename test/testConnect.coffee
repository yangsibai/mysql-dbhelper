sqlHelper = require('../src/index')
    dbConfig:
        host: '192.168.1.88',
        user: 'root',
        port: 3306,
        password: '',
        database: 'test'
    timeout: 2

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
    conn = sqlHelper.createConnection()
    sql = "select 1+1 as result;"
    conn.query sql, [], (err, result)->
        test.ok not err
        test.ok result.length > 0
        test.ok result[0].result is 2
        conn.end()
        test.done()

exports.testExecute = (test)->
    conn = sqlHelper.createConnection()

    sql = "select * from test;"

    conn.execute sql, (err, result)->
        test.ok not err
        test.ok result.length > 0
        conn.end()
        test.done()

exports.test$Execute = (test)->
    conn = sqlHelper.createConnection()
    sql = "select 1+1 as result;"
    conn.$execute sql, (err, result)->
        test.ok conn._socket._readableState.ended
        test.ok not err
        test.ok result.length > 0
        test.ok result[0].result is 2
        setTimeout ()->
            test.ok conn._socket._readableState.ended
            test.done()
        , 100

exports.testExecuteScalar = (test)->
    conn = sqlHelper.createConnection()
    sql = "select 1+1 as result,1+2 as result2;"

    conn.executeScalar sql, (err, result)->
        test.ok not err
        test.ok result is 2
        conn.end()
        test.done()

exports.test$ExecuteScalar = (test)->
    conn = sqlHelper.createConnection()
    sql = "select 1+1 as result,1+2 as result2;"

    conn.$executeScalar sql, (err, result)->
        test.ok not err
        test.ok result is 2
        conn.end (err)->
            test.ok err
            test.done()

exports.testEndConnection = (test)->
    conn = sqlHelper.createConnection()
    sql = "select 1 + 1 as result;"
    conn.executeScalar sql, (err, result)->
        test.ok not err
        test.ok result is 2
        conn.end (err)->
            test.ok not err
            conn.end (err)->
                test.ok err
                test.done()

exports.slowQuery = (test)->
    conn = sqlHelper.createConnection()
    sql = "select sleep(5);"
    conn.execute sql, (err, result)->
        test.ok not err
        test.done()
