local TaskFlow = require("app.extends.TaskFlow")
local RoleStatePanelActiveZhaoReadyItem = {}

defVars(
    RoleStatePanelActiveZhaoReadyItem,
    {
        _lastScale = {"LastScale", 1.5}
    }
)

function RoleStatePanelActiveZhaoReadyItem:create()
    local p = Resource:getUIByName("Panel_fightActiveZhaoReadyItem")
    Helper:convertUIByParent(p)
    p = Helper:tableCover(p, clone(RoleStatePanelActiveZhaoReadyItem))
    p:init()
    return p
end

function RoleStatePanelActiveZhaoReadyItem:init()
    -- 成员变量定义 add by TangJian 2017/02/25 11:53:54
    self._direction = 1 -- 方向
    self._animDuration = 0.2 -- 动画持续时间
    self._animMoveDistance = 50 -- 动画移动距离

    self._animTaskFlow = TaskFlow:create()

    -- 补回丢失的字体描边信息 add by TangJian 2017/02/25 11:51:14
    self.Text_title:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    -- 调度器 add by TangJian 2017/02/25 11:50:53
    -- local i = 1
    -- self:schedule(function()
    --     i = i + 1
    --     if i % 2 == 0 then
    --         self:show()
    --     else
    --         self:hide()
    --     end
    -- end, 2)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 15:49:27
-- @desc 设置动画时间
function RoleStatePanelActiveZhaoReadyItem:setAnimDuration(duration)
    self._animDuration = duration
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 11:54:35
-- @desc 设置方向
function RoleStatePanelActiveZhaoReadyItem:setDirection(direction)
    direction = switch(direction, {[1] = 1, [-1] = -1, default = 1})
    if self._direction ~= direction then
        self._direction = direction
    end
end

function RoleStatePanelActiveZhaoReadyItem:show(callback)
    self._animTaskFlow:startTask(
        function()
            callback =
                Helper:getDef(
                callback,
                function()
                end
            )

            local parentSize = self:getContentSize()
            local animDuration = self._animDuration
            local animMoveDistance = -self._animMoveDistance * self._direction

            -- 图片动画 add by TangJian 2017/02/25 11:34:24
            self.Image_back:setOpacity(0)
            self.Image_back:runActionWithName("Image_backAnim", YXEaseAction:create(cc.FadeIn:create(animDuration), Sine_EaseOut))

            -- 文字动画 add by TangJian 2017/02/25 11:34:22
            self.Text_title:setOpacity(0)
            -- self.Text_title:runActionWithName("Text_titleAnim", cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2)))
            -- cc.Sequence:create(YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.25, 3, 3), Sine_EaseOut), YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.75, 1.5, 1.5), Sine_EaseIn)),
            self.Text_title:runActionWithName(
                "Text_titleAnim",
                YXEaseAction:create(cc.Spawn:create(cc.FadeIn:create(animDuration), cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2))), Sine_EaseOut)
            )

            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(animDuration),
                    cc.CallFunc:create(
                        function()
                            self._animTaskFlow:finishTask()
                            callback()
                        end
                    )
                )
            )
        end
    )
end

function RoleStatePanelActiveZhaoReadyItem:show1(callback)
    self._animTaskFlow:startTask(
        function()
            callback =
                Helper:getDef(
                callback,
                function()
                end
            )

            local parentSize = self:getContentSize()
            local animDuration = self._animDuration
            local animMoveDistance = -self._animMoveDistance * self._direction

            -- 图片动画 add by TangJian 2017/02/25 11:34:24
            self.Image_back:setOpacity(0)
            self.Image_back:runActionWithName("Image_backAnim", YXEaseAction:create(cc.FadeIn:create(animDuration), Sine_EaseOut))

            -- 文字动画 add by TangJian 2017/02/25 11:34:22
            self.Text_title:setOpacity(0)
            self.Text_title:runActionWithName(
                "Text_titleAnim",
                YXEaseAction:create(
                    cc.Spawn:create(
                        cc.Sequence:create(
                            YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.25, 3, 3), Sine_EaseOut),
                            YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.75, self._lastScale, self._lastScale), Sine_EaseIn)
                        ),
                        cc.FadeIn:create(animDuration),
                        cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2))
                    ),
                    Sine_EaseOut
                )
            )

            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(animDuration),
                    cc.CallFunc:create(
                        function()
                            self._animTaskFlow:finishTask()
                            callback()
                        end
                    )
                )
            )
        end
    )
end

