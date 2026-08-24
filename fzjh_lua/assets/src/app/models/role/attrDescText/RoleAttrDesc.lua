local RoleAttrDesc = {
    _looksDsc = {
        male = {},
        female = {}
    }
}

local function loadLooksDesc()
    local looksDesc = require("script.role.looksDesc")["looksDsc"]
    for k,v in pairs(looksDesc) do
        table.insert(RoleAttrDesc._looksDsc.male,{looks = v.looks,dsc = v.color..v.maleDsc})
        table.insert(RoleAttrDesc._looksDsc.female,{looks = v.looks,dsc = v.color..v.femaleDsc})
    end

    table.sort(RoleAttrDesc._looksDsc.male,function(a,b)
        return a.looks < b.looks
    end)
    table.sort(RoleAttrDesc._looksDsc.female,function(a,b)
        return a.looks < b.looks
    end)
end

loadLooksDesc()


function RoleAttrDesc:getLooksDsc()
    return self._looksDsc
end



return RoleAttrDesc00000