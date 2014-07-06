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
获取连接
@param {Function} cb callback function
###
exports.createConnection = (_dbConfig) ->
	conn = mysql.createConnection(_dbConfig)

	conn.execute = ->
		execute.apply(this, arguments)

	conn.executeScalar = ->
		executeScalar.apply(this, arguments)

	conn.update = ->
		update.apply(this, arguments)

	conn.insert = ->
		insert.apply(this, arguments)

	conn.executeFirstRow = ->
		executeFirstRow.apply(this, arguments)
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
	if _.isFunction(paras)
		cb = paras
		paras = []

	this.query sql, paras, (err, result) ->
		if _.isFunction(cb)
			if err
				cb err
			else
				cb err, result

###
查询第一行第一列的内容
@param {String} sql
@param {Array} paras parameters array
@param {Function} cb callback function
###
executeScalar = (sql, paras, cb) ->
	if _.isFunction(paras)
		cb = paras
		paras = []

	this.query sql, paras, (err, result) ->
		if _.isFunction(cb)
			if err
				cb err
			else
				if result.length > 0
					for name,value of result[0]
						cb null, value
						return
				else
					cb null, null

###
    更新
###
update = (sql, paras, cb)->
	if _.isFunction(paras)
		cb = paras
		paras = []

	this.query sql, paras, (err, result)->
		if _.isFunction(cb)
			if err
				cb err
			else if result.changedRows > 0
				cb null, true, result.changedRows
			else
				cb null, false

###
    插入
###
insert = (sql, paras, cb)->
	if _.isFunction(paras)
		cb = paras
		paras = []

	this.query sql, paras, (err, result)->
		if _.isFunction(cb)
			if err
				cb err
			else if result.affectedRows > 0
				cb null, true, result.insertId
			else
				cb null, false

###
    获取第一行数据
###
executeFirstRow = (sql, paras, cb)->
	if _.isFunction(paras)
		cb = paras
		paras = []

	this.query sql, paras, (err, result)->
		if _.isFunction(cb)
			if err
				cb err
			else if result.length > 0
				cb null, result[0]
			else
				cb null, null

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