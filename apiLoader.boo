namespace com.voodoowarez.Eve.Retrieve

import Npgsql

import System
import System.IO
import System.Net
import System.Data

# arguments

sproc, location = argv


# retrieve xml

wc as WebClient
data as Stream
reader as StreamReader

if location.StartsWith("eve://"):
	location = location.Substring(6)
	if(location == "status"):
		location = "/server/ServerStatus.xml.aspx"
	elif(location == "sov"):
		location = "/map/Sovereignty.xml.aspx"
	elif(location == "kills"):
		location = "/map/Kills.xml.aspx"
	elif(location == "jumps"):
		location = "/map/Jumps.xml.aspx"
	elif(location == "fwSov"):
		location = "/map/FacWarSystems.xml.aspx"
	elif(location == "name"):
		location = "/eve/CharacterName.xml.aspx"
	elif(location == "fwTop"):
		location = "/eve/FacWarTopStats.xml.aspx"
	elif(location == "stations"):
		location = "/eve/ConquerableStationList.xml.aspx"
	elif(location == "alliances"):
		location = "/eve/AllianceList.xml.aspx"
	location = "http://api.eve-online.com" + location	

print "heading to location", location

if location.StartsWith("http"):
	wc = WebClient()
	wc.Headers.Add("user-agent", "Eve Retrieve Log System/voodoowarez.com")
	data = wc.OpenRead(location)
	reader = StreamReader(data)
else:
	reader = StreamReader(location)
	

# load xml into parameters

xml = NpgsqlParameter()
xml.DbType = DbType.String
xml.Value = reader.ReadToEnd()


# clean up

data.Close() if data
reader.Close()
	

# execute

print "running sproc", sproc
SqlFactory.RunSprocNonQuery(sproc,(xml,))

