local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_HeiMuYaLing = {}

function RoleUseItem_HeiMuYaLing:__doUseItem()
    local role = self._role

    local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")

	local tab = {
		["riyueshimenrenwu1"] = {
			[1] = "他现在应该躲在YEL$DNOR地图。",
			[2] = "他善于易容伪装，经常扮作一个老头子。",
			[3] = "他的妻女都死了，他自己身上应该带着伤。",
		},
		["riyueshimenrenwu2"] = {
			[1] = "她现在应该躲在YEL$DNOR地图。",
			[2] = "她善于易容伪装，经常扮作尼姑或者老太太。",
			[3] = "她喜欢小孩子，擅长用剑。",
		},
		["riyueshimenrenwu3"] = {
			[1] = "他现在应该躲在YEL$DNOR地图。",
			[2] = "他嗜酒如命，一日不可无酒。",
			[3] = "他拳脚功夫很不错。",
		},
    }
    if DEBUG_MODE == 1 then
        receiveTask = {}
        local index = math.random(1,3)
        receiveTask.success = "riyueshimenrenwu"..index
        receiveTask.mapId = "fb01"
    end

	if receiveTask.success == nil  or tab[receiveTask.success] == nil then
		return
    end

	local tmp = tab[receiveTask.success]
	local map = User:getRole():getMapById(receiveTask.mapId)
	local dsc = TeacherTask:spliceTaskDsc(tmp[1],"$D",map.name)
	tmp[1] = dsc
    for i=1,#tmp do
		role._iOutput:delayTextPrint(i/2, tmp[i])
    end
    return true
end

return NewClass("RoleUseItem_HeiMuYaLing", {AbstractUseItem}, RoleUseItem_HeiMuYaLing)
000000000000