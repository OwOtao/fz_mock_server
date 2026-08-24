local Resource = {}

function Resource:init()
    -- require("app.controllers.Audio")
end
Resource:init() -- 初始化

local function print()
end

local resList =
{
	fonts =
	{
		default = "Font/default.ttf",
        HYCFS = "Font/HYCFS.ttf",
        -- HYCFS = "Font/HYCFS.ttf",
		["微软雅黑"] = "Font/default.ttf"
	},
	imgs =
	{
		button1 = "Image/UI/MainUI/anniu01.png",
		button2 = "Image/UI/MainUI/anniu02.png",
		button3 = "Image/UI/MainUI/anniu03.png",
        button4 = "Image/UI/TaskUI/anniu.png",

		taskButton1a = "Image/UI/TaskUI/anniuword01.png",
		taskButton1b = "Image/UI/TaskUI/anniuword01b.png",
		taskButton2a = "Image/UI/TaskUI/anniuword02.png",
		taskButton2b = "Image/UI/TaskUI/anniuword02b.png",
		taskButton3a = "Image/UI/TaskUI/anniuword03.png",
		taskButton3b = "Image/UI/TaskUI/anniuword03b.png",
        taskButton4a = "Image/UI/TaskUI/anniuword04.png",
        taskButton4b = "Image/UI/TaskUI/anniuword04b.png",
        taskButton5a = "Image/UI/TaskUI/anniuword05.png",
        taskButton5b = "Image/UI/TaskUI/anniuword05b.png",
        taskButton6a = "Image/UI/TaskUI/anniuword06.png",
        taskButton6b = "Image/UI/TaskUI/anniuword06b.png",
        taskButton7a = "Image/UI/TaskUI/anniuword07.png",
        taskButton7b = "Image/UI/TaskUI/anniuword07b.png",
        taskButton8a = "Image/UI/TaskUI/anniuword08.png",
        taskButton8b = "Image/UI/TaskUI/anniuword08b.png",
        taskButton9a = "Image/UI/TaskUI/anniuword09.png",
        taskButton9b = "Image/UI/TaskUI/anniuword09b.png",
        taskButton10a = "Image/UI/TaskUI/anniuword10.png",
        taskButton10b = "Image/UI/TaskUI/anniuword10b.png",
        taskButton11a = "Image/UI/TaskUI/anniuword11.png",
        taskButton11b = "Image/UI/TaskUI/anniuword11b.png",
        taskButton12a = "Image/UI/TaskUI/anniuword12.png",
        taskButton12b = "Image/UI/TaskUI/anniuword12b.png",
        taskButton13a = "Image/UI/TaskUI/anniuword13.png",
        taskButton13b = "Image/UI/TaskUI/anniuword13b.png",
        taskButton14a = "Image/UI/TaskUI/anniuword14.png",
        taskButton14b = "Image/UI/TaskUI/anniuword14b.png",
        taskButton15a = "Image/UI/TaskUI/anniuword15.png",
        taskButton15b = "Image/UI/TaskUI/anniuword15.png",
        taskButton16a = "Image/UI/TaskUI/anniuword16.png",
        taskButton16b = "Image/UI/TaskUI/anniuword16.png",
        taskButton17a = "Image/UI/TaskUI/anniuword17.png",
        taskButton17b = "Image/UI/TaskUI/anniuword17.png",
        taskButton18a = "Image/UI/TaskUI/anniuword18.png",
        taskButton18b = "Image/UI/TaskUI/anniuword18.png",
        taskButton21a = "Image/UI/TaskUI/anniuword21.png",
        taskButton21b = "Image/UI/TaskUI/anniuword21.png",
        taskButton22a = "Image/UI/TaskUI/anniuword22.png",
        taskButton22b = "Image/UI/TaskUI/anniuword22.png",

		taskGuaJi = "Image/UI/TaskUI/guaji.png", -- 挂机按钮图标
        headFrame01 = "Image/UI/MainUI/biankuang01.png", --普通头像框
        headFrame02 = "Image/UI/MainUI/biankuang02.png", --月卡会员头像框
        headFrame03 = "Image/UI/MainUI/biankuang03.png", --排行榜会员头像框
        headFrame04 = "Image/UI/RankingUI/2.png",        --排行榜普通头像框

        anniversaryFrame = "Image/UI/AttrUI/frame/anniversary_Frame.png", --周年庆头像框
        anniversaryFrame2 = "Image/UI/AttrUI/frame/anniversary_Frame2.png", --2周年庆头像框
        anniversaryFrame3 = "Image/UI/AttrUI/frame/anniversary_Frame3.png", --3周年庆头像框
        mingcangwuyueFrame = "Image/UI/AttrUI/frame/mingcangwuyue_Frame.png", --名藏五岳头像框
        anniversaryFrame4 = "Image/UI/AttrUI/frame/anniversary_Frame4.png", --4周年庆头像框
        anniversaryFrame5 = "Image/UI/AttrUI/frame/anniversary_Frame5.png", --5周年庆头像框
        anniversaryInfoFrame = "Image/UI/AttrUI/frame/anniversary_InfoFram.png", -- 周年庆角色信息边框
        anniversaryInfoFrame2 = "Image/UI/AttrUI/frame/anniversary_InfoFram2.png", -- 2周年庆角色信息边框
        anniversaryInfoFrame3 = "Image/UI/AttrUI/frame/anniversary_InfoFram3.png", -- 3周年庆角色信息边框
        anniversaryInfoFrame4 = "Image/UI/AttrUI/frame/anniversary_InfoFram4.png", -- 4周年庆角色信息边框
        anniversaryInfoFrame5 = "Image/UI/AttrUI/frame/anniversary_InfoFram5.png", -- 5周年庆角色信息边框
        anniversaryRankFrame = "Image/UI/AttrUI/frame/anniversary_RankFrame.png", -- 周年庆排行榜头像框
        anniversaryRankFrame2 = "Image/UI/AttrUI/frame/anniversary_RankFrame2.png", -- 2周年庆排行榜头像框
        anniversaryRankFrame3 = "Image/UI/AttrUI/frame/anniversary_RankFrame3.png", -- 3周年庆排行榜头像框
        mingcangwuyueRankFrame = "Image/UI/AttrUI/frame/mingcangwuyue_RankFrame.png", --名藏五岳头像框
        anniversaryRankFrame4 = "Image/UI/AttrUI/frame/anniversary_RankFrame4.png", -- 4周年庆排行榜头像框
        anniversaryRankFrame5 = "Image/UI/AttrUI/frame/anniversary_RankFrame5.png", -- 5周年庆排行榜头像框

        title_flod = "Image/UI/AttrUI/title_flod.png",
        title_unflod = "Image/UI/AttrUI/title_unflod.png",

        -- 男人物头像 --------------------------------------------------------------
        nan_head1 = "Image/UI/AttrUI/nan/9.png",
        nan_head2 = "Image/UI/AttrUI/nan/10.png",
        nan_head3 = "Image/UI/AttrUI/nan/11.png",
        nan_head4 = "Image/UI/AttrUI/nan/12v2.png",
        nan_head5 = "Image/UI/AttrUI/nan/13v2.png",
        nan_head6 = "Image/UI/AttrUI/nan/14.png",
        nan_head7 = "Image/UI/AttrUI/nan/15.png",
        nan_head8 = "Image/UI/AttrUI/nan/16.png",
        nan_head9 = "Image/UI/AttrUI/nan/17.png",
        nan_head10 = "Image/UI/AttrUI/nan/18.png",
        nan_head11 = "Image/UI/AttrUI/nan/19.png",
        nan_head12 = "Image/UI/AttrUI/nan/20.png",
        nan_head13 = "Image/UI/AttrUI/nan/21.png",
        nan_head14 = "Image/UI/AttrUI/nan/22.png",
        nan_head15 = "Image/UI/AttrUI/nan/23.png",
        nan_head16 = "Image/UI/AttrUI/nan/24.png",
        nan_head17 = "Image/UI/AttrUI/nan/25.png",
        nan_head18 = "Image/UI/AttrUI/nan/26.png",
        nan_head19 = "Image/UI/AttrUI/nan/27.png",
        nan_head20 = "Image/UI/AttrUI/nan/28.png",
        nan_head21 = "Image/UI/AttrUI/nan/29.png",
        nan_head22 = "Image/UI/AttrUI/nan/30.png",
        nan_head23 = "Image/UI/AttrUI/nan/nan_head6.png",
        nan_head24 = "Image/UI/AttrUI/nan/nan_head3.png",
        nan_head25 = "Image/UI/AttrUI/nan/nan_head7.png",
        nan_head26 = "Image/UI/AttrUI/nan/nan_head5.png",
        nan_head27 = "Image/UI/AttrUI/nan/nan_head2.png",
        nan_head28 = "Image/UI/AttrUI/nan/nan_head1.png",
        nan_head29 = "Image/UI/AttrUI/nan/nan_head4.png",
        nan_head30 = "Image/UI/AttrUI/nan/wugang.png",
        nan_head31 = "Image/UI/AttrUI/nan/wangwei.png",
        nan_head32 = "Image/UI/AttrUI/nan/nantong1.png",
        nan_head33 = "Image/UI/AttrUI/nan/nantong2.png",
        nan_head34 = "Image/UI/AttrUI/nan/nantong3.png",
        nan_head35 = "Image/UI/AttrUI/nan/nantong4.png",

        --- 女人物头像 ----------------------------------------------
        nv_head1 = "Image/UI/AttrUI/nv/9.png",
        nv_head2 = "Image/UI/AttrUI/nv/10.png",
        nv_head3 = "Image/UI/AttrUI/nv/11.png",
        nv_head4 = "Image/UI/AttrUI/nv/12.png",
        nv_head5 = "Image/UI/AttrUI/nv/13.png",
        nv_head6 = "Image/UI/AttrUI/nv/14.png",
        nv_head7 = "Image/UI/AttrUI/nv/15.png",
        nv_head8 = "Image/UI/AttrUI/nv/16.png",
        nv_head9 = "Image/UI/AttrUI/nv/17.png",
        nv_head10 = "Image/UI/AttrUI/nv/18.png",
        nv_head11 = "Image/UI/AttrUI/nv/19.png",
        nv_head12 = "Image/UI/AttrUI/nv/20.png",
        nv_head13 = "Image/UI/AttrUI/nv/21.png",
        nv_head14 = "Image/UI/AttrUI/nv/22.png",
        nv_head15 = "Image/UI/AttrUI/nv/23.png",
        nv_head16 = "Image/UI/AttrUI/nv/24.png",
        nv_head17 = "Image/UI/AttrUI/nv/25.png",
        nv_head18 = "Image/UI/AttrUI/nv/26.png",
        nv_head19 = "Image/UI/AttrUI/nv/27.png",
        nv_head20 = "Image/UI/AttrUI/nv/28.png",
        nv_head21 = "Image/UI/AttrUI/nv/29.png",
        nv_head22 = "Image/UI/AttrUI/nv/30.png",
        nv_head23 = "Image/UI/AttrUI/nv/nv_head6.png",
        nv_head24 = "Image/UI/AttrUI/nv/nv_head2.png",
        nv_head25 = "Image/UI/AttrUI/nv/nv_head3.png",
        nv_head26 = "Image/UI/AttrUI/nv/nv_head1.png",
        nv_head27 = "Image/UI/AttrUI/nv/nv_head5.png",
        nv_head28 = "Image/UI/AttrUI/nv/nv_head4.png",
        nv_head29 = "Image/UI/AttrUI/nv/nv_head7.png",
        nv_head30 = "Image/UI/AttrUI/nv/change.png",
        nv_head31 = "Image/UI/AttrUI/nv/tonglao.png",
        nv_head32 = "Image/UI/AttrUI/nv/nvtong1.png",
        nv_head33 = "Image/UI/AttrUI/nv/nvtong2.png",
        nv_head34 = "Image/UI/AttrUI/nv/nvtong3.png",
        nv_head35 = "Image/UI/AttrUI/nv/nvtong4.png",

        -- 面具
        mianju1004 = "Image/UI/AttrUI/mianju/guojing.png",
        mianju1005 = "Image/UI/AttrUI/mianju/yangkang.png",
        mianju1006 = "Image/UI/AttrUI/mianju/munianci.png",
        mianju1007 = "Image/UI/AttrUI/mianju/chenglingsu.png",
        mianju1008 = "Image/UI/AttrUI/mianju/guoxiang.png",
        mianju1009 = "Image/UI/AttrUI/mianju/miaoruolan.png",

        mianju1010 = "Image/UI/AttrUI/mianju/linghucong(Y).png",
        mianju1011 = "Image/UI/AttrUI/mianju/yuelingsan2.png",
        mianju1012 = "Image/UI/AttrUI/mianju/yangguo.png",
        mianju1013 = "Image/UI/AttrUI/mianju/xiaolongnv.png",
        mianju1014 = "Image/UI/AttrUI/mianju/liqiushui.png",
        mianju1015 = "Image/UI/AttrUI/mianju/xiangwentian.png",
        mianju1016 = "Image/UI/AttrUI/mianju/muwanqin.png",
        mianju1017 = "Image/UI/AttrUI/mianju/duanyu.png",

        -- 信物
        xinwu200_01 = "Image/UI/AttrUI/xinwu/xinwu200_01.png",
        xinwu200_02 = "Image/UI/AttrUI/xinwu/xinwu200_02.png",
        xinwu200_03 = "Image/UI/AttrUI/xinwu/xinwu200_03.png",
        xinwu200_04 = "Image/UI/AttrUI/xinwu/xinwu200_04.png",
        xinwu200_05 = "Image/UI/AttrUI/xinwu/xinwu200_05.png",
        xinwu200_06 = "Image/UI/AttrUI/xinwu/xinwu200_06.png",
        xinwu200_07 = "Image/UI/AttrUI/xinwu/xinwu200_07.png",
        xinwu200_08 = "Image/UI/AttrUI/xinwu/xinwu200_08.png",
        xinwu200_09 = "Image/UI/AttrUI/xinwu/xinwu200_09.png",
        xinwu200_10 = "Image/UI/AttrUI/xinwu/xinwu200_10.png",
        xinwu200_11 = "Image/UI/AttrUI/xinwu/xinwu200_11.png",
        xinwu200_12 = "Image/UI/AttrUI/xinwu/xinwu200_12.png",

        -- 特殊头像
        special_1 = "Image/UI/AttrUI/special/special_1.png",
        special_2 = "Image/UI/AttrUI/special/special_2.png",
        special_3 = "Image/UI/AttrUI/special/special_3.png",
        special_4 = "Image/UI/AttrUI/special/special_4.png",
        special_5 = "Image/UI/AttrUI/special/special_5.png",
        special_6 = "Image/UI/AttrUI/special/special_6.png",

        -- @author LiJie    @time 2016/11/26 14:42:57  增加武功书页的加减图片
        addMsg = "Image/UI/GpongFuPageUI/add.png",
        subMsg = "Image/UI/GpongFuPageUI/sub.png",
        -- @author LiJie    @time 2016/11/30 10:22:35  签到的图片
        signIn = "Image/UI/SignInUI/signGou.png",
        unSignIn = "Image/UI/SignInUI/unNormalSign.png",

        -- 签到宝箱
        signInChest1 = "Image/UI/SignInUI/baoxiang-2.png",
        signInChest2 = "Image/UI/SignInUI/baoxiang-5.png",
        signInChest3 = "Image/UI/SignInUI/baoxiang-7.png",

        -- 签到元宝
        signInYuanBao1 = "Image/UI/SignInUI/yuanbao-2.png",
        signInYuanBao2 = "Image/UI/SignInUI/yuanbao-5.png",
        signInYuanBao3 = "Image/UI/SignInUI/yuanbao-7.png",

        -- 签到天香雨露
        signInTianXiang1 = "Image/UI/SignInUI/tianxiangyulu-2.png",
        signInTianXiang2 = "Image/UI/SignInUI/tianxiangyulu-5.png",
        signInTianXiang3 = "Image/UI/SignInUI/tianxiangyulu-7.png",

        -- 签到醉梦生
        signInZuiMengSheng1 = "Image/UI/SignInUI/jiu-2.png",
        signInZuiMengSheng2 = "Image/UI/SignInUI/jiu-5.png",
        signInZuiMengSheng3 = "Image/UI/SignInUI/jiu-7.png",


        -- 经脉印记
        JingMaiYinJiItemBack = "OtherImage/JingMai/JingMaiYinJiItemBack.png",

        --治疗按钮
        zhiliao = "Image/UI/MeridianUI/zhiliao.png" 
	},
	textStyles =
	{
		taskButton = -- 任务按钮文字
		{
			fontName = "Font/default.ttf",
			fontSize = 32,
			fontColor = cc.c4b(0, 0, 0, 255),
			outlineWidth = 5,
			outlineColor = cc.c4b(255, 255, 255, 255)
		},
		taskRewardAnim = -- 任务奖励动画文字
		{
			fontName = "Font/default.ttf",
			fontSize = 42,
			fontColor = cc.c4b(57, 219, 92, 255),
			outlineWidth = 5,
			outlineColor = cc.c4b(0, 0, 0, 255)
		},
		taskDamageNum = -- 伤害数字
		{
			fontName = "Font/default.ttf",
			fontSize = 45,
			fontColor = cc.c4b(255, 64, 64, 255),
			outlineWidth = 0,
			outlineColor = cc.c4b(0, 0, 0, 255)
		}
	},
	skAnims =
	{
        gongfuNew = {
            skel ="Anim/gongfu1/gongfu.json",
            atlas = "Anim/gongfu1/gongfu.atlas"
        },
		gongfu = {
                    skel ="Anim/gongfu/gongfu.json",
                    atlas = "Anim/gongfu/gongfu.atlas"
                    },
		effects = {
                    skel = "Anim/effects/effects.json",
                    atlas = "Anim/effects/effects.atlas"
                    },
        ep2 = {
                    skel = "Anim/ep2/skeleton.json",
                    atlas = "Anim/ep2/skeleton.atlas"
                    },
        portrait = {
                    skel = "Anim/portrait/skeleton.json",
                    atlas = "Anim/portrait/skeleton.atlas"
                    },
        maskEffect = {
            skel = "Anim/portrait/maskEffect/skeleton.json",
            atlas = "Anim/portrait/maskEffect/skeleton.atlas"
            },
        newyear = {
                    skel = "Anim/2018newyear/paifang.json",
                    atlas = "Anim/2018newyear/paifang.atlas"
                    },
        -- 护盾
        hudun = {
                    skel = "Anim/FightEffect/fanghu.json",
                    atlas = "Anim/FightEffect/fanghu.atlas"
                },
        createZhao = {
                        skel = "Anim/createZhao/createZhao.json",
                        atlas = "Anim/createZhao/createZhao.atlas"
                    },
	}
}

