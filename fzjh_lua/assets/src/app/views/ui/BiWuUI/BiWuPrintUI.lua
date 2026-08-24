local Resource = require("app.Resource")
local BiWu = require("app.models.BiWu.BiWu")
local BiWuPrintUI = class("BiWuPrintUI",cc.Layer)

function BiWuPrintUI:createInRunningScene()
	local layer = BiWuPrintUI:getInstance()

	return layer
end

function BiWuPrintUI:create(  )
	local p = BiWuPrintUI:new()
	p:init()
	return p
end

function BiWuPrintUI:init()
	self._UI = require("Layer.BiWuUI.BiWuPrintUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self._textLayer = cc.Node:create()
	self:addChild(self._textLayer)

	self.exitlayer = nil
	self._index = 1

	self.distance = 0

	self._isShowProps = nil
	self:setSelfAndChildrenCascadeOpacityEnabled(true)

	--
	self:hideButtons()

	self:controllShow()

	self._isShowButtonsAnim = false

	------用来保存创建好的Panelitem
	self.Panel_itemArry = {}

	----点击了无中生有或者灵机一动的标识
	self._wuZhongShengYouLingJiYiDong = nil

	-----这次显示按钮的个数
	self._nowUseCardCount = nil
end

--初始化六个按钮的位置button的位置
function BiWuPrintUI:initButtonPosition(func)
	self.Panel_8.Button_Prop3:setVisible(false)
	self.Panel_8.Button_Prop3:setPosition(540.0000, 450.0000)

	self.Panel_8.Button_Prop2:setVisible(false)
	self.Panel_8.Button_Prop2:setPosition(540.0000, 600.0000)

	self.Panel_8.Button_Prop1:setVisible(false)
	self.Panel_8.Button_Prop1:setPosition(540.0000, 750.0000)

	self.Panel_8.Button_Prop6:setVisible(false)
	self.Panel_8.Button_Prop6:setPosition(740.0000, 450.0000)

	self.Panel_8.Button_Prop5:setVisible(false)
	self.Panel_8.Button_Prop5:setPosition(740.0000, 600.0000)

	self.Panel_8.Button_Prop4:setVisible(false)
	self.Panel_8.Button_Prop4:setPosition(740.0000, 750.0000)

	if func then
		func()
	end
end

function BiWuPrintUI:createRandomButtons(count)
	local Jinnang = {

		[1] = {

			name = "RED暗箭伤人" ,
			callback = function( me , he , renqi_delta )
				--减少敌人气血
				local str ="WHT你左手微动，趁$N WHT不注意往他胸口飞出几枚暗箭，他淬不及防被击中，鲜血不断冒出。看来你胜券大握，胜利在望了。"
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				local delta_qi = math.floor( he:getAttr( "qi" ) * 0.3 )

				PopText( he.name .. "受到了" .. tostring( delta_qi ) .. "点伤害" )
				he:setAttr( "qi" , he:getAttr( "qi" ) - delta_qi )

				--更新气血条
				self:setQiXueNeiLiPersentOfOther( he )

				local result = {
					renqi_delta = -0.3,
				}
				return result
			end,
		},
		[2] = {
			name = "DWT灵丹妙药" ,
			callback = function( me , he , renqi_delta )
				local str =  "WHT你从怀中掏出一粒红色丹药，服了下去，你只觉气血一阵翻腾，身上的伤势好了大半。"
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				me:setAttr( "qiPercent" , me.qiPercent + 0.5 )

				local delta_qi = math.floor( me.qiMax * 0.5 )
				me:setAttr( "qi" , me.qi + delta_qi )

				PopText( "气血 +" .. tostring( delta_qi ) )

				self:setQiXueNeiLiPersentOfMine( me )
				return nil
			end,
		},
		[3] = {
			name = "DWT打赏换人" ,
			callback = function( me , he , renqi_delta )
				local role = User:getRole()
				local str = ( "WHT你偷偷摸出些银两交给了WHT$NWHT，WHT$NWHT会意一笑，随即弃权，台下又上来一人。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				if tonumber(role:getAttr("money")) < 2000 then
					PopText("你的金钱不够你打赏换人，失败！")
					return nil
				else
					self:printItemEffectsText(str)
					PopText( "碎银 -2000" )
					role:addAttr( "money" , -2000 )

					return { act = "换人" }
				end
			end,
		},
		[4] = {
			name = "DWT巧舌如簧" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 1 , 100 )
				local str = ""
				------------------------lijie  2016/09/23  更改了概率
				if rnd <= 40 then
					--狂暴
					str = ( "WHT你将关于WHT$NWHT的几桩丑闻尽数盘出，$N愤怒异常，直言要与你决一生死，看来接下来将是一场恶战了。")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
					he.attackFactor = 1.3
					return nil
				else
					str = ( "WHT你将关于WHT$NWHT的几桩丑闻尽数盘出，$N羞愧难当，支支吾吾不敢反驳，只得悻悻下了擂台，台下又上来一人。")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
					return { act = "换人" }
				end
			end,
		},
		[5] = {
			name = "RED暗中下毒" ,
			callback = function( me , he , renqi_delta )
				local str = ( "WHT你掏出一瓶毒药涂抹在你的兵器上，涂擦了毒药的武器在阳光的照耀下散发出妖异的紫色，待会定能让$NWHT吃尽苦头。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				
                if me:getCurrWeaponType() == "拳脚" then
					PopText( "你没有装备兵器" )
					
				else
					self:printItemEffectsText(str)
					me:setFlag( "暗中下毒" , true )
					return {
						renqi_delta = -0.5
					}
				end
				return nil
			end,
		},
		[6] = {
			name = "DWT护心铜镜" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你摸出一面护心镜放在胸口，这下你的防护力提升了不少，这场战斗你更有把握获胜了！")

				--防御增加30%等同于敌人攻击减少30%
				he.attackFactor = 0.5

				PopText( "你的防御变高了" )

				return nil
			end,
		},
		-- -----------------------------------------------------------------------
		[7] = {
			name = "DWT九转大还" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你摸出一颗九转大还藏于袖中，此物可活死人，肉白骨，即使待会不敌，亦可服下此物，再战一回！")
				me:setFlag( "九转大还" , true )
				return nil
			end,
		},
		[8] = {
			name = "DWT金蝉脱壳" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你趁众人不意，偷偷下了擂台，武馆管家正要核对名单，但台下观众纷纷吵闹着要看下一场对决，武馆管家只好作罢。")

				PopText("你偷偷下了擂台")
				return { act = "下台" }
			end,
		},
		[9] = {
			name = "RED借刀杀人" ,
			callback = function( me , he , renqi_delta )
				local str = "WHT你对着$NWHT哈哈一笑：看你手上兵器还不错,拿来给我看看。"
				str = string.gsub(str,"$N",tostring(he:getName()))
				if he:getCurrWeaponType() == "拳脚" then
					PopText( "对手没有装备兵器,借刀失败！" )
				else
					PopText( "你获得对手装备的兵器" )
					self:printItemEffectsText( str )
				end
				return { renqi_delta = -0.3 , act = "拿对手武器杀对手" }
			end,
		},
		[10] = {
			name = "DWT以逸待劳" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你运转着内力，似乎进入了一种微妙的境界，内力自丹田内不断涌出，似乎无穷无尽一般，看来这场对决你不用担心内力的消耗了。")

				me.neiliCostScale = 0.0
				me:setFlag( "以逸待劳" , true )
				return nil
			end,
		},
		[11] = {
			name = "DWT刀刀入肉" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你内力运至周天各脉，突然感觉全身气力大增，身体进入了一种全新的状态，一拳一脚皆包含巨大威力，不过内力损耗亦是巨大！")

				me:setAttr( "jiaLi" , math.floor( me:getFinalAttr( "jiaLi" ) * 1.5 ) )
				me.neiliCostScale = 2.0
				return nil
			end,
		},
		[12] = {
			name = "RED趁火打劫" ,
			callback = function( me , he , renqi_delta )
				local str  = ( "WHT你含笑看着$N一身华服，心中暗暗决定，待会若是战而胜之，定好好威胁勒索一笔。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				--防御增加30%等同于敌人攻击减少30%
				return {
					renqi_delta = -0.2 ,
					victoryCallback = function()
						PopText( "你打败了他，威胁索要了10000碎银" )
						User:getRole():addAttr( "money" , 10000 )
						self:delayFunc(1,function ()
							self:winResultDispose(me,he)
						end)
					end
				}
			end,
		},
		[13] = {
			name = "DWT步步高升" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText( "WHT你忽生异感，心中渴望与人厮杀一番，一股昂然的战意笼罩了你的全身，越战则越强，愈胜则愈勇。")

				-- me.attackFactor = 1.2--临时解决方案

				me:setFlag( "步步高升" , true )

				return { bubugaosheng = 1 }
			end,
		},
		[14] = {
			name = "RED浑水摸鱼" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 500 , 2000 )
				self:printItemEffectsText("WHT旁边的擂台上爆发了一声巨响，台上观众纷纷向那边看去，你一个妙手空空，从数个观众那里偷得了".. tostring( rnd ) .. "银两。")

				PopText( "碎银 +" .. rnd  )
				User:getRole():addAttr( "money" , rnd )
				return { renqi_delta = -0.1 }
			end,
		},
		[15] = {
			name = "DWT打草惊蛇" ,
			callback = function( me , he , renqi_delta )
				local str = ("WHT你使眼色叫小弟向$NWHT丢了一条毒蛇，$NWHT吓得跳下了擂台，台上只余一条毒蛇。你哈哈笑道：胆小鼠辈，看我的！")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)

				-- 清空he
				-- table.clean(he)
				-- 创建草惊蛇
				he.noWeapon =  true
				Helper:tableCover(he, self:createCaoJingShe())

				-- 记下草惊蛇
				-- local fightAllData = BiWu:getfightAllData()
				-- fightAllData.user = clone(he)

				return { act = "打草惊蛇" }
			end,
		},
		[16] = {
			name = "DWT瞒天过海" ,
			callback = function( me , he , renqi_delta )
				local role = User:getRole()
				if tonumber(role:getAttr("money")) < 2000 then
					PopText("你的金钱不够你瞒天过海，失败！")
					return nil
				else
					self:printItemEffectsText("WHT你掏出一个钱袋塞到武馆管家怀中，武馆管家笑眯眯地朝你使了一个眼色，你会意一笑，微一点头，心中顿时明白，这场已无悬念。")
					role:addAttr( "money" , -2000 )
					PopText("碎银 - ".."2000")
					return {
						loseCallback = function()
						----------弹出字幕叠加了
							self:delayFunc(1,function ()
								PopText( "你虽然被打败了，但仍然被判为胜利" )
							end)
							self:winResultDispose( me , he )
						end
					}
				end
				return nil
			end,
		},
		[17] = {
			name = "RED笑里藏刀" ,
			callback = function( me , he , renqi_delta )
				local str = ("WHT你面带微笑走向$NWHT，向其拱了拱手，$NWHT亦向你还礼，殊不知他已经中了你的诡毒，护体内功将会大打折扣。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				--防御增加30%等同于敌人攻击减少30%
				me.attackFactor = 1.3
				return { renqi_delta = -0.3 }
			end,
		},
		[18] = {
			name = "RED顺手牵羊" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 500 , 1000 )

				local str = ("WHT$NWHT正在登台，你走上前去搀扶，$NWHT连连告谢，殊不知你一个妙手空空盗走了$NWHT的"..rnd.."银子。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				PopText( "碎银 +" .. rnd  )
				User:getRole():addAttr( "money" , rnd )
				return { renqi_delta = -0.3 }
			end,
		},
		[19] = {
			name = "DWT乾坤一掷" ,
			callback = function( me , he , renqi_delta )
				local role = User:getRole()
				local dropMoeny = math.floor(role:getAttr( "money" )%10000)
				local dropDamage = math.floor( dropMoeny/10 )
				local str = ("WHT你单手一翻，摸出数枚银子，冷笑一扬，银子飞速打向$NWHT,$NWHT受到了"..dropDamage.."点伤害！")
				str = string.gsub(str,"$N",tostring(he:getName()))
				if tonumber(role:getAttr("money")) < dropMoeny then
					PopText("你的金钱不够你乾坤一掷，失败！")
				else
					self:printItemEffectsText(str)
					PopText( "碎银 -" .. dropMoeny  )
					role:addAttr( "money" , -dropMoeny )
					he:addAttr( "qi" , -tonumber(dropDamage) )
					--更新气血条
					self:setQiXueNeiLiPersentOfOther( he )
				end

				return nil
			end,
		},
		[20] = {
			name = "RED求助师门" ,
			callback = function( me , he , renqi_delta )
				local  str  = ("WHT为了这一战，你苦苦相求你师傅，你师傅终于答应为你与$NWHT先行交手一二试其深浅，这一次你获胜的几率大大提升！")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				return { act = "求助师门" , renqi_delta = -0.3 }
			end,
		},
		[21] = {
			name = "DWT指桑骂槐" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 1 , 100 )
				if rnd < 25 then
					local str = ("WHT你对$NWHT冷嘲暗讽，言辞犀利，$NWHT十分地羞愧，竟不敢上台，主动弃权了，你毫发无损地获得了胜利。")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
					return { act = "直接胜利" }
				elseif rnd < 50 then
					local str = ("WHT你对$NWHT冷嘲暗讽，言辞犀利，$NWHT羞愧难当，对你恨之入骨，他死死地盯着你，看来他已经失去了理智，这对你来说是个好消息。")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
					he.dodge = 0.5
					he.parry = 0.5
				elseif rnd < 75 then
					local str = ("WHT你对$NWHT冷嘲暗讽，言辞犀利，$NWHT却无动于衷，冷笑一声，摆了一个架势，便要与你相斗！")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
				else
					local str = ("WHT你对$NWHT冷嘲暗讽，言辞犀利，$NWHT却反数落你数桩丑闻，这深深地刺激了你，你此时此刻只想将他打趴，其他的不做多想，这对于比武来说可是大忌。")
					str = string.gsub(str,"$N",tostring(he:getName()))
					self:printItemEffectsText(str)
					me.dodge = 0.5
					me.parry = 0.5
				end

				return nil
			end,
		},
		[22] = {
			name = "DWT灵机一动" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText("WHT你灵机一动，各种计谋顿时涌上心头，哈哈哈！")
				return { act = "灵机一动" }
			end,
		},
		[23] = {
			name = "DWT无中生有" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText("WHT有之所始，以无为本。将欲全有，必反於无也。你打算再想想计谋。")

				return { act = "无中生有" }
			end,
		},
		[24] = {
			name = "DWT饮鸩止渴" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText("WHT你服下了手中的不死丸 ，此丸可使你身中剧毒，却能让你受多重的伤也能继续战斗不死，但只能维系一小段时间！")

				me.qi = 1
				me.qiPercent = 0.01
				PopText( "你中了剧毒" )

				me:setFlag( "饮鸩止渴" , true )

				self:refreshMineAndOtherStatus()

				return nil
			end,
		},
		[25] = {
			name = "DWT背水一战" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText("WHT你身上气势一凝，爆发出一声大喝，此战避无可避，退无可退，背水一战，只在今日！")

				me.attackFactor = 2.0
                me:prepareSkill( "qinggong" , nil )
                me:prepareSkill( "zhaojia" , nil )
                
				PopText( "伤害提高100%" )
				return nil
			end,
		},
		[26] = {
			name = "RED釜底抽薪" ,
			callback = function( me , he , renqi_delta )
				local role = User:getRole()
				local str
				if he:getCurrWeaponType() == "拳脚" then
					str = ("WHT你从怀里摸出了两锭银两偷偷塞入武馆管家怀中，管家微微一笑，正准备找了个借口将$NWHT的兵器收走，却没想到此人竟是空手！")
				else
					str = ("WHT你从怀里摸出了两锭银两偷偷塞入武馆管家怀中，管家微微一笑，找了个借口将$NWHT的兵器收走了！")
				end
				str = string.gsub(str,"$N",tostring(he:getName()))
				if tonumber(role:getAttr("money")) < 200 then
					PopText("你的金钱不够你釜底抽薪，失败！")
					return nil
				else
					self:printItemEffectsText(str)
					he.noWeapon = true 
					if he.noWeapon == true and he:getCurrWeaponType()~="拳脚" then --使用锦囊直接实现功能
						if he.shenBingweapon  then 
					 		he.shenBingweapon = {}
						end
						he:setEquipByName( "weapon" , nil )	
					end
					role:addAttr( "money" , -200 )
					PopText( "银两 -200" )

					return { renqi_delta = -0.3 }
				end
		
			end,
		},
		[27] = {
			name = "HIG一丝不挂" ,
			callback = function( me , he , renqi_delta )
				self:printItemEffectsText("WHT你大喝一声，将身上衣服尽数褪去，台下观众发出阵阵呐喊，此战若胜，你的人气将成倍提升。")

				he.attackFactor = 1.3
				PopText( "防御降低30%" )
				return { renqi_delta = 1 }
			end,
		},

		[28] = {
			name = "RED摇尾乞怜" ,
			callback = function( me , he , renqi_delta )
				local str = ""
				local act = nil
				if math.random( 1 , 100 ) > 50 then
					str =("WHT你泪流满面地向$NWHT述说你的艰辛，$NWHT觉得你十分可怜，于是主动弃权，然而台下观众十分不满，你的人气锐减了！")
					act = "直接胜利"
				else
					str =("WHT你泪流满面地向$NWHT述说你的艰辛，$NWHT却无动于衷，这使得你大为丢脸，你的人气锐减了！")
				end
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				return {
					renqi_delta = -0.2 ,
					act = act,
				}
			end,
		},
		[29] = {
			name = "DWT神兵利器" ,
			callback = function( me , he , renqi_delta )
				local str = ("WHT你将手中小瓶内藏之物，尽数倒向$NWHT，$NWHT绽放出赤色光芒，似乎比之前厉害了不少。")
				str = string.gsub(str,"$N",tostring(me:getCurrWeaponName()))
				if me:getCurrWeaponType() == "拳脚" then
					PopText( "你没有装备兵器" )
				else
					self:printItemEffectsText(str)
					me.attackFactor = 1.3
					PopText( "你的兵器伤害变高了" )
				end
				return nil
			end,
		},
		[30] = {
			name = "DWT攀亲带故" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 1 , 100 )
				local  str = ""
				if rnd < 25 then
					str = ("WHT你冲着$NWHT拱了拱手：这不是$M$NWHT么，我俩上次还一起喝酒来着，可曾记得？$NWHT摸了摸头，表示不认识你。")
				elseif rnd < 50 then
					str = ("WHT你冲着$NWHT拱了拱手：这不是$M$NWHT么，我俩上次还一起喝酒来着，可曾记得？$NWHT冷笑一声: 你这等鸡鸣狗盗之徒，我怎么会与你为伍！休要多言！放马过来！台下一偏哗然")
					return { renqi_delta = -0.2}
				elseif rnd < 75 then
					str = ("WHT你冲着$NWHT拱了拱手：这不是$M$NWHT么，我俩上次还一起喝酒来着，可曾记得？$NWHT微微一笑：交情归交情，不过我们还是手上见个真章再说吧！")
				else
					str = ("WHT你冲着$NWHT拱了拱手：这不是$M$NWHT么，我俩上次还一起喝酒来着，可曾记得？$NWHT: 哈哈哈，原来是故人，如此甚好，此宝刀借你一用，当是为君助威了。你面露难色，硬着头皮拿着这把宝刀作战")

					me:addItemCount("item01_03",1)
					local items = me:getItemsWithItemId("item01_03" )
					me:setEquipByName("weapon", items[1] )
				end
				str = string.gsub(str,"$N",tostring(he:getName()))
				str = string.gsub(str,"$M",tostring(he:getFamilyName()))
				self:printItemEffectsText(str)
				return nil
			end,
		},
		[31] = {
			name = "DWT打情骂俏" ,
			callback = function( me , he , renqi_delta )
				local rnd = math.random( 1 , 100 )
				local str = ""
				if rnd < 33 then
					str = ("WHT你淫笑道：哪里来的小娘子，好生俊俏！$NWHT大怒道：你是在找死！$NWHT撸起双袖，死死盯着你，摆出一副与你不死不休的架势！")

					he.dodge = 0.7
					he.parry = 0.5
				elseif rnd < 66 then
					str = ("WHT你淫笑道：哪里来的小娘子，好生俊俏！但$NWHT面无表情，似乎无动于衷。")
				else
					str = ("WHT你淫笑道：哪里来的小娘子，好生俊俏！$NWHT冷笑道：看你身虚体弱，怕是禁不起几回折腾，去补补再来把。你不由得大为愤怒，世上居然有如此厚颜无耻之人，你已经忍不住想动手了！")

					me.dodge = 0.7
					me.parry = 0.5
				end

				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)

				return nil
			end,
		},
		[32] = {
			name = "DWT以彼之矛" ,
			callback = function( me , he , renqi_delta )
				local str = ""
				-- str = ("WHT$NWHT对着你大喝一声：今日便让你尝尝我这$JWHT的厉害！你莞尔一笑，摆出一个架势：哦？我也会$JWHT，就让我们看看谁的更厉害！")
				str = ("你轻哼一声，缓缓说道：今日我便以你擅长的方式战胜你，让你晓得我的厉害！话音刚落，拿出一把$JWHT，摆开了架势。")			
				local currWeaponName = he:getCurrWeaponType()	--当前武功名字 getCurrSkillName  现改为兵器
				if currWeaponName == "拳脚" then
					-- currSkillName = "基本拳脚"
					str = ("你轻哼一声，缓缓说道：今日我便以你擅长的方式战胜你，让你晓得我的厉害！话音刚落，双手握拳，摆开了架势。")
				end
				-- str = string.gsub(str,"$N",tostring(he:getName()))
				str = string.gsub(str,"$J",tostring(currWeaponName))

				self:printItemEffectsText(str)

				return { act = "获取对手拳脚武器" }
			end,
		},
		[33] = {
			name = "DWT垂死挣扎" ,
			callback = function( me , he , renqi_delta )
			local str = ""
				str = ("WHT你暗运一口真气，护住身上各处罩门，这一口真气可使你在临危时爆发一次，若不能击溃敌人，你必败无疑！")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				me:setFlag( "垂死挣扎" , true)
				return nil
			end,
		},
		[34] = {
			name = "HIG让你三招" ,
			callback = function( me , he , renqi_delta )
			local  str  = ""
				str = ("WHT你面露微笑：这位少侠，看你初来乍到，我就让你三招，以尽地主之谊。台下爆发出巨大的叫好声，你的人气爆长了。")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)
				me:setFlag( "让你三招" , 3)
				return { renqi_delta = 1.0 }
			end,
		},
		[35] = {
			name = "DWT贴身肉搏" ,
			callback = function( me , he , renqi_delta )
				local str = ""
				str = ("WHT你对着$NWHT大喝一声 可敢与我徒手一博！$NWHT冷笑一声 有何不敢！ 你俩赤手空拳站在擂台之上，只待一战！")
				str = string.gsub(str,"$N",tostring(he:getName()))
				self:printItemEffectsText(str)		
				local currWeaponName1 = me:getCurrWeaponType()
				local currWeaponName2 = he:getCurrWeaponType()
				if currWeaponName1 == "拳脚" then
					PopText( "没有装备武器！" )
				else
					PopText( "你卸下了兵器" )
				end
				if currWeaponName2 == "拳脚" then
					PopText( he:getName() .. "没有装备武器！" )
				else
					PopText( he:getName() .. "卸下了兵器" )
				end
				me.noWeapon = true
				he.noWeapon =  true	
				if he.noWeapon == true and he:getCurrWeaponType()~="拳脚" then --使用锦囊直接实现功能
						if he.shenBingweapon  then 
					 		he.shenBingweapon = {}
						end
						he:setEquipByName( "weapon" , nil )	
				end
				if me.noWeapon == true and me:getCurrWeaponType()~="拳脚" then 
					me:setEquipByName( "weapon" , nil )
				end

				return nil
			end,
		},


		-- [36] = {
		-- 	name = "DWT借尸还魂" ,
		-- 	callback = function( me , he , renqi_delta )
		-- 		-- self:printItemEffectsText("WHT你对自己使用了苗疆控魂蛊，若在短时间内被人重伤，将血涂于敌人身上，可控制敌人的身体为己所用。")
		-- 		-- return {
		-- 		-- 	victoryCallback = function()
		-- 		-- 		self:winResultDispose(me,he)
		-- 		-- 	end
		-- 		--  }
		-- 		self:printItemEffectsText("WHT你对自己使用了苗疆控魂蛊，在战斗不济时，会用此术偷取对手些许血量！")
		-- 		me:setFlag( "借尸还魂" , true )
		-- 		return nil
		-- 	end,
		-- },
	}

	local function get_one_card( usedCards , maxcount )
			repeat
				local valid = true

				local card_index = math.random( 1 , maxcount )

				for i=1,#usedCards do
					if usedCards[i] == card_index then
						--重复
						valid = false
						break
					end
				end

				if valid == true then
					return card_index
				end

			until( #usedCards == maxcount )
	end

	local function get_some_card(usedCards , maxcount, count)
		local retArray = {}
		for i=1, count do
			local cardIndex = get_one_card(usedCards , maxcount)
			 if cardIndex then
			 	if Game:isTesting() then
					local DebugHelper = require("app.views.layer.DebugLayer.DebugHelper")
					if DebugHelper:getLunJianJinNangId() then
						local index = DebugHelper:getLunJianJinNangId()
						table.insert(usedCards, index)
						table.insert(retArray, index)
					else
						table.insert(usedCards, cardIndex)
				 		table.insert(retArray, cardIndex)
					end
			 	else
				 	table.insert(usedCards, cardIndex)
				 	table.insert(retArray, cardIndex)
				end
			else
				break
			end
		end
		return retArray, #retArray
	end

	local fightAllData = BiWu:getfightAllData()

	if fightAllData.oneFight.usedCards == nil then
		fightAllData.oneFight.usedCards = {}
		BiWu:savefightAllData( fightAllData )
	end

	local usedCards = clone( fightAllData.oneFight.usedCards )

	local JinnangCount = #Jinnang

	local cardIndexArray, cardCount = get_some_card(usedCards, JinnangCount, count)
	local cards = {}

	for i, cardIndex in ipairs(cardIndexArray) do
		Jinnang[cardIndex].index = cardIndex
		table.insert(cards, Jinnang[cardIndex])
	end
	---这次显示按钮的个数
	self._nowUseCardCount = #cards
	-- --------计谋小于3个  或者  大于 3  小于 6个 的提示
	if (cardCount >= 1 and cardCount < 3) or (cardCount > 3 and cardCount < 6 ) then
		PopText("36计，你已经使用的差不多了")
	end

	self:setButtonProp(cards)

end



function BiWuPrintUI:show(type,ControllLayer)
	-- MainControllLayer = ControllLayer
	self:setOpacity(255)
	self.distance = 0
	self._index = 1
	self._type = type
	self:setVisible(true)
	self._isShowProps = false
	self._isShowButtonsAnim = false
	----------点击了无中生有、灵机一动的标识
	self._wuZhongShengYouLingJiYiDong = nil

	---战斗结束点了逃跑，这次战斗不能再次点击
	self._buttonRun = nil

	self.Panel_me:setOpacity(255)
	self.Panel_he:setOpacity(255)
	self.Panel_he:setVisible(false)
	self.Panel_me:setVisible(false)

	-----初始化六个按钮的位置
	self:initButtonPosition()

	self:refreshMineAndOtherStatus()

end

function BiWuPrintUI:clearPaneItem()
	self._textLayer:removeAllChildren()
	self.Panel_itemArry = {}
	self.distance = 0
	self._index = 1
end

----控制显示
function BiWuPrintUI:controllShow()
	if self._isShowProps == true then
		self.Panel_8:setVisible(true)
		self.Panel_he:setVisible(true)
		self.Panel_me:setVisible(true)

		-- self.Panel_8.Button_Prop1:setVisible(true)
		-- self.Panel_8.Button_Prop2:setVisible(true)
		-- self.Panel_8.Button_Prop3:setVisible(true)
		if self._isShowButtonsAnim == false then
			self:showButtonsAnim()
			self._isShowButtonsAnim = true
		end
	else
		self.Panel_8:setVisible(false)
		-- self.Panel_he:setVisible(false)
		-- self.Panel_me:setVisible(false)
		self.Panel_8.Button_Prop1:setVisible(false)
		self.Panel_8.Button_Prop2:setVisible(false)
		self.Panel_8.Button_Prop3:setVisible(false)
		self.Panel_8.Button_Prop4:setVisible(false)
		self.Panel_8.Button_Prop5:setVisible(false)
		self.Panel_8.Button_Prop6:setVisible(false)
	end
end

function BiWuPrintUI:hide( needAnim )
	self._isShowProps = false

	self.Panel_he:setVisible(false)
	self.Panel_me:setVisible(false)

	if needAnim == nil or needAnim == false then
		self:setVisible(false)
	else
		self:fadeOutSelf(self)
	end
end

function BiWuPrintUI:fadeOutSelf(Node)
	local animDuration = 0.5
	local fightAllData = BiWu:getfightAllData()
	local  str  = ""
	if fightAllData.allBattleName then
		if fightAllData.result == "win" then
			PopText("你战胜了"..fightAllData.allBattleName[1])
			if fightAllData.oneFight.win_points then
				if fightAllData.oneFight.win_points == 0 then
					str ="这次战斗你没有赢得人气"
				else
					str ="这次战斗你赢了"..tostring(math.floor(fightAllData.oneFight.win_points)).."人气"

					-- fightAllData.add_renqi = fightAllData.add_renqi + fightAllData.oneFight.win_points
				end
			end
		else
			PopText("你败给了"..fightAllData.allBattleName[1])
			if fightAllData.oneFight.lose_points then
				if fightAllData.oneFight.lose_points == 0 then
					str ="这次战斗你没有失去人气"
				else
					str ="这次战斗你输掉了"..tostring(math.floor(fightAllData.oneFight.lose_points)).."人气"
					-- fightAllData.add_renqi = fightAllData.add_renqi - fightAllData.oneFight.win_points
				end
			end
		end

	end
	self:delayFunc(1,function()
		PopText(str)
	end)
	Node:runAction(cc.Sequence:create(YXEaseAction:create(cc.FadeOut:create(animDuration), Sine_EaseOut),
		cc.CallFunc:create(
			function()
				self:setVisible(false)
			end)) )
end


function BiWuPrintUI:printText(Text,type)
	if type == nil then
		local DefaultBattleText = BiWu:getDefaultBattleText()
		self.Panel_itemArry = BiWu:createTextFromArray(self._textLayer, self.Panel_item, DefaultBattleText)
	end

	if Text then
		local arry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, Text)
		for i,v in ipairs(arry) do
			table.insert(self.Panel_itemArry,arry[i])
		end
		arry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, {{"你心念一动，决定："}} )
		for i,v in ipairs(arry) do
			table.insert(self.Panel_itemArry,arry[i])
		end
	end

	self:playTextAnim()
