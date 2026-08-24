local RoleUseItemFactory = {}

local RoleUseItem_BuChang = require("app.models.role.item.UseItem.RoleUseItem_BuChang")
local RoleUseItem_QiXiChengHao = require("app.models.role.item.UseItem.RoleUseItem_QiXiChengHao")
local RoleUseItem_XiMiChengHao = require("app.models.role.item.UseItem.RoleUseItem_XiMiChengHao")
local RoleUseItem_AnniversaryTitle = require("app.models.role.item.UseItem.RoleUseItem_AnniversaryTitle")
local RoleUseItem_ShiWuDuiHuan = require("app.models.role.item.UseItem.RoleUseItem_ShiWuDuiHuan")
local RoleUseItem_YuLuJingShui = require("app.models.role.item.UseItem.RoleUseItem_YuLuJingShui")
local RoleUseItem_XiSuiDan = require("app.models.role.item.UseItem.RoleUseItem_XiSuiDan")
local RoleUseItem_ZhouHuoDong = require("app.models.role.item.UseItem.RoleUseItem_ZhouHuoDong")
local RoleUseItem_JiaoZiFuDai = require("app.models.role.item.UseItem.RoleUseItem_JiaoZiFuDai")
local RoleUseItem_BaFangLiHe = require("app.models.role.item.UseItem.RoleUseItem_BaFangLiHe")
local RoleUseItem_JuHuaJiu = require("app.models.role.item.UseItem.RoleUseItem_JuHuaJiu")
local RoleUseItem_SkillBook = require("app.models.role.item.UseItem.RoleUseItem_SkillBook")
local RoleUseItem_Composite = require("app.models.role.item.UseItem.RoleUseItem_Composite")
local RoleUseItem_HeiMuYaLing = require("app.models.role.item.UseItem.RoleUseItem_HeiMuYaLing")
local RoleUseItem_JunQingMiHan = require("app.models.role.item.UseItem.RoleUseItem_JunQingMiHan")
local RoleUseItem_Snakelet = require("app.models.role.item.UseItem.RoleUseItem_Snakelet")
local RoleUseItem_LongZi = require("app.models.role.item.UseItem.RoleUseItem_LongZi")
local RoleUseItem_JueJinChan = require("app.models.role.item.UseItem.RoleUseItem_JueJinChan")
local RoleUseItem_LingShi = require("app.models.role.item.UseItem.RoleUseItem_LingShi")
local RoleUseItem_LuoPan = require("app.models.role.item.UseItem.RoleUseItem_LuoPan")
local RoleUseItem_YaoCai = require("app.models.role.item.UseItem.RoleUseItem_YaoCai")
local RoleUseItem_Note = require("app.models.role.item.UseItem.RoleUseItem_Note")
local RoleUseItem_ShiHe = require("app.models.role.item.UseItem.RoleUseItem_ShiHe")
local RoleUseItem_QiYu = require("app.models.role.item.UseItem.RoleUseItem_QiYu")
local RoleUseItem_ActiveZhaoBook = require("app.models.role.item.UseItem.RoleUseItem_ActiveZhaoBook")
local RoleUseItem_Furniture = require("app.models.role.item.UseItem.RoleUseItem_Furniture")
local RoleUseItem_Special = require("app.models.role.item.UseItem.RoleUseItem_Special")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")
local RoleUseItem_ZuoYouHuBo3 = require("app.models.role.item.UseItem.RoleUseItem_ZuoYouHuBo3")
local RoleUseItem_ShuXin = require("app.models.role.item.UseItem.RoleUseItem_ShuXin")
local RoleUseItem_ShowDialogUse = require("app.models.role.item.UseItem.RoleUseItem_ShowDialogUse")
local RoleUseItem_ShowDescUse = require("app.models.role.item.UseItem.RoleUseItem_ShowDescUse")
local RoleUseItem_ShowDialogBatchUse = require("app.models.role.item.UseItem.RoleUseItem_ShowDialogBatchUse")
local RoleUseItem_FamilyTokenItem = require("app.models.role.item.UseItem.RoleUseItem_FamilyTokenItem")
local RoleUseItem_NewYearFamilyTokenFuDai = require("app.models.role.item.UseItem.RoleUseItem_NewYearFamilyTokenFuDai")
local RoleUseItem_JiangHuDuoBaoLiHe = require("app.models.role.item.UseItem.RoleUseItem_JiangHuDuoBaoLiHe")
local RoleUseItem_NianBeastChengHao = require("app.models.role.item.UseItem.RoleUseItem_NianBeastChengHao")
local RoleUseItem_XuJuanLiHe = require("app.models.role.item.UseItem.RoleUseItem_XuJuanLiHe")
local RoleUseItem_AnniversaryTitleOf6th = require("app.models.role.item.UseItem.RoleUseItem_AnniversaryTitleOf6th")
local RoleUseItem_XinShenLiHe = require("app.models.role.item.UseItem.RoleUseItem_XinShenLiHe")
local RoleUseItem_QiaoDuoTianGongChengHao = require("app.models.role.item.UseItem.RoleUseItem_QiaoDuoTianGongChengHao")
local RoleUseItem_LanternFestivalChengHao = require("app.models.role.item.UseItem.RoleUseItem_LanternFestivalChengHao")
local RoleUseItem_AnniversaryTitleOf7th = require("app.models.role.item.UseItem.RoleUseItem_AnniversaryTitleOf7th")
local RoleUseItem_QiXi2023 = require("app.models.role.item.UseItem.RoleUseItem_QiXi2023")
local RoleUseItem_ZhongYuan2023 = require("app.models.role.item.UseItem.RoleUseItem_ZhongYuan2023")
local RoleUseItem_MeiRongWan = require("app.models.role.item.UseItem.RoleUseItem_MeiRongWan")

