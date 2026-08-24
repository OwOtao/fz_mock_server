local InheritEventLayer = class("InheritEventLayer", LayerEx)


function InheritEventLayer:create()
	local p = InheritEventLayer:new()
	p:init()
	return p
end

local inheritEvent =
{
	[1] =
	{
		problem = "自打你收养$IN以来，除了教$HE一些基本常识外交流甚少，可能是之前的遭遇使这孩子对你并不敢太过靠近，你正愁以后该如何相处，此时$IN冷不丁对你问道：“你我素不相识，你为何救我？”",
		answer =
		{
			[1] = {"那幽冥教作恶多端，将你等无辜孩童囚于孤家集，既被我撞见了，岂有不救之理。", 2},
			[2] = {"当时也未曾多想，此事算是你我的缘分吧。", 0},
			[3] = {"与其便宜了幽冥教，倒不如为我所用了。", -2},
		}
	},
	[2] =
	{
		problem = "近日，你开始教$IN一些基本的武功，$IN倒也学得有模有样，只是练功的时候似有疑虑，你上前询问，$IN支吾半晌后问道：“学武功那么辛苦，你为什么学武功呢？”",
		answer =
		{
			[1] = {"当然是为了行侠仗义，除暴安良。", 2},
			[2] = {"学武功不仅可强身健体，亦可修身养性。", 0},
			[3] = {"江湖之中弱肉强食，不学好武功如何与人争斗。", -2},
		}
	},
	[3] =
	{
		problem = "某日，你正教$IN些基础功夫，$IN冷不丁地问道：“武功要练到什么程度，才算是最高境界呢？”",
		answer =
		{
			[1] = {"若能将一身武功报效于国家，救民于水火，方可为最高境界。", 2},
			[2] = {"武功的并无最高境界，只有不断地自我超越。", 0},
			[3] = {"自然是天下无敌，惟我独尊了。", -2},
		}
	},
	[4] =
	{
		problem = "你将$IN带回来并教他本事也有些时日了，决定带$HE外出历练一番，途中遇到一伙强盗调戏良家妇女，甚是嚣张，$IN有些害怕，扯着你的衣角问道：“我们现在该怎么办呢？”",
		answer =
		{
			[1] = {"路见不平拔刀相助，方是我江湖儿女的本色，待我去制服那帮暴徒，你趁机救下那女子。", 2},
			[2] = {"江湖险恶，我们在此静待片刻，伺机而动。", 0},
			[3] = {"这些不长眼的蟊贼，敢在这里放肆，待我杀他的个干净！", -2},
		}
	},
	[5] =
	{
		problem = "某日，你正教$IN一些江湖常识，$IN疑惑地问道：“正派的都是好人，邪派的都是坏人吗？”",
		answer =
		{
			[1] = {"正派虽不敢说都是光明磊落之人，但大多都心怀侠义，邪派或许有个别有情有义之人，但终非正道。", 2},
			[2] = {"正邪只在一念之间，没有绝对的善也没有绝对的恶，同样没有恶就没有善。", 0},
			[3] = {"嘁，正派大多是伪君子罢了，邪派倒是有很多真性情的人。", -2},
		}
	},
	[6] =
	{
		problem = "你教$IN读《论语》，当念到“有朋自远方来”时，$IN瞪大眼睛问到：“那到底什么是真正的朋友啊？”",
		answer =
		{
			[1] = {"同生死共患难，为朋友两肋插刀，才算得上是真正的朋友。", 2},
			[2] = {"以心换心，或能交到真心朋友，但人心隔肚皮，防人之心不可无啊。", 0},
			[3] = {"朋友？不过是逢场作戏，在江湖中只有这一身武功和手中长剑才是你真正的朋友。", -2},
		}
	},
	[7] =
	{
		problem = "近日，你觉察到$IN练功时常常心不在焉，几番询问，$HE方才说出心中疑虑：“假如你知道你的杀父仇人在哪，你会去找他报仇吗？”",
		answer =
		{
			[1] = {"君子报仇十年不晚，与其让仇恨占据你的人生，何不做些更有意义的事。", 2},
			[2] = {"你杀了仇人，你仇人的孩子又要杀了你为他的父母报仇，冤冤相报何时了啊。", 0},
			[3] = {"杀父之仇不同戴天，此仇不报枉为人子。", -2},
		}
	},
	[8] =
	{
		problem = "近日你收到一封英雄帖，邀请你参加郭大侠召开的英雄大会，你决定带$IN去见见世面，途中$IN突然问道：“怎样才算得上是大侠啊？”",
		answer =
		{
			[1] = {"自然是像郭大侠那样，为国为民，才算得上是真正的大侠。", 2},
			[2] = {"一众人口中的大侠也可能是某些人心中的大恶人，个中玄妙，还须你自己慢慢体会。", 0},
			[3] = {"大侠？做事无愧于心便可，要那虚名何用！", -2},
		}
	},
	[9] =
	{
		problem = "$IN在跟随你这些年，各方面也有了长足的进步，你觉得是时候告诉他一些江湖中的往事了，$IN听罢后问道：“那江湖到底是什么？”",
		answer =
		{
			[1] = {"人即是江湖，有人的地方就有江湖。", 2},
			[2] = {"每个人心中都有属于自己的江湖，你身在江湖后心中自有答案。", 0},
			[3] = {"江湖，便是纷争之地，野心家的名利场。", -2},
		}
	},
}