end


function BiWuPrintUI:printItemEffectsText(Text,func)
	--邀战
	--邀战
	local texts =
	{
		[1] =
		{
			[1] = Text,
		}
	}

	self.Panel_itemArry = BiWu:createTextFromArray(self._textLayer, self.Panel_item, texts)

	self._index = 1

	self:playTextAnim()
end


function BiWuPrintUI:playTextAnim()
	self._isShowProps = false

	local count = #self.Panel_itemArry

	while self._index <= count + 1 do

		local currIndex = self._index

		self:delayFunc(self._index, function()
			if self.Panel_itemArry[currIndex] then
				BiWu:runActionText(self.Panel_itemArry[currIndex], currIndex, 2, self.distance,true)
				--保存上一个文本出现的高度
				local height = self.Panel_itemArry[currIndex]:getRichText():getNewContentSizeHeight()
				self.distance = self.distance + height
			else
				--加一个条件，控制在战斗结束后不要显示出来
				if BiWu.fightMark ~= 2 then
					self._isShowProps = true
				end

				self:controllShow()
			end
		end)

		self._index = self._index + 1
	end
end

function BiWuPrintUI:refreshMineAndOtherStatus()
	----在显示之前把对手和自己的信息传递过去
	local fightAllData = BiWu:getfightAllData()
	local role
	if fightAllData.role then
		role = Role:create(fightAllData.role)
	else
		role = User:getRole()
	end
	
	if role:getCurrQiMax() <  role:getAttr("qi")  then
		role:setAttr("qi",role:getCurrQiMax())
	end
	-----显示这次战斗中自己的气血状态
	self:setQiXueNeiLiPersentOfMine(role)
	BiWu:savefightAllData(fightAllData)
	------对手的气血状态
	if fightAllData.user then
		local player = Role:create(fightAllData.user)
		self:setQiXueNeiLiPersentOfOther(player)
	end
