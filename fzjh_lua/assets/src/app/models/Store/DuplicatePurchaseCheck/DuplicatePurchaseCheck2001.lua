--[[
##### 2001:拳脚技巧页个数

- 类型编号：2001
- 含义：拳脚技巧页个数
- 检索值：skillpageUL
- 判断条件：比较符号
- 判断值：数值
- 拼贴格式："已拥有【拳脚技巧页】数量" + `<比较符号>` + `<数值> `
  - `<比较符号>`转化方式：
    - ①  ">"  为  "大于"  ;
    - ②  ">=" 为 "大于等于"；
    - ③  "=" 为 "等于"；
    - ④  "<" 为  "小于"  ;
    - ⑤  "<=" 为  "小于等于"  ;
- 提示文本举例：
  - 检索Id：800003，检索值：skillpageUL，判断条件：>=，判断值：10
  - 输出的提示文本为：已拥有【拳脚技巧页】数量大于等于10
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck2001 = {}

function DuplicatePurchaseCheck2001:checkDuplicatePurchase(role)
    local result = false

    local msg = nil

    local searchValue = self._res:getSearchvalue()

    if searchValue ~= "skillpageUL" then
        error("该类型[2001]检索值只允许填：skillpageUL")
    end

    local pageCount = 1

    role:getFistFootSystem():getTalentPageCount(
        function(isOk, msg, data)
            if isOk then
                pageCount = tonumber(data.count) or 1
            end
        end,
        true
    )

    if self:_compareValue(pageCount) then
        result = true
        msg = string.format("已拥有【拳脚技巧页】数量%s%s", self:_getCompareSymbolText(), tostring(self:_getJudgingValue()))
    else
        result = false
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck2001", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck2001)
0000000000000000