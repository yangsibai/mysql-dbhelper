mysql = require("mysql")
_ = require("underscore")

class DbHelper
    constructor: (_cfg)->
        @cfg =
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
        for key, value of _cfg
            @cfg[key] = value

    createConnection: ->
        _options = @cfg
        conn = mysql.createConnection(@cfg.dbConfig)

        endConnectionProxy = conn.end

        #auto close connection when timeout
        timeoutObj = setTimeout ->
            try
                unless conn._socket._readableState.ended
                    endConnectionProxy.apply(conn)
                else
                    console.error("connection has been closed, last query:#{conn.lastQuery}")
            catch e
                console.log e.message, conn.lastQuery
        , @cfg.timeout * 1000

        conn.end = (cb)->
            clearTimeout(timeoutObj)
            unless conn._socket._readableState.ended
                return endConnectionProxy.apply(this, arguments)
            else
                console.error("connection has been closed, last query:#{conn.lastQuery}")
                cb(new Error("connection has been closed, last query:#{conn.lastQuery}"))

        queryProxy = conn.query


        ###
            执行 sql
            @param {String} sql
            @param {Array} paras parameters array
            @param {Function} cb callback function
        ###
        conn.query = (sql, paras, cb)->
            conn.lastQuery = sql
            if _.isFunction(paras) and _.isUndefined(cb)
                cb = paras
                paras = []
            queryProxy.call this, sql, paras, (err, result)->
                if err
                    console.dir err if _options.debug
                    _options.onError err
                    err = _options.customError if _options.customError
                cb err, result if _.isFunction(cb)

        conn.execute = conn.query

        ###
            查询并在完成后立即关闭连接
            @param {String} sql
            @param {Array} [paras]
            @param {Function} cb callback function
        ###
        conn.$execute = (sql, paras, cb)->
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
        conn.executeScalar = (sql, paras, cb) ->
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
        conn.$executeScalar = (sql, paras, cb)->
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
        conn.update = (sql, paras, cb)->
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
        conn.$update = (sql, paras, cb)->
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
        conn.insert = (sql, paras, cb)->
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
        conn.$insert = (sql, paras, cb)->
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
        conn.executeNonQuery = (sql, paras, cb)->
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
        conn.$executeNonQuery = (sql, paras, cb)->
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
        conn.executeFirstRow = (sql, paras, cb)->
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
        conn.$executeFirstRow = (sql, paras, cb)->
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
        conn.exist = (sql, paras, cb)->
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
        conn.$exist = (sql, paras, cb)->
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

        return conn

module.exports = exports = (options)->
    return new DbHelper(options)