end

function BiWuPrintUI:setExitLayer(layer)
	self.exitlayer = layer
end

-------------------------------------------------
--告辞、激战、挑衅的调用
function BiWuPrintUI:beyBeyButton()
	-- local defaultText = BiWu:getDefaultText()
	-- self:printText(ByeByeText)

end


--战斗入口
function BiWuPrintUI:battleButton()
	self._textLayer:setOpacity(255)
	self._textLayer:removeAllChildren()

	self:refreshMineAndOtherStatus()

	self:createRandomButtons(3)

	local Text = BiWu:_getBattleReplyText()


	self:printText(Text)

	Audio:playMusic( "biwu_shangtai" )
end

function BiWuPrintUI:provokeButton()
	local Text = BiWu:_getProvokeReplyText()
	self:printText(Text)
end

--挑战入口
function BiWuPrintUI:tiaoZhan()
	self._textLayer:setOpacity(255)
	self._textLayer:removeAllChildren()

	self:refreshMineAndOtherStatus()

	self:createRandomButtons(3)

	local Text = BiWu:_getTiaoZhanText()
	self:printText(Text,"挑战")

	Audio:playMusic( "biwu_shangtai" )
end


---------------------------------------------------------------------------------------------------------------------------
----道具使用

--设置我的 气血值  and  名字
function BiWuPrintUI:setQiXueNeiLiPersentOfMine(player)
	local QiPercent, CurrQiPercent, NlPercent
	local role

	if player == nil then
		role= User:getRole()
	else
		role = player
	end

	QiPercent = math.floor(role:getAttr("qi")/role:getFinalAttr("qiMax")*100)
	CurrQiPercent = math.floor(Helper:getDef(role:getAttr("qiPercent"), 1)*100)
	NlPercent = math.floor(role:getAttr("neili")/role:getFinalAttr("neiliMax")*100)

	if role.name then
		self.Panel_me.Text_2:setString(role.name)
	end
	self.Panel_me.Panel_1.LoadingBar_2:setPercent(CurrQiPercent)
	self.Panel_me.Panel_1.LoadingBar_3:setPercent(QiPercent)
	self.Panel_me.Panel_2.LoadingBar_3:setPercent(NlPercent)
	
	self.Panel_me.Panel_1.Text_num:setString(math.floor(role:getAttr("qi")).."/"..math.floor(role:getCurrQiMax()))
	self.Panel_me.Panel_2.Text_num:setString(math.floor(role:getAttr("neili")).."/"..math.floor(role:getFinalAttr("neiliMax")))
