local ActiveZhaoLearnBookConditonRes = require("app.models.book.ActiveZhaoLearnBookConditonRes")

local BookSkillsHelper = {}

function BookSkillsHelper:getActiveSkillLearnForBookText(activeId)
    -- 规范化 activeId：去掉结尾的数字，例如 "shengsijie10" -> "shengsijie"
    local _activeIdStr = tostring(activeId)
    local normalizedActiveId = _activeIdStr:match("^(.-)%d*$") or _activeIdStr

    local active_zhao = Skill:getActiveZhao(normalizedActiveId)
    if active_zhao.learnMethod ~= 1 then
        return ""
    end

    local skill_id = Skill:getSkillIdByZhaoId(normalizedActiveId)

    --@RefType [src.app.models.book.ActiveZhaoLearnBookConditonRes#ActiveZhaoLearnBookConditonRes]
    local bookLearnConditionRes = ActiveZhaoLearnBookConditonRes.getBookLearnConditionRes(skill_id)

    local allPages = bookLearnConditionRes:getAllPages()

    if allPages and #allPages > 0 then
        local pageNames = {}
        for _, page in ipairs(allPages) do
            --@RefType [src.app.models.book.ActiveZhaoLearnBookConditonRes#Page]
            page = page

            local page_item_id = page:getPageItemId()

            local item = Item:getItemByKey(page_item_id)

            if item == nil then
                assert(false, "ActiveZhaoLearnBookConditonRes:getActiveSkillIdByPageItemId() - 没有找到对应的学习残页ID:" .. tostring(page_item_id))
            end

            assert(item.zhaoId ~= nil, "ActiveZhaoLearnBookConditonRes:getActiveSkillIdByPageItemId() - 学习残页没有配置对应的主动技能ID, itemId:" .. tostring(page_item_id))

            if item.zhaoId == normalizedActiveId then
                return string.format("学习%d本%s后习得", page:getPageNeedCount(), item.name)
            end
        end
    end

    assert(false, "BookSkillsHelper:getActiveSkillLearnForBookText() - not find active skill learn for book text by activeId:" .. tostring(activeId))
end

return BookSkillsHelper
000000