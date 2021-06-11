local aes = require("aes")
local aesObj = aes:new()

local key = "1234567890123456"

local buf = aesObj:ecb_EncryptDecrypt("abc",key,true)

print(aesObj:ecb_EncryptDecrypt(buf,key,false))