end

--设置我的 气血值  and  名字
function BiWuPrintUI:setQiXueNeiLiPersentOfOther(player)
	local QiPercent, CurrQiPercent, NlPercent
	local role
	if player == nil then
		role= Role:create()--User:getRole()
		print("...new  player")
	else
		role = player
	end
   
	QiPercent = math.floor(role:getAttr("qi")/role:getFinalAttr("qiMax")*100)
	CurrQiPercent = math.floor(Helper:getDef(role:getAttr("qiPercent"), 1)*100)
	NlPercent = math.floor(role:getAttr("neili")/role:getFinalAttr("neiliMax")*100)
    
	if role.name then
		self.Panel_he.Text_3:setString(role.name)
	end
	self.Panel_he.Panel_3.LoadingBar_2:setPercent(CurrQiPercent)
	self.Panel_he.Panel_3.LoadingBar_3:setPercent(QiPercent)
	self.Panel_he.Panel_4.LoadingBar_3:setPercent(NlPercent)
    
	self.Panel_he.Panel_3.Text_num:setString(math.floor(role:getAttr("qi")).."/"..math.floor(role:getCurrQiMax()))
	self.Panel_he.Panel_4.Text_num:setString(math.floor(role:getAttr("neili")).."/"..math.floor(role:getFinalAttr("neiliMax")))
end


