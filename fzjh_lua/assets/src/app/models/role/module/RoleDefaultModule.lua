local RoleFormula = require("app.models.formula.RoleFormula")
local Module = require("third.module.Module")
local RoleDefaultModule = class("RoleDefaultModule", Module)

function RoleDefaultModule:ctor()
    -- 模块名
    self._name = "RoleDefaultModule"
end

function RoleDefaultModule:getDsc(target, role, isNeedAgeDesc, isNeedLookDesc, isNeedQiDesc)
    local innerFunc = function(self)
        isNeedAgeDesc = Helper:getDef(isNeedAgeDesc, true)
        isNeedLookDesc = Helper:getDef(isNeedLookDesc, true)
        isNeedQiDesc = Helper:getDef(isNeedQiDesc, true)
        local desc = ""
        local cl = "WHT"
        local sex = "他"
        if self.sex == "女" then
            sex = "她"
        elseif self.sex == "野兽" then
            return (self.dsc == nil and "" or tostring(self.dsc))
        end

        if self:checkRoleIsPolymorph() then --易容改貌
            if self.polymorph.sex == "女" then
                sex = "她"
            else
                sex = "他"
            end
        end
        if MapIsEmpty(role) == false then
            local relation = role:getRelation(self)
            if relation and self:getAttr("onlyId") ~= User:getRoleAttr("onlyId") then
                desc = cl .. self.name .. "是你的" .. relation .. "。\n"
            end
        end
        local dsc = ""
        if self.dsc then
            dsc = self.dsc
        end
        local title = ""
        if self.title then --title 不知道哪里用了
            title = "江湖人称" .. self.title .. "。"
        end

        if self.onlyId == User:getRoleAttr("onlyId") then
            if string.len(dsc) > 0 then
                desc = desc .. tostring(dsc) .. "\n"
            end
        else
            if self.jobType and self.realName then
                desc = desc .. cl .. sex .. "就是" .. tostring(self.realName) .. "。" .. title .. tostring(dsc) .. "\n"
            else
                desc = desc .. cl .. sex .. "就是" .. tostring(self.name) .. "。" .. title .. tostring(dsc) .. "\n"
            end
        end

        -- add by XiaoZhiWei 2017/03/31 11:16:40 增加年龄描述开关
        if isNeedAgeDesc == true then
            desc = desc .. cl .. sex .. "看起来约" .. self:getAgeDsc()
        end
        if self.specialType == "中元节" or self.specialType == "中元节伴生" then
            if type(self.npcDsc) ~= "string" then
                local ghosts = require("app.models.Activities.ghosts")
                self.npcDsc = ghosts:checkGhostDsc(self)
            end
            desc = "WHT" .. self.npcDsc .. "\n"
            if self.sex == "男" then
                sex = "他"
            else
                sex = "她"
            end
        end
        -- add by XiaoZhiWei 2017/03/31 11:22:50 增加长相描述开关
        if self:getFaceDsc() ~= nil and isNeedLookDesc == true then
            if isNeedAgeDesc == true then
                if (self.specialType == "中元节" or self.specialType == "中元节伴生") and self.ghostPlayer ~= 1 then
                    -- desc = desc..sex..cl.."生得"..self:getFaceDsc()..cl.."。\n"
                    -- print(dsc,"相貌描述1")
                elseif self.ghostPlayer == 1 then
                elseif self.canSeeInheritHistory == true then
                    desc = "WHT" .. sex .. "就是" .. "self.name。\n"
                    desc = desc .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
                else
                    desc = desc .. "，" .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
                end
            else
                desc = desc .. sex .. cl .. "生得" .. self:getFaceDsc() .. cl .. "。\n"
            end
        end
        if isNeedQiDesc == true then
            desc = desc .. cl .. sex .. "的武功看来" .. self:getKongfuDsc() .. cl .. "，出手似乎" .. self:getJialiDsc() .. cl .. "。\n"

            desc = desc .. cl .. sex .. "看起来" .. self:getQiDsc() .. "。\n"
        end

        if self.specialType == "中元节" or self.specialType == "中元节伴生" then
            local role = User:getRole()
            if self.canSeeInheritHistory == true then
                for k, v in pairs(self.inheritHistory) do
                    if i == #self.inheritHistory then
                        -- 判断是否有改名
                        if v.inheritName ~= self.name then
                            v.inheritName = self.name
                        end
                    end
                    local map = role:getMapById("fb" .. tostring(v.retireMap))
                    desc =
                        desc ..
                        cl ..
                            "公元" ..
                                Helper:numberCast(Helper:date("%y", v.inheritTime)) ..
                                    "年" ..
                                        Helper:numberCast(Helper:date("%m", v.inheritTime)) ..
                                            "月" .. Helper:numberCast(Helper:date("%d", v.inheritTime)) .. "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. map.name .. "。\n"
                end
            end
        else
            for i, v in ipairs(self.inheritHistory) do
                if i == #self.inheritHistory then
                    -- 判断是否有改名
                    if v.inheritName ~= self.name then
                        v.inheritName = self.name
                    end
                end
                desc =
                    desc ..
                    cl ..
                        "公元" ..
                            Helper:numberCast(Helper:date("%y", v.inheritTime)) ..
                                "年" ..
                                    Helper:numberCast(Helper:date("%m", v.inheritTime)) ..
                                        "月" ..
                                            Helper:numberCast(Helper:date("%d", v.inheritTime)) ..
                                                "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. Map:getDefaultMapById(Map:getMapIdByIndex(v.retireMap)).name .. "。\n"
            end
        end

        if self.ZhiZuoZuTotalCount ~= nil then
            if self.name == "柳如烟" then
                desc = desc .. cl .. "她已收到" .. self.ZhiZuoZuTotalCount .. "个钱袋。\n"
            else
                desc = desc .. cl .. "此人已被怒怼" .. self.ZhiZuoZuTotalCount .. "次。\n"
            end
        end

        if self.wuJueChallengeCount ~= nil then
            desc = desc .. cl .. "此人已被战胜" .. self.wuJueChallengeCount .. "次。\n"
        end

        if self.isShowEquips == 1 then
            local weapoonName = self:getCurrWeaponName()
            local weapon = self:getEquipByName("weapon")
            if weapon then
                desc = desc .. cl .. "	□" .. weapoonName .. cl .. "\n"
            end

            local equipsTab = {
                [1] = "head", -- 头帽
                [2] = "cloth", -- 上装
                [3] = "pants", -- 下装
                [4] = "belt", -- 腰带
                [5] = "yaozhui", -- 腰坠
                [6] = "shoes", -- 鞋子
                [7] = "necklace", -- 项链
                [8] = "hand", -- 手部
                [9] = "ring" -- 戒指
            }

            for i, v in ipairs(equipsTab) do
                local equip = self:getEquipByName(v)
                if equip and self:getOneItemByKey(equip.itemId) then
                    desc = desc .. cl .. "	□" .. self:getOneItemByKey(equip.itemId).name .. cl .. "\n"
                end
            end
        end
        return desc
    end

    return true, innerFunc(target)
