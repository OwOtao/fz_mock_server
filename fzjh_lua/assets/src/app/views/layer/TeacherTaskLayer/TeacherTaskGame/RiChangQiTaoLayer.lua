local RiChangQiTaoLayer = class("RiChangQiTaoLayer", cc.Layer)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function RiChangQiTaoLayer:create()
    local p = RiChangQiTaoLayer:new()
    p:init()
    return p
end
function RiChangQiTaoLayer:init()
    local UI= require("Layer/TeacherTask/TeacherTaskGame/RiChangQiTaoUI.lua").create()['root']
    UI:addTo(self)
    Helper:convertUIByParent(self) -- 获得所有子节点

end
function RiChangQiTaoLayer:enterLayer(map,role)
    local layer = self:getInstance()
    layer:show()
    layer:initLayer(map,role)
end
function RiChangQiTaoLayer:initLayer(map,role)
    self.Image_back:setVisible(false)
    self.Text_name:setVisible(false)
    self.Text_dsc:setVisible(false)
    self.Button_panwen:setVisible(false)
    self.Text_money:setVisible(false)   
    self:showText(function()
        self.Image_back:setVisible(true)
        self.Text_name:setVisible(true)
        self.Text_dsc:setVisible(true)
        self.Button_panwen:setVisible(true)
        self.Text_money:setVisible(true)
        self:initReceiveTask()
        self:singSong(map,role)
    end)
    self.yayi = false
end
function RiChangQiTaoLayer:initReceiveTask()
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
    local money = Helper:getDef(receiveTask.money,0)
    self.Text_money:setString("赏钱："..tostring(money).."/10000")
end
function RiChangQiTaoLayer:showText(func)
    local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
    local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
    teacherAnimationLayer:setVisible(false)
    local str = {
        [1] = "                         莲花落 #####",
        [2] = "      人道光阴疾似梭，我说光阴两样过。",
        [3] = "      昔日繁华人羡我，一年一度易蹉跎。",
        [4] = "      可怜今日我无钱，一时一刻如长年。",
        [5] = "     我曾轻裘肥马载高轩，指麾万众驱山前。",
        [6] = "      一声围合魑魅惊，百姓邀迎如神明。",
        [7] = "     今日黄金散尽谁复矜，朋友离群猎狗烹。",
        [8] = "      昼无擅粥夜无眠，落得接头唱哩莲。",
        [9] = "      一生两载谁能堪，不怨爷娘不怨天。",
        [10] = "      早知到此遭坎坷，悔教当日结妖魔。",
        [11] = "      而今无计可奈何，殷勤劝人休似我！",
    }
    if not MapIsEmpty(str) then
        teacherAnimationLayer:createTextFromArrayWithIntervalDistance(str,950)
        teacherAnimationLayer:setHideWithCallFunc(function()
            if func then
                func()
                Audio:stopMusic("LianHuaLuo")
            end
        end)
        teacherAnimationLayer:show()
        Audio:playMusic("LianHuaLuo",true)
    end
end
function RiChangQiTaoLayer:singSong(map,role)
    local time = 1
    local receiveTask = Helper:getDef(TeacherTask:getTeacherTaskAttr("receiveTask"),{})
    self._handel = self:schedule(function()
        if Helper:getDef(receiveTask.money,0) >= 10000 then
            map:removeRoomRole(receiveTask.roomId,receiveTask.npcId)
            map.__MapLayer:setNeedRefreshMap()
            receiveTask.roomId = {}
            receiveTask.jiangli = 2
            TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
            TeacherTask:setTeacherTaskAttr("isComplete","Y")
            self:unschedule(self._handel)
            self:hide() 
        else
            self:setShowText(map,self:updateTextTime(time))
            time = time + 1
        end
    end,1.0)
