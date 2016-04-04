local https = require('ssl.https') -- luasec
local http = require('socket.http') -- luasocket
local json = require("json") -- luajson

local API_VERSION = '1'
--local DOMAIN_URL = 'http://localhost:8080'
local DOMAIN_URL = 'https://' .. API_VERSION .. '.sensout-oscar.appspot.com'

local Oscar = {}
Oscar.__index = Oscar
setmetatable(Oscar, {__call = function (cls, ...) return cls.new(...) end})
function Oscar.new(accessToken)
	local self = setmetatable({}, Oscar)
	-- TODO read from local file
	self.accessToken = accessToken
	self.trial_ids = {}
	self.trial_keys = {}
  return self
end

function Oscar:_urlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

function Oscar:_call(url, params)
	-- prepare url
	url = DOMAIN_URL .. url
	local first = true
	for k,v in pairs(params) do
		url = url .. (first and '?' or '&') .. k .. '=' .. self:_urlEncode(v)
		first = false
	end
	-- prepare request
	response = {}
	save = ltn12.sink.table(response) -- need a l1tn12 sink to get back the page content    
  src = ltn12.source.string('')
	heads = {}
	heads['Content-Type'] = 'application/json'
	heads['Accept'] = 'application/json'
	heads['Authorization'] = 'Bearer ' .. self.accessToken
	if string.match(url, 'http://') then
     ok, code, headers = http.request{url = url, method = 'get', headers = heads, source = src, sink = save}
  else
     ok, code, headers = https.request{url = url, method = 'get', headers = heads, source = src, sink = save}
  end
	if response[1] ~= nil then
    -- Try to decode json
    local status, result = pcall(json.decode, table.concat(response))
    if status and result then
      if result.redirect then
				error("Your are not authenticated. You should try updating your access token.")
			else
				return result
			end
    else
    	error("Did not manage to parse API response: " .. response[1])
    end
  else
  	error("No response from API: " .. response)
    response = nil
  end
  return response
end

function Oscar:_getJobHash(job)
	return table.concat(job, "")
end

function Oscar:getJobId(job)
	return self.trial_ids[self:_getJobHash(job)]
end

function Oscar:suggest(experiment)
	local result = self:_call(
		'/suggest',
		{ 
			experiment = json.encode(experiment) 
		})
	-- result is non nil or error has been raised
	if type(result['job']) == 'table' then
		local hash = self:_getJobHash(result['job'])
		self.trial_ids[hash] = result['trial_id']
		self.trial_keys[hash] = result['trial_key']
		return result['job']
	else
		error("No job returned. Check your parameters and quotas " .. json.encode(result))
	end
end

function Oscar:update(job, result)
	return self:_call(
		'/update',
		{ 
			trial_key = self.trial_keys[self:_getJobHash(job)],
			result = json.encode(result) 
		})
end

return Oscar