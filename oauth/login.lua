local cjson = require("cjson.safe")
local error_code = require("error_code")
local cache = require("cache")

local function url_args_exists_check(url_args , ...)
    local args = {...}
    for _,v in ipairs(args) do
        if not url_args[v] then
            return v
        end
    end
    return false
end

local function url_args_value_check(...)

end

function baseRandom(n , m)
    math.randomseed(os.clock() *math.random(1000000 , 90000000) + math.random(1000000 , 90000000))
    return math.random(n , m)
end

function stringRandom(len)
    local BC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local SC = 'abcdefghijklmnopqrstuvwxyz'
    local NO = '0123456789'
    local template = BC .. SC .. NO
    local str = {}
    for i = 1 , len , 1 do
        local index = baseRandom(1 , 62)
        str[i] = string.sub(template , index , index)
    end
    return table.concat(str , "")
end

local function get_token(args , user_id)
    --local res = ngx.location.capture("/api/v1/get_token" ,{ args = {
    --                    grant_type = args.grant_type ,
    --                    client_id = args.client_id ,
    --                    client_secret = args.client_secret ,
    --                    user_id = user_id
    --                    }
    --                })
    --return res.body
    --local res = {code = 0 , msg = 'test' , response = {expires_in = 1296000 , access_token = stringRandom(16)}}
    return stringRandom(8)
end

local function authPass(url , send_body , token)
    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri("http://192.168.31.100:8361" .. url ,
           {
                method = "POST",
                body = cjson.encode(send_body),
                headers = {
                    ["Content-Type"] = "application/json" ,
                    ["Accept"] = "application/json" ,
                    ["token"] = token
                }
           })
    if res.status == 200 then
        return cjson.decode(res.body)
    else 
        return nil
    end
end

local function get_user_id_from_oauth(token)
    local args = ngx.req.get_uri_args()
    local start_time = ngx.now()
    local res = ngx.location.capture("/api/v1/token_to_user" , {
            method = ngx.HTTP_POST ,
            body = ngx.encode_args({token = token})
        })
    local end_time = ngx.now()
    ngx.ctx.phase = 'get_user_id_from_oauth'
    ngx.ctx.elapsed_time = end_time - start_time
    return cjson.decode(res.body).response.user_id
end

local function get_user_id_from_api(send_body)
    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri("http://192.168.31.100:8361/v1/user/login/auth/loginByUserName",
           {
                method = "POST",
                body = cjson.encode(send_body),
                headers = {
                    ["Content-Type"] = "application/json"
                }
           })
    if res.status == 200 then
        return cjson.decode(res.body)
    else 
        return nil
    end
end


--local results = {code = -1 , msg = "失败" , response = false , proxy = "nginx"}
local results = {
          code = -1,
          msg = "失败",
          traceId = {}
        }

local request_method = ngx.var.request_method
if request_method == "POST" then
    ngx.req.read_body()
    local args = cjson.decode(ngx.req.get_body_data())
    if not args then
        results.msg = "请求不完整"
        goto GO_END
    end
    local user_token = ngx.req.get_headers()["token"]
    if user_token then
        --get userid in redis and verify token's legality , whether expired
        local user_id = cache.get_cache(user_token)
        if user_id == ngx.null then
            local result = get_user_id_from_oauth(user_token)
            results.msg = "token过期"
        else 
            auth_result = authPass(ngx.var.uri , args , user_id)
            if auth_result then
                results = auth_result
            else
                results.msg = "请求错误"
            end
        end
    elseif args.userName and args.userPwd then
        --1.args check
        --2.get userid
        --local check_result = url_args_exists_check(args , 'grant_type' , 'client_id' , 'client_secret')
        if check_result then
            results.code = error_code.exist[check_result].code
            results.msg = error_code.exist[check_result].msg
            ngx.say(cjson.encode(results))
        else 
            --local api_result = get_user_id_from_api(args.userName , args.userPwd)
            local api_result = get_user_id_from_api(args)
            if api_result then
                if api_result.code == 20000000 then
                    local user_id = api_result.response.token
                    local token = get_token(args , user_id)
                    --cache in redis
                    --to do
                    --local token = cjson.decode(access_token).response.access_token
                    --local expire_time = cjson.decode(access_token).response.expires_in
                    local expire_time = 1296000
                    local is_cache = cache.set_cache(token , user_id , expire_time)

                    api_result.response.token = token
                    results = api_result
                else 
                    results = api_result
                end
            else 
                results.msg = "服务不可用"
            end
        end

    else 
        results.msg = "参数不完整"
    end
elseif request_method == "GET" then
    --
end


::GO_END::
ngx.say(cjson.encode(results))