###
Created by massimo on 14-3-14.
###

mysql = require("mysql")
#helper = require("../services/helper")
_ = require("underscore")

options =
	dbConfig:
		host: 'localhost',
		user: 'root',
		port: 3306,
		password: '',
		database: 'default'
	log: (err)->
		console.dir err
	customError: null
	debug: true

###
    config
###
#module.exports = (_options)->
#	setOptions options, _options, true

###
获取数据库连接
@return {Connection}
###
getDbConnection = ->
	conn = mysql.createConnection(options.dbConfig)
	conn.connect()
	return conn

###
获取连接
@param {Function} cb callback function
###
exports.createConnection = (_dbConfig) ->
	conn = mysql.createConnection(_dbConfig)

	conn.execute = ()->
		execute.apply(this, arguments)

	return conn

###
记录异常并返回
@param {Error} err
@param {Function} [cb] callback function
@param {Error} [cusResponseError] custom response error
###
dbError = exports.dbError = (err, cb, cusResponseError) ->
#	helper.error err  if err instanceof Error
	unless config.isProduct()
		console.dir err
	cb cusResponseError or new Error("operation fail")  if _.isFunction(cb)

###
执行 sql
@param {String} sql
@param {Array} paras parameters array
@param {Function} cb callback function
###
execute = (sql, paras, cb) ->
	this.query sql, paras, (err, result) ->
		if err
			dbError err, cb
		else
			cb err, result

###
查询第一行第一列的内容
@param {String} sql
@param {Array} paras parameters array
@param {Function} cb callback function
###
exports.executeScalar = (conn, sql, paras, cb) ->
	conn = getDbConnection()
	conn.query sql, paras, (err, result) ->
		conn.end()
		if err
			dbError err, cb
		else
			if result.length > 0
				cb null, result[0][0]
			else
				cb null, null

###
执行语句返回受影响行数
@param {String} sql
@param {Array} paras parameters array
@param {Function} cb callback function
###
exports.executeNonQuery = (sql, paras, cb) ->
	conn = getDbConnection()
	conn.query sql, paras, (err, result) ->
		conn.end()
		if err
			dbError err, cb
		else
			cb null, result.affectedRows, result.insertId  if _.isFunction(cb)

###
    update
###
exports.executeUpdate = (sql, paras, cb)->
	conn = getDbConnection()
	conn.query sql, paras, (err, result)->
		conn.end()
		if err
			dbError err, cb
		else if result.affectedRows <= 0
			cb new Error("operation fail")
		else
			cb null

###
查询第一行
@param {String} sql
@param {Array} paras parameters array
@param {Function} cb callback function
###
exports.executeFirstRow = (sql, paras, cb) ->
	conn = getDbConnection()
	conn.query sql, paras, (err, result) ->
		conn.end()
		if err
			dbError err, cb
		else if result.length > 0
			cb null, result[0]
		else
			cb null, null

###
拼接sql
@param {Array} array sql array
@return {String}
###
exports.concatSql = (array) ->
	if _.isArray(array)
		array.join " "
	else
		throw new Error("parameter must be a array")

###
    set default options
    @param {Object} options options parameter
    @param {Object} defaultOptions default options
    @param {Boolean} override override options by defaultOptions or not
###
setOptions = (options, defaultOptions, override)->
	unless defaultOptions
		return
	unless options
		options = defaultOptions
	else
		for key,value of defaultOptions
			if override
				options[key] = value if defaultOptions[key]
			else
				options[key] = value unless options[key]