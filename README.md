##mysql-dbhelper

A simple [node-mysql](https://github.com/felixge/node-mysql) utility to help you work with db operation easily.

[![NPM](https://nodei.co/npm/mysql-dbhelper.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/mysql-dbhelper/)

###Install

    npm install mysql-dbhelper

###Get Started

    dbHelper = require("mysql-dbhelper")(options);
    conn = dbHelper.createConnection();
    sql = "SELECT name FROM users WHERE id=?";
    userId = 1;
    conn.$executeScalar sql, [userId], function(err, name){
        // work with name
    };

###Options

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
        customError: null, // if specified, will hide original error, please catch real error by onError, this is handy when you don't want to show server error to user
        timeout: 30, // auto close connection after 30 seconds
        debug: false
    }

###Note

**1. All methods which start with a `$` mean that the connection will auto close after execute.**

For example:

    conn.$executeFirstRow('SELECT * FROM users WHERE id = ?', [1], function(err, row){
        //The connection has been closed, you don't need to execute `conn.end()`
    });

**2. Connection will auto close if db error occured:**

    sql = 'INSERT INTO users(email, password) VALUES (?, ?, ?)'; // This will cause a error
    params = ['foo@gmail.com', 'bar']
    conn.insert(sql, params, function(err, success){
        if(err){
            console.dir(err);  // Don't need a `conn.end`
        }
        else{
            // Do other things and don't forget close the connection
            console.log('success');
            conn.end();
        }
    });

This can be handy if you use `CoffeeScript`:

    conn.insert sql, params, (err, success)->
        return cb(err) if err # Don't need close connection if error occured.

        #Do other things and don't forget close the connection
        console.log 'success'
        conn.end()

**3. `params` can be omited in every api. If your sql don't need a param, just omit the second param.**

For example:

    conn.$execute('SELECT * FROM users', [], callback);

equals to:

    conn.$execute('SELECT * FROM users', callback);

##api

###conn.execute(sql, [params,] callback)

Execute a sql query:

    conn.execute(sql, [params], function(err, res){
        console.log(result.length);
        console.log(result.insertId);
        console.log(result.affectedRows);
    });

###conn.executeScalar(sql, [params,] callback)

Execute a sql and return first row and first column value, return `null` if don't have one.

    conn.executeScalar(sql, [params], function(err, val){
        console.dir(err);
        console.log(val);
    });

###conn.executeFirstRow(sql, [params,] callback)

Execute a sql and return first row, return `null` if don't have one.

    conn.executeFirstRow(sql, [params], (err, firstRow){
        console.dir(err);
        console.dir(firstRow);
    });

###conn.executeNonQuery(sql, [params,] callback)

Execute a sql and return affect rows count:

    conn.executeNonQuery(sql, [params], function(err, affectRowsCount){
        console.dir(err);
        console.log(affectRowsCount);
    });

###conn.update(sql, [params,] callback)

Execute a `update` query:

    conn.update(sql, [params], function(err, success, affectedRows){
        console.dir(err);
        console.log(success);
        console.log(affectedRows); //Note: affectedRows is real affected count
    });

###conn.insert(sql, [params,] callback)

Execute a `insert` query:

    conn.insert(sql, [params], function(err, success, insertId){
        console.dir(err);
        console.log(success);
        console.log(insertId);
    });

###conn.exist(sql, [params,] callback)

Execute a sql query, return `true` if has a query result

    conn.insert(sql, [params], function(err, exist, result){
        console.dir(err);
        console.log(exist);
    });

##License

MIT
