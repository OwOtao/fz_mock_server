local LoginConf = {}

local activity_conf = {
    RIPKING = {
        startTime = {
            date = "20181031",
            time = 0
        },

        endTime = {
            date = "20181106",
            time = 24
        },

        img = "Image/UI/MainUI/rip_back.png",

        btnImg = "Image/UI/MapUI/anniu04.png",

        btnName = "我知矣",

        desc = "武林泰斗、一代奇人金大侠近日已驾鹤西去，天地俱泪，草木同悲。斯人已逝，音容宛在。诸位江湖同道可前往华山之巅祭奠。",

        showCondi = function ()
            local bool = false

            --@RefType [src.app.models.role.Role#Role]
            local role = User:getRole()

            local flag = role:getInheritFlag("RIPKING")
            
            if flag == 0 then
                bool = true
            end
            
            return bool
        end,

        btnFunc = function ()
            --@RefType [src.app.models.role.Role#Role]
            local role = User:getRole()

            role:setInheritFlag("RIPKING",1)
        end
    }
}

function LoginConf:getConf(activity_code)
    local conf = activity_conf[activity_code]

    return conf
end


function LoginConf:checkNeeOpen( activity_code )
    
    local conf = self:getConf(activity_code)
    
    if MapIsEmpty(conf) then
        return false
    end
    
    local startTime = conf.startTime

    local endTime = conf.endTime

    if GetTime() < Helper:getTimeStampWithStringDate(startTime.date, startTime.time) or GetTime() > Helper:getTimeStampWithStringDate(endTime.date, endTime.time) then
        return false
    end

    if conf.showCondi ~= nil and conf.showCondi() == false then
        return false
    end

    return true
end


return  LoginConf00000