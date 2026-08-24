-- local ShenBingEffct = {}

-- function ShenBingEffct:create()
--     local p = clone(ShenBingEffct)
--     p:ctor()
--     return p 
-- end

-- function ShenBingEffct:ctor()
--     self._ShenBingEffctMap = {} --神兵拥有的特性
--     self.attr = {}  --特性加成
-- end

-- function ShenBingEffct:init()

-- end


-- local godweapon = require("script.others.godweapon")
-- local weaponList = godweapon["weaponSpecials"]
-- local role = User:getRole()
-- --CN 成功淬炼次数 weight 武器重量 ,currDex 身法, currStr臂力
-- local params = {CN ,weight, currDex = User:getRoleAttr("currDex"),currStr = User:getRoleAttr("currStr")}
-- local addValue , value, formula,specialnumber
-- for i,v in ipairs(weaponList) do 
--     if role.ShenBing.effct1 ==  v.specialid then
--         value = v.value 
--         formula = v.formula
--         specialnumber = v.specialnumber  --特性代号
--         if value == 0 then
--             addValue = Helper:GetValueFromScript(formula,params) -- 加成数值
--         else 
--             addValue = value
--         end
--     end
-- end
-- local ShenBingEffctList = {
--     [1] = function (role,value)   --提升攻击力
        
        
--     end,   
--     [2] = function ()   --提升武器伤害力 
      
    
--     end,
--     [3] = function ()   --提升武器额外硬度
       
        
--     end,
--     [4] = function ()  --降低重量值 
        
        
--     end,
--     [5] = function ()       --增加重量值
       
       
--     end,
--     [6] = function ()       --提升武器的额外坚韧度
      
        
--     end,
--     -----------------------------------
--     [7] = function ()      --击中敌人造成额外伤害(触发)
      
        
--     end,
--     [8] = function ()      --击中敌人一定几率使其带上流血效果
      

--     end,
--     [9] = function ()   --击中敌人可造成额外伤害，并有一定几率造成流血效果。
       

--     end,
--     [10] = function ()  --击中敌人时，有一定几率使得敌人获得招架降低效果
      
        
--     end,
--     [11] = function ()  --击中敌人时，有一定几率使得敌人获得攻速降低效果。
        
        
--     end,
--     [12] = function ()    --攻击命中敌人时，有一定几率可以打落别人兵器  
     
        
--     end,
--     [13] = function ()  --提升敌人格挡时，打飞他武器的概率
       
        
--     end,
--     [14] = function ()  --格挡住敌人时一定几率反击
--        value 
--        fro... 
        
--     end,
--     [15] = function ()  --自己格挡住敌人武器时，有一定几率打落敌人的兵器
       
        
--     end,
--     [16] = function ()  --敌人格挡自身攻击时，还是会承受部分伤害
       
        
--     end
-- }

-- function ShenBingEffct:init()
--     -- 初始化资源配表
-- end

-- -- 获取效果的属性，资源配表
-- function ShenBingEffct:getEffectAttr(effctId)
--     local resMap
--     return resMap[effctId] 
--     for k,v in pairs(resMap) do
--         if v.specialid == effctId then
--             return v
--         end
--     end
-- end

-- -- 判断是否存在硬度加成
-- function ShenBingEffct:isYingDuAdd(effctId)
--     -- 获取特效的属性  
--     self:getEffectAttr(effctId)
--     if specialnumber == 3 then 
--         return true false
--     end
-- end

-- -- 获取加成数值
-- function ShenBingEffct:getAddNum(effctId, value)
--      -- 获取特效的属性  
--     self:getEffectAttr(effctId)

--     return ShenBingEffctList[specialnumber](nil, value)
-- end


-- return ShenBingEffct000000000