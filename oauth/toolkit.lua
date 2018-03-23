function baseRandom(n , m)
    math.randomseed(os.clock() *math.random(1000000 , 90000000) + math.random(1000000 , 90000000))
    return math.random(n , m)
end

function numRandom(len)
    num = ""
    for i = 1 , len , 1 do
        num = num .. base_random(0,9)
    end
    return num
end

function letterRandom(len)
    letter = ""
    for i = 1 , len , 1 do
        letter = letter .. string.char(base_random(97,122))
    end
    return letter
end

function capitalRandom(len)
    capital = ""
    for i = 1 , len , 1 do
        capital = capital .. string.char(base_random(65,90))
    end
    return capital
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