function InheritEventLayer:init()
	self._UI = require("Layer/InheritUI/InheritEventUI.lua").create()['root']
	self._UI:addTo(self)

	self.answer_1 = 0
	self.answer_2 = 0
	self.answer_3 = 0

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")
	self:setButton()
end

function InheritEventLayer:setButton()
	self.Panel_back:releaseFunc(function()
		--self:hide(true)
	end)
	self.Button_1:setVisible(true)
	self.Button_2:setVisible(true)
	self.Button_3:setVisible(true)
	self.Text_button_1:setVisible(true)
	self.Text_button_2:setVisible(true)
	self.Text_button_3:setVisible(true)

	self.Button_1:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		local inherit = User:getRoleAttr("inherit")
		inherit.zhengqi = inherit.zhengqi + self.answer_1
		inherit.eventCount = inherit.eventCount + 1
		RichPrint("main", "你的一番话语在" .. inherit.name .. "幼小的心中似乎产生了微妙的影响。")
	end)

	self.Button_2:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		local inherit = User:getRoleAttr("inherit")
		inherit.zhengqi = inherit.zhengqi + self.answer_2
		inherit.eventCount = inherit.eventCount + 1
		RichPrint("main", "你的一番话语在" .. inherit.name .. "幼小的心中似乎产生了微妙的影响。")
	end)

	self.Button_3:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		local inherit = User:getRoleAttr("inherit")
		inherit.zhengqi = inherit.zhengqi + self.answer_3
		inherit.eventCount = inherit.eventCount + 1
		RichPrint("main", "你的一番话语在" .. inherit.name .. "幼小的心中似乎产生了微妙的影响。")
	end)
end

-- 设置文本
function InheritEventLayer:setText(index)
	if index >= 1 and index <= 9 then
		local inherit = User:getRoleAttr("inherit")
		local role = User:getRole()
		local problem = clone(inheritEvent[index].problem)
		problem = string.gsub(problem, "$IN", inherit.name)
		problem = string.gsub(problem, "$HE", role:getHeOrHer(inherit.sex))
		self.Text_desc:setString(problem)

		self.Text_button_1:setString(inheritEvent[index].answer[1][1])
		self.answer_1 = inheritEvent[index].answer[1][2]

		self.Text_button_2:setString(inheritEvent[index].answer[2][1])
		self.answer_2 = inheritEvent[index].answer[2][2]

		self.Text_button_3:setString(inheritEvent[index].answer[3][1])
		self.answer_3 = inheritEvent[index].answer[3][2]

		-- 交换位置
		self:changeBtn()
		self:changeBtn()
		self:changeBtn()
	end
	self.Text_desc_0:setString("你思考了一会，回答道：")
	self:setButton()
end

-- 设置对话(非传承事件使用)
function InheritEventLayer:setTalk(problem, desc, answer)
	self.Text_desc:setString(problem)
	self.Text_desc_0:setString(desc)


	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Button_3:setVisible(false)
	self.Text_button_1:setVisible(false)
	self.Text_button_2:setVisible(false)
	self.Text_button_3:setVisible(false)

	self.Button_1:setPositionY(1000)
	self.Text_button_1:setPositionY(1000)
	self.Button_2:setPositionY(700)
	self.Text_button_2:setPositionY(700)
	self.Button_3:setPositionY(400)
	self.Text_button_3:setPositionY(400)

	if answer[1] then
		self.Text_button_1:setString(answer[1])
		self.Button_1:setVisible(true)
		self.Text_button_1:setVisible(true)
	end

	if answer[2] then
		self.Text_button_2:setString(answer[2])
		self.Button_2:setVisible(true)
		self.Text_button_2:setVisible(true)
	end

	if answer[3] then
		self.Text_button_3:setString(answer[3])
		self.Button_3:setVisible(true)
		self.Text_button_3:setVisible(true)
	end
end

-- 设置按钮
function InheritEventLayer:setButton1(func)
	self.Button_1:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		if func then
			func()
		end
	end)
end

function InheritEventLayer:setButton2(func)
	self.Button_2:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		if func then
			func()
		end
	end)
end

function InheritEventLayer:setButton3(func)
	self.Button_3:releaseFunc(function()
		PopupLayerController:hideLayer("InheritEventLayer", function(layer)
			self:hide()
		end)
		if func then
			func()
		end
	end)
end

-- 交换位置
function InheritEventLayer:changeBtn()
	local btn =
	{
		self.Button_1,
		self.Button_2,
		self.Button_3,
	}
	local text =
	{
		self.Text_button_1,
		self.Text_button_2,
		self.Text_button_3,
	}

	local num1 = math.random(1, 3)
	local num2 = math.random(1, 3)

	local x,y = btn[num1]:getPosition()
	btn[num1]:setPosition(btn[num2]:getPosition())
	text[num1]:setPosition(text[num2]:getPosition())
	btn[num2]:setPosition(x, y)
	text[num2]:setPosition(x, y)
end

Helper:classDefNodeGetInstance(InheritEventLayer)

return InheritEventLayer0000