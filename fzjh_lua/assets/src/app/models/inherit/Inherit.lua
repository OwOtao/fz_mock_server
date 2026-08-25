local User = require("app.models.user.User")

local Role = require("app.models.role.Role")

local MeridianHelper = require("app.models.Meridian.MeridianHelper")

local Inherit = {}

-- 创建传承前辈
function Inherit:createSeniorRole(map)
	local inherit = User:getRoleAttr("inherit")
	local role = User:getRole()

	-- 传承次数
	local inheritCount = User:getRoleAttr("inheritCount")

	-- 传承部分
	if inheritCount >= 1 then
		-- 地图添加历代传承角色
		local inheritHistory = role:getAttr("inheritHistory")

		for k,v in ipairs(inheritHistory) do
			local mapId = Map:getMapIdByIndex(v.retireMap)
			if mapId == map.id then
				local text = "YEL" .. v.parentName .. ":你看上去有点像我认识的一个人。"
				if k == #inheritHistory then
					text = "YEL" .. v.parentName .. ":自上次一别，你看上去又成长了不少，江湖险恶，自己要多加小心。"
				end

				local dsc = string.gsub(v.parentDsc, "$N", "\n")

				local MapInfo = require("app.models.map.MapInfo")

				-- 论道
				local lundaoBtnName = "" -- 论道按钮名称 论道或驳斥
				local confirmText = ""	 -- 论道二次确认按钮名称 赞同或驳斥
				local lundaoText = "" 	 -- 论道二次确认文本
				if v.zhengqiState == nil then
					v.zhengqiState = 1
				end
				--v.zhengqiState = 1
				if v.zhengqiState == 1 then
					lundaoBtnName = "论道"
					confirmText = "赞同"
					lundaoText = "你与" .. v.parentName .. "煮茶论道，就江湖正邪两道进行了深入的探讨（此处省略一万字），对于" .. v.parentName .. "的观点你是否赞同？（点击赞同将继承其一部分的侠义值）"
				elseif v.zhengqiState == 2 then
					lundaoBtnName = "驳斥"
					confirmText = "驳斥"
					lundaoText = "你一时听信了" .. v.parentName .. "之言，现在后悔不已，是否对" .. v.parentName .. "的言论进行驳斥？（选择驳斥则扣除从" .. v.parentName .. "继承的侠义值且无法再次继承，请侠士慎重选择）"
				end

				map = MapInfo:addMapRoleByRandom(map, Helper:tableCover(require("app.models.npc.BaseNpc"):create(),
					{
						id = "inherit" .. k,
						sex = "野兽",
						type = "role",
						name = v.parentName,
						inheritIndex = k,
						dsc = dsc,
						canTalk = true,
						canConsult = false,
						canKill = false,
						caozuo = (k == #inheritHistory and v.zhengqiState ~= 3),
						caozuoName = lundaoBtnName,
						caozuo1 = true,
						caozuoName1 = "请教",
						caozuo2 = true,
						caozuoName2 = "决斗",
						conditionAndResults =
						{
							{
								conditionRelation = "and",
								conditions =
								{
									{
										type = "玩家操作",
										arg1 = "玩家操作",
										arg2 = "交谈",
									}
								},
								results =
								{
									{
										type = "文本输出",
										arg1 = "文本输出",
										arg2 = text,
									},
								},
							},
							{
								conditionRelation = "and",
								conditions =
								{
									{
										type = "玩家操作",
										arg1 = "玩家操作",
										arg2 = "操作2",
									}
								},
								results =
								{
									{
										type = "弹出文本",
										arg1 = "弹出文本",
										arg2 = "你何故要恩将仇报？",
									},
								},
							},
							{
								conditionRelation = "and",
								conditions =
								{
									{
										type = "玩家操作",
										arg1 = "玩家操作",
										arg2 = "操作",
									}
								},
								results =
								{
									{
										type = "论道驳斥",
										arg1 = "论道驳斥",
										arg2 = lundaoText,
										arg3 = confirmText,
										arg4 = v.parentName,
									},
								},
							},
							{
								conditionRelation = "and",
								conditions =
								{
									{
										type = "玩家操作",
										arg1 = "玩家操作",
										arg2 = "操作1",
									}
								},
								results =
								{
									{
										type = "传承请教",
										arg1 = "传承请教",
									},
								},
							},
						}
					}))
			end
		end

		local result, text = role:setCurrMap(map)
		if result == true then
			--PopText("成功添加角色" .. v[1])
			print("成功添加角色")
		else
			PopText(text)
		end

	end
end

-- 论道
function Inherit:lundao()
	local role = User:getRole()
	local inheritHistory = role:getAttr("inheritHistory")
	local inheritInfo = inheritHistory[#inheritHistory]

	local state = inheritInfo.zhengqiState

	if inheritInfo == nil then
		return
	end

	-- 从服务器获取正气值
	HttpManagerEx:getInheritHistoryRoleAttr({"zhengqi","xingzhen"} ,function(status, errcode, errmsg, data, isEncrypted)
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            else
            	if MapIsEmpty(data) then
            		return
            	end

	            local zhengqi = 0

	            if data[1].zhengqi ~= nil then
	            	zhengqi = data[1].zhengqi
	            end

	            do
		            local xingZhenData
	            	if data[1].xingzhen ~= nil and data[1].xingzhen.effectsCount~= nil and data[1].xingzhen.effectsCount.zhengqi ~= nil then
			        	xingZhenData = data[1].xingzhen.effectsCount.zhengqi
	            	end

	            	
	            	if xingZhenData ~= nil then
	            		local npcDatas = require("script.others.zouxuejing")
	            		local allNum = 0
	            		local zhengqiNum = 0
	            		local value = 0

		            	for k,v in pairs(xingZhenData) do
		            		local effectData = npcDatas.effect[k]
		            		if effectData ~= nil then
		            	    	value = effectData.value
		            			allNum = allNum + v
		            		else
		            			if DEBUG_MODE == 1 then
		            				assert(false,"行针数据没有对应资源，检查策划行针相关资源，effectId ："..k)
		            			end
		            		end

		            	end
		            	zhengqiNum = allNum * value
		            	zhengqi = zhengqi + zhengqiNum
		            end    	
	           	end

				if state == 1 then
					role:addAttr("zhengqi", math.floor(zhengqi / 2))
					inheritInfo.zhengqiState = 2
					PopText("获得侠义正气 " .. math.floor(zhengqi / 2))
				elseif state == 2 then
					role:addAttr("zhengqi", -math.floor(zhengqi / 2))
					inheritInfo.zhengqiState = 3
					PopText("获得侠义正气 " .. -math.floor(zhengqi / 2))
				end
            end
        end
    end, IS_SHOW_WAITING)
end

-- 测试用，手动插入一个历代传承角色
function Inherit:insertInheritHistory()
	local role = User:getRole()
	local inheritHistory = role:getAttr("inheritHistory")

	if User:getRoleAttr("inheritCount") >= 5 then
		PopText("已经传承五次，无法继续传承")
		return
	end

	-- 保留角色所学江湖技能
	local bookSkills = require("app.models.book.BookSkills")
	local jianghuSkills = clone(bookSkills:getbookSkill())
	local parentSkills = {}

	-- for k,v in pairs(jianghuSkills) do
	-- 	local skill = User:getRole():getSkill(v.skillId)
	-- 	if skill then
	-- 		table.insert(parentSkills, {id = skill.id, exp = math.ceil(skill.exp)})
	-- 	end
	-- end
	for index,skill in pairs(jianghuSkills) do 
        if skill and skill.belong == 1 then --剔除门派技能 1为门派
            jianghuSkills[index] = nil
        end
    end
	for k,v in pairs(jianghuSkills) do
		local skill = Skill:getSkill(v.skillId)
		if skill then
			-- 测试所有技能等级随机
			table.insert(parentSkills, {id = skill.id, exp = math.ceil(skill:getExp(math.random(1,700)))})
		end
	end

	table.insert(inheritHistory,
		{
			parentName = User:getRoleAttr("name") .. tostring(User:getRoleAttr("inheritCount") + 1), 	-- 当前角色姓名
			inheritName = User:getRoleAttr("name"),														-- 继承人姓名
			inheritTime = GetTime(),																	-- 继承时间
			retireMap = 5,																				-- 当前角色隐退副本
			parentDsc = User:getRole():getInheritDsc(),													-- 当前角色描述
			parentSkills = parentSkills,																-- 当前角色所学的江湖技能
			zhengqiState = 1,																			-- 论道状态
		})

	role:setAttr("inheritCount", User:getRoleAttr("inheritCount") + 1)

	-- role:setAttr("inheritHistory", inheritHistory)
end

-- 领养
function Inherit:LingYang()
	-- 随机孤儿类型
	local type = math.random(1,4)
	local inherit = User:getRoleAttr("inherit")
	-- 标记为已领养
	User:setRoleAttr("isHaveOrphan", true)
	User:getRole():setFlag("传承开始", 0)
	inherit.isSetName = false
	inherit.isFinish = false

	inherit.type = type
	inherit.intimacy = 0			-- 亲密度
	inherit.age = 8 				-- 年龄
	inherit.endurance = 100 		-- 疲劳
	inherit.zhengqi = 0 			-- 正邪值
	inherit.addAttr = 0 			-- 培养增加的属性和
	inherit.eventCount = 1
	inherit.sex = User:getRoleAttr("sex")
	if inherit.sex == "男" then
		if type == 1 then 				-- 男 胖
			inherit.physique = 4 		-- 体质
			inherit.noema = 2 			-- 心智
			inherit.morality = 3 		-- 德行
			inherit.temperament = 1 	-- 气质

		elseif type == 2 then			-- 男 瘦
			inherit.physique = 5 		-- 体质
			inherit.noema = 5 			-- 心智
			inherit.morality = 3 		-- 德行
			inherit.temperament = 3 	-- 气质

		elseif type == 3 then			-- 男 顽皮
			inherit.physique = 5 		-- 体质
			inherit.noema = 3 			-- 心智
			inherit.morality = 2 		-- 德行
			inherit.temperament = 2 	-- 气质

		elseif type == 4 then			-- 男 文弱
			inherit.physique = 1 		-- 体质
			inherit.noema = 3 			-- 心智
			inherit.morality = 5 		-- 德行
			inherit.temperament = 4 	-- 气质
		end
	elseif inherit.sex == "女" then
		if type == 1 then 				-- 女 活泼
			inherit.physique = 3 		-- 体质
			inherit.noema = 3 			-- 心智
			inherit.morality = 4 		-- 德行
			inherit.temperament = 4 	-- 气质

		elseif type == 2 then			-- 女 文静
			inherit.physique = 1 		-- 体质
			inherit.noema = 4 			-- 心智
			inherit.morality = 5 		-- 德行
			inherit.temperament = 5 	-- 气质

		elseif type == 3 then			-- 女 呆萌
			inherit.physique = 1 		-- 体质
			inherit.noema = 2 			-- 心智
			inherit.morality = 4 		-- 德行
			inherit.temperament = 5 	-- 气质

		elseif type == 4 then			-- 女 泼辣
			inherit.physique = 5 		-- 体质
			inherit.noema = 3 			-- 心智
			inherit.morality = 3 		-- 德行
			inherit.temperament = 2 	-- 气质
		end
	end

	local desc =
	{
		[1] =
		{
			"$S生于孤家集，",
			"$S生于孤家集附近的牛家村，",
			"$S生于孤家集附近的李家村，",
			"$S生于孤家集附近的王家村，",
			"$S生于孤家集附近的云来村，",
			"$S生于孤家集附近的七里屯，",
			"$S生于孤家集附近的刘家庄，",
			"$S生于孤家集附近的裕丰村，",
			"$S生于孤家集附近的钟山村，",
			"$S生于孤家集附近的新马庄，",
			"$S生于孤家集附近的黄金屯，",
			"$S生于孤家集附近的九里村，",
			"$S生于孤家集附近的云家庄，",
			"$S生于孤家集附近的莫家庄，",
			"$S生于孤家集附近的衡水村，",
			"$S生于孤家集附近的新庄村，",
			"$S生于孤家集附近的永乐屯，",
			"$S生于孤家集附近的长富屯，",
			"$S生于孤家集附近的万丰屯，",
			"$S生于孤家集附近的天兴屯，",
		},

		[2] =
		{
			"五岁时父母外出务工再也没有回来，从此被幽冥教收养。",
			"父母在$S两岁时抛下了$S，因此被幽冥教收养。",
			"四岁时父母无故失踪，因此被幽冥教收养。",
			"三岁时父母在修山路时因意外掉落山崖，因而被幽冥教收养。",
			"$S的父母在$S四岁时候将$S交给幽冥教抚养，没想到数年后竟然双双病亡。",
			"$S的父母在四岁时离奇失踪，是幽冥教收养了$S。",
			"$S的父母在$S两岁时就离家出走，没有再回来，是幽冥教收养了$S。",
			"$S的父母在$S三岁的时候因一场瘟疫身亡，是幽冥教将其捡回并治好了$S。",
			"两岁时随父母回娘家省亲，双亲被一伙蒙面人杀害，幸好幽冥教路过，将其救下。",
			"三岁时$S的父母无故失踪，幽冥教收留了$S。",
			"四岁的$S被父母所抛弃，是幽冥教收养了$S。",
			"五岁时$S的父母因一场瘟疫而亡，碰巧幽冥教路过，救下了$S。",
			"$S的父母在四岁的时候离$S而去，是幽冥教救下了$S。",
			"$S的父母在$S五岁时被强盗所杀，恰好幽冥教路过，将强盗杀死，救下了$S。",
			"$S三岁的时候家中起火，父母皆被烧死，唯有$S活了下来。",
			"$S四岁时外出玩耍，回家却见父母倒于血泊之中，幽冥教收养了$S。",
			"$S的父母在$S两岁那年因一场瘟疫而亡，是幽冥教收养了$S。",
			"$S的父母在$S三岁那年无故失踪，幽冥教收留了$S，",
			"$S的父母在$S三岁的时候抛下了$S，是幽冥教收养了$S。",
			"$S一出生就没有了父母，被幽冥教抚养长大，",
			"$S的父母在$S四岁时在一场火灾中离世，是幽冥教收养了$S，",
			"$S的父母在$S五岁时被山贼所杀，是幽冥教收养了$S，",
			"$S的父母在$S两岁时将$S托付给幽冥教，为此$S一直耿耿于怀，",
			"$S的父母在$S两岁时候因一场瘟疫而亡，是幽冥教收养了$S。",
			"$S刚出生时，$S的父母就遗弃了$S，是幽冥教收养了$S，",
			"在$S三岁那年，强盗洗劫了$S所在的村庄，村中只剩$S一人，被人幽冥教收养，",
			"在$S四岁那年，家中起火，父母皆被烧死，唯有$S活了下来。",
			"在$S五岁那年，$S的父母因为一场意外丧命，是幽冥教收留了$S，",
			"在$S四岁那年，村中水井被人投毒，$S的父母不幸罹难，幽冥教收留了$S，",
			"在$S三岁那年，$S的父母因为家贫而遗弃了$S，是幽冥教收养了$S，",

		},
		[3] =
		{
			"在机缘巧合下于$T跟随你逃出孤家集并为你所领养。"
		}


	}
	local descStr = ""
	for i,v in ipairs(desc) do
		descStr = descStr .. v[math.random(1, #v)]
	end
	local sex = "它"
	if inherit.sex == "男" then
		sex = "他"
	elseif inherit.sex == "女" then
		sex = "她"
	end
	local tiemDesc = Helper:numberCast(Helper:date("%y", GetTime())) .. "年" .. Helper:numberCast(Helper:date("%m", GetTime())).. "月" .. Helper:numberCast(Helper:date("%d", GetTime())).. "日"
	inherit.desc = string.gsub(descStr, "$S", sex)
	inherit.desc = string.gsub(inherit.desc, "$T", tiemDesc)
end

-- 传承 测试
function Inherit:testInherit()
	-- 上传存档
	HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 then
			local role = User:getRole():createInheritRole()

			local inheritHistory = role:getAttr("inheritHistory")
			local dsc = User:getRole():getInheritDsc()

			inheritHistory[#inheritHistory].retireMap = 5
			inheritHistory[#inheritHistory].parentDsc = dsc

			local userId = User:getUserId()
			local dataVer = User:getRole():getServerActionSystem():getDataVersion()
			local currencyVersion = User:getRole():getCurrencyVersion()
			
	        DataBase:resetRoleData()

			HttpManagerEx:inherit(
				role:getTrimData(), 
				userId,
				dataVer,
				currencyVersion,
				function(status, errcode, errmsg, data)
				    if status == 200 then
				        if errcode == 0 then
				            Game:restart(function()
				                cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
				                    PopText("传承成功")
				                end)
				            end)
				        else
				            Game:restart(function()
				                cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
				                    print(errmsg)
				                    PopText(errmsg)
				                end)
				            end)
				        end
				    end
				end, IS_SHOW_WAITING)
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

-- 传承正式
function Inherit:doInherit(inheritImprintingData)
	assert(type(inheritImprintingData) == "table", "Inherit:doInherit - inheritImprintingData must be a table")

	local roleName = User:getRoleAttr("name")
	if roleName == "无名氏" then
		PopText("无名氏状态下，无法进行传承")
		return
	end

	if #inheritImprintingData <= 0  then
		inheritImprintingData = {{}}
	end
	
	-- 上传存档
    HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 and errcode == 0 then
            local role = User:getRole():createInheritRole()

            MeridianHelper:meridianDoInherit(role, inheritImprintingData)

            local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
            local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
            teacherAnimationLayer:setVisible(false)
            local text =
                {
                    [1] = "长年的江湖争斗令你感到厌倦，",
                    [2] = "于是你决定急流勇退，",
                    [3] = "从此做一位闲云野鹤，不再过问江湖之事,",
                    [4] = "你觉得是时候将衣钵传与$IN了。",
                    [5] = "你将随身多年的行囊交付与$S，里面是你的积蓄和全部的家当，",
                }
            text[4] = string.gsub(text[4], "$IN", role.name)
            local str = "你将随身携带的"
            local flag = false
            if User:getRole():yueKaIsValid() then
                str = str .. "江湖名士腰牌"
                flag = true
            end
            if User:getRole():monthFenShenFuIsValid() then
                str = str .. "一叠符"
                flag = true
            end
            if flag then
                str = str .. "交到$S手上并嘱咐$S此物甚为重要须妥善保管，"
                table.insert(text, str)
            end
            local shenbingItems = User:getRole():getAttr("shenBingItems")
            if MapIsEmpty(shenbingItems) == false then
            	local weapon_name = shenbingItems[1].nameColor..shenbingItems[1].name
                local str = "你将耗费毕生心血打造的神兵" .. weapon_name .. "ORA交到$S手中，"
                table.insert(text, str)
            end
            table.insert(text, "你拍了拍$S的肩膀，一股真气涌入$S的体内，")
            table.insert(text, "最后背身而去，决定隐居在")

            local trueSex=User:getRoleAttr("inherit").sex
            local strSex="他"
            if trueSex=="女" then 
            	strSex="她"
            end
            for i,str in pairs(text) do 
            	if string.find(str,"$S") then 
            		text[i] = string.gsub(str, "$S", strSex)
            	end
            end
            -- 随机隐退地址
            local addrs =
                {
                    {"牛家村", 3},
                    {"华山村", 5},
                    {"逍遥林", 6},
                    {"青城山", 8},
                    {"金陵城", 9},
                    {"扬州城", 10},
                    {"南阳", 11},
                    {"汝州", 12},
                    {"嵩山", 13},
                    {"苏州城", 15},
                    {"华山", 18},
                    {"太行谷", 19},
                    {"襄阳城", 20},
                    {"武当山", 21},
                    {"落英谷", 22},
                    {"峨眉山", 24},
                    {"长安城", 25},
                    {"武功镇", 26},
                    {"终南山", 27},
                    {"大理城", 30},
                    {"长恨谷", 32},
                }

            local addr = {}

            for i = 1, 4 do
                local index = math.random(1, #addrs)
                table.insert(addr, addrs[index])
                table.remove(addrs, index)
            end

            local inheritHistory = role:getAttr("inheritHistory")
            local dsc = User:getRole():getInheritDsc()

            local qwert = {
                [1] = "请选择隐退的地点：",
                [2] = {
                    -- 隐退地点保存继承角色身上
                    [1] = {addr[1][1], clickFunc = function()
                        inheritHistory[#inheritHistory].retireMap = addr[1][2]
                        inheritHistory[#inheritHistory].parentDsc = dsc
                    end},
                    [2] = {addr[2][1], clickFunc = function()
                        inheritHistory[#inheritHistory].retireMap = addr[2][2]
                        inheritHistory[#inheritHistory].parentDsc = dsc
                    end},
                    [3] = {addr[3][1], clickFunc = function()
                        inheritHistory[#inheritHistory].retireMap = addr[3][2]
                        inheritHistory[#inheritHistory].parentDsc = dsc
                    end},
                    [4] = {addr[4][1], clickFunc = function()
                        inheritHistory[#inheritHistory].retireMap = addr[4][2]
                        inheritHistory[#inheritHistory].parentDsc = dsc
                    end},
                }
            }
            table.insert(text, qwert)
            Audio:playMusic("inherit", true)

            -- 显示文本动画后，开始传承
            teacherAnimationLayer:createTextFromArray(text, "传承", 50)
            teacherAnimationLayer:show(
                function()
                    Audio:stopMusic()

					local currencyVersion = User:getRole():getCurrencyVersion()

					HttpManagerEx:canInherit(currencyVersion,function(status, errcode, errmsg, data)
						if status == 200 and errcode == 0 then
							local userId = User:getUserId()
							local dataVer = User:getRole():getServerActionSystem():getDataVersion()

							IS_ABLE_TO_SAVE_DATA = false
							DataBase:resetRoleData()

							HttpManagerEx:inherit(
								role:getTrimData(), 
								userId,
								dataVer,
								currencyVersion,
								function(status, errcode, errmsg, data)
									if status == 200 then 
										if errcode == 0 then
											Game:restart(function()
												cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
													PopText("传承成功")
												end)
											end)
											return true
										elseif errcode == 6 then
											--@desc 已经传承过了
											Game:restart(function()
												cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
													PopText(errmsg)
												end)
											end)
											return true
										else
											IS_ABLE_TO_SAVE_DATA = true
											PopText(errmsg)
											return false
										end
									else
										IS_ABLE_TO_SAVE_DATA = true
										PopText(errmsg)
										return false
									end
								end, 
								IS_SHOW_WAITING,
								HTTP_MANAGER_RETRY_TYPE_RETRY
							)
						else
							PopText(errmsg)
						end
					end, IS_SHOW_WAITING)
                end)
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

return Inherit000000000000000