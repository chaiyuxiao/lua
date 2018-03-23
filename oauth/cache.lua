local redis = require "resty.redis" 


local _M={}

function _M.get_cache(key)
    
    local red = redis.new()
    local ok , err = red.connect(red,"127.0.0.1","10000")
    if not ok then
        return false
    end
    
    red:set_timeout(60000)

    value , err = red:get(key)    

    red:set_keepalive(100000, 100)

    return value
end
 
function _M.set_cache(key , value , expire_time)
    
    local red = redis.new()
    local ok , err = red.connect(red,"127.0.0.1","10000")
    if not ok then
        return false
    end

    red:set_timeout(600000)

    res , err = red:set(key , value)
    res , err = red:expire(key , expire_time) 

    red:set_keepalive(100000, 100)

    return res
end

return _M