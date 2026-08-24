local LoadingBar = ccui.LoadingBar

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:20:01
-- @desc 懒惰初始化
function LoadingBar:lazeInit()
    if self.LoadingBar_animEnabled == nil then
        self.LoadingBar_animEnabled = false
    end
    if self.LoadingBar_percent == nil then
        self.LoadingBar_percent = 100
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:36:15
-- @desc 替换掉设置percent方法
if LoadingBar.setPercent_old == nil then
    LoadingBar.setPercent_old = LoadingBar.setPercent
    LoadingBar.setPercent = function(self, percent)
        if type(percent) == "number" then
            self:lazeInit()
            if self.LoadingBar_animEnabled == true then
                self.LoadingBar_percent = percent
            else
                self.LoadingBar_percent = percent
                LoadingBar.setPercent_old(self, percent)
            end
        else
            print("error: type(percent) = ", type(percent))
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 11:42:21
-- @desc 得到百分比
if LoadingBar.getPercent_old == nil then
    LoadingBar.getPercent_old = LoadingBar.getPercent
    LoadingBar.getPercent = function(self)
        self:lazeInit()
        if self.LoadingBar_animEnabled == true then
            return self.LoadingBar_percent
        else
            return LoadingBar.getPercent_old(self)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:19:16
-- @desc 设置LoadingBar动画是否可用
function LoadingBar:setAnimEnable(b)
    self:lazeInit()
    if self.LoadingBar_animEnabled ~= b then
        if b == true then
            self:scheduleUnique(function(elapsed)
                local addPercent = 0
                local dif = self.LoadingBar_percent - self:getPercent_old()
                addPercent = dif * 15 / 100
                self:setPercent_old(self:getPercent_old() + addPercent)
            end, 0, "LoadingBarAnim")
            -- print("5 add by TangJian 2016/11/08 22:51:34")
        elseif b == false then
            self:unscheduleWithTag("LoadingBarAnim")
        else
            error("type(b) = " .. type(b))
        end
        self.LoadingBar_animEnabled = b
    end
end
0000000