function BiWuPrintUI:markCardIndexUsed( card_index )
	--把当前选中的按钮放入本次上台队列中，本次上台不会再抽到了
	local fightAllData = BiWu:getfightAllData()
	if fightAllData.oneFight.usedCards == nil then
		fightAllData.oneFight.usedCards = {}
	end
	table.insert( fightAllData.oneFight.usedCards , card_index )
	BiWu:savefightAllData( fightAllData )
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建角色[草惊蛇]
function BiWuPrintUI:createCaoJingShe()
	local MapResHelper = require("app.models.map.MapResHelper")
	local roleMap= assert(MapResHelper:getMapNpcBaseRes("fb07"))
	local role={}
 	role = roleMap["npc07_209"]
 	if  MapIsEmpty(role) ==true then 
 		print("-------没蛇-----")
 	else
	 	-- Npc:initRoleWithRandomAttr(role)
	 	-- Map:initNpcEquipsAndItems(role)
		-- Npc:initNpcActiveZhao(role)
		Npc:initNpc(role)
	end
	role.name = "草惊蛇"
	role.species = "蛇"
	role.dsc = "这是一条蛇"
	return clone(role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 求助师门
function BiWuPrintUI:createMaster(teacherId)
	local role = Npc:getNpc(teacherId)
	return clone(role)
end
-----借刀杀人  从对手手里拿武器过来，并装备上，如果没有，就使用失败  拿对手武器杀对手
function BiWuPrintUI:createJieDaoKillPople(me,he)
	if he:getCurrWeaponType() == "拳脚" then
		return me,he
	else
		----先判断当前武器的是神兵还是普通武器
		if he.shenBingweapon then --and he:getCurrWeaponName() == he.shenBingweapon.name
			--装备的神兵
			me.shenBingweapon = he.shenBingweapon
			he.shenBingweapon = {}
		end
		if me.equips and he.equips and he.equips.weapon then
			me.equips.weapon = he.equips.weapon
			he.equips.weapon = {}
		end
		---防止删除了神兵，对方数据出错
		he.equips.weapon = {}
	end
	return me ,he
end

-----以彼之矛  从对手手里拿武器 、拳脚  拿过来  获取对手拳脚武器
function BiWuPrintUI:createYiBiZhiMaoKillPople(me,he)
	-- if me.skills and he.skills then
	-- 	me.skills = he.skills
	-- end
	-----------只拿出对手的基本拳脚,获取对手准备的拳脚    （现改为只获得基本拳脚， 不会获得对手的技能）
	-- if he.skillPrepare and he.skillPrepare.quanjiao2  then
		-- me.skillPrepare.quanjiao2 = he.skillPrepare.quanjiao2
		-- local skill = he:getSkill(he.skillPrepare.quanjiao2)
		-- me:setSkill(he.skillPrepare.quanjiao2,skill)
	-- end

	-- if he.skillPrepare and he.skillPrepare.quanjiao1 then
		-- me.skillPrepare.quanjiao1 = he.skillPrepare.quanjiao1
		-- local skill = he:getSkill(he.skillPrepare.quanjiao1)
		-- me:setSkill(he.skillPrepare.quanjiao1,skill)
	-- end
-------将对手准备
	-- if me.skills and he.skills and he.skills.jibenquanjiao then
	-- 	me:setEquipByName( "weapon" , nil )
		-- me.skills.jibenquanjiao = he.skills.jibenquanjiao
	-- end
	if he:getCurrWeaponType() =="拳脚" then
		me:setEquipByName( "weapon" , nil )
	else
		----先判断当前武器的是神兵还是普通武器
		if he.shenBingweapon and he.shenBingweapon.name then
			--装备的神兵
			me.shenBingweapon = he.shenBingweapon
		end
		if me.equips and he.equips and he.equips.weapon then
			me.equips.weapon = he.equips.weapon
		end
		if he.equips and (he.equips.weapon == nil or MapIsEmpty(he.equips.weapon))then
			me.equips.weapon = {}
		end
	end
	return me
end
----根据卡牌名字推cardIndex
function BiWuPrintUI:cardNameToCardId(str)
	local cardId = 1
	local tb = BiWu:getCardTab()
	for i=1,#tb do
		if tostring(tb[i]) == tostring(str) then
			cardId = i
			break
		end
	end
	return cardId
end


function BiWuPrintUI:useCardAndShowEffectThenGoBattle( cardIndex ,str, func )
	Audio:playEffect("xiaoAnNiu")

	if self._wuZhongShengYouLingJiYiDong == true then
		self:hideButtonsAimOtherbutton()
	else
		self:hideButtonsAim()
	end

	-- self:initButtonPosition()
	if cardIndex then
		self:markCardIndexUsed( cardIndex )
	end

	--开始PK，应该在匹配对手成功后，开始战斗
	local fightAllData = BiWu:getfightAllData()

	---保存此次开盘卡牌的名字和id
	if str then
		fightAllData.cardId = self:cardNameToCardId(str)
		fightAllData.cardName = tostring(str)
	end

	--直接开战时  cardIndex ,str, func全为nil   将 卡牌id 清零 
	if not cardIndex  and  not str  and not func then
		fightAllData.cardId  = 0
		fightAllData.cardName =  nil
	end

	if fightAllData and fightAllData.user and fightAllData.role then
		--战斗以后，标识当前状态，如果此时退出游戏就是run状态
		local callbackResult = nil

		--调用道具函数回调
		local me = Role:create(fightAllData.role)--Helper:tableCover( Role:create() , fightAllData.role )
		if not MapIsEmpty(fightAllData.role._shenbingCache) then
			for k,v in pairs(fightAllData.role._shenbingCache) do
				setmetatable(me._shenbingCache[k], getmetatable(v))
			end
		end
		local he = Role:create(fightAllData.user)
	
		--只要不是挑战就应该把对手的血量加满
		if self._type ~= "挑战" then
			BiWu:setRoleFullStatus(he)
		end

		if func then
			callbackResult = func( me , he )
		end

		print( "#############################################")
		print( "#############################################")
		print( "#############################################")
		--Helper:print_lua_table( fightAllData.user )

		--处理各种标记
		if me.noWeapon == true then
			me:setEquipByName( "weapon" , nil )
		end

		if he.noWeapon == true then
			he:setEquipByName( "weapon" , nil )
		end

		if me.attackFactor ~= nil then
			me.attackScaleFactor = me.attackFactor
		end

		if me.dodge ~= nil then
			me.dodgeScaleFactor = me.dodge
		end

		if me.parry ~= nil then
			me.parryScaleFactor = me.parry
		end

		if he.attackFactor ~= nil then
			he.attackScaleFactor = he.attackFactor
		end

		if he.dodge ~= nil then
			he.dodgeScaleFactor = he.dodge
		end

		if he.parry ~= nil then
			he.parryScaleFactor = he.parry
		end

                -- 论剑战斗也是让当前气血和未加成经脉最大值一致
		if me:getCurrQiMax() <  me:getAttr("qi")  then
			me:setAttr("qi",me:getCurrQiMax())
		end

		fightAllData.result = "run"

		---改变数据后，保存
		BiWu:savefightAllData( fightAllData )


		--延迟笑一下
		self:delayFunc( 1.0 , function()
			if User:getRoleAttr("sex") == "男" then
				Audio:playEffect("heng_man")
			else
				Audio:playEffect("heng_woman")
			end
		end)

		--从回调中获取变化信息
		if callbackResult ~= nil then

			if fightAllData.oneFight.win_points == nil then
				fightAllData.oneFight.win_points = 1
			end



			local fightBaseRenqi = fightAllData.oneFight.win_points

			--人气变化
			if callbackResult.renqi_delta ~= nil then


				if callbackResult.renqi_delta > 0 then
					fightAllData.oneFight.renqi_delta = math.ceil( fightBaseRenqi * callbackResult.renqi_delta )
					self:delayFunc(1,function ()
						PopText( "GRN人气 +".. tostring( fightAllData.oneFight.renqi_delta ) )
					end)
				else
					fightAllData.oneFight.renqi_delta = math.floor( fightBaseRenqi * callbackResult.renqi_delta )
					if fightAllData.oneFight.renqi_delta == 0 then
					else
						self:delayFunc(1,function ()
							PopText( "RED人气 ".. tostring( fightAllData.oneFight.renqi_delta ) )
						end)
					end

				end
			end

			if callbackResult.act ~= nil then

				if callbackResult.act == '换人' then

				elseif callbackResult.act == '下台' then

				elseif callbackResult.act == '打草惊蛇' then

				elseif callbackResult.act == '求助师门' then
					if me.teacherId == nil then
						PopText("你都没有师傅，何来求助之说！")
					else
						me = self:createMaster(me.teacherId)
						BiWu:setRoleFullStatus(me)
					end
					if PRINT_MODE == 1 then
						print("me = "..luaTableEncode(me))
					end
				elseif callbackResult.act == '灵机一动' then
					self:delayFunc(1.5,function ()
						self:createRandomButtons(6)
						self:showButtonsAnimOtherButton(true)
						self._wuZhongShengYouLingJiYiDong = true
					end)
					return
				elseif callbackResult.act == '无中生有' then
					self:delayFunc( 1.5 , function()
						self:createRandomButtons(3)
						self:showButtonsAnim(true)
						self._wuZhongShengYouLingJiYiDong = true
					end)

					return

 				elseif callbackResult.act == '拿对手武器杀对手' then
 					me,he = self:createJieDaoKillPople(me,he)
 				elseif callbackResult.act == '获取对手拳脚武器' then
 					me = self:createYiBiZhiMaoKillPople(me,he)
				end
			end
		end

		--延迟一下，开始战斗
		self:delayFunc( 3 , function()
			self._textLayer:setSelfAndChildrenCascadeOpacityEnabled(true)
			self._textLayer:runAction( YXEaseAction:create( cc.FadeOut:create( 1.0 ) ,  Sine_EaseOut ) )
			self.Panel_me:setSelfAndChildrenCascadeOpacityEnabled(true)
			self.Panel_me:runAction( YXEaseAction:create( cc.FadeOut:create( 1.0 ) ,  Sine_EaseOut ) )
			self.Panel_he:setSelfAndChildrenCascadeOpacityEnabled(true)
			self.Panel_he:runAction( YXEaseAction:create( cc.FadeOut:create( 1.0 ) ,  Sine_EaseOut ) )
		end)

		self:delayFunc( 5 , function()

			--一个文件保存战斗状态
			local fightAllData = BiWu:getfightAllData()

			BiWu.fightMark = 1

			--让这个界面变成全黑
			self:delayFunc( 3 , function()
					self.Panel_he:setVisible(false)
					self.Panel_me:setVisible(false)
				end)

			if callbackResult ~= nil then
				if callbackResult.act == '换人' then
					--换人直接胜利
					self:winResultDispose(me,he)
					return
				elseif callbackResult.act == '直接胜利' then
					self:winResultDispose(me,he)
					return
				elseif callbackResult.act == '下台' then
					---向服务器说明这次下台在上台不算回合数，，就是调用取消
					-- self:loseResultDispose(me,he)
					local params = {}
					params.result = "win"
					params.fid = fightAllData.fid
					params.id = fightAllData.id
					params.card_id = fightAllData.cardId

					BiWu:sendBiWuFightResult(params,function ()
					   	self:hide()
					   	BiWu.layerStatus = "mainLayer"
					end,function()
				   		--向服务器汇报战斗结果出错,回到mainLayer界面，从新上台，别卡死在黑屏界面
				   		self:hide()
				   		BiWu.layerStatus = "mainLayer"
				   	end)
					----控制在mainlayer界面能不能打印
					BiWu._inMainlayerCanPrintFightMesg = true
					BiWu._isPrintTiaoZhanMesg = false
					return
				end
			end



			if TANGJIAN_TEST_ENABLE then
				local FightLayer = require("app.views.layer.FightLayer.FightLayer")
				FightLayer:startLunJianFight({ me }, { he },
				function(fightLayer, eventType, ...)
					local fight = fightLayer:getFight()
					if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
						local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
						fight:setPlayer(role)

						-- fight:start(true)
					elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
						-- local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
						-- fight:setPlayer(role)
						PopText("战斗开始")
					elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
						local winTeamId, teams = ...

						BiWu:setFightResultAttrToRole(fight:getRoleByTeamIdAndInTeamId(1, 1),me)
						BiWu:setFightResultAttrToRole(fight:getRoleByTeamIdAndInTeamId(2, 1),he)

						User:getRole():addSeeSkillAfterFight(he) --战斗结束后添加见闻武学技能
						
						if winTeamId == 1 then
							--玩家胜利
							if callbackResult ~= nil and callbackResult.victoryCallback ~= nil then
								callbackResult.victoryCallback( self )
							else
								self:winResultDispose(me,he)
							end
							
						elseif winTeamId == 2 then
							PopText("你被" .. he:getName() .. "打趴在地")

							--玩家失败
							if callbackResult ~= nil and callbackResult.loseCallback ~= nil then
								callbackResult.loseCallback( self )
							else
								self:loseResultDispose(me,he)
							end
						else
							--玩家逃走
							self:loseResultDispose(me,he)
						end
						fightLayer:hide()
					elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
						User:getRole():addSeeSkillAfterFight(he) --战斗结束后添加见闻武学技能
						if self._buttonRun == true then
						else
							self._buttonRun = true
						    PopText([[你大喝一声：“三十六计，走为上计”]])
						  	--玩家逃走
						  	BiWu:setFightResultAttrToRole(fight:getRoleByTeamIdAndInTeamId(1, 1),me)
						  	BiWu:setFightResultAttrToRole(fight:getRoleByTeamIdAndInTeamId(2, 1),he)

						 	self:loseResultDispose(me,he)

							self:delayFunc(1,function ()
								fightLayer:hide(function()
									fightLayer:destroyInstance()
									cleanTable(fightLayer)
								end)
							end)
						end
					end
				end)
			else
				local FightLayer = require("app.views.layer.WordFightLayer")
				local fightLayer = FightLayer:getInstance()

				fightLayer:show(true, "切磋")
				fightLayer:setSelfAndChildrenCascadeOpacityEnabled(true)
				fightLayer:setOpacity( 0 )
				fightLayer:runAction( YXEaseAction:create( cc.FadeIn:create( 0.5 ) ,  Sine_EaseOut ) )
				fightLayer:startFight({ me }, { he },
					function(winTeamId, teams)

						if winTeamId == 1 then
							--玩家胜利
							if callbackResult ~= nil and callbackResult.victoryCallback ~= nil then
								callbackResult.victoryCallback( self )
							else
								self:winResultDispose(me,he)
							end
						elseif winTeamId == 2 then
							--玩家失败
							if callbackResult ~= nil and callbackResult.loseCallback ~= nil then
								callbackResult.loseCallback( self )
							else
								self:loseResultDispose(me,he)
							end
						else
							--玩家逃走
							self:loseResultDispose(me,he)
						end
					end
				)
			end
		end)
	end
end
------赢了的结果处理
function BiWuPrintUI:winResultDispose(me,he)
	local fightAllData = BiWu:getfightAllData()
	local fightWeekAllData = BiWu:getfightWeekAllData()

	--------如果用的是借刀he的武器就为空，技能也为空，这时候用原始数据保存本周对战记录
	local fightBattle = fightAllData.user

	-- ----打草惊蛇的特殊处理
	do
		he.name = fightBattle.name
	end


	local fightRusltMesg = ""
	-----本周对栈数据的记录
	local list ={}

	--向服务器发送的而数据
	local params ={}

	--胜利

	local heMenPai = he:getFamilyName() --- 门派
	local heName = he.name
	if heMenPai == nil then
		heMenPai = "江湖散人"
	end

	fightAllData.opponentMenPaiName = tostring(heMenPai)..tostring(heName)


	local heChenHao = he:getChengHaoColorName() --- 称号，没有默认普通百姓，自身带颜色

	--胜利
	local fightTimes = tonumber(BiWu:getFightDataMap(me:getName(),"times"))
	local isSkillBlood =BiWu:getFightDataMap(me:getName(),"isSkillBlood")

	if fightTimes == nil then
		fightTimes = 0
	end
	---一次出手、 三次出手胜利的计算
	if fightTimes <= 1 then
		params.oneWin = 1
	elseif fightTimes <= 3  then
		params.threeWin = 1
	end

	--不受伤害的计算
	if me:getFinalAttr("qiMax") == me:getAttr("qi") then
		params.noHurtWin = 1
	end

	--血量低于百分之十赢了
	if me:getAttr("qiPercent") <= 10 then
		params.winAndBloodLessTen = 1
	end

	----对战结果的统计
	params.result = "win"
	fightAllData.result = "win"

	list.dsc = "GRN胜"

	------战胜一个记录一个
	if  fightAllData.oneFight.peopleNum == nil then
		 fightAllData.oneFight.peopleNum = 0
	end

	fightAllData.oneFight.peopleNum =  fightAllData.oneFight.peopleNum + 1

	---对战信息的记录
	local figure = math.random(1,3)
	local mesg ={
					[1] = "你战胜了".."NOR"..tostring(heChenHao).."HIW"..tostring(heName),
					[2] = "你打败了".."NOR"..tostring(heMenPai).."HIY的HIW"..tostring(heName),
					[3] = "你战胜了".."NOR"..tostring(heMenPai).."HIY的HIW"..tostring(heName),
				}
	fightRusltMesg = mesg[figure]

	params.renqi_delta = fightAllData.oneFight.renqi_delta

   	---战斗结束的标志，用于在printUI界面控制战斗的开始与否
   	BiWu.fightMark = 2

   	--
		--对战结束告诉服务器此次对战ID
   	params.fid  = fightAllData.fid ---从服务器获取的bfid
   	params.id = fightAllData.id

   	--记录战斗结束的时间
   	fightAllData.fightOverTime = GetTime()
   	---

	-----------------------------------------------------------------------------------
	------本周对战信息的对手信息数据保存，点击头像显示用 getFamilyName（）有问题
	list.userid = he.userid
	list.sex = he.sex
	list.looks = he.looks

	list.real_menpai = he:getFamilyName()
	if list.real_menpai == nil then
		list.real_menpai = "江湖散人"
	end

	list.name = he.name

	if he:yueKaIsValid() == true then
		list.yueka = "YES"
		list.yueKaValid = "Y"
	else
		list.yueka = "NO"
		list.yueKaValid = "N"
   	end

   	do
   		list.title_type = he.title_type
   		list.yuekaTime = he.yuekaTime
   		list.age = he.age
   		list.equips = fightBattle.equips
   		list.skills = fightBattle.skills
   		list.kongfu = he.kongfu
   		list.qi = he.qi
   		list.qiPercent = he.qiPercent
   		list.qiMax = he.qiMax
   		list.jiaLi = he.jiaLi
   		list.shenBingweapon = fightBattle.shenBingweapon
   		list.skillPrepare = fightBattle.skillPrepare

   		local currTime = GetTime()
   		list.dataTime = Helper:date("%m", currTime).."-"..Helper:date("%d", currTime).." "..Helper:date("%H", currTime)..":"..Helper:date("%M", currTime)

   end

   ----保存所有对手的名字
   if fightAllData.allBattleName == nil then
   		fightAllData.allBattleName = {}
   end
   	table.insert(fightAllData.allBattleName,1,tostring(heMenPai)..tostring(heName))

   ----------------------------------------------------------------------------------------------
   	---将本周对战记录保存在本地，一个礼拜清除一次
	table.insert(fightWeekAllData.weekUserData.list,1,list)
	while #fightWeekAllData.weekUserData.list > 100 do
		table.remove(fightWeekAllData.weekUserData.list,101)
	end

   	if fightAllData.oneFight.tiaoZhanMesg == nil then
   		fightAllData.oneFight.tiaoZhanMesg = {}
   	end
   	table.insert(fightAllData.oneFight.tiaoZhanMesg,fightRusltMesg)


	BiWu:savefightAllData(fightAllData)
	BiWu:savefightWeekAllData(fightWeekAllData)

    ----一场战斗结束。将状态设置到玩家身上,
    --求助师门，不需要设置
    if fightAllData.cardId == 20 or fightAllData.cardName =="RED求助师门" then

    else
    	----一场战斗结束。将状态设置到玩家身上,
		BiWu:setFightResultAttrToRole(me, User:getRole())
		----一场战斗结束后，将clone的me的属性设置到fightAllData.role上去，下次战斗，从fightAllData  clone
		fightAllData.role = Role:create(fightAllData.role)		   
	   	BiWu:setFightResultAttrToRole(me, fightAllData.role)
	end
   	----刷新玩家和对手的气血状态
	self:refreshMineAndOtherStatus()


	----将卡牌的id汇报给服务器
	if fightAllData.cardId then
		params.card_id = fightAllData.cardId
	else
		params.card_id = 0
	end

   	--告诉服务器战斗结果
   	BiWu:sendBiWuFightResult(params,function()
   		self:hide(true)
   		self:delayFunc(2,function ()
   			   	-- 胜利界面跳转
   			   	BiWu.layerStatus = "exitLayer"
   				MainControllLayer:pushLayer("BiWuExitLayer")
   				local biWuExitLayer = MainControllLayer:getLayer("BiWuExitLayer")
   				biWuExitLayer:clearPaneItem()
   				biWuExitLayer._textLayer:removeAllChildren()
   				---显示第几回合
   				biWuExitLayer:runActionBoutLayer()
   				biWuExitLayer:show()
   				---胜利之后，自己的气血和内力回到上限值
   				biWuExitLayer:setMineQiNeiMax()
   		end)

   	end,function()
   		--向服务器汇报战斗结果出错,回到mainLayer界面，从新上台，别卡死在黑屏界面
   		self:hide()
   		BiWu.layerStatus = "mainLayer"
   	end)


end

------输了的结果处理
function BiWuPrintUI:loseResultDispose(me,he)
	local fightAllData = BiWu:getfightAllData()
	local fightWeekAllData = BiWu:getfightWeekAllData()

	--------如果用的是借刀杀人，he的武器就为空，技能也为空，这时候用原始数据保存本周对战记录
	local fightBattle = fightAllData.user

	-- ----打草惊蛇的特殊处理
	do
		he.name = fightBattle.name
	end

	----控制在mainlayer界面能不能打印
	BiWu._inMainlayerCanPrintFightMesg = true
	BiWu._isPrintTiaoZhanMesg = false

	local fightRusltMesg = ""
	-----本周对栈数据的记录
	local list ={}

	--向服务器发送的而数据
	local params ={}

	--胜利

	local heMenPai = he:getFamilyName() --- 门派
	local heName = he.name
	if heMenPai == nil then
		heMenPai = "江湖散人"
	end
	fightAllData.opponentMenPaiName = tostring(heMenPai)..tostring(heName)


	local heChenHao = he:getChengHaoColorName() --- 称号，没有默认普通百姓，自身带颜色

	---失败
	fightAllData.result = "lose"
	params.result = "lose"

	list.dsc = "RED负"

	--失败需要告诉服务器的值
	fightAllData.qi = he:getAttr("qi")    -- 气血
	fightAllData.qiMax = he:getFinalAttr("qiMax")  -- 最大气血
	fightAllData.neili = he:getAttr("neili")   -- 内力
	fightAllData.neiliMax = he:getFinalAttr("neiliMax")-- 最大内力

	params.qi = he:getAttr("qi")    -- 气血
	params.qiMax = he:getFinalAttr("qiMax")  -- 最大气血
	params.neili = he:getAttr("neili")   -- 内力
	params.neiliMax = he:getFinalAttr("neiliMax")-- 最大内力

	local figure = math.random(1,3)
	local mesg ={
					[1] = "NOR"..tostring(heChenHao).."HIW"..tostring(heName).."HIY战胜了你",
					[2] = "NOR"..tostring(heChenHao).."HIW"..tostring(heName).."HIY打败了你",
					[3] = "NOR"..tostring(heMenPai).."HIY的HIW"..tostring(heName).."HIY战胜了你",
				}
	fightRusltMesg = mesg[figure]

	params.renqi_delta = fightAllData.oneFight.renqi_delta

   	---战斗结束的标志，用于在printUI界面控制战斗的开始与否
   	BiWu.fightMark = 2

   	--
	--对战结束告诉服务器此次对战ID
   	params.fid  = fightAllData.fid ---从服务器获取的bfid
   	params.id = fightAllData.id

   	--记录战斗结束的时间
   	fightAllData.fightOverTime = GetTime()
   	---

	-----------------------------------------------------------------------------------
	------本周对战信息的对手信息数据保存，点击头像显示用 getFamilyName（）有问题
	list.userid = he.userid
	list.sex = he.sex
	list.looks = he.looks

	list.real_menpai = he:getFamilyName()
	if list.real_menpai == nil then
		list.real_menpai = "江湖散人"
	end

	list.name = he.name

	if he:yueKaIsValid() == true then
		list.yueka = "YES"
		list.yueKaValid = "Y"
	else
		list.yueka = "NO"
		list.yueKaValid = "N"
	end

   	do
   		list.title_type = he.title_type
   		list.yuekaTime = he.yuekaTime
   		list.age = he.age
   		list.equips = fightBattle.equips
   		list.skills = fightBattle.skills
   		list.kongfu = he.kongfu
   		list.qi = he.qi
   		list.qiPercent = he.qiPercent
   		list.qiMax = he.qiMax
   		list.jiaLi = he.jiaLi
   		list.shenBingweapon = fightBattle.shenBingweapon
   		list.skillPrepare = fightBattle.skillPrepare

   		local currTime = GetTime()
   		list.dataTime = Helper:date("%m", currTime).."-"..Helper:date("%d", currTime).." "..Helper:date("%H", currTime)..":"..Helper:date("%M", currTime)

		-- 物种, 描述
		-- list.species = he.species

		-- list.dsc = he.dsc
   end

	----保存所有对手的名字
	if fightAllData.allBattleName == nil then
		fightAllData.allBattleName = {}
	end
   	table.insert(fightAllData.allBattleName,1,tostring(heMenPai)..tostring(heName))

   ----------------------------------------------------------------------------------------------
   	---将本周对战记录保存在本地，一个礼拜清除一次
   	table.insert(fightWeekAllData.weekUserData.list,1,list)
   	while #fightWeekAllData.weekUserData.list > 100 do
   		table.remove(fightWeekAllData.weekUserData.list,101)
   	end

   	------保存挑战者的信息，用于显示擂主的信息
   	fightAllData.challengeData = list

   	if fightAllData.oneFight.tiaoZhanMesg == nil then
   		fightAllData.oneFight.tiaoZhanMesg = {}
   	end
   	table.insert(fightAllData.oneFight.tiaoZhanMesg,fightRusltMesg)


	BiWu:savefightWeekAllData(fightWeekAllData)
	BiWu:savefightAllData(fightAllData)

    ----一场战斗结束。将状态设置到玩家身上,
    --求助师门，不需要设置(直接用求助师门的名字？)
    if fightAllData.cardId == 20 or fightAllData.cardName == "RED求助师门" then

    else
	   	BiWu:setFightResultAttrToRole(me,User:getRole())
		   ----一场战斗结束后，将clone的me的属性设置到fightAllData.role上去，下去战斗，从fightAllData  clone
		fightAllData.role = Role:create(fightAllData.role)		   
	   	BiWu:setFightResultAttrToRole(me, fightAllData.role)
	end

   	----刷新玩家和对手的气血状态
	self:refreshMineAndOtherStatus()


	----将卡牌的id汇报给服务器
	if fightAllData.cardId then
		params.card_id = fightAllData.cardId
	else
		params.card_id = 0
	end
   	--告诉服务器战斗结果
   	BiWu:sendBiWuFightResult(params,function ()
   		---隐藏自己跳转到mainlayer界面
   		self:hide()
   		BiWu.layerStatus = "mainLayer"

   		-- 校准服务器时间
		HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
			if status == 200 and errcode == 0 and data.time ~= nil then
				SetTime(tonumber(data.time))
				NETWORK_STATE = 1
   			end
   		end)
   	end,function ()
   		--向服务器汇报战斗结果出错,回到mainLayer界面，从新上台，别卡死在黑屏界面
	   	self:hide(true)
	   	self:delayFunc(1,function ()
	   		BiWu.layerStatus = "mainLayer"
	   	end)
   	end,
   	-----战斗失败，请求超时的特殊处理
   	function ()
   	 	local currTime = GetTime()
   	 	local  fightAllData = BiWu:getfightAllData()
   	 	fightAllData.fightExpired_time = currTime + 10 * 60
   	 	fightAllData.result = "lose"
   	 	BiWu:savefightAllData(fightAllData)

   	 	---隐藏自己跳转到mainlayer界面
   	 	self:hide()
   	 	BiWu.layerStatus = "mainLayer"
   	end)-----战斗结果

