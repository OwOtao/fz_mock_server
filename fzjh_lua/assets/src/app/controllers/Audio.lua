local Audio = {}
--  是否debug模式 屏蔽打印
-- local isMusicOn = true
-- local isEffectOn = true
local music , loop
-- local audioKey = "audioKey"

local effectTabs =
{
    fengAndNiao = "1.mp3",              -- 风声和鸟
    niao = "2.mp3",                     -- 鸟
    ying = "3.mp3",                     -- 鹰
    daAnNiu = "4.mp3",                  -- 大按钮
    xiaoAnNiu = "5.mp3",                -- 小按钮
    fanHuiQuXiao = "6.mp3",             -- 返回取消
    daSuanPan = "7.mp3",                -- 打算盘
    gouMai = "8.mp3",                   -- 购买
    jiangHuJieMian2 = "9.mp3",          -- 江湖界面2
    jiaoHu = "10.mp3",                  -- 交互
    nianShaoNormalNan =                 -- 年少-通用-男  （随机取1个播放,数组部分均是相同规则）
    {
        "11.mp3",
        "12.mp3"
    },
    nianShaoNormalNv =                  -- 年少-通用-女
    {
        "13.mp3",
        "14.mp3"
    },
    nianQingZhengNan =                  -- 年轻-正-男
    {
        "15.mp3",
        "16.mp3",
        "17.mp3"
    },
    nianQingZhengNv =                   -- 年轻-正-女
    {
        "18.mp3",
        "19.mp3",
        "20.mp3"
    },
    nianQingXieNan =
    {
        "21.mp3",
        "22.mp3"
    },
    nianQingXieNv =
    {
        "23.mp3",
        "24.mp3",
        "25.mp3"
    },
    chengShuZhengNan =                  -- 成熟-正-男
    {
        "26.mp3",
        "27.mp3"
    },
    chengShuXieNan =
    {
        "28.mp3",
        "29.mp3",
        "30.mp3"
    },
    nianLaoZhengNan =                   -- 年老-正-男
    {
        "31.mp3",
        "32.mp3",
        "33.mp3"
    },
    nianLaoXieNan =
    {
        "34.mp3",
        "35.mp3"
    },
    nianZhangZhengNv =                  -- 年长-正-女
    {
        "36.mp3",
        "37.mp3"
    },
    nianZhangXieNv =
    {
        "38.mp3",
        "39.mp3",
        "40.mp3",
        "41.mp3"
    },
    carriage = "42.mp3",                -- 马车
    yinDao = "43.mp3",                  -- 引导
    yinDao2 = "44.mp3",
    yinDao3 = "45.mp3",
    yinDao4 = "46.mp3",
    yinDao5 = "47.mp3",
    yinDao6 = "48.mp3",
    yinDao7 = "49.mp3",
    yinDao8 = "50.mp3",

       -- 地图音效
    jiaobu =                 --脚步通用
    {
        "51.mp3",
        "52.mp3",
        "53.mp3",
        "54.mp3"
    },
    nanpao = "51.mp3",      --脚步男跑
    nvpao = "53.mp3",       --脚步女跑
    nvzou = "54.mp3",       --脚步女走
    zacao = "55.mp3",      --脚步杂草
    youyong = "56.mp3",     --脚步游泳
    luoshui = "57.mp3",     --脚步落水
    caishuye =              --踩树叶脚步
    {
        "58.mp3",
        "59.mp3",
        "60.mp3"
    },
    mudiban =               --木地板脚步
    {
        "61.mp3",
        "62.mp3",
        "63.mp3",
        "64.mp3",
        "65.mp3",
        "66.mp3",
        "67.mp3"
    },
    chenzhongjiaobu = "68.mp3",     --沉重木地板脚步
    nidi = "69.mp3",                --脚步泥地
    nidinianye =                    --脚步泥地粘液
    {
        "70.mp3",
        "71.mp3",
        "72.mp3"
    },
    zhaozedi =                      --脚步沼泽地
    {
        "73.mp3",
        "74.mp3",
        "75.mp3",
        "76.mp3",
        "77.mp3"
    },
    shidimian =                     --脚步湿地面
    {
        "78.mp3",
        "79.mp3",
        "80.mp3"
    },
    xuedi =                         --脚步雪地
    {
        "81.mp3",
        "82.mp3",
        "83.mp3",
        "84.mp3",
        "85.mp3"
    },
    nandaodi = "86.mp3",            --男倒地声
    nvdaodi = "87.mp3",             --女倒地声
    --场景环境音效
    chengzhenbaitian = "88.mp3",    --城镇白天
    chengzhenyewan = "89.mp3",      --城镇夜晚
    jiaowai = "90.mp3",             --郊外
    mache = "91.mp3",               --马车
    mengjing = "92.mp3",            --梦境
    shulin = "93.mp3",              --树林（有鸟叫）
    zhaoze = "94.mp3",               --沼泽
    chalou = "95.mp3",              --茶楼
    paizhong = "96.mp3",            --排钟
    huo = "97.mp3",                 --室内火
    shui = "98.mp3",                --室内水中
    simiao = "99.mp3",              --寺庙室内
    fengzhongniao = "100.mp3",      --风中鸟叫
    jinpo = "jinpo.mp3",            --紧迫时使用
    gou =                           --狗叫
    {
        "101.mp3",
        "102.mp3"
    },
    gouchuan = "103.mp3",           --狗喘
    ji = "104.mp3",                 --鸡叫
    lang = "105.mp3",               --狼叫
    ma = "106.mp3",                 --马叫
    niao =                          --鸟叫
    {
        "107.mp3",
        "108.mp3"
    },
    niaofei = "109.mp3",            --鸟飞

    ying = "110.mp3",               --鹰叫
    tianqifeng = "120.mp3",         --天气风
    tianqileiyu = "121.mp3",        --天气雷雨
    tianqixyu =                     --天气雨
    {
        "122.mp3",
        "123.mp3"
    },


    -- 战斗音效
    heart = "",                     --心跳
    dead = {},                      --死亡
    dadou = "dadou.mp3",
    dadou2 = "dadou2.mp3",
    -- 刀
    daofa =
    {
        other =                 -- 其他
        {
            "124.mp3",
            "125.mp3",
            "126.mp3"
        },
        start =                  --开始音效
        {
            "127.mp3"
        },
        dodge =                  --招架
        {
            "128.mp3",
            "129.mp3"
        },
        attack =                 --击中
        {
            "130.mp3",
            "131.mp3",
            "132.mp3",
            "133.mp3",
            "134.mp3",
        },
        miss =                    --未击中
        {
            "135.mp3",
            "136.mp3",
            "137.mp3",
            "138.mp3",
            "139.mp3",
        }
    },
    -- 剑
    jianfa =
    {
        other =                 -- 其他
        {
            "140.mp3"
        },
        start =                  --开始音效
        {
            "141.mp3"
        },
        dodge =                  --招架
        {
            "142.mp3",
            "143.mp3",
            "144.mp3",
            "145.mp3",
            "146.mp3",
            "147.mp3"
        },
        attack =                 --击中
        {
            "148.mp3",
            "149.mp3",
            "150.mp3",
            "151.mp3",
        },
        miss =                    --未击中
        {
            "152.mp3",
            "153.mp3",
            "154.mp3",
            "155.mp3",
            "156.mp3",
        }
    },


    -- 暗器
    anqi =
    {
        other =                 -- 其他
        {
        },
        start =                  --开始音效
        {
            "157.mp3"
        },
        dodge =                  --招架
        {
            "158.mp3",
            "159.mp3",
            "160.mp3"
        },
        attack =                 --击中
        {
            "161.mp3",
            "162.mp3",
            "163.mp3",
            "164.mp3",
        },
        miss =                    --未击中
        {
            "165.mp3",
            "166.mp3",
            "167.mp3",
            "168.mp3",
            "169.mp3",
            "170.mp3",
        }
    },
    -- 鞭
    bianfa =
    {
        other =                 -- 其他
        {
        },
        start =                  --开始音效
        {
            "171.mp3"
        },
        dodge =                  --招架
        {
            "172.mp3",
        },
        attack =                 --击中
        {
            "173.mp3",
            "174.mp3",
            "175.mp3",
            "176.mp3",
            "177.mp3",
        },
        miss =                    --未击中
        {
            "178.mp3",
            "179.mp3",
            "180.mp3",
        }
    },
    -- 棍
    gunfa =
    {
        other =                 -- 其他
        {
            "182.mp3"
        },
        start =                  --开始音效
        {
            "183.mp3"
        },
        dodge =                  --招架
        {
            "184.mp3",
            "185.mp3",
            "186.mp3",
        },
        attack =                 --击中
        {
            "187.mp3",
            "188.mp3",
            "189.mp3",
        },
        miss =                    --未击中
        {
            "190.mp3",
            "191.mp3",
            "192.mp3",
            "193.mp3",
            "194.mp3",
            "195.mp3",
            "196.mp3",
            "197.mp3",
            "198.mp3",
            "199.mp3",
        }
    },
    -- 拳脚
    quanjiao =
    {
        other =                 -- 其他
        {
            "200.mp3"
        },
        start =                  --开始音效
        {
            "201.mp3"
        },
        dodge =                  --招架
        {
            "202.mp3",
            "203.mp3",
            "204.mp3",
            "205.mp3",
            "206.mp3",
            "207.mp3",
            "208.mp3",
        },
        attack =                 --击中
        {
            "209.mp3",
            "210.mp3",
            "211.mp3",
            "212.mp3",
            "213.mp3",
            "214.mp3",
            "215.mp3",
            "216.mp3",
            "217.mp3",
            "218.mp3",
            "219.mp3",
            "220.mp3",
        },
        miss =                    --未击中
        {
            "221.mp3",
            "222.mp3",
        }
    },
    shuangchi =
    {
        other =                 -- 其他
        {
            "124.mp3",
            "125.mp3",
            "126.mp3"
        },
        start =                  --开始音效
        {
            "127.mp3"
        },
        dodge =                  --招架
        {
            "128.mp3",
            "129.mp3"
        },
        attack =                 --击中
        {
            "130.mp3",
            "131.mp3",
            "132.mp3",
            "133.mp3",
            "134.mp3",
        },
        miss =                    --未击中
        {
            "135.mp3",
            "136.mp3",
            "137.mp3",
            "138.mp3",
            "139.mp3",
        }
    },

    --s神兵界面播放声音
    jinrujiemian = "223.mp3",
    shengji = "224.mp3",
    qianghua = "225.mp3",
    jianfaStart = "141.mp3",
    daofaStart = "127.mp3",
    bianfaStart = "171.mp3",
    gunfaStart = "183.mp3",
    shuangchiStart = "183.mp3",
    qinfaStart = "184.map3",

-----论剑播放声音
    biwu_leitai = "biwu_leitai.mp3",
    biwu_shangtai = "biwu_shangtai.mp3",
    biwu_tiaozhan_2 = "biwu_tiaozhan_2.mp3",



    --躲避暗器界面音效
    anqishoot = "168_anqi.mp3",
    anqihit = "163.mp3",

    --被击打男女生
    hurt_man = {
        "hurt_man1.mp3",
        "hurt_man2.mp3",
        "hurt_man3.mp3",
        "hurt_man4.mp3",
    },
    hurt_woman = {
        "hurt_women6.mp3",
        "hurt_women7.mp3",
        "hurt_women5.mp3",
        "hurt_woman3.mp3"
    },
    ha_man = {
        "ha_man1.mp3",
        "ha_man2.mp3",
    },
    ha_woman = {
        "ha_woman1.mp3",
        "ha_woman2.mp3",
    },
    heng_man = {
        "30.mp3",
        "heng_man1.mp3"
    },
    heng_woman = {
        "13.mp3",
        "14.mp3",
    },
  
    jinzhang_incave = "m35.mp3",
    jinzhang_outcave = "m35_0.mp3",
    jinzhang_outcave2 = "m35_1.mp3",
    inherit = "inherit.mp3",
    windyFly = "windyFly.mp3", -- 风筝起飞
    windyContinued = "windyContinued.mp3", -- 风筝背景音乐

    -- 守墓
    CemeteryFrie = "fire.mp3",
    CemeterySmallRain = "smallRain.mp3",
    CemeteryMiddleRain = "middleRain.mp3",
    CemeteryBigRain = "bigRain.mp3",
    CemeteryWind = "wind.mp3",

    -- 乡试
    VillageExam = "bianpaosheng.mp3",
    -- 太监喊话
    taijian = "taijian.mp3",
    -- 皇帝出场
    king = "king.mp3",

    -- 赛龙舟开场
    DragonBoatIn = "DragonBoatIn.mp3",

    -- 赛龙舟进行
    DragonBoatIng = "DragonBoatIng.mp3",

    -- 冲穴成功
    meridianBreakSucc = "meridian/breakSucc.mp3",
    meridianBreakFaild = "meridian/breakFaild.mp3",
    meridianBreaking = "meridian/breaking.mp3",
    meridianBreakEvent = "meridian/breakEvent.mp3",

    LianHuaLuo = "lianhualuo.mp3",--莲花落
    LunJian = "kunlunqinqu.mp3",--昆仑论剑

    ZengWen = "duanzao-Heating.mp3",--温度提升
    DuanDa = "duanzao-Blacksmith.mp3",--锻打
    RongLian = "duanzao-Furnace.mp3",--熔炼
    tangmengzhiluan = "tangmenzhiluan.mp3" ,--唐门之乱
    tuanyuanfan = "tuanyuanmusic.mp3",
    chunjiebianpao = "chunjiebianpao.mp3",
    xitai = "xitai.mp3",
    chunjiemiaohui = "chunjiemiaohui.mp3", -- 春节庙会
    xinchunbianpao = "xinchunbianpao.mp3", -- 新春鞭炮
    qixiBgm = "qixiBgm.mp3",--七夕Bgm
    plmusic = "plmusic.mp3",  --爬楼
    banjia = "banjia.mp3",
    huijiaBGM="huijiaBGM.mp3",--回家
    bgm001="bgm001.mp3",  --修筑
    bgm002="bgm002.mp3",  --豪宅
    bgm003="bgm003.mp3",   --高级豪宅
    
    DaijiBGM = "daiji.mp3", --进游戏时待机音效
    Bajian = "bajian.mp3", --拔剑
    shenzhaocg="shenzhaocg.mp3",--神照日常传功
    shenzhaocgjs="shenzhaocgjs.mp3",--神照传功结束

    --琴音助功
    qyzg1 = "qyzg1.mp3",
    qyzg2 = "qyzg2.mp3",
    qyzg3 = "qyzg3.mp3",
    qyzg4 = "qyzg4.mp3",
    qyzg5 = "qyzg5.mp3",
    qyzghe = "qyzghe.mp3",

    --自创武学
    createZhao = "zcwxbgm.mp3",
    creatingZhao = "zcwxyinxiao.mp3"
}

