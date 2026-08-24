local inherit = require("third.inherit.inherit")
local IZhaoImprovedPoolPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.IZhaoImprovedPoolPresenterOutput")
local IZhaoImprovedPoolPresenterInput = require("app.presenters.selfCreatedSkill.zhaoImprovedPool.IZhaoImprovedPoolPresenterInput")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local isImplement = require("third.assertIsInstance.assertIsInstance")

local LiLianMapZhaoImprovedPoolPresenter = {}

function LiLianMapZhaoImprovedPoolPresenter:create(IZhaoImprovedPoolOutput,selfCreatedSkillSystem,zhaoIndex)
    local p = inherit({}, LiLianMapZhaoImprovedPoolPresenter)
    p:init(IZhaoImprovedPoolOutput,selfCreatedSkillSystem,zhaoIndex)
    return p
end

function LiLianMapZhaoImprovedPoolPresenter:init(IZhaoImprovedPoolOutput,selfCreatedSkillSystem,zhaoIndex)
    self._selfCreatedSkillSystem = selfCreatedSkillSystem
    self._zhaoIndex = zhaoIndex
    self._IZhaoImprovedPoolOutput = isImplement(IZhaoImprovedPoolOutput, IZhaoImprovedPoolPresenterOutput)
    self._titleTable = {}
end


function LiLianMapZhaoImprovedPoolPresenter:showLayer(propList,canUseItem,callback,skillDataId)
    self._propList = propList
    self._canUseItem = canUseItem
    self._callback = callback
    self._skillDataId = skillDataId
    
    self:initTabView()
    self:createListView(1)
    self:setTitleImageShow()
    self:setImageBack()
    self:setPanelBack()
    self:showTextTital()
    self:showTextDesc()
    self:showTextDsc()
    self:setTipDsc()

    self._IZhaoImprovedPoolOutput:setShowLayer()
end

function LiLianMapZhaoImprovedPoolPresenter:initTabView()
    local list1 = self:filtraList("书卷",self._propList)
    local list2 = self:filtraList("书册",self._propList)

    self._titleTable = {
        {name = "全部", type = "全部",list = self._propList},
        -- {name = "书卷", type = "书卷",list = list1},
        -- {name = "书册", type = "书册",list = list2},
    }

    self._IZhaoImprovedPoolOutput:initTabView(self._titleTable,function(index,panel)
        Audio:playEffect("xiaoAnNiu")
        self:createListView(index)
        self:setTitleImageShow(panel)
    end)
end

function LiLianMapZhaoImprovedPoolPresenter:filtraList(type,list)
    local newList = {}
    for i,v in ipairs(list) do
        local propData = SelfCreatedSkillManager:getPropMap(v.propId)
        if propData and propData.type == type then
            table.insert( newList, v )
        end
    end
    return newList
end


function LiLianMapZhaoImprovedPoolPresenter:createListView(index)
    local list = {}
    local retData = {}
    self.hidePreBg = nil
    list = self._titleTable[index].list

    if not MapIsEmpty(list) then
        self._IZhaoImprovedPoolOutput:setTextEmpty(false,"")
    else
        self._IZhaoImprovedPoolOutput:setTextEmpty(true,"你的改良池空空如也")
    end

    for i, v in ipairs(list) do
        local retList = {
            name = "改良道具名称",
            count = 0,
            buttonFunc = EMPTY_FUNC
        }

        local item = SelfCreatedSkillManager:getPropMap(v.propId)
        if item then
            retList["name"] = item.name
            retList["count"] = v.count
            retList["buttonFunc"] = function(row)
                Audio:playEffect("xiaoAnNiu")
                if self.hidePreBg ~= nil then
                    self:hidePreBg()
                end
                row:setTouchEnabled(false)

                row.Image_title_bg_1:setVisible(true)
                row.Image_title_bg_2:setVisible(true)
                row.Image_title_bg_3:setVisible(true)

                self.hidePreBg = function()
                    row.Image_title_bg_1:setVisible(false)
                    row.Image_title_bg_2:setVisible(false)
                    row.Image_title_bg_3:setVisible(false)
                end

                self:showItemDetailLayer(item,row)
            end
            table.insert( retData, retList)
        end
    end

    self._IZhaoImprovedPoolOutput:setListView(retData)
    
end

function LiLianMapZhaoImprovedPoolPresenter:showItemDetailLayer(item,row)
    PopupLayerController:showLayer(
        "ItemDetailLayer",
        --@layer: [app.views.layer.PopLayer.ItemDetailLayer#ItemDetailLayer]
        function(layer)
            layer:setItemDesc(item.dsc)
            layer:setItemType(item.type)
            layer:setLeftBtn()
            layer:clearListView()
            layer:setItemDescTwo()
            if self._canUseItem then
                layer:setRightBtn(
                    "使 用",
                    function()
                        Audio:playEffect("xiaoAnNiu")
                        self._selfCreatedSkillSystem:useImproveProp(item.id,self._zhaoIndex,self._skillDataId,function(data)
                            if self._callback then
                                self._callback(data)
                            end
                            self._IZhaoImprovedPoolOutput:popText("你使用了"..item.name)
                            self._IZhaoImprovedPoolOutput:richPrint(item.useDsc)

                            layer:hideLayer()
                            self:hideLayer()
                        end)
                    end
                )
            else
                layer:setRightBtn()
            end
            
            layer:showLayer(
                item,
                function()
                    row:setTouchEnabled(true)
                end
            )
        end
    )
end

function LiLianMapZhaoImprovedPoolPresenter:setTitleImageShow(panel)
    self._IZhaoImprovedPoolOutput:setTitleImageShow(panel)
end

function LiLianMapZhaoImprovedPoolPresenter:setImageBack()
    self._IZhaoImprovedPoolOutput:setImageBack(function()
        Audio:playEffect("xiaoAnNiu")
        self:hideLayer()
    end)
end

function LiLianMapZhaoImprovedPoolPresenter:setPanelBack()
    self._IZhaoImprovedPoolOutput:setPanelBack(function()
        Audio:playEffect("xiaoAnNiu")
        self:hideLayer()
    end)
end

function LiLianMapZhaoImprovedPoolPresenter:showTextTital()
    self._IZhaoImprovedPoolOutput:setTextTital(false)
end

function LiLianMapZhaoImprovedPoolPresenter:showTextDsc()
    local text = "请选择你要使用的道具"
    self._IZhaoImprovedPoolOutput:setTextDsc(text,true)
end

function LiLianMapZhaoImprovedPoolPresenter:showTextDesc()
    local text = "\n点击上方感叹号可查看关于改良池玩法介绍。"
    self._IZhaoImprovedPoolOutput:setTextDesc(false)
end

function LiLianMapZhaoImprovedPoolPresenter:setTipDsc()
    local text = "完成历练任务有几率获得卷轴。\n卷轴可用来对当前招式进行优化与改良。\n传承将会保留已拥有的道具"
    self._IZhaoImprovedPoolOutput:setTipDsc(false)
end

function LiLianMapZhaoImprovedPoolPresenter:hideLayer()
    self._IZhaoImprovedPoolOutput:hideLayer()
end

isImplement(LiLianMapZhaoImprovedPoolPresenter, IZhaoImprovedPoolPresenterInput)
return LiLianMapZhaoImprovedPoolPresenter
0000000