end

---道具 按钮
function BiWuPrintUI:setButtonProp(cards)
	local cardCount = #cards

	assert(cardCount >= 0 and cardCount <= 6)

	local function getButtonByIndex(index)
		return self.Panel_8["Button_Prop"..index]
	end

	for i = 1, 6 do
		local button = getButtonByIndex(i)
		if i <= cardCount then
			button:setVisible(true)
		else
			button:setVisible(false)
		end
	end

-------如果cardCount = 1  ，没有计谋了的处理
	if cardCount == 0 then
		PopText("你已经无计可施，直接开战吧")
		local button = getButtonByIndex(1)
		if button then
			button:setVisible(true)
			button.Text_buttonName:setString("DWT直接开战")
			button:releaseFunc(function ()
				self:useCardAndShowEffectThenGoBattle(nil,nil,nil)
			end)
		end
	else
		for i, card in ipairs(cards) do
			local button = getButtonByIndex(i)
			if button then
				button:setVisible(true)
				button.Text_buttonName:setString(card.name)
				button:releaseFunc(function ()
					self:useCardAndShowEffectThenGoBattle( card.index, card.name, card.callback )
				end)
			end
		end
	end

end

--显示按钮
function BiWuPrintUI:showButtons()
	local Button_Prop1 = self.Panel_8.Button_Prop1
	local Button_Prop2 = self.Panel_8.Button_Prop2
	local Button_Prop3 = self.Panel_8.Button_Prop3

	Button_Prop1:setVisible(true)
	Button_Prop2:setVisible(true)
	Button_Prop3:setVisible(true)
