--[[
    author:Seven
    time:2024-01-10 21:04:41
    desc:
]]
local ServerItemConst = {}

--@desc: 服务器物品id ，使用时需使用checkItemIsCanUse接口进行消耗
ServerItemConst.SERVER_ITEM_ID = {
    DUOBAOLIHE01_21 = "21duobaolihe01",
    DUOBAOLIHE02_21 = "21duobaolihe02",
    DUOBAOLIHE03_21 = "21duobaolihe03",
    ITEMSXNMG01_21 = "21itemsxnmg01",
    XCXWFD1_21 = "21xcxwfd1",
    XCXWFD2_21 = "21xcxwfd2",
    XCXWFD3_21 = "21xcxwfd3",
    DUOBAOLIHE01_22 = "22duobaolihe01",
    DUOBAOLIHE02_22 = "22duobaolihe02",
    FUKUTOKEN_22 = "22fukutoken",
    JIANGHUREELBOX_22 = "22jianghureelbox",
    MENPAIREELBOX_22 = "22menpaireelbox",
    NEWYEARBOARD_22 = "22newyearboard",
    QUANREELBOX_22 = "22quanreelbox",
    XINSHENGIFTBOX_22 = "22xinshengiftbox",
    BAFANGLIHE01 = "bafanglihe01",
    BAITUOSHANXINWU = "baituoshanxinwu",
    DINGZHIWAN = "dingzhiwan",
    DRXIANGLU03 = "drxianglu03",
    EMEIXINWU = "emeixinwu",
    FOURWILLOWXINGWU = "fourwillowxingwu",
    GAIBANGXINWU = "gaibangxinwu",
    GUMUXINWU = "gumuxinwu",
    HAIJINGXINWU = "haijingxinwu",
    HOMEBW1 = "homebw1",
    HOMEBW2 = "homebw2",
    HOMEBW3 = "homebw3",
    HOMEBW4 = "homebw4",
    HUASHANXINWU = "huashanxinwu",
    JIAOZIFUDAI01 = "jiaozifudai01",
    JINQIANBANGXINWU = "jinqianbangxinwu",
    KONGTONGXINWU = "kongtongxinwu",
    KUNLUNXINWU = "kunlunxinwu",
    LUOYUEXINWU = "luoyuexinwu",
    MEIRONGWAN = "meirongwan",
    MENKECARD1 = "menkecard1",
    MINGJIAOXINWU = "mingjiaoxinwu",
    QUANZHENXINWU = "quanzhenxinwu",
    RENYANNIANXINGWU = "renyannianxingwu",
    SANJUECARD1 = "sanjuecard1",
    SHAOLINXINWU = "shaolinxinwu",
    TANGMENXINWU = "tangmenxinwu",
    TAOHUADAOXINWU = "taohuadaoxinwu",
    TIANJILING001 = "tianjiling001",
    TIANJILING002 = "tianjiling002",
    TIANSHANXINWU = "tianshanxinwu",
    TIEZHANGXINWU = "tiezhangxinwu",
    WUDANGXINWU = "wudangxinwu",
    WUDUXINWU = "wuduxinwu",
    XINGXIUXINWU = "xingxiuxinwu",
    XISUIDAN01 = "xisuidan01",
    XISUIDAN02 = "xisuidan02",
    XISUIDAN03 = "xisuidan03",
    XISUIDAN04 = "xisuidan04",
    XISUIDAN05 = "xisuidan05",
    XISUIDAN06 = "xisuidan06",
    XISUIDAN07 = "xisuidan07",
    XISUIDAN08 = "xisuidan08",
    ZNQ3WJ5 = "znq3wj5",    
}

--使用detectionGoods接口进行查询，不进行消耗
ServerItemConst.SERVER_ONLY_CHECK_ITEM_ID = {
    ZHOUHUODONGTX1 = "zhouhuodongtx1",
    ZHOUHUODONGTX2 = "zhouhuodongtx2",
    ZHOUHUODONGTX3 = "zhouhuodongtx3",
    ZHOUHUODONGTX4 = "zhouhuodongtx4",
    ZHOUHUODONGTX5 = "zhouhuodongtx5",
    QIXIJIETX_22 = "22qixijieTX",
    CONGRATULATIONSXN_22 = "22congratulationsxn",
    ANNIVERSARYTX_22 = "22anniversarytx",
    SZJDJ2 = "szjdj2",
    JIAREN005 = "jiaren005",
}

--添加使用时需使用checkItemIsCanUse接口进行消耗的道具
local function addServerItem()
    local familyTokenItems = requireWithEncrypt("script.others.familyTokenItems")["Sheet1"]

    for itemId, v in pairs(familyTokenItems) do
        local index = string.upper(itemId)
        
        if not ServerItemConst.SERVER_ITEM_ID[index] then
           ServerItemConst.SERVER_ITEM_ID[index] = itemId
        end 
    end
end

addServerItem()

return ServerItemConst
00000000000000