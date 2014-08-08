##mysql-helper
对 node.js mysql 的一个简单包装

##api

	dbHelper=require("mysql-dbhelper")(options)

	conn=dbHelper.createConnection()

###options
    defaultOptions=
        dbConfig:
            host: 'localhost',
            user: 'root',
            port: 3306,
            password: '',
            database: 'test'
        onError: (err)->
            console.dir err
        customError: null
        timeout: 60
        debug: true

###conn.execute

执行 sql 然后返回执行结果

	conn.execute(sql,[params],cb)
	
	cb=function(err,result){
		conn.length //返回结果集的行数
		conn.insertId //insert 语句插入完成后的自增id
		conn.affectedRows //受影响的行数
	}

###conn.executeScalar

执行 sql 然后返回第一行第一列的值，如果没有，返回 null

	conn.executeScalar(sql,[params],cb)
	
	cb=function(err,val){
	}

###conn.executeFirstRow

执行 sql 然后返回第一行的内容,如果没有，返回null

	conn.executeFirstRow(sql,[params],cb)

    cb=function(err,firstRow){
        
    }

###conn.executeNonQuery

执行 sql 然后返回受影响的行数

	conn.executeNonQuery(sql,[params],cb)

    cb=function(err,affectRows){
        
    }

###conn.update

执行 update 语句，然后返回是否成功，和真实受影响的行数

	conn.update(sql,[params],cb)
    
    cb=function(err,success,affectedRows){
        
    }

###conn.insert

执行 insert 语句，然后返回是否成功，和自增 id

	conn.insert(sql,[params],cb)

    cb=function(err,success,insertId){
        
    }

###conn.exist

执行 sql ,返回是否存在查询结果

	conn.insert(sql,[params],cb)

    cb=function(err,exist){
        
    }
