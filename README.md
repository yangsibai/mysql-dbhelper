##mysql-dbhelper

一个简单，易用，友好的 node-mysql 的包装类

[![NPM](https://nodei.co/npm/mysql-dbhelper.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/mysql-dbhelper/)

###Install

    npm install mysql-dbhelper

###Get Start

	dbHelper = require("mysql-dbhelper")(options);
	conn = dbHelper.createConnection();
	sql = "SELECT name FROM users WHERE id=?";
	userId = 1;
	conn.$executeScalar sql, [userId], function(err, name){
		// code
	};

###options

	defaultOptions = {
		dbConfig: {
			host: 'localhost',
			user: 'root',
			port: 3306,
			password: '',
			database: 'test'
		},
		onError: function(err){
			console.dir(err);
		},
		customError: null,
		timeout: 60,
		debug: false
	}

##api

以下所有方法，添加 `$` 开头表示执行 `sql` 结束后自动关闭连接。

例如 `conn.execute` 对应的自动关闭连接的方法为 `conn.$execute`。

所有方法中第二个参数参数数组 `params` 都是可以省略的。

###conn.execute(sql, [params,] callback)

执行 sql 然后返回执行结果

	conn.execute(sql, [params], function(err, res){
		console.log(result.length); //返回结果集的行数
		console.log(result.insertId); //insert 语句插入完成后的自增id
		console.log(result.affectedRows); //受影响的行数
    });

###conn.executeScalar(sql, [params,] callback)

执行 `sql` 然后返回第一行第一列的值，如果没有，返回 `null`

	conn.executeScalar(sql, [params], function(err, val){
		console.dir(err);
		console.log(val);
	});

###conn.executeFirstRow(sql, [params,] callback)

执行 `sql` 然后返回第一行的内容,如果没有，返回 `null`

	conn.executeFirstRow(sql, [params], (err, firstRow){
		console.dir(err);
		console.dir(firstRow);
	});

###conn.executeNonQuery(sql, [params,] callback)

执行 `sql` 然后返回受影响的行数

	conn.executeNonQuery(sql, [params], function(err, affectRowsCount){
		console.dir(err);
		console.log(affectRowsCount);
	});

###conn.update(sql, [params,] callback)

执行 `update` 语句，然后返回是否成功，和真实受影响的行数

	conn.update(sql, [params], function(err, success, affectedRows){
		console.dir(err);
		console.log(success);
		console.log(affectedRows);
	});

###conn.insert(sql, [params,] callback)

执行 `insert` 语句，然后返回是否成功，和自增 id

	conn.insert(sql, [params], function(err, success, insertId){
		console.dir(err);
		console.log(success);
		console.log(insertId);
	});

###conn.exist(sql, [params,] callback)

执行 `sql` ,返回是否存在查询结果

	conn.insert(sql, [params], function(err, exist){
		console.dir(err);
		console.log(exist);
	});

##TODO

+ more test
