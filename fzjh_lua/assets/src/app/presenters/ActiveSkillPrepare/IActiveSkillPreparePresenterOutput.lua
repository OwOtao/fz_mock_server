local interface = require("third.class.interface")
local IActiveSkillPreparePresenterOutput = {}

--[[
    @desc: 设置导航栏
    author:TangJian
    time:2022-09-09 18:56:05
    --@texts: 导航标签名
	--@index: 当前激活的
    @return:
]]
function IActiveSkillPreparePresenterOutput:setNavigationBar(texts, index)
end

--[[
    @desc: 设置准备的主动技能列表
    author:TangJian
    time:2022-09-09 18:55:52
    --@items: {{"主动技能名", "武学名"}}
    @return:
]]
function IActiveSkillPreparePresenterOutput:showMiddleList(items)
end

--[[
    @desc: 设置顶部文字
    author:TangJian
    time:2022-09-09 18:54:55
    --@text: 
    @return:
]]
function IActiveSkillPreparePresenterOutput:setTopText(text)
end

--[[
    @desc: 设置底部文字
    author:TangJian
    time:2022-09-09 18:55:28
    --@text: 
    @return:
]]
function IActiveSkillPreparePresenterOutput:setBottomText(text)
end

return interface("IActiveSkillPreparePresenterOutput", IActiveSkillPreparePresenterOutput)
000000