end

--隐藏按钮
function BiWuPrintUI:hideButtons()
	local Button_Prop1 = self.Panel_8.Button_Prop1
	local Button_Prop2 = self.Panel_8.Button_Prop2
	local Button_Prop3 = self.Panel_8.Button_Prop3

	Button_Prop1:setVisible(false)
	Button_Prop2:setVisible(false)
	Button_Prop3:setVisible(false)

	local Button_Prop4 = self.Panel_8.Button_Prop4
	local Button_Prop5 = self.Panel_8.Button_Prop5
	local Button_Prop6 = self.Panel_8.Button_Prop6

	Button_Prop4:setVisible(false)
	Button_Prop5:setVisible(false)
	Button_Prop6:setVisible(false)
end

--显示按钮动画
function BiWuPrintUI:showButtonsAnim(Type)
	self:initButtonPosition(function ()
		local Button_Prop1 = self.Panel_8.Button_Prop1
		local Button_Prop2 = self.Panel_8.Button_Prop2
		local Button_Prop3 = self.Panel_8.Button_Prop3

		-- self:showButtons()

		Button_Prop1:setOpacity( 0 )
		Button_Prop2:setOpacity( 0 )
		Button_Prop3:setOpacity( 0 )

		Button_Prop1:setTouchEnabled( true )
		Button_Prop2:setTouchEnabled( true )
		Button_Prop3:setTouchEnabled( true )

		local animDuration = 0.25
		if Type == true then
			if self._wuZhongShengYouLingJiYiDong == true then
				Button_Prop1:setPosition(cc.p(540 + 300, Button_Prop1:getPositionY() - 240))
				Button_Prop2:setPosition(cc.p(540 - 300, Button_Prop2:getPositionY()- 240))
				Button_Prop3:setPosition(cc.p(540 + 300, Button_Prop3:getPositionY() - 240))
			else
				Button_Prop1:setPosition(cc.p(540 + 300, Button_Prop1:getPositionY() - 120))
				Button_Prop2:setPosition(cc.p(540 - 300, Button_Prop2:getPositionY()- 120))
				Button_Prop3:setPosition(cc.p(540 + 300, Button_Prop3:getPositionY() - 120))
			end
		else
			Button_Prop1:setPosition(cc.p(540 + 300, Button_Prop1:getPositionY()))
			Button_Prop2:setPosition(cc.p(540 - 300, Button_Prop2:getPositionY()))
			Button_Prop3:setPosition(cc.p(540 + 300, Button_Prop3:getPositionY()))
		end

		Button_Prop1:runAction(
			YXEaseAction:create( cc.Spawn:create(
			cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_Prop1:getPositionY()) ) ,
			cc.FadeIn:create(animDuration)
		),  Sine_EaseOut ) )

		Button_Prop2:runAction(
			YXEaseAction:create( cc.Spawn:create(
			cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_Prop2:getPositionY()) ) ,
			cc.FadeIn:create(animDuration)
		),  Sine_EaseOut ) )

		Button_Prop3:runAction(
			YXEaseAction:create( cc.Spawn:create(
			cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_Prop3:getPositionY()) ) ,
			cc.FadeIn:create(animDuration)
		),  Sine_EaseOut ) )

		--------只显示这次应该显示的按钮
		local function getButtonByIndex(index)
			return self.Panel_8["Button_Prop"..index]
		end

		for i=1,6 do
			local button = getButtonByIndex(i)
			if i <= self._nowUseCardCount then
				button:setVisible(true)
			else
				button:setVisible(false)
			end
		end
		----第一个按钮总是要显示出来
		getButtonByIndex(1):setVisible(true)
	end)

