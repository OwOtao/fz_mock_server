local JMForLua = {}

function JMForLua:decrypt(str)
    return JM:stringDecrypt(str)
end

function JMForLua:encrypt(str, version)
	if version == nil then
		version = GameChannelContext:getEncryptVersion()
	end

	return JM:stringEncrypt(str, version)
end

return JMForLua
00