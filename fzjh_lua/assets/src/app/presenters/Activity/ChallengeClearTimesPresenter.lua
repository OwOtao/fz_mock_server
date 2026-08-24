local ChallengeClearTimesPresenter = class("ChallengeClearTimesPresenter", cc.Layer)

function ChallengeClearTimesPresenter:create()
    local p = ChallengeClearTimesPresenter:new()
    p:init()
    return p
end

function ChallengeClearTimesPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.ChallengeClearTimesUI"):create()

    self.__ui:addTo(self)

    self:__setRuleFunc()

    local interactor = require("app.models.Action.ChallengeClearTimes")

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self.__interactor = interactor:create()
end

function ChallengeClearTimesPresenter:showLayer()
    self.__interactor:setRole(User:getRole())
    
    self.__interactor:init(
        function()
            self:__initUI()

            self.__ui:showUI()
        end
    )
end

function ChallengeClearTimesPresenter:setActionId(actionId)
    self.__interactor:setActionId(actionId)
end

function ChallengeClearTimesPresenter:__initUI()
    self.__ui:setTextTitle(self.__interactor:getActionName())

    self.__ui:setDesc(self.__interactor:getActionDesc())

	self:__initShowTaskList()
    
	self.__ui:setButtonName("一键领取奖励")

	self.__ui:setButtonHongDian(self.__interactor:checkTaskIsFinish())

	self.__ui:setButtonFunc(function()
		self.__interactor:doReward(function()
			self:__initUI()
		end)
	end)
end

function ChallengeClearTimesPresenter:__initShowTaskList()
	local taskList = self.__interactor:getTaskList()

	table.sort(taskList, function(a,b)
		if a.state ~= b.state then
			return a.state < b.state
		else
			return a.task_id < b.task_id
		end
	end)

	local taskShowList = {}

    for __,taskData in ipairs(taskList) do
		local taskId = taskData.task_id

		local task = self.__interactor:getTaskInfo(taskId)

		local taskShowData = {
			name = task.tasktitle,
			desc = task.taskdesc,
			loadTexture = "Image/UI/ActionUI/complete.png",
			rewardText = task.rewardstext,
			hongdianVisible = false,
			conditionText = "",
			conditionInfoText = "",
			conditionFunc = EMPTY_FUNC
		}

		if self.__interactor:checkStateIsUnFinish(taskData.state) then
			taskShowData.loadTexture = "Image/UI/ActionUI/incomplete.png"
        end

		if self.__interactor:checkStateIsFinish(taskData.state) then
			taskShowData.hongdianVisible = true
        end

		taskShowData.itemFunc = function()
			self:__showGoodsInfoUI(taskData.reward)
		end

		if #task.condition == 1 then
			taskShowData.textEnable = false

			local conId = task.condition[1]

			local conditionInfo = self.__interactor:getConditionInfo(conId)

			local clearTimes = self.__interactor:getMapClearTimes(conId)

			taskShowData.conditionText = "当前进度："..conditionInfo.conditiontext.."("..clearTimes.."/"..conditionInfo.times..")"
		else
			taskShowData.textEnable = true

			taskShowData.conditionText = "点击查看任务详细进度"

			local symbolText = task.condition[1] == "and" and "(需全部完成)" or "(完成一项即可)"

			taskShowData.conditionInfoText = "当前进度"..symbolText

			local conIds = task.condition[2]

			for i,conId in ipairs(conIds) do
				local conditionInfo = self.__interactor:getConditionInfo(conId)

				local clearTimes = self.__interactor:getMapClearTimes(conId)

				taskShowData.conditionInfoText = taskShowData.conditionInfoText.."\n"..conditionInfo.conditiontext.."("..clearTimes.."/"..conditionInfo.times..")"
			end

			taskShowData.conditionFunc = function()
				self.__ui:setPanelInfoVisible(true)

				self.__ui:setPanelInfoFunc(function()
					self.__ui:setPanelInfoVisible(false)

					self.__ui:hideImageBg()
				end)
			end
		end

        
		table.insert(taskShowList,taskShowData)
    end

    self.__ui:showListView(taskShowList)
end

function ChallengeClearTimesPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeClearTimesPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function ChallengeClearTimesPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function ChallengeClearTimesPresenter:__setRuleFunc()
	self.__ui:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function ChallengeClearTimesPresenter:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

function ChallengeClearTimesPresenter:__showGoodsInfoUI(goodsList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

Helper:classDefNodeGetInstance(ChallengeClearTimesPresenter)

return ChallengeClearTimesPresenter
00000000000