end

function RoleDefaultModule:acceptMapFightResult(target,role, fightType)
    local fightResultFunc = function(self)
        local qi = role:getAttr("qi")
        local neili = role:getAttr("neili")
        local qiMax = role:getRole():getCurrQiMax()
		local qiPercent = role:getAttr("qiPercent")

        if qi < qiMax*0.2 and fightType == "切磋" then
        	qi = qiMax * 0.2
        end

		qi = math.max(qi,1)
		qiPercent = math.max(qiPercent,1/role:getAttr("qiMax"))
    
        self:setAttr("qiPercent", qiPercent)
        self:setAttr("neili", neili)
        self:setAttr("qi", qi)
        self:setFlag("战斗脱离时间", GetTime())
    
        -- 只有是玩家自身的时候才需要 改变以下属性
        if self == User:getRole() then
    
        	local weaponData = self:getEquipByName("weapon")
        	if weaponData ~= nil then
        		local items = role:getRole():getItemWithOnlyId(weaponData.id)
        		if not MapIsEmpty(items) then
        		if items.wanhaodu and items.wanhaodu == 0 and items.type ~= "神兵" then
        				self:getItemWithOnlyId(weaponData.id).wanhaodu = items.wanhaodu
        				self:setEquipByName("weapon",nil)
        			end
        		end
        	end			
    
        	local zhengqi = role:getRole():getAttr("zhengqi")
        	self:setAttr("zhengqi",zhengqi)
        	if POISONSYS then
        		local rolePoison = role._role:getAttr("poison")
        		self.poison = rolePoison
        	end
        	-- 杀死的情况才处理 add by TangJian 2016/11/25 18:04:06
        	if fightType == "杀死" then
        		--开启神书任务期间杀死npc不扣除正气值 add by Gao Hanzheng
                local ShenShuHelper = require("app.models.shenshu.shenshu")
                
        		if ShenShuHelper:checkIsInFindBook(self) then
                    return
                end

        		-- 正气值 add by TangJian 2016/11/08 15:20:01
        		local killedRoles = role:getKilledRoles()
        		if #killedRoles > 0 then
        			self:addAttr("kill", 1)
    
        			local killedRole = killedRoles[1]
        			local rZhengQi = self:getAttr("zhengqi")
        			local tZhengQi = killedRole:getAttr("zhengqi")
    
        			self:setAttr("zhengqi", tonumber(rZhengQi - tZhengQi))
        			-- PopText("杀人, 正气值变化: " .. rZhengQi .. " -> " .. tonumber(rZhengQi - tZhengQi))
        		end
    
        		-- 如果死了 add by TangJian 2016/11/08 14:50:57
        		if role:isDead() then
        			local killer = role:getKiller() -- 得到杀死自己的人
        			self:addAttr("dead", 1)
        			self:setAttr("deadReason", killer:getName())
        			self:setAttr("killedBySkillName", killer:getCurrAttackSkill().name)
    
        			-- PopText("被杀 deadReason = " .. killer:getName())
        			-- PopText("被杀 killedBySkillName = " .. killer:getCurrAttackSkill().name)
        		end
        	end
        else
        	if role:getRole():getFlag("兵器被打飞") ~= 1 then
        		self:setEquipByName("weapon", role:getRole():getEquipByName("weapon"))
        		print("role:getRole():getEquipByName(weapon)=",role:getRole():getEquipByName("weapon"))
        		if NPC_AI then
        			if self.weapon then
        				self.weapon = role._role.weapon
        			end
        			-- local Map = require("app.models.map.Map")
        			Npc:initNpcActiveZhao(self)
        		end
        	end
    
        	--仆人特性
        	if JIAYUAN_SYSTEM_IS_OPEN == true then
        		local qiecuoMoneyReduceValue = role:getRole():getBuffAttr("qiecuoMoneyReduce")
        		if qiecuoMoneyReduceValue < 0 then
        			PopText("碎银"..qiecuoMoneyReduceValue)
        			User:getRole():addAttr("money",qiecuoMoneyReduceValue)
        		elseif qiecuoMoneyReduceValue > 0 then
        			assert(false,"检查资源表数值")
        		end
        	end
        end
    end
    return true,fightResultFunc(target)
