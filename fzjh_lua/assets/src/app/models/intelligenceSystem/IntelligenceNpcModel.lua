local CRFactory = require("app.models.HomelandModel.CRFactory")
local MapInfo = require("app.models.map.MapInfo")
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
local IntelligenceNpcModel = {
    _baseAttr = {
        id = "scout01",
        sex = "男",
        age = 20,
        looks = 23,
        type = "role",
        name = "徐书生",
        dsc = "他年及弱冠，却已博览群书，通晓江湖种种秘辛。有人说他师从百晓生，亦有人说他来自于一个神秘组织，但真相如何，他本人从来未曾提及。",
    }
}

function IntelligenceNpcModel:addNpc(map)
    local roomId = HomelandRoomUtil:getDaMenRoomId(map)
    local npc = self._baseAttr

    npc.canSee = true
    npc.conditionAndResults = {
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "可传承玩家标记等于",
                    arg2 = "徐书生对话标记",
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "副本故事",
                    arg2 = "你刚走到门口，便见一位风度翩翩的书生，摇着折扇向你走来。;YEL徐书生：大侠，久仰大名！在下徐书生，奉命前来为大侠提供情报。;YEL徐书生：在下每日都会来此，大侠若想买情报，尽管来找在下便是。",
                    arg3 = "2;2"
                },
                {
                    arg1 = "可传承玩家标记设置",
                    arg2 = "徐书生对话标记",
                    arg3 = 1,
                }
            }
        }
    }
    CRFactory:createBtnCR(npc, "交谈", "情报探子交谈")
    CRFactory:createBtnCR(npc, "江湖情报", "江湖情报")
    CRFactory:createBtnCR(npc, "江湖秘辛", "江湖秘辛")
    CRFactory:openOrCloseBtnFunc(npc, "情报探子交谈", "open")
    CRFactory:openOrCloseBtnFunc(npc, "江湖情报", "open")
    CRFactory:openOrCloseBtnFunc(npc, "江湖秘辛", "open")

    -- Npc:initNpc(npc)

    npc = Helper:tableCover(require("app.models.npc.BaseNpc"):create(), npc)
    MapInfo:addMapRole(map, npc)
    MapInfo:addRoleToRoom(map, roomId, npc.id)
end

function IntelligenceNpcModel:talk()
    local textList = {
        "在下网罗的江湖秘辛定然不假，但搜集来的江湖情报来源却是五花八门，有些情报属实，有些却是蜚语流言。情报是真是假，少侠可要擦亮眼睛自己甄别了。",
        "江湖中能令我敬佩的，只有三位大侠：第一位是一个姓金的书生，第二位号称“神仙醋”，最后一位正是我徐家的祖辈。",
        "哈哈哈！天下风云出我辈，一入江湖岁月催。皇图霸业笑谈中，不胜人生一场醉。"
    }
    local text = textList[math.random(1,#textList)]
    RichPrint("main", "YEL"..self._baseAttr.name.."："..text)
end


return IntelligenceNpcModel00000000