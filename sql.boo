namespace com.voodoowarez.Eve.Retrieve

import Npgsql

import System
import System.Data
import System.Data.Common
import System.Configuration

class SqlFactory:

	static _conn as IDbConnection
	
	static Connection as IDbConnection:
		get:
			if not _conn:
				#NpgsqlEventLog.Level = LogLevel.Debug
				#NpgsqlEventLog.LogName = "npgsql.log"
				#NpgsqlEventLog.EchoMessages = true
				_conn = NpgsqlConnection(ConfigurationSettings.AppSettings["dbConnString"]);
			return _conn
	
	static def RunQuery(query as string):
		conn = Connection
		conn.Open()
		adapter = NpgsqlDataAdapter(query,conn)
		dataSet = DataSet()
		adapter.Fill(dataSet)
		conn.Close()
		return dataSet
	
	static def RunSprocScalar(sprocName as string, params as (DbParameter)):
		cmd,conn = _RunSproc(sprocName, params)
		o = (cmd as NpgsqlCommand).ExecuteScalar()
		(conn as IDbConnection).Close()
		return o
	
	static def RunSprocNonQuery(sprocName as string, params as (DbParameter)):
		cmd,conn = _RunSproc(sprocName, params)
		(cmd as NpgsqlCommand).ExecuteNonQuery()
		(conn as IDbConnection).Close()
	
	static def RunSprocReader(sprocName as string, params as (DbParameter)):
		cmd,conn = _RunSproc(sprocName, params)
		return (cmd as NpgsqlCommand).ExecuteReader()
	
	static def RunCommand(command as string, params as (DbParameter)):
		conn = Connection
		conn.Open()
		sproc = NpgsqlCommand(command,conn)
		sproc.CommandTimeout = 600
		for param in params:
			sproc.Parameters.Add(param)
		sproc.ExecuteNonQuery()
		conn.Close()
	
	static private def _RunSproc(sprocName as string, params as (DbParameter)):
		conn = Connection
		conn.Open()
		sproc = NpgsqlCommand(sprocName,conn)
		sproc.CommandType = CommandType.StoredProcedure
		sproc.CommandTimeout = 600
		for param in params:
			sproc.Parameters.Add(param)
		return (sproc,conn)


