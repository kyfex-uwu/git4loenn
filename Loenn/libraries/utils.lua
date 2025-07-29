local logging = require("logging")

--##

local g4l = {}

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

return g4l