end
function RiChangQiTaoLayer:updateTextTime(time)
    local taskTime = Helper:getDef(time,1)
    self.reTab = Helper:getDef(self.reTab,{})
    if taskTime % 4 == 0 then
        self.reTab["luren"] = self:getShowText(1)
    else
        if self.reTab["luren"] then
            print("路人文本存在时间**********************：",self.reTab["luren"].time)
            self.reTab["luren"].time = self.reTab["luren"].time + 1
            if self.reTab["luren"].time == 2 then
                self.reTab["luren"] = nil
            end
        end
    end
    if taskTime % 9 == 0 then
        self.reTab["yayi"] = self:getShowText(2)
    else
        if self.reTab["yayi"] then
            print("**********************衙役文本存在时间：",self.reTab["yayi"].time)
            self.reTab["yayi"].time = self.reTab["yayi"].time + 1
            if self.reTab["yayi"].time == 2 then
                self.reTab["yayi"] = nil
                self.yayi = false
            end
        end
    end
    if self.reTab["yayi"] == nil then
        self.yayi = false
    end
    return self.reTab
end
function RiChangQiTaoLayer:getShowText(tag)
    local function getRandomMoney(num1,num2)
        local random = 0
        if num1 and not num2 then
            random = num1
        end
        if num1 and num2 then
            random = math.random(num1,num2)
        end
        return random
    end 
    local tab = {
        [1] = {
            word = "一个衣着华丽的中年贵妇被你的歌声吸引，停下了脚步。",
            said = "YEL贵妇叹道“也是个苦命人”，扔下一笔赏钱走了。",
            money = getRandomMoney(2000,4000) ,
            type = "路人",
            time = 0,
        },
        [2] = {
            word = "一个身形佝偻的老人被你的歌声吸引，停下了脚步。",
            said = "RED老人叹道“可怜的孩子，好好活着吧”，掏出一笔赏钱然后走开了",
            money = getRandomMoney(1000,2000),
            type = "路人",
            time = 0,
        },
        [3] = {
            word = "一个脑满肠肥的中年富商被你的歌声吸引，停下了脚步。",
            said = "CYN富商鄙夷道：“叫花子，拿去！”扔下一笔赏钱后快步掩鼻走开。",
            money = 50 ,
            type = "路人",
            time = 0,
        },
        [4] = {
            word = "一个意气风发的年轻书生被你的歌声吸引，停下了脚步。",
            said = "HIY书生摇头晃脑说道：“还是要多读圣贤书啊！”然后丢下一笔赏钱后走了。",
            money = getRandomMoney(300,500),
            type = "路人"
            ,
            time = 0,
        },
        [5] = {
            word = "一个嬉皮笑脸的泼皮被你的歌声吸引，停下了脚步。",
            said = "HIW泼皮：“这位朋友的莲花落唱得真好，今天真遇到高人了。”然后悻悻走开了。",
            money =  getRandomMoney(-100,-200),
            type = "路人",
            time = 0,
        },
        [6] = {
            word = "一个顽童被你的歌声吸引，停下了脚步。",
            said = " HIR顽童往破碗里扔了一颗石头，然后笑嘻嘻地跑开了。",
            money = 0,
            type = "路人",
            time = 0,
        },
        [7] = {
            word = "一个身背大剑、衣衫破旧、满面风尘的游侠被你的歌声吸引，停下了脚步。",
            said = " HIR“世间悲苦之人何其多也？我如何全救得过来？！不过见到了，又岂能袖手旁观。”扔下一笔钱然后走了。",
            money = getRandomMoney(1000,1500),
            type = "路人",
            time = 0,
        }
    }
    local yayi = {
        word = "一个满脸横肉的衙役走了过来，直勾勾地打量着你，嘴角噙着冷笑。",
        said_success = "哼，不识抬举！",
        said_defeat = "RED衙役连滚带爬地跑了，不忘放下狠话：“哼，你给我等着！”",
        money = getRandomMoney(-100,-500),
        type = "衙役",
        time = 0,
    }
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask") 
    if tag == 1 then
        local list = clone(tab)
        if receiveTask.money == 0 then
            table.remove(list,5)
        end
        return list[math.random(1,#list)]
    else
        return yayi
    end 
end
function RiChangQiTaoLayer:setShowText(map,tab)
    tab = Helper:getDef(tab,{})
    print("setShowText step 1")
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
    local str = ""
    local func = nil
    local list = Helper:getDef(tab["luren"],{})
    local function getText(str1,str2)
        str1 = Helper:getDef(str1,"")
        str2 = Helper:getDef(str2,"")
        if str ~= "" then
            str1 = str1 .."\n" .. str2
        else
            str1 = str1 .. str2
        end
        return str1
    end
    str = getText(str,Helper:getDef(list.word,""))
    if tab["luren"] == nil then
        func = function()
            PopText("现在还没有人经过")
        end
    else
        func = function()
            if receiveTask.money + list.money <= 0 and receiveTask.money > 0 then
                PopText("泼皮偷走了你的全部赏钱！")
            elseif receiveTask.money > receiveTask.money + list.money then
                PopText("泼皮偷走了"..tostring(0-list.money).."赏钱！")
            else
                PopText("获得赏钱X"..tostring(list.money)) 
            end 
            receiveTask.money = receiveTask.money + list.money
            receiveTask.money = math.max(receiveTask.money,0)
            RichPrint("main",list.said)
            TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
            self:initReceiveTask()
            tab["luren"] = nil
            self:setShowText(map,tab)
        end
    end
    local list = Helper:getDef(tab["yayi"],{})
    if tab["yayi"] ~= nil then
        str = getText(str,Helper:getDef(list.word,""))
        func = function()
            self.yayi = true
            self:createYaYi(map,tab)
            self:pauseSchedulerAndActions(self._handel)
        end
    end
    self.Text_dsc:setString(str)
    self.Button_panwen:releaseFunc(function()
        if func then
            func()
        end
    end)
end
function RiChangQiTaoLayer:createYaYi(map,tab)
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
    local roleId = receiveTask.npcBaseId[2]..tostring(Helper:getOnlyId())
    -- local receiveTask = self:getTeacherTaskAttr("receiveTask")
    local role = {}
    local basenpc = TeacherTask:getNPCBaseList(receiveTask.npcBaseId[2])
    for k ,v in pairs(basenpc) do
        role[k] = v
    end
    role.id = roleId
    role.baseId = receiveTask.npcBaseId[2]
    role.canCompete = true
    role.canTalk = false
    role.canKill = false
    role.type = "role"
    -- role = TeacherTask:replaceRoleAttr(role)
    map:createRole(role)
    map:addRoomRole(receiveTask.roomId,role.id,true)
    role = map:getRole(role.id)
    map.__MapLayer:setNeedRefreshMap()

        local currRole = map:getRole(role.id)
        local role = currRole
        local currMap = map
        self.mapLayer = map.__MapLayer
        local player = User:getRole()
        currMap:doConditionAndResult(role.conditionAndResults,
            {
                operation = "切磋",
                currRole = role,
                currRoomId = self.mapLayer._currRoom.id,
                mapLayer = self.mapLayer
            })

        role:initNpcAttr() -- NPC状态初始化

        currMap:afterFightWithQieCuo(player, role, function(winTeamId)
            -- 战斗胜利条件结果
            if winTeamId == 1 then
                -- PopText("你战胜了" .. role:getName())
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "成功",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })

                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
                map:removeRoomRole(receiveTask.roomId,currRole.id)
                map.__MapLayer:setNeedRefreshMap()
                RichPrint("main","RED衙役连滚带爬地跑了，不忘放下狠话：“哼，你给我等着！”")
                self.yayi = false
                tab["yayi"]= nil
                self:setShowText(map,tab)
                self:resumeSchedulerAndActions(self._handel)
                map:doRoomConditionAndResult(receiveTask.roomId)
            else
                -- PopText("你被" .. role:getName() .. "打趴在地")
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "失败",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })

                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
                RichPrint("main","哼，不识抬举！")
                RichPrint("main","你被巡逻的衙役轰了出来，乞讨可是门技术活，还是回去向长老们请教请教吧。")
                map:removeRoomRole(receiveTask.roomId,currRole.id)
                map:removeRoomRole(receiveTask.roomId,receiveTask.npcId)
                 map:doRoomConditionAndResult(receiveTask.roomId)
                receiveTask.roomId = {}
                receiveTask.jiangli = 1
                TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
                TeacherTask:setTeacherTaskAttr("isComplete","Y")
                map.__MapLayer:setNeedRefreshMap()
                self:unschedule(self._handel)
                self:hide()
                self:destroyInstance()
            end
        end)    
end
Helper:classDefNodeGetInstance(RiChangQiTaoLayer)
return RiChangQiTaoLayer
000000