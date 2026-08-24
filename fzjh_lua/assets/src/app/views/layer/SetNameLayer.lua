
local SetNameLayer = class("SetNameLayer", function()
  local ui = require("Layer/SetNameUI.lua").create()['root']
  Helper:convertUIParent(ui)
  return ui
end)

function SetNameLayer:create()
  local p = SetNameLayer.new()
  return p
end

function SetNameLayer:ctor()
  -- 初始化变量
  self._editBoxString = ""

  -- 初始化编辑框
  local size = self.EditBoxArea:getContentSize()
  local editBox = ccui.EditBox:create(size, "请输入")
  self.EditBoxArea:getParent():addChild(editBox)
  editBox:setPosition(self.EditBoxArea:getPositionX(), self.EditBoxArea:getPositionY())

  -- 设置输入类型
  editBox:setInputMode(6)
  editBox:setReturnType(1)

  -- 是否正在编辑
  self._isEditing = false

  -- 注册事件监听
  editBox:onEditHandler(function(event)
    local eventName = event.name
    local eventTarget = event.target

    if PRINT_MODE == 1 then
      print("eventName = "..tostring(eventName))
      print("eventTarget = "..tostring(eventTarget))
    end

    if eventName == "began" then
      self._isEditing = true
    elseif eventName == "changed" then
      self._editBoxString = editBox:getText()
      if PRINT_MODE == 1 then
        print("self._editBoxString = "..tostring(self._editBoxString))
      end

    elseif eventName == "end" then

    elseif eventName == "return" then
      self._isEditing = false
    end
  end)

  self.editBox = editBox

  -----------------------------------------------------------------------------------------------------------
  -- @author TangJian
  -- @desc 随机姓名按钮
  self.Button_randomName:releaseFunc(function()
    if self._isEditing == false then
      local role = User:getRole()
      editBox:setText(Helper:getRandomName(role.sex))
    end
  end)

  -----------------------------------------------------------------------------------------------------------
  -- @author TangJian
  -- @desc 初始化确认按钮
  local existNameMap = {}
  self.Button_confirm:releaseFunc(function()
    if self._editBoxString == nil or self._editBoxString == "" then
      PopText("名字不能为空!!!")
      return
    end

    if not Helper:isChinese(self._editBoxString) then
      PopText("名字必须是中文!!!")
      return
    end

    if Helper:isMaskOff(self._editBoxString) then
      -- PopText("名字包含不合法字符!!")
      PopText(tostring(self._editBoxString) .. " 是非法词汇，请更换后再试。")
      return
    end

    if existNameMap[self._editBoxString] then
      PopText("名字已经存在!!")
      return
    end

    self.Button_confirm:setTouchEnabled(false)
    -- HttpManagerEx:checkUserName(self._editBoxString, function(response)
    --   print("response = "..response)
    --   local recvData = json.decode(response)
    --   local errcode = recvData.errcode
    --   if errcode == 0 then
    --     print("名字可用")
    --     HttpManagerEx:submitUserName(User:getRole():getAttr("userid"), self._editBoxString, function(str)
    --       print("response = "..response)
    --       local recvData = json.decode(response)
    --       local errcode = recvData.errcode
    --       if errcode == 0 then
    --         User:getRole().name = self._editBoxString
    --         self.Button_confirm:setTouchEnabled(true)
    --         PopText("姓名设置成功!!")

    --         -- 设置姓名标记
    --         User:getRole().isChangeName = true
            
    --         self:hide()
    --       else
    --         PopText("姓名设置失败!!")

    --         self:hide()
    --       end
    --     end)
    --   else
    --     PopText("名字已经存在!!")
    --     self.Button_confirm:setTouchEnabled(true)
    --     existNameMap[self._editBoxString] = true
    --   end
    -- end)
  end)
end



Helper:classDefNodeGetInstance(SetNameLayer)
return SetNameLayer
00000000