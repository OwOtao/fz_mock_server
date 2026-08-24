-- 兼容math.mod 函数 luajit 2.1 已废弃 
if math.mod == nil then
	math.mod = math.fmod
end0000000000000