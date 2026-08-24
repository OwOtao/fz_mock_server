local newClass = require("third.class.NewClass")

local Resource = require("app.Resource")

local Task = require("app.models.task.Task")

local LiLianTaskBtnPresenter = {}

function LiLianTaskBtnPresenter:create()
    return LiLianTaskBtnPresenter.new()
end

function LiLianTaskBtnPresenter:init()
    self.__ui:setInnerBtnClickMusic("daAnNiu")
    self.__ui:setNameImg(Resource:getImgPath(self.__task.buttonB))
    self.__ui:setProgressImg(Resource:getImgPath(self.__task.buttonA))
    self.__ui:setProgressPercent(100)
    self:updateUI()
end

function LiLianTaskBtnPresenter:getId()
    return self.__task.id
end

function LiLianTaskBtnPresenter:setTask(task)
    --@RefType [BaseTask]
    self.__task = task
end

function LiLianTaskBtnPresenter:setUI(ui)
    --@RefType [TaskBtnUI]
    self.__ui = ui
end

function LiLianTaskBtnPresenter:setMainTaskPresenter(mainTaskPresenter)
    --@RefType [MainTaskPresenter]
    self.__mainTaskPresenter = mainTaskPresenter
end

function LiLianTaskBtnPresenter:updateUI()
    local style = Task:getTaskStyle(self.__task.id)
    if style == "已接受" then
        self.__ui:setInnerBtnName("进行中")
        self.__ui:setInnerBtnClickFunc(
            function()
                self.__mainTaskPresenter:acceptLiLianTask(self:getId())
            end
        )
    elseif style == "待提交" then
        self.__ui:setInnerBtnName("任务完成")
        self.__ui:setInnerBtnClickFunc(
            function()
                self.__mainTaskPresenter:submitLiLianTask(self:getId())
            end
        )
    elseif style == "已完成" then
        self.__ui:setInnerBtnName("已完成")
        self.__ui:setInnerBtnClickFunc(
            function()
                PopText("你本周已完成，请下周再来。")
            end
        )
        
    elseif style == "已派遣" then
        self.__ui:setInnerBtnName("已派遣")
        self.__ui:setInnerBtnClickFunc(
            function()
                PopText("该任务已派遣")
            end
        )
    else
        self.__ui:setInnerBtnName("接受")
        self.__ui:setInnerBtnClickFunc(
            function()
                self.__mainTaskPresenter:acceptLiLianTask(self:getId())
            end
        )
    end
end

return newClass("LiLianTaskBtnPresenter", {}, LiLianTaskBtnPresenter)
000000000000000