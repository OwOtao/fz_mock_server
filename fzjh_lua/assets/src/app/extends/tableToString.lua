local function func()
	-- 用来判断变量名是否有效
	local validVarNames = {}
	local function varNameValid(varName)
		local cacheRet = validVarNames[varName]
		if cacheRet ~= nil then
			return cacheRet
		end

		local ret = nil
	    if loadstring("local "..varName) == nil then
	    	ret = false
	    else
	    	ret = true
	    end
	    validVarNames[varName] = ret
	    return ret
	end

	---table数据发送时，转为字符串发送
	local function tableToString(tb)
		if type(tb) ~= "table" then
			return tostring(tb)
		end

	    assert(type(tb) == "table", "type(tb) = "..type(tb))
	    local function _tableToString(name, tb, tableList)
			if type(tb) == "table" then
				
				-- 不需要序列化
				if tb.__isNotSerializable then
					return nil
				end

				if tableList[tb] then
					-- return _tableToString(tableList[tb], "table:"..tableList[tb], tableList)
				else
					-- 记录遍历过的table
					tableList[tb] = name

					-- 判断是否为纯数组
					local isArray = true
					local arrayCount = 0
					for k, v in pairs(tb) do
						if type(k) == "number" then
							arrayCount = arrayCount + 1
							if k == arrayCount then
							else
								isArray = false
								break
							end
						else
							isArray = false
							break
						end
					end

					-- 遍历table
					local luaTable = {}
        			table.insert(luaTable, "{")		
					if isArray then -- 数组的情况
						for k, v in ipairs(tb) do -- 循环方法自动略过nil
							local ret = _tableToString(k, v, tableList)
			                if ret then
			                	table.insert(luaTable, ret)
			                	table.insert(luaTable, ",")

		                        -- luaString = luaString .. ret .. ","
			                end
			            end
					else -- 混合情况
						for k, v in pairs(tb) do -- 循环方法自动略过nil
							local ret = _tableToString(k, v, tableList)
			                if ret then
			                	local kType = type(k)
			                    if kType == "string" then
			                        if varNameValid(k) then
			                			table.insert(luaTable, k)
			                			table.insert(luaTable, "=")
			                			table.insert(luaTable, ret)
			                			table.insert(luaTable, ",")


			                            -- luaString = luaString .. k .. "=" .. ret .. ","
			                        else
			                        	table.insert(luaTable, "[\"")
			                			table.insert(luaTable, k)
			                			table.insert(luaTable, "\"]=")
			                			table.insert(luaTable, ret)
			                			table.insert(luaTable, ",")

			                            -- luaString = luaString .. "[\"" .. k .. "\"]=" .. ret .. ","
			                        end
			                    elseif kType == "number" then
			                    	table.insert(luaTable, "[")
		                			table.insert(luaTable, k)
		                			table.insert(luaTable, "]=")
		                			table.insert(luaTable, ret)
		                			table.insert(luaTable, ",")

			                    	-- luaString = luaString .. "[" .. k .. "]=" .. ret .. ","
			                    elseif kType == "boolean" then
			                    	table.insert(luaTable, "[")
		                			table.insert(luaTable, tostring(k))
		                			table.insert(luaTable, "]=")
		                			table.insert(luaTable, ret)
		                			table.insert(luaTable, ",")

			                        -- luaString = luaString .. "[" .. tostring(k) .. "]=" .. ret .. ","
			                    end
			                end
			            end
					end

        			table.insert(luaTable, "}")		
        			return table.concat(luaTable, "")
				end
				return nil
	        elseif type(tb) == "string" then
	            if tb == nil then
	                return nil
	            elseif string.find(tb, "%[") ~= nil or string.find(tb, "%]") ~= nil then
	                return "[=["..tb.."]=]"
	            else
	                return "[["..tb.."]]"
	            end
	        elseif type(tb) == "userdata" or type(tb) == "function" then
	            return nil
	        else
	            return tostring(tb)
	        end
	    end
	    local retString = _tableToString("root", tb, {});
	    retString = string.gsub(retString, ",}", "}")
	    retString = string.gsub(retString, "\\n", "\n")
	    return retString
	end

	---table数据发送时，转为字符串发送
	-- 这个带格式化
	local function tableToStringFormat(tb)
		if type(tb) ~= "table" then
			return tostring(tb)
		end

	    assert(type(tb) == "table", "type(tb) = "..type(tb))
		local placeholder = "    "
	    local function _tableToString(name, tb, tableList, depth)
			depth = depth + 1
			if type(tb) == "table" then
				-- 不需要序列化
				if tb.__isNotSerializable then
					return nil
				end
				
				if tableList[tb] then
					-- return _tableToString(tableList[tb], "table:"..tableList[tb], tableList)
				else
					-- 记录遍历过的table
					tableList[tb] = name

					-- 判断是否为纯数组
					local isArray = true
					local arrayCount = 0
					for k, v in pairs(tb) do
						if type(k) == "number" then
							arrayCount = arrayCount + 1
							if k == arrayCount then
							else
								isArray = false
								break
							end
						else
							isArray = false
							break
						end
					end

					-- 准备前缀后缀
					local prefix1 = string.rep(placeholder, depth)
					local prefix2 = string.rep(placeholder, depth + 1)

					-- 遍历table
					local luaString = "\n"..prefix1.."{\n"
					if isArray then -- 数组的情况
						for k, v in ipairs(tb) do -- 循环方法自动略过nil
							local ret = _tableToString(k, v, tableList, depth)
			                if ret then
		                        luaString = luaString .. prefix2 .. ret .. "," .. "\n"
			                end
			            end
					else -- 混合情况
						for k, v in pairs(tb) do -- 循环方法自动略过nil
							local ret = _tableToString(k, v, tableList, depth)
			                if ret then
			                	local kType = type(k)
			                    if kType == "string" then
			                        if varNameValid(k) then
			                            luaString = luaString .. prefix2 .. k .. "=" .. ret .. "," .. "\n"
			                        else
			                            luaString = luaString .. prefix2 .. "[\"" .. k .. "\"]=" .. ret .. "," .. "\n"
			                        end
			                    elseif kType == "number" then
			                    	luaString = luaString .. prefix2 .. "[" .. k .. "]=" .. ret .. "," .. "\n"
			                    elseif kType == "boolean" then
			                        luaString = luaString .. prefix2 .. "[" .. tostring(k) .. "]=" .. ret .. "," .. "\n"
			                    end
			                end
			            end
					end
		            luaString = luaString .. "\n" .. prefix1 .. "}"
					return luaString
				end
				return nil
	        elseif type(tb) == "string" then
	            if tb == nil then
	                return nil
	            elseif string.find(tb, "%[") ~= nil or string.find(tb, "%]") ~= nil then
	                return "[=["..tb.."]=]"
	            else
	                return "[["..tb.."]]"
	            end
	        elseif type(tb) == "userdata" or type(tb) == "function" then
	            return nil
	        else
	            return tostring(tb)
	        end
	    end
	    local retString = _tableToString("root", tb, {}, -1)
		retString = string.gsub(retString, "\n\n", "\n")
	    retString = string.gsub(retString, ",}", "}")
	    retString = string.gsub(retString, "\\n", "\n")
	    return retString
	end


	-----------------------------------------------------------------------------------------------------------
	-- @author XiaoZhiWei
	-- @time 2017/11/29 00:38:40
	-- @desc 创建一个协程
	local function coroutineTableToString()
		return coroutine.create(
		function(tb)
			if type(tb) ~= "table" then
				return tostring(tb)
			end

		    assert(type(tb) == "table", "type(tb) = "..type(tb))
		    local function _tableToString(name, tb, tableList)
				if type(tb) == "table" then
					-- 不需要序列化
					if tb.__isNotSerializable then
						return nil
					end
					
					if tableList[tb] then
						-- return _tableToString(tableList[tb], "table:"..tableList[tb], tableList)
					else
						-- 记录遍历过的table
						tableList[tb] = name

						-- 判断是否为纯数组
						local isArray = true
						local arrayCount = 0
						for k, v in pairs(tb) do
							if type(k) == "number" then
								arrayCount = arrayCount + 1
								if k == arrayCount then
								else
									isArray = false
									break
								end
							else
								isArray = false
								break
							end
						end

						-- 遍历table
						local luaTable = {}
		    			table.insert(luaTable, "{")		
						if isArray then -- 数组的情况
							for k, v in ipairs(tb) do -- 循环方法自动略过nil
								local ret = _tableToString(k, v, tableList)
				                if ret then
				                	table.insert(luaTable, ret)
				                	table.insert(luaTable, ",")

			                        -- luaString = luaString .. ret .. ","
				                end
				            end
						else -- 混合情况
							for k, v in pairs(tb) do -- 循环方法自动略过nil
								local ret = _tableToString(k, v, tableList)
				                if ret then
				                	local kType = type(k)
				                    if kType == "string" then
				                        if varNameValid(k) then
				                			table.insert(luaTable, k)
				                			table.insert(luaTable, "=")
				                			table.insert(luaTable, ret)
				                			table.insert(luaTable, ",")


				                            -- luaString = luaString .. k .. "=" .. ret .. ","
				                        else
				                        	table.insert(luaTable, "[\"")
				                			table.insert(luaTable, k)
				                			table.insert(luaTable, "\"]=")
				                			table.insert(luaTable, ret)
				                			table.insert(luaTable, ",")

				                            -- luaString = luaString .. "[\"" .. k .. "\"]=" .. ret .. ","
				                        end
				                    elseif kType == "number" then
				                    	table.insert(luaTable, "[")
			                			table.insert(luaTable, k)
			                			table.insert(luaTable, "]=")
			                			table.insert(luaTable, ret)
			                			table.insert(luaTable, ",")

				                    	-- luaString = luaString .. "[" .. k .. "]=" .. ret .. ","
				                    elseif kType == "boolean" then
				                    	table.insert(luaTable, "[")
			                			table.insert(luaTable, tostring(k))
			                			table.insert(luaTable, "]=")
			                			table.insert(luaTable, ret)
			                			table.insert(luaTable, ",")

				                        -- luaString = luaString .. "[" .. tostring(k) .. "]=" .. ret .. ","
				                    end
				                end
				            end
						end

		    			table.insert(luaTable, "}")		
		    			local ret = table.concat(luaTable, "")
		    			coroutine.yield()
		    			return ret
					end
					return nil
		        elseif type(tb) == "string" then
		            if tb == nil then
		                return nil
		            elseif string.find(tb, "%[") ~= nil or string.find(tb, "%]") ~= nil then
		                return "[=["..tb.."]=]"
		            else
		                return "[["..tb.."]]"
		            end
		        elseif type(tb) == "userdata" or type(tb) == "function" then
		            return nil
		        else
		            return tostring(tb)
		        end
		    end
		    local retString = _tableToString("root", tb, {});
		    retString = string.gsub(retString, ",}", "}")
		    retString = string.gsub(retString, "\\n", "\n")
		    coroutine.yield(true, retString)
		end)
	end


	local function stringToTable(string)
	    local getTable = loadstring("return "..string)
	    if getTable == nil then return nil end
	    return getTable()
	end

	if PRINT_MODE == 1 then
		print("stringToTable = "..type(stringToTable))
	end

	if DEBUG_MODE == 1 then
		return tableToStringFormat, stringToTable, coroutineTableToString
	end

	return tableToString, stringToTable, coroutineTableToString
end

return func
00000000000