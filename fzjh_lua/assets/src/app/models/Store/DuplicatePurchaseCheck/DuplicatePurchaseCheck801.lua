--[[
##### 801：是否拥有称号

- 类型编号：801
- 含义：是否拥有称号
- 检索值：称号Id
- 判断条件：=
- 判断值：逻辑值
- 拼贴格式：`<逻辑值>`+"称号" + 【`<称号名称>`】
  - `<称号名称>`转化方式：根据检索值中填写的称号Id，读取`<称号配置表.xlsx>`表中`<称号文本;text>`字段值
  - - `<逻辑值>`转化方式：
      - ①  "1"  为  "已拥有"  ;
      - ②  "0" 为 "未拥有"；
- 提示文本举例：
  - 检索Id：800000，检索值：40048，判断条件：=，判断值：1
  - 输出的提示文本为：已拥有称号【重光破晓】
]]
local newClass = require("third.class.NewClass")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck801 = {}

--[[
    @desc: 
    author:tanqinjian
    time:2026-05-18 14:37:53
    --@role: 
    @return:bool true:不允许购买 false:允许购买
]]
function DuplicatePurchaseCheck801:checkDuplicatePurchase(role)
    local result = false

    local msg = nil

    local titleId = self._res:getSearchvalue()

    local boolHasTitle = role:hasBasicTitle(titleId)

    local c_value = boolHasTitle and 1 or 0

    if self:_compareValue(c_value) then
        result = true
        local titleName = RoleTitleResManager:getBasicTitleClassById(titleId):getText()
        msg = string.format("%s称号【%s】", boolHasTitle and "已拥有" or "未拥有", titleName)
    else
        result = false
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck801", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck801)
000000000