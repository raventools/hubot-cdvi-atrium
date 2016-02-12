# Description
#   Control CDVI Atrium security systems
#
# Configuration:
#   HUBOT_ATRIUM_URL - URL (without trailing slash) to Atrium web software
#   HUBOT_ATRIUM_USERNAME - Login username
#   HUBOT_ATRIUM_PASSWORD - Login password
#   HUBOT_DOOR_IDS - Unique identifiers for doors
#
# Commands:
#   hubot door me - Unlock the door
#
# Author:
#   Stephen Yeargin <stephen.yeargin@gmail.com>

xml2js = require 'xml2js'
crypto = require 'crypto'

module.exports = (robot) ->
	atrium_url = process.env.HUBOT_ATRIUM_URL

	robot.respond /(door|door me|unlock)$/, (msg) ->
		msg.send 'Sending unlock command ...'
		sendUnlockCommand msg

	sendUnlockCommand = (msg) ->
		doors = process.env.HUBOT_DOOR_IDS.split ','
		robot.logger.debug doors
		for door in doors
			robot.logger.debug door
			webPost "doors_cmd=unlock_T&doors_id=#{door}", msg
	
	webPost = (data, msg) ->
		robot.logger.debug "Hitting up: #{atrium_url}/login.xml"
		parser = new xml2js.Parser()
		# Obtain login session ID
		robot.http("#{atrium_url}/login.xml")
	    .get() (err, res, body) ->
				return if handleError msg, err
				parser.parseString body, (err, result) ->
					return if handleError msg, err
					robot.logger.debug 'Retrieved session key. Result:'
					robot.logger.debug result
			
					# Build credentials
					key = result.LOGIN.KEY[0]
					console.log('rc4', rc4)
					username = rc4 key, process.env.HUBOT_ATRIUM_USERNAME
					password = crypto.createHash('md5').update(process.env.HUBOT_ATRIUM_PASSWORD).digest("hex")

					# Post credentials
					robot.logger.debug 'Taking key and posting it to get a cookie'
					postdata = "login_user=#{username}&login_pass=#{password}"
					data = JSON.stringify(postdata)
					robot.http("#{atrium_url}/login.xml")
				    .post(data) (err, res, body) ->
	    				return if handleError msg, err
							parser.parseString body, (err, result) ->
			          return if handleError msg, err
								robot.logger.debug 'Posted credentials. Result:'
								robot.logger.debug result
								# Receive authenticated cookie
								key = result['cookie']
					      # Send encoded instruction
								postdata = postEnc data, key
								data = JSON.stringify(postdata)
								robot.http("#{atrium_url}/doors.xml")
							    .post(data) (err, res, body) ->
							      return if handleError msg, err
										robot.logger.debug 'Posted command to open door. Result:'
										robot.logger.debug body

  ##
  # Handle Error
  handleError = (msg, err) ->
		if err?
			robot.logger.error err
			msg.send "An error occured! #{err}"
			return true
		else
      return false

  ##
  # Post Encoding
  postEnc = (strRaw, key) ->
    if typeof key == 'undefined'
      return ''

    enc = rc4(key, strRaw)
    chk = postChkCalc(strRaw)
    'post_enc=' + enc + '&post_chk=' + chk

  ## Private Methods ##

  ##
  # RC4 Encryption
  rc4 = (key, text) ->
    s = new Array
    i = 0
    while i < 256
      s[i] = i
      i++
    j = 0
    x = undefined
    i = 0
    while i < 256
      j = (j + s[i] + key.charCodeAt(i % key.length)) % 256
      x = s[i]
      s[i] = s[j]
      s[j] = x
      i++
    i = 0
    j = 0
    ct = ''
    y = 0
    while y < text.length
      i = (i + 1) % 256
      j = (j + s[i]) % 256
      x = s[i]
      s[i] = s[j]
      s[j] = x
      ct += (text.charCodeAt(y) ^ s[(s[i] + s[j]) % 256]).toString(16).pad('0', 2).toUpperCase()
      y++
    ct

  ##
  # Post Check Calculate
	postChkCalc = (str) ->
	  chk = 0
	  i = 0
	  while i < str.length
	    chk += str.charCodeAt(i)
	    i++
	  (chk & 0xFFFF).toString(16).pad('0', 4).toUpperCase()