end

function RoleDefaultModule:checkAttr(target, name)
    local doWith = function(self)
        -- 先准备公式需要的参数, 写成方法的形式, 懒加载

        -- 内功生命系数
        local factor = function()
            return self:getPrepareSkillFactor("neigong", "HpRate")
        end
        local age = function()
            return self:getAttr("age")
        end
        local neiliMax = function()
            return self:getAttr("neiliMax")
        end
        local neiLiLimit = function()
            return self:getNeiLiLimit()
        end
        local effectCon = function()
            return self:getEffectCon()
        end
        local con = function()
            return self:getFinalAttr("con")
        end

        local qiMaxChange = false

        -- 经验
        if name == "exp" then
            -- 经验影响角色等级
            self.lv = self:getLv()
            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
        elseif name == "lv" then
            -- 角色等级影响经验
            self.exp = self:getExp()
        elseif name == "jing" and self.jing > self:getJingMax() then
            -- 气血， 气血 不能超出最大值
            self.jing = self:getJingMax()
        elseif (name == "qi" or name == "qiMax") and self.qi > self:getCurrQiMax() then
            -- 年龄
            self.qi = self:getCurrQiMax()
        elseif name == "age" then
            -- 先天根骨
            self:setJingMax()
            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
        elseif name == "str" then
            self:calcNeiLiLimit()
        elseif name == "dex" then
            self:calcNeiLiLimit()
        elseif name == "con" then
            -- 内功生命系数
            self:calcNeiLiLimit()
            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
        elseif name == "secCon" then
            self:calcNeiLiLimit()
            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
        elseif name == "neiliMax" then
            if self.neiliMax > self:getNeiLiLimit() then
                self.neiliMax = self:getNeiLiLimit()
                if (User ~= nil and self == User:getRole()) or User == nil then
                    PopText("内力最大值已到达上限")
                end
            end

            if self.neili > self.neiliMax * 2 then
                self.neili = self.neiliMax * 2
            end

            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
        elseif name == "qiPercent" then
            -- 内功变换时气血上限受影响
            if self:getAttr("qiPercent") > 1 then
                self:setAttr("qiPercent", 1)
            elseif self:getAttr("qiPercent") < 0 then
                self:setAttr("qiPercent", 0)
            end
        elseif name == "neigong" then
            self.qiMax = RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con})
            qiMaxChange = true
            -- 加力值需要变化
            local jiaLiMax = self:getJiaLiMax()
            local jiaLi = self:getFinalAttr("jiaLi")
            self:setAttr("jiaLi", math.min(jiaLi, jiaLiMax))
            self:calcNeiLiLimit() -- add by XiaoZhiWei 2017/07/19 09:43:02 基本内容发生变化时,重新计算一下内力上限
        elseif name == "leftRightFightExp" then
            -- 左右互搏经验不超过900
            if self:getAttr("leftRightFightExp") > 901 then
                self:setAttr("leftRightFightExp", 901)
            end
        elseif name == "pijuan" and self:getAttr("pijuan") > self:getFinalAttr("pijuanMax") then
            self.pijuan = self:getFinalAttr("pijuanMax")
        elseif name == "zhengqi" then
            self:limitAttrZhengQiRange()
        end

        if qiMaxChange == true and self.qi > self:getCurrQiMax() then
            self.qi = self:getCurrQiMax()
        end
    end
    return true, doWith(target)
end

function RoleDefaultModule:initAttrMonitor(target)
    return true
end

return RoleDefaultModule
00000