function Resource:loadRes()
	self:loadUI() -- 载入UI
	self:loadSkAnim() -- 载入动画
end

function Resource:releaseRes()
	self:releaseUI()
end

function Resource:getImgPath(imgName)
	return assert(resList.imgs[imgName])
end

function Resource:getFontPath(fontName)
	return assert(resList.fonts[fontName])
end

function Resource:getTextByStyleName(name)
	local textStyle = resList.textStyles[name]
	if textStyle then
		local text = ccui.Text:create("", textStyle.fontName, textStyle.fontSize)
		text:setTextColor(textStyle.fontColor)
		text:enableOutline(textStyle.outlineColor, textStyle.outlineWidth)
		return text
	end
	assert(false)
	return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/01 16:36:06
-- @desc 判断是否有这个状态
function Resource:getBuffIconImageFileName(name)
    local BuffIconMap = require("script.newbattle.demo.buffIcon")["Buff图标"]
    local buffIconInfo = BuffIconMap[name]

    if buffIconInfo then
        return buffIconInfo.iconRes
    end
    
    return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/21 21:15:55
-- @desc 得到增益效果图标
function Resource:getBuffIconImage(name)
    local fileName = self:getBuffIconImageFileName(name)
    if fileName then
        local image = ccui.ImageView:create(self:getBuffIconImageFileName(name))
        return image
    end
    return nil
