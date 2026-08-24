local GiftPagePresenter = class("GiftPagePresenter", cc.Layer)

function GiftPagePresenter:create()
    local p = GiftPagePresenter:new()
    p:init()
    return p
end

function GiftPagePresenter:init()
    self.__ui = require("app.views.ui.SkillUI.MapActivePracticeUI"):create()

    self.__ui:addTo(self)
end

function GiftPagePresenter:showLayer()
    self.__zhaoIdList = self.__model:getZhaoIdList()

    self.__zhaoLearnNum = self.__model:getZhaoLearnNum()

    self.__praResMap = self.__model:getPraResMap()

    self.__zhaoLearnMaxNum = self.__praResMap.number

    self:__initSkillTitleList()

    self:setIndex(1)

    self:setSkillId(nil)

    self:showTextAttr1()

    self:showTextAttr2()

    self:showTextDesc()

    self:showTabListView()

    self:refreshSkillListView()

    self:hideZhaoDesc()

    self:showPanelTip()

    self:setTextTitle()
    
    self:setForgetButton()

    self.__ui:show()
end

function GiftPagePresenter:__refreshLayer()
    self:__initSkillTitleList()
    
    self:showTextDesc()

    self:__setSkillListView()
end

function GiftPagePresenter:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)

    self:__setSkillListView()
end

function GiftPagePresenter:setModel(model)
    self.__model = model
end

function GiftPagePresenter:setPlayer(player)
    self.__role = player
end

function GiftPagePresenter:setIndex(index)
    self.__index = index
end

function GiftPagePresenter:setSkillId(skillId)
    self.__skillId = skillId
end

function GiftPagePresenter:showTextAttr1()
    self.__ui:setTextAttr1("")
end

function GiftPagePresenter:showTextAttr2()
    self.__ui:setTextAttr2("")
end

function GiftPagePresenter:showTextDesc()
    self.__ui:setTextDesc("陪练已掌握："..self.__zhaoLearnNum.."/"..self.__zhaoLearnMaxNum)
end

function GiftPagePresenter:setTextTitle()
    self.__ui:showTitle()
    
    self.__ui:setTextTitle("秘籍残页")
end

function GiftPagePresenter:showTabListView()
    local retArray = {}
    for i,skillTab in ipairs(self.__skillTitleList) do
        local tab = {
            title = "",
            func = EMPTY_FUNC
        }
        tab["title"] = skillTab.name
        tab["func"] = function()
            self:setIndex(i)

            self:setSkillId(nil)

            self:refreshSkillListView()
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTabListView(retArray)
end

function GiftPagePresenter:__setSkillListView()
    local retArray = {}
    local bookList = self.__skillTitleList[self.__index].list

    if MapIsEmpty(bookList) == false then
        for index,v in ipairs(bookList) do
            local tab = {
                name = "",
                image = Resource:getImgPath("title_flod"),
                func = EMPTY_FUNC
            }

            local skillId = v.id

            local bookData = v.bookData

            tab["name"] = "【" .. v.bookData.name .. "】"
            
            if skillId == self.__skillId then
                tab["image"] = Resource:getImgPath("title_unflod")
            end

            tab["func"] = function()
                self:setSkillId(v.id)

                self:__setSkillListView()

                if not MapIsEmpty(bookData) then
                    local insetPos = index
                    for k,page in ipairs(bookData.page) do
                        if page.count > 0 then
                            insetPos = insetPos + 1

                            local itemId = page.itemId

                            local itemAttr = Item:getOneItemByKey(itemId)

                            self.__ui:insertActive(insetPos-1, 
                                {   
                                    name = "【" .. page.CHName .. "】" .. " X " .. page.count, 
                                    exp = "",
                                    func = function()
                                        self:showZhaoDesc(itemAttr)
                                    end
                                }
                            )
                        end
                    end
                    self.__ui:jumpToItem(index)
                end
            end
            table.insert(retArray, tab)
        end
    end

    self.__ui:setSkillListView(retArray)
end