function RoleStatePanelActiveZhaoReadyItem:hide1(callback)
    self._animTaskFlow:startTask(
        function()
            callback =
                Helper:getDef(
                callback,
                function()
                end
            )

            local parentSize = self:getContentSize()
            local animDuration = self._animDuration
            local animMoveDistance = -self._animMoveDistance * self._direction

            -- 图片动画 add by TangJian 2017/02/25 11:34:24
            self.Image_back:setOpacity(255)
            self.Image_back:runActionWithName("Image_backAnim", YXEaseAction:create(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(animDuration)), Sine_EaseOut))

            -- 文字动画 add by TangJian 2017/02/25 11:34:22
            self.Text_title:setOpacity(255)
            self.Text_title:setPosition(cc.p(parentSize.width / 2, parentSize.height / 2))
            -- self.Text_title:runActionWithName("Text_titleAnim", cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2)))
            self.Text_title:runActionWithName(
                "Text_titleAnim",
                cc.Sequence:create(
                    cc.DelayTime:create(1),
                    YXEaseAction:create(
                        cc.Spawn:create(cc.FadeOut:create(animDuration), cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2 + animMoveDistance, parentSize.height / 2))),
                        Sine_EaseOut
                    )
                )
            )

            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(animDuration + 1),
                    cc.CallFunc:create(
                        function()
                            self._animTaskFlow:finishTask()
                            callback()
                        end
                    )
                )
            )
        end
    )
end

function RoleStatePanelActiveZhaoReadyItem:show2(callback)
    self._animTaskFlow:startTask(
        function()
            callback =
                Helper:getDef(
                callback,
                function()
                end
            )

            local parentSize = self:getContentSize()
            local animDuration = self._animDuration
            local animMoveDistance = -self._animMoveDistance * self._direction

            -- 图片动画 add by TangJian 2017/02/25 11:34:24
            self.Image_back:setOpacity(0)
            self.Image_back:runActionWithName("Image_backAnim", YXEaseAction:create(cc.FadeIn:create(animDuration), Sine_EaseOut))

            -- 文字动画 add by TangJian 2017/02/25 11:34:22
            self.Text_title:setOpacity(0)
            self.Text_title:setPosition(cc.p(parentSize.width / 2 + animMoveDistance, parentSize.height / 2))
            self.Text_title:setScale(2.5)
            -- self.Text_title:runActionWithName("Text_titleAnim", cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2)))
            -- cc.Sequence:create(YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.25, 3, 3), Sine_EaseOut), YXEaseAction:create(cc.ScaleTo:create(animDuration * 0.75, 1.5, 1.5), Sine_EaseIn)),
            self.Text_title:runActionWithName(
                "Text_titleAnim",
                cc.Sequence:create(
                    YXEaseAction:create(
                        cc.Spawn:create(
                            cc.Sequence:create(YXEaseAction:create(cc.ScaleTo:create(animDuration, 1, 1), Sine_EaseIn)),
                            cc.FadeIn:create(animDuration),
                            cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2))
                        ),
                        Sine_EaseOut
                    ),
                    cc.DelayTime:create(1)
                )
            )

            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(animDuration + 1),
                    cc.CallFunc:create(
                        function()
                            self._animTaskFlow:finishTask()
                            callback()
                        end
                    )
                )
            )
        end
    )
end

function RoleStatePanelActiveZhaoReadyItem:hide(callback)
    self._animTaskFlow:startTask(
        function()
            callback =
                Helper:getDef(
                callback,
                function()
                end
            )

            local parentSize = self:getContentSize()
            local animDuration = self._animDuration
            local animMoveDistance = -self._animMoveDistance * self._direction

            -- 图片动画 add by TangJian 2017/02/25 11:34:24
            self.Image_back:setOpacity(255)
            self.Image_back:runActionWithName("Image_backAnim", YXEaseAction:create(cc.FadeOut:create(animDuration), Sine_EaseOut))

            -- 文字动画 add by TangJian 2017/02/25 11:34:22
            self.Text_title:setOpacity(255)
            self.Text_title:setPosition(cc.p(parentSize.width / 2, parentSize.height / 2))
            -- self.Text_title:runActionWithName("Text_titleAnim", cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2, parentSize.height / 2)))
            self.Text_title:runActionWithName(
                "Text_titleAnim",
                YXEaseAction:create(
                    cc.Spawn:create(cc.FadeOut:create(animDuration), cc.MoveTo:create(animDuration, cc.p(parentSize.width / 2 + animMoveDistance, parentSize.height / 2))),
                    Sine_EaseOut
                )
            )

            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(animDuration),
                    cc.CallFunc:create(
                        function()
                            self._animTaskFlow:finishTask()
                            callback()
                        end
                    )
                )
            )
        end
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/27 11:30:55
-- @desc 设置title
function RoleStatePanelActiveZhaoReadyItem:setTitle(title)
    self.Text_title:setString(title)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/07 15:47:00
-- @desc 得到标题大小
function RoleStatePanelActiveZhaoReadyItem:getTitleSize()
    return self.Text_title:getContentSize()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/07 15:49:48
-- @desc 得到背景图大小
function RoleStatePanelActiveZhaoReadyItem:getImageBackSize()
    return self.Image_back:getContentSize()
end

return RoleStatePanelActiveZhaoReadyItem
00000000