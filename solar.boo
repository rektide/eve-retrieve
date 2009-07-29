namespace com.voodoowarez.Eve.Retrieve

import System
import System.Data

import Npgsql
import Jayrock.Json
import Jayrock.Json.Conversion

class SolarExporter (Jayrock.Json.Conversion.IExporter):

	c = 299792458.0

	InputType as Type:
		get:
			return typeof(DataSet)

	def Export(context as ExportContext, v as Object, writer as JsonWriter):
		table = (v as DataSet).Tables[0]
		writer.WriteStartArray()
		for row as DataRow in table.Rows:
			writer.WriteStartArray()
			writer.WriteString(row["solarsystemname"])
			writer.WriteNumber(cast(Int32,row["solarsystemid"]))
			writer.WriteNumber(cast(Int32,row["constellationid"]))
			writer.WriteNumber(cast(Int32,row["regionid"]))
			writer.WriteNumber(cast(Double,row["x"])/c)
			writer.WriteNumber(cast(Double,row["y"])/c)
			writer.WriteNumber(cast(Double,row["z"])/c)
			writer.WriteEndArray()
		writer.WriteEndArray()
			

class SolarRetrieve:

	static def PerRegion(regionId as String):
		return runQuery("Select * from mapsolarsystems where regionid = '"+regionId+"';")

	static def PerConstellation(constellationId as String):
		return runQuery("select * from mapsolarsystems where constellationid = '"+constellationId+"';")
	
	static private def runQuery(query as String):
		conn = SqlFactory.Connection
		conn.Open()
		adapter = NpgsqlDataAdapter(query,conn)
		dataSet = DataSet()
		adapter.Fill(dataSet)
		conn.Close()
		return dataSet

dataSet = SolarRetrieve.PerConstellation(argv[0])
writer = JsonTextWriter(Console.Out)
JsonConvert.Export(dataSet, writer)

