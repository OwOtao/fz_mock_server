local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local ShiMenQingGuiLayer = class("ShiMenQingGuiLayer", cc.Layer)
local Npc = require("app.models.npc.Npc")

function ShiMenQingGuiLayer:create()
	local p = ShiMenQingGuiLayer:new()
	p:init()
	return p
end
function ShiMenQingGuiLayer:init()
	local UI= require("Layer/TeacherTask/MenPaiQIngGUi.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点
end
function ShiMenQingGuiLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()
end
function ShiMenQingGuiLayer:setBack()
	local PrintLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	title:setBackCallFunc(function()
		PrintLayer:setPanelVisible(false)
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end)
	PrintLayer:setPanelVisible(true)
	PrintLayer:setPanleReleaseFunc(function()
		MainControllLayer:popLayer()
		PrintLayer:setPanelVisible(false)
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
		title:setTitleBack()
	end)
end
function ShiMenQingGuiLayer:initLayer(flag)
	local familyTab = TeacherTask:getFamilyDsc()
	local TitleLayer = MainControllLayer:getLayer("TitleLayer")
	TitleLayer:setLayerTitleName("ShiMenQingGuiLayer",familyTab.position)
	local str = "每日可完成数量有上限；每天凌晨HIY5NOR点重置，未完成的任务清空；\n每日师门任务可获得贡献度最多HIY4000NOR点；\n有几率获得其他物品奖励如秘籍残页；\n一般来说，任务颜色品质越高，奖励越好。ORN橙色NOR最优，HIM紫色NOR次之，BLU蓝色NOR再次之，GRN绿色NOR最差；\n有些任务可以指派出去由其他同门代劳；每日可指派次数有上限。\n任务领取后可以放弃，但是放弃后需要经过RED5分钟NOR后方可再接取。"
	local textColor = cc.c3b(156,156,156)
	if flag == "任务说明" then
		self:initRichTextPreview(str,self.Image_48.Text_dsc2,self,textColor,"Text_dsc")
		self.Image_48.Text_dsc1:setVisible(false)
	else
		self.Image_48.Text_dsc2:setVisible(false)
		if self["Text_dsc"] then
			self["Text_dsc"]:removeFromParent()
			self["Text_dsc"] = nil
		end
		self:setMenGuiText()
	end
	self.Image_48.Text_title:setString(flag)
	self:setBack()
end
function ShiMenQingGuiLayer:initRichTextPreview(str,DscArea,parent,textColor,name,verticalSpace)
	local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	size.height = size.height + 29
	DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	point.y = point.y - 20
   	richTextScroll:setPosition(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(true)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
   	parent[name]:pushBackNewLine()
	-- parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(255)
	parent[name]:setAnchorPoint(0.5000, 0.5000)
	parent[name]:setTouchEnabled(false) 
   	-- parent[name]:getRichText():setVerticalSpace(200)

end
function ShiMenQingGuiLayer:setMenGuiText()
	local familyId = User:getRole():getFamilyId()
	local tab = {
	["wudang"] = "我派遵初真十戒，忠、孝、济世、守身、\n节俭、利人、清修。\n我派弟子，不得陷于贪求无厌之欲。\n凡武当中人，当以行侠仗义，匡扶正道为己任。",
	["emei"] = "峨嵋中人，需以清净为本，勿杀生，勿淫邪，勿妄言。\n修真者，不言师，不与人较技，不在人前演艺。\n凡入峨眉者，需与邪道划清界限，邪门歪道得而诛之。",
	["huashan"] = "华山重剑，习武当以剑法为重。\n华山弟子当心怀正道，行侠仗义。\n华山弟子当尊师重道，勤学苦练，以振兴本门为己任。",
	["kunlun"] = "凡入昆仑，除日常习武之外，身外技艺亦需时常习之。\n昆仑弟子需保持无争之心，绝不能意气用事。\n为弟子者，需尊师重道，相互友爱。",
	["xingxiu"] = "星宿以掌门为尊，任何忤逆者，杀无赦。\n为达目的，可用尽一切手段。\n星宿弟子应当勤学苦练，使星宿独步天下。",
	["baituoshan"] = "背师叛逃者，杀无赦。\n泄露白驼武功秘籍者，杀无赦。\n偷学秘籍者，杀无赦。",
	["tianshan"] = "入我天山，当勤修苦练，不得废怠、\n天山之人，需清静无为，不得私自械斗。\n天山虽不自诩名门正派，但烧杀掳掠之事仍旧不可为之。",
	["quanzhen"] = "我教弟子，需以五戒为修身根本。\n遵道法五戒，不杀生，不荤酒，不口是心非，不偷盗，不邪淫。\n需持五戒，校正身心，去除杂念，方可修行。",
	["dali"] = "佛门弟子需使六根清净，勿妄视，勿妄听，勿妄言。\n寺中弟子需慈悲为怀，广度世人。\n入天龙者需心地清明，切不可有争强好胜之心。",
	["gaibang"] = "丐帮弟子当以义字为重。\n入丐帮者皆为兄弟姐妹，当相互扶持，相互敬爱。\n为我丐帮弟子，当匡扶正义，替天行道。",
	["mizong"] = "凡入我寺，当抛却尘念。清净修为。\n凡入我寺，当遵守寺规，绝不可破戒。\n雪山弟子当潜心苦修，不可强涉世事纷扰。",
	["wudu"] = "入教者当遵守教规，不得违背教主。\n当团结一心，一同对外。\n当勤加修炼，不可倦怠练功。",
	["tiezhang"] = "入我帮者，绝不可背叛师门。\n帮众弟子，应戮力同心，不得做欺上罔下之举。\n我帮与海鲸势不两立，若有与海鲸帮往来者，逐出师门。",
	["riyueshenjiao"] = "教主文成武德，任何对教主不尊者，必诛之。\n我日月以武为尊，能者居上。\n入神教者，永不得背叛。",
	["mingjiao"] = "入我明教，当遵圣火引导，不可背师叛教。\n教中弟子当上下一心，壮大我教。\n我教海纳百川，绝不能存身份、来历之偏见。",
	["kongtong"] = "入我派者，当上尊重掌门师长，下护同门。\n崆峒弟子当勤学苦练，壮大门楣。\n崆峒弟子当一心向善，绝不可心存恶念，误入歧途。",
	["murong"] = "入我山庄者，当以家族利益至上。\n慕容弟子当团结一心，不可背弃师门。\n慕容武学绝不可外传，违者必诛之。",
 	["taohuadao"] = "桃花弟子需尊师重道，上尊下卑。\n除勤学苦练，不可倦怠奇门阵法修炼。\n桃花弟子当远离纷争，不得私自争斗。",
	["tangmen"] = "入我唐门者，凡事以唐家为重，绝不可因小失大。\n唐门弟子虽修习暗器，但绝不可做不耻之事，不得无端伤人。\n唐家武器一律不得淬毒，违者门规重罚。",
	["gumu"] = "古墓以内修为重，需祛除争斗之心。\n古墓弟子当清心寡欲，潜心修行。\n古墓弟子当上下齐心，不得背信弃义。",
	["haijing"] = "入我帮者，当勤加修炼，不可废置修为。\n海鲸弟子当精通水性，不得心存畏惧。\n海鲸与铁掌势不两立，不得与铁掌弟子私下往来。",
	["youming"] = "一入我教，终身不得脱离。\n教中弟子当遵教主之言，不得违背。\n教中秘法，需修行得当，绝不可对外泄露。" ,
	["shaolin"] = "佛门以悲悯之怀，习武只可备以自卫，戒逞血气之私，有好勇斗狠之举。\n凡少林弟子，以四威仪为戒，睡如弓，坐如钟，走如风，站如钉。\n少林清规，戒杀、戒盗、戒淫、戒妄、戒酒。",
	["guanfu"] = "官府弟子，当秉公执法，决不姑息养奸。\n凡官府中人，当以国家大任为先，私人恩怨为轻。\n官府以维持秩序为己任，需忠义两全。" ,
	["luoyue"] = " 凡入我山庄，需约束行为，不做杀人放火之事。\n落月弟子当齐力同心，不得私心争斗。\n落月弟子习武当为本心，不得肆意妄为。",
	}
	local str = Helper:getDef(tab[familyId],"联系客服")
	self.Image_48.Text_dsc1:setVisible(true)
	self.Image_48.Text_dsc1:setString(tab[familyId])
end
Helper:classDefNodeGetInstance(ShiMenQingGuiLayer)
return ShiMenQingGuiLayer
000000000