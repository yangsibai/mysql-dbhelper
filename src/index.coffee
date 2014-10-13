###
created by massimo on 14-3-14.
###

mysql = require("mysql")
_ = require("underscore")

###
    default config
###
_options =
    dbConfig:
        host: 'localhost',
        user: 'root',
        port: 3306,
        password: '',
        database: 'test'
    onError: (err)->
        console.dir err
    customError: null
    timeout: 30
    debug: false

###
    获取连接
    @param {function} cb callback function
###
createConnection = () ->
    conn = mysql.createConnection(_options.dbConfig)

    proxied = conn.end

    #auto close connection when timeout
    timeoutObj = setTimeout ->
        unless conn._socket._readableState.ended
            proxied.apply(conn)
        else
            console.warn("connection has been closed, last query:#{conn.lastQuery}")
    , _options.timeout * 1000

    conn.end = (cb)->
        clearTimeout(timeoutObj)
        unless conn._socket._readableState.ended
            return proxied.apply(this, arguments)
        else
            console.warn("connection has been closed, last query:#{conn.lastQuery}")

    queryProxied = conn.query
    conn.query = ->
        conn.lastQuery = arguments[0]
        return queryProxied.apply(this, arguments)

    conn.execute = ->
        execute.apply(this, arguments)

    conn.executeScalar = ->
        executeScalar.apply(this, arguments)

    conn.executeFirstRow = ->
        executeFirstRow.apply(this, arguments)

    conn.executeNonQuery = ->
        executeNonQuery.apply(this, arguments)

    conn.update = ->
        update.apply(this, arguments)

    conn.insert = ->
        insert.apply(this, arguments)

    conn.exist = ->
        exist.apply(this, arguments)

    conn.$execute = ->
        $execute.apply(this, arguments)

    conn.$executeScalar = ->
        $executeScalar.apply(this, arguments)

    conn.$executeFirstRow = ->
        $executeFirstRow.apply(this, arguments)

    conn.$executeNonQuery = ->
        $executeNonQuery.apply(this, arguments)

    conn.$update = ->
        $update.apply(this, arguments)

    conn.$insert = ->
        $insert.apply(this, arguments)

    conn.$exist = ->
        $exist.apply(this, arguments)

    return conn

###
    执行 sql
    @param {String} sql
    @param {Array} paras parameters array
    @param {Function} cb callback function
###
execute = (sql, paras, cb) ->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @query sql, paras, (err, result)->
        if err
            console.dir err if _options.debug
            _options.onError err # catch error
            err = _options.customError if _options.customError # hide real error
        cb err, result if _.isFunction(cb)

###
    查询并在完成后立即关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$execute = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    查询第一行第一列的内容
    @param {String} sql
    @param {Array} paras parameters array
    @param {Function} cb callback function
###
executeScalar = (sql, paras, cb) ->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, (err, result)->
        if _.isFunction cb
            if err
                cb err
            else if result.length > 0
                for name,value of result[0]
                    cb null, value
                    return
            else
                cb null, null

###
    查询第一行第一列的内容，然后自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$executeScalar = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @executeScalar sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    更新
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
update = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, (err, result)->
        if _.isFunction(cb)
            if err
                cb err
            else if result.changedRows > 0
                cb null, true, result.changedRows
            else
                cb null, false

###
    更新并且自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$update = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @update sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    插入
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
insert = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, (err, result)->
        if _.isFunction(cb)
            if err
                cb err
            else if result.affectedRows > 0
                cb null, true, result.insertId
            else
                cb null, false

###
    插入数据并且自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$insert = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @insert sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    执行sql,返回受影响的行数
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
executeNonQuery = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, (err, result)->
        if _.isFunction(cb)
            if err
                cb err
            else if result.affectedRows > 0
                cb null, true, result.affectedRows
            else
                cb null, false

###
    执行sql,返回受影响的行数，然后自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$executeNonQuery = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @executeNonQuery sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    获取第一行数据
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
executeFirstRow = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @execute sql, paras, (err, result)->
        if _.isFunction(cb)
            if err
                cb err
            else if result.length > 0
                cb null, result[0]
            else
                cb null, null

###
    获取第一行的数据，然后自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$executeFirstRow = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []
    @executeFirstRow sql, paras, ()=>
        cb.apply this, arguments if _.isFunction(cb)
        @end()

###
    判断是否存在
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
exist = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []

    @execute sql, paras, (err, results)->
        if _.isFunction(cb)
            if err
                cb err
            else if results.length > 0
                cb null, true, results
            else
                cb null, false, results

###
    判断是否存在，然后自动关闭连接
    @param {String} sql
    @param {Array} [paras]
    @param {Function} cb callback function
###
$exist = (sql, paras, cb)->
    if _.isFunction(paras) and _.isUndefined(cb)
        cb = paras
        paras = []

    @execute sql, paras, (err, results)=>
        if _.isFunction(cb)
            if err
                cb err
            else if results.length > 0
                cb null, true, results
            else
                cb null, false, results
            @end()

module.exports = exports = (options)->
    for key,value of options
        _options[key] = value

    return (
        createConnection: createConnection
    )
