--[[
##### 1003：是否拥有护元经脉页

- 类型编号：1003
- 含义：是否拥有护元经脉页
- 检索值：jmskillpage
- 判断条件：=
- 判断值：逻辑值
- 拼贴格式：`<逻辑值>`+ "【护元经脉页】"
  - `<逻辑值>`转化方式：
    - ①  "1"  为  "已拥有"  ;
    - ②  "0" 为 "未拥有"；
- 提示文本举例：
  - 检索Id：800002，检索值：jmskillpage，判断条件：=，判断值：1
  - 输出的提示文本为：已拥有【护元经脉页】
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck1003 = {}

function DuplicatePurchaseCheck1003:checkDuplicatePurchase(role)
    local result = false

    local msg = nil

    local searchValue = self._res:getSearchvalue()

    if searchValue ~= "jmskillpage" then
        error("该类型检索值只允许填：jmskillpage")
    end

    local page_index = 2

    local boolHasMeridianImprintingPage = role:getMeridianSystem():isUnLockMeridianImprintingPage(page_index)

    local c_value = boolHasMeridianImprintingPage and 1 or 0

    --@RefType [src.app.models.Meridian.BasicMeridianImprintingPage#BasicMeridianImprintingPage]
    local BasicMeridianImprintingPage = require("app.models.Meridian.BasicMeridianImprintingPage")

    if self:_compareValue(c_value) then
        result = true
        msg = string.format("%s【%s页】", boolHasMeridianImprintingPage and "已拥有" or "未拥有", BasicMeridianImprintingPage.PAGE_NAME_INDEX[page_index])
    else
        result = false
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck1003", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck1003)
0000000000000