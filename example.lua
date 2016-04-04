-- set up Oscar
local Oscar = require 'Oscar'
local ACCESS_TOKEN = 'copy the access token from your Account panel here'
local scientist = Oscar(ACCESS_TOKEN)

-- define your experiment hyperparameters' space here
local experiment = {
	name = 'test',
	parameters = {
		x = { min = -2, max = 2 },
		c = { 3, 4, 5 }
	}
}

-- get a job suggestion
local job = scientist:suggest(experiment)
print(job)

-- do your complex job here
local duration = math.random(100)
local loss = math.pow(job.x * job.c, 2)
local result = {
	loss = loss,
	duration = duration
}

-- update Oscar
print(result)
scientist:update(job, result)