local familyTokenItems = requireWithEncrypt("script.others.familyTokenItems")["Sheet1"]


function RoleUseItemFactory:create(itemId, itemType, itemTag, specialType)
    print("RoleUseItemFactory:create:", itemId, itemType, itemTag, specialType)

    local roleUseItem = nil
    if specialType == ITEM_USE_TYPE.USE_ITEM_YONGBING then
        roleUseItem = RoleUseItem_Confirm.new()
    elseif familyTokenItems[itemId] then
        roleUseItem = RoleUseItem_FamilyTokenItem.new()
    elseif itemId == "23zyjlCH" then
        roleUseItem = RoleUseItem_ZhongYuan2023.new()
    elseif itemId == "23qxjlCH" then
        roleUseItem = RoleUseItem_QiXi2023.new()
    elseif itemId == "23znqjlCH" then
        roleUseItem = RoleUseItem_AnniversaryTitleOf7th.new()
    elseif itemId == "23yuanxiaojieTX" then
        roleUseItem = RoleUseItem_LanternFestivalChengHao.new()
    elseif itemId == "22qixijieTX" then
        roleUseItem = RoleUseItem_QiaoDuoTianGongChengHao.new()
    elseif itemId == "22anniversarytx" then
        roleUseItem = RoleUseItem_AnniversaryTitleOf6th.new()
    elseif itemId == "22xinshengiftbox" then
        roleUseItem = RoleUseItem_XinShenLiHe.new()
    elseif itemId == "22congratulationsxn" then
        roleUseItem = RoleUseItem_NianBeastChengHao.new()
    elseif itemId == "22jianghureelbox" or itemId == "22menpaireelbox" or itemId == "22quanreelbox" then
        roleUseItem = RoleUseItem_XuJuanLiHe.new()
    elseif itemId == "21duobaolihe01" or itemId == "21duobaolihe02" or itemId == "21itemsxnmg01" or itemId == "21duobaolihe03" or itemId == "22duobaolihe01" or itemId == "22duobaolihe02" then
        roleUseItem = RoleUseItem_JiangHuDuoBaoLiHe.new()
    elseif itemId == "21xcxwfd1" or itemId == "21xcxwfd2" or itemId == "21xcxwfd3" then
        roleUseItem = RoleUseItem_NewYearFamilyTokenFuDai.new()
    elseif itemId == "qixibuchangdaoju1" then
        roleUseItem = RoleUseItem_BuChang.new()
    elseif itemId == "qxchenghaobuchang" or itemId == "qxchenghaobuchang2" or itemId == "qxchenghaobuchang3" or itemId == "qxchenghaobuchang4" then
        roleUseItem = RoleUseItem_QiXiChengHao.new()
    elseif itemId == "zishenximi1" then
        roleUseItem = RoleUseItem_XiMiChengHao.new()
    elseif itemId == "21znqchenghao" then
        roleUseItem = RoleUseItem_AnniversaryTitle.new()
    elseif itemId == "shiwuchoujiang1" or itemId == "shiwuchoujiang2" or itemId == "shiwuchoujiang3" then
        roleUseItem = RoleUseItem_ShiWuDuiHuan.new()
    elseif itemId == "yulujingshui1" then
        roleUseItem = RoleUseItem_YuLuJingShui.new()
    elseif
        itemId == "xisuidan01" or itemId == "xisuidan02" or itemId == "xisuidan03" or itemId == "xisuidan04" or itemId == "xisuidan05" or itemId == "xisuidan06" or itemId == "xisuidan07" or
            itemId == "xisuidan08"
     then
        roleUseItem = RoleUseItem_XiSuiDan.new()
    elseif itemId == "zhouhuodongtx1" or itemId == "zhouhuodongtx2" or itemId == "zhouhuodongtx3" or itemId == "zhouhuodongtx4" or itemId == "zhouhuodongtx5" then
        roleUseItem = RoleUseItem_ZhouHuoDong.new()
    elseif itemId == "jiaozifudai01" then
        roleUseItem = RoleUseItem_JiaoZiFuDai.new()
    elseif itemId == "bafanglihe01" then
        roleUseItem = RoleUseItem_BaFangLiHe.new()
    elseif itemId == "shimenwupin33" then
        roleUseItem = RoleUseItem_HeiMuYaLing.new()
    elseif itemId == "shimenwupin32" then
        roleUseItem = RoleUseItem_JunQingMiHan.new()
    elseif itemId == "shimenwupin29" then
        roleUseItem = RoleUseItem_Snakelet.new()
    elseif itemId == "shimenwupin30" then
        roleUseItem = RoleUseItem_LongZi.new()
    elseif itemType == "节日酒" then
        if itemTag == "2017菊花酒" then
            
        else
            roleUseItem = RoleUseItem_JuHuaJiu.new()
        end
    elseif itemType == "书页" or itemType == "武学秘宝" then
        roleUseItem = RoleUseItem_SkillBook.new()
    elseif itemType == "秘籍残页" then
        roleUseItem = RoleUseItem_ActiveZhaoBook.new()
    elseif itemType == "合成材料" then
        roleUseItem = RoleUseItem_Composite.new()
    elseif itemId == "juejinchan" then
        roleUseItem = RoleUseItem_JueJinChan.new()
    elseif itemId == "lingshi1" then
        roleUseItem = RoleUseItem_LingShi.new()
    elseif itemId == "xunbaoluopan1" then
        roleUseItem = RoleUseItem_LuoPan.new()
    elseif itemId == "zuoyouhubo3" then
        roleUseItem = RoleUseItem_ZuoYouHuBo3.new()
    elseif itemType == "特殊" then
        roleUseItem = RoleUseItem_Special.new()
    elseif itemType == "家具" then
        roleUseItem = RoleUseItem_Furniture.new()
    elseif itemType == "药材" then
        roleUseItem = RoleUseItem_YaoCai.new()
    elseif itemType == "笔记" then
        roleUseItem = RoleUseItem_Note.new()
    elseif itemType == "食盒" then
        roleUseItem = RoleUseItem_ShiHe.new()
    elseif itemType == "书信" then
        roleUseItem = RoleUseItem_ShuXin.new()
    elseif itemType == "奇遇" then
        roleUseItem = RoleUseItem_QiYu.new()
    elseif itemId == "meirongwan" then
        roleUseItem = RoleUseItem_MeiRongWan.new()
    elseif specialType == ITEM_USE_TYPE.USE_ITEM_CONFIRM then
        roleUseItem = RoleUseItem_Confirm.new()
    elseif specialType == ITEM_USE_TYPE.USE_ITEM_ONLY_SHOW_DESC then
        roleUseItem = RoleUseItem_ShowDescUse.new()
    elseif specialType == ITEM_USE_TYPE.USE_ITEM_SHOW_DIALOG then
        roleUseItem = RoleUseItem_ShowDialogUse.new()
    elseif specialType == ITEM_USE_TYPE.USE_ITEM_BATCH then
        roleUseItem = RoleUseItem_ShowDialogBatchUse.new()
    end

    assert(roleUseItem ~= nil, roleUseItem)

    return roleUseItem
end

return RoleUseItemFactory
00