end

-- 动画 ------------------------------------------------------------------------
function Resource:loadSkAnim()
    -- for key, var in pairs(resList.skAnims) do
    --     local animName = var
    --     if PRINT_MODE == 1 then
    --         print("载入动画: " .. key)
    --     end
    -- -- YXSkeletonAnimation:createWithFile( animName..".json", animName..".atlas", 1 )
    -- end
end

function Resource:getSkAnim(key, scale)
    if scale == nil then
        scale = 1
    end
    local animConfig = resList.skAnims[key]
    -- Helper:print_lua_table(resList)
    if PRINT_MODE == 1 then
        print(key)
        print("animName = " .. animConfig.skel)
    end
    local skAnim = assert(YXSkeletonAnimation:createWithFile(animConfig.skel, animConfig.atlas, scale), "动画初始化出错")
    return skAnim
end

-- UI ------------------------------------------------------------------------
function Resource:loadUI()
    self:releaseUI()

    self._UI = require("Layer/PartUI/PartUI.lua").create()['root']
    Helper:convertUI(self._UI)

    self._UI:retain()
end

function Resource:releaseUI()
    if self._UI then
        self._UI:release()
        self._UI = nil
    end
end

function Resource:getUIByName(name)
    local ui = assert(self._UI[name], "没有找到这个UI")
    return ui:clone()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/24 15:49:48