end

function BiWuPrintUI:showButtonsAnimOtherButton(Type)
	self:initButtonPosition(function ()
		local Button_Prop1 = self.Panel_8.Button_Prop1
		local Button_Prop2 = self.Panel_8.Button_Prop2
		local Button_Prop3 = self.Panel_8.Button_Prop3

		-- self:showButtons()

		--------只显示这次应该显示的按钮
		local function getButtonByIndex(index)
			return self.Panel_8["Button_Prop"..index]
		end
		for i=1,6 do
			local button = getButtonByIndex(i)
			if i <= self._nowUseCardCount then
				button:setVisible(true)
			else
				button:setVisible(false)
				if PRINT_MODE == 1 then
					print("```````````````````````````` getButtonByIndex(i)= "..tostring(i))
					print("```````````````````````````` self._nowUseCardCount = "..tostring(self._nowUseCardCount))
				end
			end
		end
		--第一个按钮总是要显示出来
		getButtonByIndex(1):setVisible(true)


		Button_Prop1:setOpacity( 0 )
		Button_Prop2:setOpacity( 0 )
		Button_Prop3:setOpacity( 0 )

		Button_Prop1:setTouchEnabled( true )
		Button_Prop2:setTouchEnabled( true )
		Button_Prop3:setTouchEnabled( true )

		local animDuration = 0.25
		if self._wuZhongShengYouLingJiYiDong == true then
			Button_Prop1:setPosition(cc.p(540 - 500, Button_Prop1:getPositionY()- 240))
			Button_Prop2:setPosition(cc.p(540 - 500, Button_Prop2:getPositionY()- 240))
			Button_Prop3:setPosition(cc.p(540 - 500, Button_Prop3:getPositionY()- 240))
		else
			Button_Prop1:setPosition(cc.p(540 + 300, Button_Prop1:getPositionY()- 120))
			Button_Prop2:setPosition(cc.p(540 - 300, Button_Prop2:getPositionY()- 120))
			Button_Prop3:setPosition(cc.p(540 + 300, Button_Prop3:getPositionY()- 120))
		end
		self:delayFunc(0.3,function ()
			Button_Prop1:runAction(
				YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( 540.0000 - 200 , Button_Prop1:getPositionY()) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ) )

			Button_Prop2:runAction(
				YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( 540.0000 - 200, Button_Prop2:getPositionY()) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ) )

			Button_Prop3:runAction(
				YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( 540.0000 - 200 , Button_Prop3:getPositionY()) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ) )
		end)


		if Type == true then

			local Button_Prop4 = self.Panel_8.Button_Prop4
			local Button_Prop5 = self.Panel_8.Button_Prop5
			local Button_Prop6 = self.Panel_8.Button_Prop6

			Button_Prop4:setOpacity( 0 )
			Button_Prop5:setOpacity( 0 )
			Button_Prop6:setOpacity( 0 )

			Button_Prop4:setTouchEnabled( true )
			Button_Prop5:setTouchEnabled( true )
			Button_Prop6:setTouchEnabled( true )

			local animDuration = 0.25
			if self._wuZhongShengYouLingJiYiDong == true then
				Button_Prop4:setPosition(cc.p(540 + 500, Button_Prop4:getPositionY()- 240))
				Button_Prop5:setPosition(cc.p(540 + 500, Button_Prop5:getPositionY()- 240))
				Button_Prop6:setPosition(cc.p(540 + 500, Button_Prop6:getPositionY()- 240))
			else
				Button_Prop4:setPosition(cc.p(540 + 300, Button_Prop4:getPositionY()- 120))
				Button_Prop5:setPosition(cc.p(540 - 300, Button_Prop5:getPositionY()- 120))
				Button_Prop6:setPosition(cc.p(540 + 300, Button_Prop6:getPositionY()- 120))
			end
			self._UI:delayFunc(0.3,function ()
				Button_Prop4:runAction(
					YXEaseAction:create( cc.Spawn:create(
					cc.MoveTo:create(animDuration, cc.p( 540.0000 + 200, Button_Prop4:getPositionY())) ,
					cc.FadeIn:create(animDuration)
				),  Sine_EaseOut ) )

				Button_Prop5:runAction(
					YXEaseAction:create( cc.Spawn:create(
					cc.MoveTo:create(animDuration, cc.p( 540.0000 + 200, Button_Prop5:getPositionY())) ,
					cc.FadeIn:create(animDuration)
				),  Sine_EaseOut ) )

				Button_Prop6:runAction(
					YXEaseAction:create( cc.Spawn:create(
					cc.MoveTo:create(animDuration, cc.p( 540.0000 + 200, Button_Prop6:getPositionY())) ,
					cc.FadeIn:create(animDuration)
				),  Sine_EaseOut ) )

			end)

		end

	end)
end

--隐藏按钮动画
function BiWuPrintUI:hideButtonsAim()
	local Button_Prop1 = self.Panel_8.Button_Prop1
	local Button_Prop2 = self.Panel_8.Button_Prop2
	local Button_Prop3 = self.Panel_8.Button_Prop3

	Button_Prop1:setTouchEnabled( false )
	Button_Prop2:setTouchEnabled( false )
	Button_Prop3:setTouchEnabled( false )

	local animDuration = 0.25
	Button_Prop1:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300 , Button_Prop1:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop2:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 - 300, Button_Prop2:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop3:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300, Button_Prop3:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )
end

--隐藏按钮动画
function BiWuPrintUI:hideButtonsAimOtherbutton()
	local Button_Prop1 = self.Panel_8.Button_Prop1
	local Button_Prop2 = self.Panel_8.Button_Prop2
	local Button_Prop3 = self.Panel_8.Button_Prop3

	Button_Prop1:setTouchEnabled( false )
	Button_Prop2:setTouchEnabled( false )
	Button_Prop3:setTouchEnabled( false )

	local animDuration = 0.25
	Button_Prop1:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 - 300 , Button_Prop1:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop2:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 - 300, Button_Prop2:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop3:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 - 300, Button_Prop3:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	local Button_Prop4 = self.Panel_8.Button_Prop4
	local Button_Prop5 = self.Panel_8.Button_Prop5
	local Button_Prop6 = self.Panel_8.Button_Prop6

	Button_Prop4:setTouchEnabled( false )
	Button_Prop5:setTouchEnabled( false )
	Button_Prop6:setTouchEnabled( false )

	local animDuration = 0.25
	Button_Prop4:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300 , Button_Prop4:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop5:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300, Button_Prop5:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

	Button_Prop6:runAction(
		YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300, Button_Prop6:getPositionY()) ) ,
		cc.FadeOut:create(animDuration)
	),  Sine_EaseOut ) )

end


Helper:classDefNodeGetInstance(BiWuPrintUI)
return BiWuPrintUI
0000000000000000