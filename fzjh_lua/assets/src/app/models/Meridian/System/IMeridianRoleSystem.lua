--[[
    author:Seven
    time:2025-01-15 17:00:35
    desc: 经脉系统接口
]]
local interface = require("third.class.interface")

local IMeridianRoleSystem = {}

function IMeridianRoleSystem:getRole()
end

--@desc: 当前经脉印记天赋页对象类列表
--@author:Seven
--@time:2025-01-17 15:24:05
--@return list [src.app.models.Meridian.BasicMeridianImprintingPage#BasicMeridianImprintingPage]
function IMeridianRoleSystem:getMeridianImprintingPages()
end

--@desc: 添加经脉印记（给所有页面都会添加）
--@author:Seven
--@time:2025-01-15 17:04:14
--@meriImpId: 经脉印记ID
--@return: nil
function IMeridianRoleSystem:addMeridianImprinting(meriImpId)
end

--@desc: 替换经脉印记
--@author:Seven
--@time:2025-01-15 17:09:30
--@meriImpPageIndex: 经脉页数
--@oMeriImpId: 被替换的经脉印记ID
--@nMeriImpId: 新的经脉印记ID
--@return: 被替换的经脉印记
function IMeridianRoleSystem:replaceMeridianImprinting(meriImpPageIndex, oMeriImpId, nMeriImpId)
end

--@desc: 切换使用的经脉印记天赋页
--@author:Seven
--@time:2025-01-15 17:13:31
--@meriImpPageIndex: 切换的页数
--@return: true | false , failMsg
function IMeridianRoleSystem:switchMeridianImprintingPage(meriImpPageIndex)
end

--@desc: 获取指定页面的经脉印记天赋页的经脉印记列表，如果未解锁返回nil,否则返回经脉印记天赋对象列表（没有就返回空的列表）
--@author:Seven
--@time:2025-01-15 18:20:10
--@meriImpPageIndex:
--@return:nil| list  [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function IMeridianRoleSystem:getPageMeridianImprintings(meriImpPageIndex)
end

--@desc: 获取当前使用的经脉印记天赋页的经脉印记
--@author:Seven
--@time:2025-01-15 17:19:48
--@return: list [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function IMeridianRoleSystem:getCurrentPageMeridianImprintings()
end

-- --@desc: 删除meriImpPageIndex页的经脉印记，如果没有返回nil, 删除成功返回删除的经脉印记天赋对象
-- --@author:Seven
-- --@time:2025-01-15 17:24:35
-- --@meriImpPageIndex: 经脉印记天赋页索引页数
-- --@meriImpId: 经脉印记ID
-- --@return: [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
-- function IMeridianRoleSystem:delMeridianImprintingFromPage(meriImpPageIndex, meriImpId)
-- end

--@desc: 获取当前使用的经脉印记天赋页页数
--@author:Seven
--@time:2025-01-15 17:21:48
--@return: number
function IMeridianRoleSystem:getCurrUsingMeridianImprintingPageNumber()
end

--@desc: 解锁新的经脉印记天赋页数,返回新增的页的页数
--@author:Seven
--@time:2025-01-15 17:14:45
--@return: number 解锁的天赋页数 , 返回 -1 表示解锁失败
function IMeridianRoleSystem:unlockMeridianImprintingPage()
end

--@desc: 获取当前系统已支持的经脉印记天赋页数总数
--@author:Seven
--@time:2025-01-15 17:18:04
--@return: number
function IMeridianRoleSystem:getMeridianImprintingPageCount()
end

--@desc: 清除所有经脉印记
--@author:Seven
--@time:2025-01-15 17:12:21
--@return: nil
function IMeridianRoleSystem:clearAllMeridianImprinting()
end

--@desc: 获取角色所有经脉印记天赋
--@author:Seven
--@time:2025-01-15 17:17:34
--@return: list [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function IMeridianRoleSystem:getAllMeridianImprintings()
end

--@desc: 当前天赋页是否拥有指定的经脉印记
--@author:Seven
--@time:2025-01-16 14:25:12
--@merImpId: 经脉印记ID
--@return: true | false
function IMeridianRoleSystem:currPageHasMeridianImprinting(merImpId)
end

--@desc: 指定天赋页是否拥有指定的经脉印记
--@author:LvBin
--@time:2025-01-20 15:47:01
--@pageIndex: 页数
--@merImpId: 经脉印记ID
--@return
function IMeridianRoleSystem:hasMeridianImprintingByPage(pageIndex, merImpId)
end

--@desc: 角色是否拥有指定的经脉印记天赋
--@author:Seven
--@time:2025-01-21 19:48:49
--@merImprId: 经脉印记ID
--@return: true | false
function IMeridianRoleSystem:roleHasImpriting(merImprId)
end

--@desc：获取经脉印记天赋页是否解锁
--@author:Seven
--@time:2025-01-16 17:08:25
--@pageIndex: 页数
--@return: true | false
function IMeridianRoleSystem:isUnLockMeridianImprintingPage(pageIndex)
end

--@desc: 重筑经脉印记
--@author:Seven
--@time:2025-01-20 11:17:58
--@keepSaveImpritingData: 保留的印记数据
function IMeridianRoleSystem:resetMeridianImpritings(keepSaveImpritingData)
end

return interface("IMeridianRoleSystem", IMeridianRoleSystem)
000000