-- @desc 普通精灵和图片普通shader
function Resource:getSpriteNormalShder()
    local key = "getSpriteNormalShder"
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(key)
    if glProgram == nil then
        local vert = [[
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
#else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
#endif

void main()
{
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
}
    ]]

    local frag = [[
    #ifdef GL_ES
        precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main()
    {
        gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    }
    ]]

        glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
    end
    return glProgram
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/24 15:30:08
-- @desc 普通精灵和图片灰度shader
function Resource:getSpriteGrayShder()
    local key = "getSpriteGrayShder"
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(key)
    if glProgram == nil then
        local vert = [[
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
#else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
#endif

void main()
{
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
}
    ]]

    local frag = [[
    #ifdef GL_ES
        precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main()
    {
        gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
        float avg = (gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) / 3.0;
        gl_FragColor.r = avg;
        gl_FragColor.g = avg;
        gl_FragColor.b = avg;
    }
    ]]

    glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
    end
    return glProgram
end

-- 动画渲染
function Resource:getSkAnimPhantomShader(r, g, b, a)
    local key = "SkAnimPhantomShader" .. r .. "," .. g .. "," .. b .. "," .. a
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(key)
    if glProgram == nil then
        local vert = [[
            attribute vec4 a_position;
            attribute vec2 a_texCoord;
            attribute vec4 a_color;

            #ifdef GL_ES
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
            #else
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
            #endif

            void main()
            {
                gl_Position = CC_MVPMatrix * a_position;
                v_fragmentColor = a_color;
                v_texCoord = a_texCoord;
            }
        ]]

        local frag = [[
            #ifdef GL_ES
            precision lowp float;
            #endif

            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;

            void main()
            {
                gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);

                float r = gl_FragColor.r;
                float g = gl_FragColor.g;
                float b = gl_FragColor.b;
                float a = gl_FragColor.a;
                float avg = ( r + g + b ) / 3.0;
                gl_FragColor.r = 0.0;
                gl_FragColor.g = avg*0.5;
                gl_FragColor.b = avg;
                gl_FragColor.a *= 0.5;
                /*
                if( gl_FragColor.a > 0.1 )
                {
                        float r = gl_FragColor.r;
                        float g = gl_FragColor.g;
                        float b = gl_FragColor.b;
                        float a = gl_FragColor.a;
                        float avg = ( r + g + b ) / 3.0;

                        if( true || a >= 0.9 && a <= 1.0 )
                        {
                            gl_FragColor.r = avg * ]].. r .. [[ * a;
                            gl_FragColor.g = avg * ]].. g .. [[ * a;
                            gl_FragColor.b = avg * ]].. b .. [[ * a;
                            gl_FragColor.a = avg * ]].. a .. [[ * a;
                        }
                        else
                        {
                            gl_FragColor = vec4( 0.0, 0.0, 0.0, 0.0 );
                        }

                }*/
            }
        ]]

        glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
    end
    return glProgram