local musicTabs =
{
    fengAndNiao = "1.mp3",              -- 风声和鸟
    jiangHuJieMian2 = "9.mp3",          -- 江湖界面2
}
local effectDoList = {}
function Audio:init()
    self.handle = Game:schedule(
        function()
            -- print("function Audio:init()")
            if #effectDoList > 0 then
                effectDoList[1].func()
                table.remove(effectDoList, 1)
            end
        end, 0)
end
Audio:init()

function Audio:stopEffect(id)
    cc.SimpleAudioEngine:getInstance():stopEffect(id)
end

function Audio:stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
end

function Audio:stopMusic()
    cc.SimpleAudioEngine:getInstance():stopMusic(true)
end

function Audio:resumeEffect()
    cc.SimpleAudioEngine:getInstance():resumeEffect()
end

function Audio:resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function Audio:pauseEffect()
    cc.SimpleAudioEngine:getInstance():pauseEffect()
end

function Audio:pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

function Audio:preloadEffect(fileName)
    cc.SimpleAudioEngine:getInstance():preloadEffect(fileName)
end

function Audio:preloadMusic(fileName)
    cc.SimpleAudioEngine:getInstance():preloadMusic(fileName)
end

function Audio:preloadAllSound() -- 预加载音频资源
    for i=1,100 do
        fileName = "Music/"..i..".mp3"
        Audio:preloadMusic(fileName)
        Audio:preloadEffect(fileName)
    end
