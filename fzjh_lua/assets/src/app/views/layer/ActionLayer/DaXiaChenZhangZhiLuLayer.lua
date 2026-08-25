local DaXiaChenZhangZhiLuLayer = class("DaXiaChenZhangZhiLuLayer", LayerEx)
local Pokedex = require("script.others.tujian")
local BookLiterary = require("app.models.book.BookLiterary")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")

function DaXiaChenZhangZhiLuLayer:create()
    local p = DaXiaChenZhangZhiLuLayer:new()
    p:init()
    return p
end

function DaXiaChenZhangZhiLuLayer:init()
    self._UI = require("Layer/ActionUI/DaXiaChenZhangZhiLuUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:__setRuleFunc()

    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self:setVisible(false)
end

function DaXiaChenZhangZhiLuLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DaXiaChenZhangZhiLuLayer",
        function(layer)
            layer:hide()
        end
    )
end
--家园相关信息
local homelandInfo = {}
--论剑排名
local lunjianRanking = 999

local conditions = {
    inherit = function(role)
        local inheritCount = role:getNumAttr("inheritCount")
        return function(value)
            return inheritCount >= value
        end
    end,
    mapComplete = function(role)
        return function(mapId)
            return Map:getMapState(mapId) == MAP_STATE.COMPLETE
        end
    end,
    decorPoint = function(role)
        local point = 0
        for k, v in pairs(Pokedex["江湖容貌"]) do
            if role:getFlag("江湖容貌图鉴成就" .. v.achievementId) == 1 then
                point = point + v.point
            end
        end

        for k, v in pairs(Pokedex["面具"]) do
            if role:getFlag("面具图鉴成就" .. v.achievementId) == 1 then
                point = point + v.point
            end
        end

        for k, v in pairs(Pokedex["信物"]) do
            if role:getFlag("信物图鉴成就" .. v.achievementId) == 1 then
                point = point + v.point
            end
        end

        return function(value)
            return point >= value
        end
    end,
    bookScore = function(role)
        local BookLiterary = require("app.models.book.BookLiterary")
        local desc = BookLiterary:getEvaluateDesc()

        for _, v in pairs(GetColorList()) do
            local s, e = string.find(desc, v.id)
            if s ~= nil and e ~= nil then
                desc = string.gsub(desc,v.id,"")
            end
        end

        local descLevelList = {
            "大浪淘沙",
            "兼收并蓄",
            "充箱盈架",
            "五花八门",
            "汗牛充栋",
            "书盈四壁",
            "包罗万象",
            "坐拥百城",
            "浩如烟海",
            "灿若星河"
        }

        local roleLevel = 1

        for i, v in ipairs(descLevelList) do
            if desc == v then
                roleLevel = i
                break
            end
        end

        return function(condDesc)
            local condiLevel = 1

            for i, v in ipairs(descLevelList) do
                if v == condDesc then
                    condiLevel = i
                    break
                end
            end

            return roleLevel >= condiLevel
        end
    end,
    collectSocre = function(role)
        local collectLevelList = {
            "小有斩获",
            "什袭而藏",
            "琳琅满目",
            "洋洋大观",
            "武库充实",
            "紫电清霜",
            "剑胆琴心",
            "地负海涵",
            "物华天宝",
            "气冲牛斗"
        }

        local roleDesc = ShenBingDesc:getRoleCollectDesc(role)
        local roleLevel = 1
        for i, v in ipairs(collectLevelList) do
            if roleDesc == v then
                roleLevel = i
                break
            end
        end

        return function(collectDesc)
            local condiLevel = 1
            for i, v in ipairs(collectLevelList) do
                if collectDesc == v then
                    condiLevel = i
                    break
                end
            end

            return roleLevel >= condiLevel
        end
    end,
    meridianCount = function(role)
        local Meridian = require("app.models.Meridian.Meridian")
        Meridian:initMerdian()
        local meridian = role:getAttr("meridian")

        local count = meridian.meridianCount

        return function(value)
            return count >= value
        end
    end,
    chenghao = function(role)
        local hadGetTitle = {}



        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary) then
            hadGetTitle["初心未泯"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary2) then
            hadGetTitle["侠骨丹心"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary3) then
            hadGetTitle["我武惟扬"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary4) then
            hadGetTitle["纵酒传灯"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary5) then
            hadGetTitle["戍卫中原"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary6) then
            hadGetTitle["乱世枭雄"] = true
        end

        if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.Anniversary7) then
            hadGetTitle["天纵之才"] = true
        end

        if role:hasBasicTitle("10003") then
            hadGetTitle["剑荡八方"] = true
        end

        if role:hasBasicTitle("40045") then
            hadGetTitle["纵横天下"] = true
        end

        if role:hasBasicTitle("40052") then
            hadGetTitle["行者无疆"] = true
        end

        return function(chengHaoStr)
            return hadGetTitle[chengHaoStr]
        end
    end,

    homeland = function(role)
        local homelandAchievement = {}
        
        local fq = role:getHomelandAttr("fq")
        if not MapIsEmpty(fq) then 
            if homelandInfo["绣女"] then
                homelandAchievement["绣女"] = true 
            end
            if homelandInfo["门客"] then
                homelandAchievement["门客"] = true 
            end
            if homelandInfo["书童"] then
                homelandAchievement["书童"] = true 
            end

            local level = 0

            local fqId = fq.fqId
            local FangQiModel = require("app.models.HomelandModel.FangQiModel")
            level = FangQiModel:getLevel(fqId)
            
            local homeLv={
                ["风雨无忧"] = 0,
                ["简室德馨"] = 1,
                ["铭香小筑"] = 2,
                ["明宅翠苑"] = 3,
                ["家有百室"] = 4
            }
            for k,v in pairs(homeLv) do 
                if level >= v then 
                    homelandAchievement[k] = true
                end
            end
        end
        
        return function(homelandCond)
            return homelandAchievement[homelandCond]
        end
    end,

    lunjian = function(role)
        return function(ranking)
            return lunjianRanking <= ranking
        end
    end,
}

