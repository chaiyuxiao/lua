local _M = {
    exist = {
        grant_type = {code = 22101 , msg = '缺少grant_type参数'} ,
        client_id = {code = 22102 , msg = '缺少client_id参数'} ,
        client_secret = {code = 22103 , msg = '缺少client_secret参数'} ,
        user_id = {code = 22104 , msg = '缺少user_id参数'} 
    } ,
    equal = {
        grant_type = {code = 22001 , msg = 'client_credentials'} 
    }
}

return _M