end

-- Audio:preloadAllSound()

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 15:57:06
-- @desc 通过文件路径播放效果
function Audio:playEffectWithFileName(fileName, isLoop)
    if type(fileName) ~= "string" then
        return
    end

    local voice = DataBase:getDataWithString("voice")
    if voice =="N" then
        return
    end

    local func = function()
        return cc.SimpleAudioEngine:getInstance():playEffect(fileName, Helper:getDef(isLoop, false))
    end
    table.insert(effectDoList, {func = func})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 15:56:54
-- @desc 通过key播放效果
function Audio:playEffect(key, isLoop)
    if type(key) ~= "string" then
        return
    end

    local voice = DataBase:getDataWithString("voice")
    if voice =="N" then
        return
    end
        local fileName = effectTabs[key]
        if type(fileName) == "table" then
            local index = math.random(1, #fileName)
            fileName = "Music/"..fileName[index]
        elseif type(fileName) == "string" then
            fileName = "Music/"..fileName
        else
            if PRINT_MODE == 1 then
                print("出错!!!!!: type(fileName) = ", type(fileName))
            end
            return
        end
        return cc.SimpleAudioEngine:getInstance():playEffect(fileName, Helper:getDef(isLoop, false))
    -- local func = function()
    --     local fileName = effectTabs[key]
    --     if type(fileName) == "table" then
    --         local index = math.random(1, #fileName)
    --         fileName = "Music/"..fileName[index]
    --     elseif type(fileName) == "string" then
    --         fileName = "Music/"..fileName
    --     else
    --         if PRINT_MODE == 1 then
    --             print("出错!!!!!: type(fileName) = ", type(fileName))
    --         end
    --         return
    --     end
    --     return cc.SimpleAudioEngine:getInstance():playEffect(fileName, Helper:getDef(isLoop, false))
    -- end
    -- table.insert(effectDoList, {func = func})
end

function Audio:playMusic(key, isLoop)
    if type(key) ~= "string" then
        return
    end
    
    if DEBUG_MODE == 1 then
   --    return
    end

    local voice =DataBase:getDataWithString("voice")
    if voice =="N" then
        return
    end

    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end

    local fileName = effectTabs[key]
    if fileName == nil then
        print("key = ",key)
        return 
    end
    if type(fileName) == "table" then
        local index = math.random(1, #fileName)
        fileName = "Music/"..fileName[index]
    elseif type(fileName) == "string" then
        fileName = "Music/"..fileName
    end
    return cc.SimpleAudioEngine:getInstance():playMusic(fileName, loopValue)
end

-- 战斗模块声音
function Audio:wordFightPlayEffect(name, type)
    if DEBUG_MODE == 1 then
       return
    end

    if true then
        return
    end

    if not name or not type or not effectTabs[name] then
        return
    end
    local effectList = effectTabs[name][type]
    local fileName = effectList[math.random(1, #effectList)]
    if fileName then
        fileName = "Music/"..fileName
    end
    return cc.SimpleAudioEngine:getInstance():playEffect(fileName)
end

-- function Audio:effectSwitch(bool)
--     isEffectOn = bool
--     Audio:setCfg()
-- end

-- function Audio:musicSwitch(bool)
--     isMusicOn = bool
--     if bool then
--         Audio:playMusic(music, loop)
--     else
--         Audio:stopMusic()
--     end
--     Audio:setCfg()
-- end

function Audio:setMusicVolume(v)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(v)
end

function Audio:setEffectsVolume(v)
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(v)
end

function Audio:playEffectWithCallback(key, isLoop, duration, callback)
    local id = self:playEffect(key, isLoop)
    display.getRunningScene():delayFunc(duration,
        function()
            callback(id)
        end)
    return id
end

return Audio
0000000000000000