end

-- 动画渲染
function Resource:getSkAnimColorShader(r, g, b, a)
    local key = "SkAnimColorShader" .. r .. "," .. g .. "," .. b .. "," .. a
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(key)
    if glProgram == nil then
        local vert = [[
            attribute vec4 a_position;
            attribute vec2 a_texCoord;
            attribute vec4 a_color;

            #ifdef GL_ES
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
            #else
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
            #endif

            void main()
            {
                gl_Position = CC_MVPMatrix * a_position;
                v_fragmentColor = a_color;
                v_texCoord = a_texCoord;
            }
        ]]

        local frag = [[
            #ifdef GL_ES
            precision lowp float;
            #endif

            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;

            void main()
            {
                gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);

                if( gl_FragColor.a > 0.01 )
                {
	                gl_FragColor.r = ]].. r .. [[;
	                gl_FragColor.g = ]].. g .. [[;
	                gl_FragColor.b = ]].. b .. [[;
	      }
                //gl_FragColor.a = ]].. a .. [[;

            }
        ]]

        glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
    end
    return glProgram
end

function Resource:getSKAnimNormalShader()
    local key = "SKAnimNormalShader"
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(key)
    if glProgram == nil then
        local vert = [[
            attribute vec4 a_position;
            attribute vec2 a_texCoord;
            attribute vec4 a_color;

            #ifdef GL_ES
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
            #else
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
            #endif

            void main()
            {
                gl_Position = CC_MVPMatrix * a_position;
                v_fragmentColor = a_color;
                v_texCoord = a_texCoord;
            }
        ]]

        local frag = [[
            #ifdef GL_ES
            precision lowp float;
            #endif

            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;

            void main()
            {
                gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
            }
        ]]

        glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
    end

    -- return self:getSkAnimGoldPhantomShader()
    return glProgram
end

function Resource:getColorTb( )
    return GetColorTb()
end


Resource:loadRes()
return Resource
0000000