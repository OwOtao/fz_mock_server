local EventRecord = {}

function EventRecord:recordEvent(eventType,eventParams,func)
	local userAttr = DataBase:getRoleData()
	
	if MapIsEmpty(userAttr) == false then
		HttpManagerEx:addIncidentLog(eventType,eventParams,userAttr,function(status, errcode, errmsg, data)
			if status ==200 and errcode == 0 then
				if func then
					func()
				end
			else
				PopText(errmsg)
			end
		end,IS_SHOW_WAITING)
	end
end

return EventRecord0000000000000