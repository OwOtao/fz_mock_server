local class = require("third.class.NewClass")

local TeacherBuildPromote = {}

function TeacherBuildPromote:create()
    return TeacherBuildPromote:new()
end

function TeacherBuildPromote:ctor()
    self._desc = "当本派处于奋发向上时，每日0点后可从撷英阁处分派各大散落弟子给与师门的贡献，需要达到一定的门派建树才能进行分配，师门每日可分配次数有限，先到先得。"

    self._buildText = ""
    
    self._list = {}

    self._rewardInfo = {}
end

function TeacherBuildPromote:setRole(role)
    self._role = role
end

function TeacherBuildPromote:setBuildTypeId(id)
    self._buildTypeId = id
end

function TeacherBuildPromote:init(successfulCallback, failedCallBack)
    local menpai = self._role:getFamilyId()
    if not menpai then
        assert(false, "需要加入门派才能进入")
        return
    end

    HttpManagerEx:getSectRevitalizationInfo(menpai,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._rewardInfo = data.buildReward
            if data.buildConditionText then
                self._buildText = "是否确定分配本日的num1点res1和num2点建筑res2？你所选择分配的建筑是buildName，分配完成后res1也会增加，若res2和res1超出当前最大等级，则超出部分无法返还。".."\n分配所需条件：\n"..data.buildConditionText
            end
            

            self:__dealWithInfo(data.buildingList)
            
            if successfulCallback then
                successfulCallback()
            end
        else
            PopText(errmsg)

            if failedCallBack then
                failedCallBack()
            end
        end
    end,IS_SHOW_WAITING)
end

function TeacherBuildPromote:getActionDesc()
    return self._desc
end

function TeacherBuildPromote:getBuildText()
    return self._buildText
end

function TeacherBuildPromote:getRewardInfo()
    return self._rewardInfo
end

function TeacherBuildPromote:getList()
    return self._list
end

function TeacherBuildPromote:getAttrName(attr)
    if attr == "upresources" then
        return "修筑度"
    end
    
    return self._role:getCHAttrName(attr)
end

function TeacherBuildPromote:doReward(callback)
    if not self._buildTypeId then
        return
    end
    
    HttpManagerEx:getSectRevitalizationReward(self._role:getFamilyId(), self._buildTypeId,function(status, errcode, errmsg, data)
        if status == 200 then
            if callback then
                callback(errcode, errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function TeacherBuildPromote:__dealWithInfo(info)
    self._list = {}

    if MapIsEmpty(info) == false then
        for k,v in pairs(info) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = v.buildTypeId
                _info.state = v.state
                _info.name = v.buildName
                _info.lv = v.buildLv
                _info.exp = v.buildCurrentExp
                _info.maxExp = v.buildMaxExp
              
                table.insert(self._list,_info)
            end
        end
    end

    table.sort(self._list, function(a, b)
        if a.state < b.state then
            return true
        elseif a.state > b.state then
            return false
        else
            return a.id < b.id
        end
        
    end)
end

return class("TeacherBuildPromote", {}, TeacherBuildPromote)
00