function GiftPagePresenter:__initSkillTitleList()
    self.__skillTitleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}},
    }

    local bookSkills = require("app.models.book.BookSkills")
	local bookActiveZhao = clone(bookSkills:getBookActiveZhao())
    local zhaoShuXiang = self.__role:getAttr("zhaoShuXiang")
    
    local _zhaoshuxiang = {}

	for i, bookCase in pairs(zhaoShuXiang) do
		if _zhaoshuxiang[bookCase.itemId] then
			_zhaoshuxiang[bookCase.itemId] = bookCase.count + _zhaoshuxiang[bookCase.itemId]
		else
			_zhaoshuxiang[bookCase.itemId] = bookCase.count
		end
	end

	local function addSkillToTable(skillType, bookData, skillId)
		if skillType == "quanjiao" then
            table.insert(self.__skillTitleList[1].list, {id = skillId,bookData = bookData})
		elseif skillType == "bingqi" then
			table.insert(self.__skillTitleList[2].list, {id = skillId,bookData = bookData})
		elseif skillType == "qinggong" then
			table.insert(self.__skillTitleList[3].list, {id = skillId,bookData = bookData})
		elseif skillType == "neigong" then
			table.insert(self.__skillTitleList[4].list, {id = skillId,bookData = bookData})
		elseif skillType == "zhaojia" then
			table.insert(self.__skillTitleList[5].list, {id = skillId,bookData = bookData})
		end
	end

    local _zhaoshuxiang_add = {}

	-- 添加书页
	for skillId, bookData in pairs(bookActiveZhao) do
		for j,page in pairs(bookData.page) do
			if _zhaoshuxiang[page.name] then
				local itemAttr = Item:getOneItemByKey(page.name)
				page.count = tonumber(_zhaoshuxiang[page.name]) + Helper:getDef(page.count,0)
				page.CHName = itemAttr.name
				page.itemId = page.name

				if not _zhaoshuxiang_add[skillId] and page.count > 0 then
					_zhaoshuxiang_add[skillId] = true
					if bookData.type[1] ~= nil then
						addSkillToTable(bookData.type[1], bookData, skillId)
					end
					if bookData.type[2] ~= nil then
						addSkillToTable(bookData.type[2], bookData, skillId)
					end
				end
			end
		end
	end
end

function GiftPagePresenter:hideZhaoDesc()
    self.__ui:hideZhaoDesc()
end

function GiftPagePresenter:showZhaoDesc(itemAttr)
    local retData = {}

    retData.name = itemAttr.name

    retData.desc = itemAttr.dsc
    
    retData.level = itemAttr.type

    retData.exp = ""

    retData.needExp = ""

    retData.leftButtonName = nil

    retData.rightButtonName = "赠\n与"

    retData.rightFunc = function()
        self:hideZhaoDesc()

        local text = "是否确认赠与陪练"..itemAttr.name.."？"
        
        self:__showConfirmLayer(
            text,
            function()
                local zhaoId = itemAttr.zhaoId

                local canGift , msg = self:__isCanGift(itemAttr)

                if canGift == false then
                    PopText(msg)
                    return
                end

                self.__model:giftZhaoPage(
                    zhaoId,
                    itemAttr.id,
                    function(isOk, errmsg, data)
                        if isOk then
                            self.__zhaoIdList = self.__model:getZhaoIdList()

                            self.__zhaoLearnNum = self.__model:getZhaoLearnNum()

                            self:__refreshLayer()

                            PopText("赠与成功，你可与其对练该绝学招式")
                        else
                            PopText(errmsg)
                        end
                    end
                )
                
            end
        )
    end

    self.__ui:showZhaoDesc(retData)
end

function GiftPagePresenter:__isCanGift(itemAttr)
    if self.__zhaoLearnNum >= self.__zhaoLearnMaxNum then
        return false , "该陪练目前的忠诚度有限，不足以学习更多招式！"
    end
    
    if not MapIsEmpty(self.__zhaoIdList) then
        for i,v in ipairs(self.__zhaoIdList) do
            if itemAttr.zhaoId == v then
                return false ,itemAttr.name.."招式，陪练已经学习过了"
            end    
        end 
    end

    return true
end

function GiftPagePresenter:showPanelTip()
    self.__ui:showPanelTip("江湖武学主动技能残页参与挑战玩法、历练任务有几率获得。\n门派武学主动技能残页可通过师门处寻找商人花费师门贡献点购买。\n已学的江湖、门派武学主动技能传承不保留，没使用在书箱内的主动技能残页传承保留。")
end

function GiftPagePresenter:setForgetButton()
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setCustomButton("忘却",function()
        self:hideZhaoDesc()

        if MapIsEmpty(self.__zhaoIdList) then
            PopText("你的陪练没有学习任何招式。")
            return
        end

        HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    User:setRoleAttr("yuanbao", data.yuanbao)

                    MainControllLayer:pushLayer("ForgetPagePresenter")
                    local forgetPagePresenter = MainControllLayer:getLayer("ForgetPagePresenter")
                    forgetPagePresenter:setModel(self.__model)
                    forgetPagePresenter:setPlayer(self.__role)
                    forgetPagePresenter:setCallBack(function()
                        self.__zhaoLearnNum = self.__model:getZhaoLearnNum()
                        
                        self:showTextDesc()
                    end)
                    forgetPagePresenter:showLayer()
                else
                    PopText(errmsg)
                end
            end
        end)
    end)
end

function GiftPagePresenter:__showConfirmLayer(text,func)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

    local dialog = DialogALayer:getInstance()
    
    dialog:hide()
    dialog:show(text)
    dialog:setButton1(
        "确定",
        function()
            func()
        end
    )
    dialog:setButton2("取消",EMPTY_FUNC)
    dialog:setWeChatVisible(false)
end

Helper:classDefNodeGetInstance(GiftPagePresenter)
return GiftPagePresenter
0000000000000000