local achievementList = {
    {
        name = "名士之后",
        tiaojian = "传承1次",
        rewardDesc = "门派顶级残页*1，称心*1",
        flagSuffix = 1,
        condition = {
            id = "inherit",
            arg1 = 1
        },
        reward = {
            item = {
                menpaicanye4 = 1,
                year2eq1 = 1
            }
        }
    },
    {
        name = "家学深厚",
        tiaojian = "传承2次",
        rewardDesc = "门派顶级残页*2，守一*1",
        flagSuffix = 2,
        condition = {
            id = "inherit",
            arg1 = 2
        },
        reward = {
            item = {
                menpaicanye4 = 2,
                year2eq2 = 1
            }
        }
    },
    {
        name = "身世显赫",
        tiaojian = "传承3次",
        rewardDesc = "门派顶级残页*3，采菱*1，伏波*1",
        flagSuffix = 3,
        condition = {
            id = "inherit",
            arg1 = 3
        },
        reward = {
            item = {
                menpaicanye4 = 3,
                year2eq3 = 1,
                year2eq4 = 1
            }
        }
    },
    {
        name = "名士豪庭",
        tiaojian = "传承4次",
        rewardDesc = "门派顶级残页*4，降妖*1，含蕊*1，摩云*1",
        flagSuffix = 4,
        condition = {
            id = "inherit",
            arg1 = 4
        },
        reward = {
            item = {
                menpaicanye4 = 4,
                year2eq5 = 1,
                year2eq6 = 1,
                year2eq7 = 1
            }
        }
    },
    {
        name = "传世名门",
        tiaojian = "传承5次",
        rewardDesc = "门派顶级残页*5，擎荷*1，踏浪*1",
        flagSuffix = 5,
        condition = {
            id = "inherit",
            arg1 = 5
        },
        reward = {
            item = {
                menpaicanye4 = 5,
                year2eq8 = 1,
                year2eq9 = 1
            }
        }
    },
    --通过第十关
    {
        name = "事端渐起",
        tiaojian = "游历完扬州城",
        rewardDesc = "经验5000，阅历50",
        flagSuffix = 6,
        condition = {
            id = "mapComplete",
            arg1 = "fb10"
        },
        reward = {
            attr = {
                ["exp"] = 5000,
                ["yueli"] = 50
            }
        }
    },
    --通过二十关
    {
        name = "剑弑金贼",
        tiaojian = "游历完襄阳城",
        rewardDesc = "经验15000，阅历100",
        flagSuffix = 7,
        condition = {
            id = "mapComplete",
            arg1 = "fb20"
        },
        reward = {
            attr = {
                ["exp"] = 15000,
                ["yueli"] = 100
            }
        }
    },
    --通过三十关
    {
        name = "玄风之秘",
        tiaojian = "游历完大理城",
        rewardDesc = "经验30000，阅历200",
        flagSuffix = 8,
        condition = {
            id = "mapComplete",
            arg1 = "fb30"
        },
        reward = {
            attr = {
                ["exp"] = 30000,
                ["yueli"] = 200
            }
        }
    },
    --通过四十关
    {
        name = "先皇宝藏",
        tiaojian = "游历完关外",
        rewardDesc = "经验50000，阅历300",
        flagSuffix = 9,
        condition = {
            id = "mapComplete",
            arg1 = "fb40"
        },
        reward = {
            attr = {
                ["exp"] = 50000,
                ["yueli"] = 300
            }
        }
    },
    {
        name = "折掌镇海",
        tiaojian = "游历完海鲸寨",
        rewardDesc = "经验80000，阅历500",
        flagSuffix = 23,
        condition = {
            id = "mapComplete",
            arg1 = "fb45"
        },
        reward = {
            attr = {
                ["exp"] = 80000,
                ["yueli"] = 500
            }
        }
    },
     {
        name = "烟远宵深",
        tiaojian = "游历完甘州",
        rewardDesc = "经验80000，阅历500",
        flagSuffix = 26,
        condition = {
            id = "mapComplete",
            arg1 = "fb50"
        },
        reward = {
            attr = {
                ["exp"] = 80000,
                ["yueli"] = 500
            }
        }
    },
    {
        name = "初心未泯",
        tiaojian = "拥有称号【初心未泯】",
        rewardDesc = "江湖美誉*100",
        flagSuffix = 10,
        condition = {
            id = "chenghao",
            arg1 = "初心未泯"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 100
            }
        }
    },
    {
        name = "侠骨丹心",
        tiaojian = "拥有称号【侠骨丹心】",
        rewardDesc = "江湖美誉*200",
        flagSuffix = 11,
        condition = {
            id = "chenghao",
            arg1 = "侠骨丹心"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 200
            }
        }
    },
    {
        name = "我武惟扬",
        tiaojian = "拥有称号【我武惟扬】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 25,
        condition = {
            id = "chenghao",
            arg1 = "我武惟扬"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "纵酒传灯",
        tiaojian = "拥有称号【纵酒传灯】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 36,
        condition = {
            id = "chenghao",
            arg1 = "纵酒传灯"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "戍卫中原",
        tiaojian = "拥有称号【戍卫中原】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 37,
        condition = {
            id = "chenghao",
            arg1 = "戍卫中原"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "乱世枭雄",
        tiaojian = "拥有称号【乱世枭雄】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 38,
        condition = {
            id = "chenghao",
            arg1 = "乱世枭雄"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "天纵之才",
        tiaojian = "拥有称号【天纵之才】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 43,
        condition = {
            id = "chenghao",
            arg1 = "天纵之才"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "剑荡八方",
        tiaojian = "拥有称号【剑荡八方】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 44,
        condition = {
            id = "chenghao",
            arg1 = "剑荡八方"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "纵横天下",
        tiaojian = "拥有称号【纵横天下】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 45,
        condition = {
            id = "chenghao",
            arg1 = "纵横天下"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "行者无疆",
        tiaojian = "拥有称号【行者无疆】",
        rewardDesc = "江湖美誉*300",
        flagSuffix = 46,
        condition = {
            id = "chenghao",
            arg1 = "行者无疆"
        },
        reward = {
            netAttr = {
                ["meiyu"] = 300
            }
        }
    },
    {
        name = "衣冠楚楚",
        tiaojian = "装饰箱成就点达到300",
        rewardDesc = "洗颜水*1，面具福袋*1",
        flagSuffix = 12,
        condition = {
            id = "decorPoint",
            arg1 = 300
        },
        reward = {
            item = {
                ["xiyanshui"] = 1,
                ["mianjufudai"] = 1
            }
        }
    },
    {
        name = "鲜衣怒马",
        tiaojian = "装饰箱成就点达到550",
        rewardDesc = "洗颜水*2，面具福袋*1",
        flagSuffix = 13,
        condition = {
            id = "decorPoint",
            arg1 = 550
        },
        reward = {
            item = {
                ["xiyanshui"] = 2,
                ["mianjufudai"] = 1
            }
        }
    },
    {
        name = "鱼龙百变",
        tiaojian = "装饰箱成就点达到750",
        rewardDesc = "洗颜水*3，面具福袋*1",
        flagSuffix = 14,
        condition = {
            id = "decorPoint",
            arg1 = 750
        },
        reward = {
            item = {
                ["xiyanshui"] = 3,
                ["mianjufudai"] = 1
            }
        }
    },
    {
        name = "千变万化",
        tiaojian = "装饰箱成就点达到1000",
        rewardDesc = "洗颜水*5，面具福袋*1，戏曲面具（劳伦斯）*1",
        flagSuffix = 15,
        condition = {
            id = "decorPoint",
            arg1 = 1000
        },
        reward = {
            item = {
                ["xiyanshui"] = 5,
                ["mianjufudai"] = 1,
                ["mianju1060"] = 1
            }
        }
    },
    {
        name = "一人千面",
        tiaojian = "装饰箱成就点达到1500",
        rewardDesc = "余志枭（戏曲面具）*1",
        flagSuffix = 24,
        condition = {
            id = "decorPoint",
            arg1 = 1500
        },
        reward = {
            item = {
                ["mianju1087"] = 1
            }
        }
    },
    {
        name = "千姿百态",
        tiaojian = "装饰箱成就点达到2500",
        rewardDesc = "洗颜水*5、天工石*3、面具福袋*1",
        flagSuffix = 39,
        condition = {
            id = "decorPoint",
            arg1 = 2500
        },
        reward = {
            item = {
                ["xiyanshui"] = 5,
                ["tiangongshi1"] = 3,
                ["mianjufudai"] = 1,
            }
        }
    },
    {
        name = "充箱盈架",
        tiaojian = "藏书评价达到充箱盈架",
        rewardDesc = "文心雕龙*1",
        flagSuffix = 16,
        condition = {
            id = "bookScore",
            arg1 = "充箱盈架"
        },
        reward = {
            item = {
                ["yeshushuji46"] = 1
            }
        }
    },
    {
        name = "五花八门",
        tiaojian = "藏书评价达到五花八门",
        rewardDesc = "战国策*1",
        flagSuffix = 17,
        condition = {
            id = "bookScore",
            arg1 = "五花八门"
        },
        reward = {
            item = {
                ["yeshushuji47"] = 1
            }
        }
    },
    {
        name = "书盈四壁",
        tiaojian = "藏书评价达到书盈四壁",
        rewardDesc = "戏曲面具（王家才女）*1",
        flagSuffix = 18,
        condition = {
            id = "bookScore",
            arg1 = "书盈四壁"
        },
        reward = {
            item = {
                ["mianju1062"] = 1
            }
        }
    },
    {
        name = "包罗万象",
        tiaojian = "藏书评价达到包罗万象",
        rewardDesc = "警世通言*1、醒世恒言*1、喻世明言*1",
        flagSuffix = 40,
        condition = {
            id = "bookScore",
            arg1 = "包罗万象"
        },
        reward = {
            item = {
                ["yeshushuji65"] = 1,
                ["yeshushuji66"] = 1,
                ["yeshushuji67"] = 1,
            }
        }
    },
    {
        name = "洋洋大观",
        tiaojian = "武藏评价为洋洋大观",
        rewardDesc = "淬炼小锦囊*5",
        flagSuffix = 19,
        condition = {
            id = "collectSocre",
            arg1 = "洋洋大观"
        },
        reward = {
            item = {
                ["cuilianjinnang3"] = 5
            }
        }
    },
    {
        name = "武库充实",
        tiaojian = "武藏评价为武库充实",
        rewardDesc = "淬炼小锦囊*8",
        flagSuffix = 20,
        condition = {
            id = "collectSocre",
            arg1 = "武库充实"
        },
        reward = {
            item = {
                ["cuilianjinnang3"] = 8
            }
        }
    },
    {
        name = "紫电清霜",
        tiaojian = "武藏评价为紫电清霜",
        rewardDesc = "淬炼小锦囊*12",
        flagSuffix = 21,
        condition = {
            id = "collectSocre",
            arg1 = "紫电清霜"
        },
        reward = {
            item = {
                ["cuilianjinnang3"] = 12
            }
        }
    },
    {
        name = "剑胆琴心",
        tiaojian = "武藏评价为剑胆琴心",
        rewardDesc = "淬炼小锦囊*12",
        flagSuffix = 41,
        condition = {
            id = "collectSocre",
            arg1 = "剑胆琴心"
        },
        reward = {
            item = {
                ["cuilianjinnang3"] = 12
            }
        }
    },
    {
        name = "地负海涵",
        tiaojian = "武藏评价为地负海涵",
        rewardDesc = "淬炼小锦囊*12",
        flagSuffix = 42,
        condition = {
            id = "collectSocre",
            arg1 = "地负海涵"
        },
        reward = {
            item = {
                ["cuilianjinnang3"] = 12
            }
        }
    },
    {
        name = "八脉俱通",
        tiaojian = "打通八条经脉",
        rewardDesc = "三才丹*5、真气丹*10",
        flagSuffix = 22,
        condition = {
            id = "meridianCount",
            arg1 = 8
        },
        reward = {
            item = {
                ["sancaidan"] = 5,
                ["jingmai101"] = 10
            }
        }
    },
    {
        name = "风雨无忧",
        tiaojian = "拥有一栋普通房屋",
        rewardDesc = "翡翠白菜*1",
        flagSuffix = 27,
        condition = {
            id = "homeland",
            arg1 = "风雨无忧"
        },
        reward = {
            item = {
                ["20dxcjjiaju01"] = 1,
            }
        }
    },
    {
        name = "简室德馨",
        tiaojian = "拥有一栋简屋",
        rewardDesc = "七贤笔筒*1",
        flagSuffix = 28,
        condition = {
            id = "homeland",
            arg1 = "简室德馨"
        },
        reward = {
            item = {
                ["20dxcjjiaju02"] = 1,
            }
        }
    },
     {
        name = "铭香小筑",
        tiaojian = "拥有一栋秀筑",
        rewardDesc = "黄花梨木椅*1",
        flagSuffix = 29,
        condition = {
            id = "homeland",
            arg1 = "铭香小筑"
        },
        reward = {
            item = {
                ["20dxcjjiaju03"] = 1,
            }
        }
    },
    {
        name = "明宅翠苑",
        tiaojian = "拥有一栋豪宅",
        rewardDesc = "神骏图*1",
        flagSuffix = 30,
        condition = {
            id = "homeland",
            arg1 = "明宅翠苑"
        },
        reward = {
            item = {
                ["20dxcjjiaju04"] = 1,
            }
        }
    },
    {
        name = "家有百室",
        tiaojian = "拥有一栋顶级豪宅",
        rewardDesc = "月纱床*1",
        flagSuffix = 31,
        condition = {
            id = "homeland",
            arg1 = "家有百室"
        },
        reward = {
            item = {
                ["20dxcjjiaju05"] = 1,
            }
        }
    },
     {
        name = "乐友好客",
        tiaojian = "拥有一名门客",
        rewardDesc = "HIC飞星棍NOR*1",
        flagSuffix = 32,
        condition = {
            id = "homeland",
            arg1 = "门客"
        },
        reward = {
            item = {
                ["eq2020dxcj01"] = 1,
            }
        }
    },
     {
        name = "掌灯伴读",
        tiaojian = "拥有一名书童",
        rewardDesc = "HIY笑林广记NOR*1",
        flagSuffix = 33,
        condition = {
            id = "homeland",
            arg1 = "书童"
        },
        reward = {
            item = {
                ["yeshushuji79"] = 1,
            }
        }
    },
     {
        name = "娟秀红颜",
        tiaojian = "拥有一名绣女",
        rewardDesc = "面具福袋*1",
        flagSuffix = 34,
        condition = {
            id = "homeland",
            arg1 = "绣女"
        },
        reward = {
            item = {
                ["mianjufudai"] = 1,
            }
        }
    },
    {
        name = "以武论道",
        tiaojian = "论剑排名达到前十",
        rewardDesc = "江湖威望*200",
        flagSuffix = 35,
        condition = {
            id = "lunjian",
            arg1 = 10
        },
        reward = {
            attr = {
                ["weiwang"] = 200,
            }
        }
    },
}

function DaXiaChenZhangZhiLuLayer:showLayer(actionId)

    local netAchievementType = {"homeland","lunjian"}
    HttpManagerEx:getGrowthInfo(netAchievementType,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local servants = {}
                if MapIsEmpty(data.homeland) == false then 
                    servants = data.homeland.servants
                end

                lunjianRanking = data.lunjian

                if MapIsEmpty(servants) == false then 
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                    for k,v in pairs(servants) do 
                        if v and v.num > 0 then 
                            local puRenJob = HomelandRoleUtil:getCHAJobTypeName(v.job)
                            homelandInfo[puRenJob] = true
                        end
                    end
                end

                self:actionTime(actionId)
                self.condiConfig = {}
                local role = User:getRole()
                for k, configFunc in pairs(conditions) do
                    self.condiConfig[k] = configFunc(role)
                end

                self:initList(role)
                self.Text_huodong:setString("大侠成长之路")
                self:show()
                
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING)
    
end

function DaXiaChenZhangZhiLuLayer:initList(role)
    self.ListView_list:removeAllItems()

    for index, achievement_data in ipairs(achievementList) do
        local panel = self.ListView_list:getItem(index - 1)
        if panel == nil then
            panel = self.Panel_row:clone()
            Helper:convertUIByParent(panel)
            self.ListView_list:pushBackCustomItem(panel)
        end

        panel.Text_title:setString(achievement_data.name)
        panel.Text_Con:setString("达成条件：" .. achievement_data.tiaojian)
        panel.Text_Reward:setString("奖励：" .. achievement_data.rewardDesc)

        if role:getInheritFlag("jhhyl" .. achievement_data.flagSuffix) == 1 then
            panel.Button_4:setTouchEnabled(false)
            panel.Button_4:setEnabled(false)
            panel.Button_4.Text_buttonName:setString("已领取")
        else
            local conditonData = achievement_data.condition

            local condiFunc = self.condiConfig[conditonData.id]

            if condiFunc(conditonData.arg1) == true then
                panel.Button_4:setTouchEnabled(true)
                panel.Button_4:setEnabled(true)
                panel.Button_4.Text_buttonName:setString("领取")
            else
                panel.Button_4:setTouchEnabled(false)
                panel.Button_4:setEnabled(false)
                panel.Button_4.Text_buttonName:setString("未达成")
            end
        end

        panel.Button_4:releaseFunc(
            function()
                local reward = achievement_data.reward

                if reward == nil then
                    assert(false, achievement_data.name .. "奖励配置错误！！！！")
                end

                if MapIsEmpty(reward.item) == false then
                    if role:checkCanBuyTwoOrMoreThings(reward.item) ~= true then
                        return
                    end
                end

                local function getLocalReward()
                    if MapIsEmpty(reward.item) == false then
                        for k, v in pairs(reward.item) do
                            role:addItemCount(k, v)
                            local item = Item:getOneItemByKey(k)
                            PopText("您获得 " .. item.name .. " x" .. v)
                        end
                    end

                    if MapIsEmpty(reward.attr) == false then
                        for attrName, value in pairs(reward.attr) do
                            role:addAttr(attrName, value)
                            PopText(role:getCHAttrName(attrName) .. " + " .. value)
                        end
                    end

                    role:setInheritFlag("jhhyl" .. achievement_data.flagSuffix, 1)
                    panel.Button_4:setTouchEnabled(false)
                    panel.Button_4:setEnabled(false)
                    panel.Button_4.Text_buttonName:setString("已领取")
                end

                if MapIsEmpty(reward.netAttr) == false then
                    PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                        layer:setPopText("")
                        layer:showLayer()
                    end)
                    HttpManagerEx:updateCurrencyByTable(
                        "add",
                        reward.netAttr,
                        "DXACH",
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    for attrName, value in pairs(data) do
                                        PopText(role:getCHAttrName(attrName) .. " +" .. value)
                                    end
                                    getLocalReward()
                                else
                                    print(errcode, errmsg)
                                end
                            end

                            PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                                layer:hideLayer()
                            end)
                        end,
                        IS_SHOW_WAITING
                    )
                else
                    getLocalReward()
                end
            end
        )
    end
end


--活动的时间和服务器一致
function DaXiaChenZhangZhiLuLayer:actionTime(actionId)
    if actionId == nil then
        return
    end

    HttpManagerEx:getNewYearFestivalState(
        actionId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if data ~= nil and data.is_open == 1 and data.status == 1 then
                    local year, month, day, time, hour, min
                    -- local startYear, startMonth, startDay
                    year = tonumber(Helper:date("%Y", tonumber(data.start)))
                    month = tonumber(Helper:date("%m", tonumber(data.start)))
                    day = tonumber(Helper:date("%d", tonumber(data.start)))
                    time = year .. "年" .. month .. "月" .. day .. "日活动上线-"
                    year = tonumber(Helper:date("%Y", tonumber(data["end"])))
                    month = tonumber(Helper:date("%m", tonumber(data["end"])))
                    day = tonumber(Helper:date("%d", tonumber(data["end"])))
                    hour = tonumber(Helper:date("%H", tonumber(data["end"])))
                    min = tonumber(Helper:date("%M", tonumber(data["end"])))
                    time =
                        time ..
                        year ..
                            "年" ..
                                month ..
                                    "月" ..
                                        day ..
                                            "日" ..
                                                hour .. "时" .. min .. "分" .. "达成以下要求,都可领取对应的江湖奖励,每个江湖奖励仅可领取一次,不可多次领取。"
                    self.Text_1:setString(time)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function DaXiaChenZhangZhiLuLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DaXiaChenZhangZhiLuLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function DaXiaChenZhangZhiLuLayer:__showRule()
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

Helper:classDefNodeGetInstance(DaXiaChenZhangZhiLuLayer)
return DaXiaChenZhangZhiLuLayer
00000000