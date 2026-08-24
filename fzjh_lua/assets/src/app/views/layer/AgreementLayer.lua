local Resource = require("app.Resource")

local AgreementLayer = class("AgreementLayer",cc.Layer)

function AgreementLayer:create()
	local agreementLayer = AgreementLayer:new()
	agreementLayer:init()
	return agreementLayer
end




function AgreementLayer:init()
	self._UI = require("Layer.Agreement.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	--初始
	self:initRichText()
	self.innerIayer = nil ---
	self.innerIayerMaxHight = 0 
	self.isTouchSlider = false 
	self:setSliderEventListener(function ()
		local percent = self.Slider:getPercent()
		self.RichText_print:jumpToPercentVertical(percent)
	end,nil,nil,nil)
end


--------------------------------------------------------------------------------------------------------------------
-- ----打印

function AgreementLayer:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(27, 22))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(10)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(true)
	self.RichText_print:setInertiaScrollEnabled(false)


end
local textColor = cc.c3b(208, 208, 208)
function AgreementLayer:print(str, fontSize,verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4444 then
		self:initRichText()
	end

	if fontSize then
		self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)

		if verticalSpace ~= nil and type(verticalSpace) == "number" then
			self.RichText_print:pushBackNewLine(verticalSpace)
		else
			self.RichText_print:pushBackNewLine()
		end
	else

		self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 38)

		if verticalSpace ~= nil and type(verticalSpace) == "number" then
			self.RichText_print:pushBackNewLine(verticalSpace)
		else
			self.RichText_print:pushBackNewLine()
			self.Panel_shelter:setVisible(true)
			self.RichText_print:setCascadeOpacity(0)
			self:delayFunc(0.5,function ()
				self.RichText_print:jumpToTop()
				self._handle = self:schedule(function (ft)
					self:update(ft)
				end,0.1)
				self.Button_Agree:setOpacity(255/3)
				self.Button_Agree:setTouchEnabled(false)
				self.Panel_shelter:setVisible(false)
				self.RichText_print:setCascadeOpacity(255)
			end)
		end
	end

	self.innerIayer = self.RichText_print:getInnerContainer()
end
-----------------------------------------------------------------------------------
function AgreementLayer:show()
	local agreementStr = [[ 		欢迎您使用小猴跳跳游戏客户端软件及服务！？RED小猴跳跳游戏客户端软件的著作权人为深圳市小猴跳跳网络科技有限公司（为方便阅读，以下或单独称“小猴跳跳”）。DWT？为使用小猴跳跳游戏客户端软件（以下简称“本软件”）及服务，您应当阅读并遵守《小猴跳跳游戏客户端软件许可及服务协议》（以下简称“本协议”），以及《小猴跳跳服务协议》。请您务必审慎阅读、充分理解各条款内容，特别是免除或者限制责任的条款，以及开通或使用某项服务的单独协议，并选择接受或不接受。限制、免责条款可能以加粗形式提示您注意。 ？除非您已阅读并接受本协议所有条款，否则您无权下载、安装或使用本软件及相关服务。您的下载、安装、使用、绑定邮箱帐号、登录等行为即视为您已阅读并同意上述协议的约束。 ？如果您未满18周岁，请在法定监护人的陪同下阅读本协议及其他上述协议，并特别注意未成年人使用条款。？一、【协议的范围】 ？1.1 【协议适用主体范围】 ？本协议是您与小猴跳跳之间关于您下载、安装、使用、复制本软件，以及使用小猴跳跳相关服务所订立的协议。 ？1.2 【协议关系及冲突条款】 ？本协议被视为《小猴跳跳服务协议》的补充协议，是其不可分割的组成部分，与其构成统一整体。本协议与上述内容存在冲突的，以本协议为准。 ？本协议内容同时包括小猴跳跳可能不断发布的关于本服务的相关协议、业务规则等内容。上述内容一经正式发布，即为本协议不可分割的组成部分，您同样应当遵守。？二、【关于本服务】 ？2.1 【本服务的内容】 ？本服务内容是指小猴跳跳向用户提供的游戏软件软件许可及服务（以下简称“本服务”）。 ？2.2 【本服务的形式】 ？2.2.1 您使用本服务需要下载小猴跳跳游戏客户端软件，对于这些软件，小猴跳跳给予您一项个人的、不可转让及非排他性的许可。您仅可为访问或使用本服务的目的而使用这些软件及服务。 ？2.3 【本服务许可的范围】 ？2.3.1 小猴跳跳给予您一项个人的、不可转让及非排他性的许可，以使用本软件。您可以为非商业目的在单一台终端设备上安装、使用、显示、运行本软件。 ？2.3.2本条及本协议其他条款未明示授权的其他一切权利仍由小猴跳跳保留，您在行使这些权利时须另外取得小猴跳跳的书面许可。小猴跳跳如果未行使前述任何权利，并不构成对该权利的放弃。？三、【软件的获取】 ？3.1 您可以直接从小猴跳跳的网站上获取本软件，也可以从得到小猴跳跳授权的第三方获取。 ？3.2 如果您从未经小猴跳跳授权的第三方获取本软件或与本软件名称相同的安装程序，小猴跳跳无法保证该软件能够正常使用，并对因此给您造成的损失不予负责。？四、【软件的安装与卸载】 ？4.1 小猴跳跳可能为不同的终端设备开发了不同的软件版本，您应当根据实际情况选择下载合适的版本进行安装。 ？4.2 下载安装程序后，您需要按照该程序提示的步骤正确安装。 ？4.3 为提供更加优质、安全的服务，在本软件安装时小猴跳跳可能推荐您安装其他软件，您可以选择安装或不安装。 ？4.4 如果您不再需要使用本软件或者需要安装新版软件，可以自行卸载。如果您愿意帮助小猴跳跳改进产品服务，请告知卸载的原因。？五、【软件的更新】 ？5.1 为了改善用户体验、完善服务内容，小猴跳跳将不断努力开发新的服务，并为您不时提供软件更新（这些更新可能会采取软件替换、修改、功能强化、版本升级等形式）。 ？5.2 为了保证本软件及服务的安全性和功能的一致性，小猴跳跳有权不经向您特别通知而对软件进行更新，或者对软件的部分功能效果进行改变或限制。 ？5.3 本软件新版本发布后，旧版本的软件可能无法使用。小猴跳跳不保证旧版本软件继续可用及相应的客户服务，请您随时核对并下载最新版本。？六、【用户个人信息保护】 ？6.1保护用户个人信息是小猴跳跳的一项基本原则，小猴跳跳将会采取合理的措施保护用户的个人信息。除法律法规规定的情形外，未经用户许可小猴跳跳不会向第三方公开、透露用户个人信息。小猴跳跳对相关信息采用专业加密存储与传输方式，保障用户个人信息的安全。 ？6.2 您在注册帐号或使用本服务的过程中，可能需要提供一些必要的信息，例如：为向您提供帐号注册服务或进行用户身份识别，需要您填写QQ号码等信息。若国家法律法规或政策有特殊规定的，您需要提供真实的身份信息。若您提供的信息不完整，则无法使用本服务或在使用过程中受到限制。 ？6.3一般情况下，您可随时浏览、修改自己提交的信息，但出于安全性和身份识别（如号码申诉服务）的考虑，您可能无法修改注册时提供的初始注册信息及其他验证信息。 ？6.4小猴跳跳将运用各种安全技术和程序建立完善的管理制度来保护您的个人信息，以免遭受未经授权的访问、使用或披露。 ？6.5未经您的同意，小猴跳跳不会向小猴跳跳以外的任何公司、组织和个人披露您的个人信息，但法律法规另有规定的除外。 ？6.6小猴跳跳非常重视对未成年人个人信息的保护。若您是18周岁以下的未成年人，在使用小猴跳跳的服务前，应事先取得您家长或法定监护人的书面同意。？七、【主权利义务条款】 ？7.1 【帐号使用规范】 ？7.1.1 您在使用本服务前需要绑定角色帐号。角色帐号可通过邮箱进行绑定注册，小猴跳跳有权根据用户需求或产品需要对帐号注册和绑定的方式进行变更，关于您使用帐号的具体规则，请遵守相关帐号使用协议以及小猴跳跳为此发布的专项规则。 ？7.1.2 角色帐号的所有权归小猴跳跳公司所有，用户完成申请注册手续后，仅获得角色帐号的使用权，且该使用权仅属于初始申请注册人，同时，初始申请注册人不得赠与、借用、租用、转让或售卖游戏帐号或者以其他方式许可非初始申请注册人使用游戏帐号。非初始申请注册人不得通过受赠、继承、承租、受让或者其他任何方式使用游戏帐号。 ？7.1.3 用户有责任妥善保管注册帐户信息及帐户密码的安全，用户需要对注册帐户以及密码下的行为承担法律责任。用户同意在任何情况下不向他人透露帐户及密码信息。在您怀疑他人在使用您的帐号时，您应立即通知小猴跳跳公司。 ？7.1.4 用户注册角色帐号后如果长期不登录该帐号，小猴跳跳有权回收该帐号，以免造成资源浪费，由此带来的任何损失均由用户自行承担。 ？7.2【用户注意事项】 ？7.2.1 您理解并同意：为了向您提供有效的服务，本软件会利用您通讯终端的处理器和带宽等资源。本软件使用过程中可能产生流量的费用，用户需自行向运营商了解相关资费信息，并自行承担相关费用。 ？7.2.2您理解并同意：本软件的某些功能可能会让第三方知晓用户的信息，例如：用户的角色帐号可以查询用户头像、名字等可公开的个人资料。 ？7.2.3您在使用本软件某一特定服务时，该服务可能会另有单独的协议、相关业务规则等（以下统称为“单独协议”），您在使用该项服务前请阅读并同意相关的单独协议。 ？7.2.4 您理解并同意小猴跳跳将会尽其商业上的合理努力保障您在本软件及服务中的数据存储安全，但是，小猴跳跳并不能就此提供完全保证，包括但不限于以下情形： ？7.2.4.1 小猴跳跳不对您在本软件及服务中相关数据的删除或储存失败负责； ？7.2.4.2 小猴跳跳有权根据实际情况自行决定单个用户在本软件及服务中数据的最长储存期限，并在服务器上为其分配数据最大存储空间等。您可根据自己的需要自行备份本软件及服务中的相关数据； ？7.2.4.3 如果您停止使用本软件及服务或服务被终止或取消，小猴跳跳可以从服务器上永久地删除您的数据。服务停止、终止或取消后，小猴跳跳没有义务向您返还任何数据。 ？7.2.5 用户在使用本软件及服务时，须自行承担如下来自小猴跳跳不可掌控的风险内容，包括但不限于： ？7.2.5.1由于不可抗拒因素可能引起的个人信息丢失、泄漏等风险； ？7.2.5.2 用户必须选择与计算机操作系统相匹配的软件版本，否则，由于软件与计算机操作系统不相匹配所导致的任何问题或损害，均由用户自行承担； ？7.2.5.3 用户在使用本软件访问第三方网站时，因第三方网站及相关内容所可能导致的风险，由用户自行承担； ？7.2.5.4 用户发布的内容被他人转发、分享，因此等传播可能带来的风险和责任； ？7.2.5.5 由于网络信号不稳定、网络带宽小等原因，所引起的小猴跳跳角色登录失败、资料同步不完整、页面打开速度慢等风险。 ？7.3【第三方产品和服务】 ？7.3.1 您在使用本软件第三方提供的产品或服务时，除遵守本协议约定外，还应遵守第三方的用户协议。小猴跳跳和第三方对可能出现的纠纷在法律规定和约定的范围内各自承担责任。 ？7.3.2 因用户使用本软件或要求小猴跳跳提供特定服务时，本软件可能会调用第三方系统或者通过第三方支持用户的使用或访问，使用或访问的结果由该第三方提供，小猴跳跳不保证通过第三方提供服务及内容的安全性、准确性、有效性及其他不确定的风险，由此若引发的任何争议及损害，与小猴跳跳无关，小猴跳跳不承担任何责任。？八、【用户行为规范】 ？8.1【信息内容规范】 ？8.1.1本条所述信息内容是指用户使用本软件及服务过程中所制作、复制、发布、传播的任何内容，包括但不限于角色帐号头像、名字、用户说明等注册信息，或文字、语音、图片等发送，以及其他使用角色帐号或本软件及服务所产生的内容。 ？8.1.2 您理解并同意，小猴跳跳一直致力于为用户提供文明健康、规范有序的网络环境，您不得利用？角色帐号或本软件及服务制作、复制、发布、传播如下干扰小猴跳跳正常运营，以及侵犯其他用户或第三方合法权益的内容，包括但不限于： ？8.1.2.1 发布、传送、传播、储存违反国家法律、危害国家安全统一、社会稳定、公序良俗、社会公德以及侮辱、诽谤、淫秽或含有任何性或性暗示的、暴力的内容； ？8.1.2.2 发布、传送、传播、储存侵害他人名誉权、肖像权、知识产权、商业秘密等合法权利的内容； ？8.1.2.3 涉及他人隐私、个人信息或资料的； ？8.1.2.4 发表、传送、传播骚扰、广告信息及垃圾信息； ？8.1.2.5 其他违反法律法规、政策及公序良俗、社会公德或干扰小猴跳跳正常运营和侵犯其他用户或第三方合法权益内容的信息。？8.2【软件使用规范】 ？除非法律允许或小猴跳跳书面许可，您使用本软件过程中不得从事下列行为： ？8.2.1 删除本软件及其副本上关于著作权的信息； ？8.2.2 对本软件进行反向工程、反向汇编、反向编译，或者以其他方式尝试发现本软件的源代码； ？8.2.3 对小猴跳跳拥有知识产权的内容进行使用、出租、出借、复制、修改、链接、转载、汇编、发表、出版、建立镜像站点等； ？8.2.4 对本软件或者本软件运行过程中释放到任何终端内存中的数据、软件运行过程中客户端与服务器端的交互数据，以及本软件运行所必需的系统数据，进行复制、修改、增加、删除、挂接运行或创作任何衍生作品，形式包括但不限于使用插件、外挂或非小猴跳跳经授权的第三方工具/服务接入本软件和相关系统； ？8.2.5 通过修改或伪造软件运行中的指令、数据，增加、删减、变动软件的功能或运行效果，或者将用于上述用途的软件、方法进行运营或向公众传播，无论这些行为是否为商业目的； ？8.2.6 通过非小猴跳跳开发、授权的第三方软件、插件、外挂、系统，登录或使用小猴跳跳软件及服务，或制作、发布、传播上述工具； ？8.2.7 自行或者授权他人、第三方软件对本软件及其组件、模块、数据进行干扰； ？8.2.8 其他未经小猴跳跳明示授权的行为。？8.3【服务运营规范】 ？除非法律允许或小猴跳跳书面许可，您使用本服务过程中不得从事下列行为： ？8.3.1 提交、发布虚假信息，或冒充、利用他人名义的； ？8.3.2 诱导其他用户点击链接页面或分享信息的； ？8.3.3 虚构事实、隐瞒真相以误导、欺骗他人的； ？8.3.4 侵害他人名誉权、肖像权、知识产权、商业秘密等合法权利的； ？8.3.5 未经小猴跳跳书面许可利用角色帐号和任何功能，以及第三方运营平台进行推广或互相推广的； ？8.3.6 利用角色帐号或本软件及服务从事任何违法犯罪活动的； ？8.3.7 制作、发布与以上行为相关的方法、工具，或对此类方法、工具进行运营或传播，无论这些行为是否为商业目的； ？8.3.8 其他违反法律法规规定、侵犯其他用户合法权益、干扰产品正常运营或小猴跳跳未明示授权的行为。？8.4 【对自己行为负责】 ？您充分了解并同意，您必须为自己注册帐号下的一切行为负责，包括您所发表的任何内容以及由此产生的任何后果。您应对本服务中的内容自行加以判断，并承担因使用内容而引起的所有风险，包括因对内容的正确性、完整性或实用性的依赖而产生的风险。小猴跳跳无法且不会对因前述风险而导致的任何损失或损害承担责任。？8.5【违约处理】？8.5.1 如果小猴跳跳发现或收到他人举报或投诉用户违反本协议约定的，小猴跳跳有权不经通知随时对相关内容进行删除，并视行为情节对违规帐号处以包括但不限于警告、限制或禁止使用全部或部分功能、帐号封禁直至注销的处罚，并公告处理结果。 ？8.5.2 您理解并同意，小猴跳跳有权依合理判断对违反有关法律法规或本协议规定的行为进行处罚，对违法违规的任何用户采取适当的法律行动，并依据法律法规保存有关信息向有关部门报告等，用户应独自承担由此而产生的一切法律责任。 ？8.5.3 您理解并同意，因您违反本协议或相关服务条款的规定，导致或产生第三方主张的任何索赔、要求或损失，您应当独立承担责任；小猴跳跳因此遭受损失的，您也应当一并赔偿。？九、【知识产权声明】 ？9.1 小猴跳跳是本软件的知识产权权利人。本软件的一切著作权、商标权、专利权、商业秘密等知识产权，以及与本软件相关的所有信息内容（包括但不限于文字、图片、音频、视频、图表、界面设计、版面框架、有关数据或电子文档等）均受中华人民共和国法律法规和相应的国际条约保护，小猴跳跳享有上述知识产权。 ？9.2 未经小猴跳跳书面同意，您不得为任何商业或非商业目的自行或许可任何第三方实施、利用、转让上述知识产权，小猴跳跳保留追究上述行为法律责任的权利。？十、【终端安全责任】 ？10.1您理解并同意，本软件同大多数互联网软件一样，可能会受多种因素影响，包括但不限于用户原因、网络服务质量、社会环境等；也可能会受各种安全问题的侵扰，包括但不限于他人非法利用用户资料，进行现实中的骚扰；用户下载安装的其他软件或访问的其他网站中可能含有病毒、木马程序或其他恶意程序，威胁您的终端设备信息和数据安全，继而影响本软件的正常使用等。因此，您应加强信息安全及个人信息的保护意识，注意密码保护，以免遭受损失。 ？10.2 您不得制作、发布、使用、传播用于窃取角色帐号及他人个人信息、财产的恶意程序。 ？10.3 维护软件安全与正常使用是小猴跳跳和您的共同责任，小猴跳跳将按照行业标准合理审慎地采取必要技术措施保护您的终端设备信息和数据安全，但是您承认和同意小猴跳跳并不能就此提供完全保证。 ？10.4 在任何情况下，您不应轻信借款、索要密码或其他涉及财产的网络信息。涉及财产操作的，请一定先核实对方身份，并请经常留意小猴跳跳有关防范诈骗犯罪的提示。？十一、【第三方软件或技术】 ？11.1 本软件可能会使用第三方软件或技术（包括本软件可能使用的开源代码和公共领域代码等，下同），这种使用已经获得合法授权。 ？11.2 本软件如果使用了第三方的软件或技术，小猴跳跳将按照相关法规或约定，对相关的协议或其他文件，可能通过本协议附件、在本软件安装包特定文件夹中打包等形式进行展示，它们可能会以“软件使用许可协议”、“授权协议”、“开源代码许可证”或其他形式来表达。前述通过各种形式展现的相关协议或其他文件，均是本协议不可分割的组成部分，与本协议具有同等的法律效力，您应当遵守这些要求。如果您没有遵守这些要求，该第三方或者国家机关可能会对您提起诉讼、罚款或采取其他制裁措施，并要求小猴跳跳给予协助，您应当自行承担法律责任。 ？11.3 如因本软件使用的第三方软件或技术引发的任何纠纷，应由该第三方负责解决，小猴跳跳不承担任何责任。小猴跳跳不对第三方软件或技术提供客服支持，若您需要获取支持，请与第三方联系。？十二、【其他】 ？12.1 您使用本软件即视为您已阅读并同意受本协议的约束。小猴跳跳有权在必要时修改本协议条款。您可以在本软件的最新版本中查阅相关协议条款。本协议条款变更后，如果您继续使用本软件，即视为您已接受修改后的协议。如果您不接受修改后的协议，应当停止使用本软件。 ？12.2本协议签订地为中华人民共和国广东省深圳市福田区。 ？12.3 本协议的成立、生效、履行、解释及纠纷解决，适用中华人民共和国大陆地区法律（不包括冲突法）。 ？12.4 若您和小猴跳跳之间发生任何纠纷或争议，首先应友好协商解决；协商不成的，您同意将纠纷或争议提交本协议签订地有管辖权的人民法院管辖。 ？12.5 本协议所有条款的标题仅为阅读方便，本身并无实际涵义，不能作为本协议涵义解释的依据。 ？12.6 本协议条款无论因何种原因部分无效或不可执行，其余条款仍有效，对双方具有约束力。（正文完）]]
	agreementStr = string.gsub(agreementStr,"？","\n\n 		")
	self:print("【首部及导言】",48)
	self:print(agreementStr)
	self:setVisible(true)
	self.Slider:setPercent(0)
end
function AgreementLayer:onResume()
	self.Button_Agree:setOpacity(255/3)
	self.Button_Agree:setTouchEnabled(false)
	self.Slider:setPercent(0)
end
function AgreementLayer:hide( )
	self:unschedule( self._handle)
	self:setVisible(false)
	--初始
	self:initRichText()
end
----设置同意按钮是否可见，可触摸
function AgreementLayer:isAtBottom( )
	local pointY = self.innerIayer:getPositionY()
	if pointY >= 0 then
		self.Button_Agree:setOpacity(255)
		self.Button_Agree:setTouchEnabled(true)
	else
		self.Button_Agree:setOpacity(255/3)
		self.Button_Agree:setTouchEnabled(false)
	end
end

function AgreementLayer:update(ft)
	self:isAtBottom()
	if self.isTouchSlider == true then
		self:moveSlider()
	else
		self:reversedMoveSlider()
	end
end

---同意按钮
function AgreementLayer:setButtonAgree( func)
	self.Button_Agree:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		----设置角色属性，一个角色值显示一次
		User:getRole():setFlag("isShowAgreement", true)
		self:hide()
		if func  then
			func()
		end
	end)
end
---不同意按钮
function AgreementLayer:setButtonDisagree( func )
	self.Button_Disagree:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		User:getRole():setFlag("isShowAgreement", false)
		self:hide()
		if func  then
			func()
		end
	end)
end

---------------拖动按钮
function AgreementLayer:setSliderEventListener( beganFunc, endedFunc,movedFunc, canceledFunc )
	self.Slider:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.isTouchSlider = true
			if beganFunc then
				beganFunc(ref, eventType) 
			end
		elseif eventType == ccui.TouchEventType.ended then
			self.isTouchSlider = false 
			if endedFunc then
				endedFunc(ref, eventType)
			end
		elseif eventType == ccui.TouchEventType.moved then
			self.isTouchSlider = true 
			if movedFunc then
				movedFunc(ref, eventType)
			end
		elseif eventType == ccui.TouchEventType.canceled then
			self.isTouchSlider = false
			if canceledFunc then
				canceledFunc(ref, eventType)
			end
		end
	end)


end
-----最后没使用监听事件方法，用updata不断的刷新，实现
function AgreementLayer:moveSlider()
	-- self:setSliderEventListener(nil,function ()
		local percent = self.Slider:getPercent()
		self.RichText_print:jumpToPercentVertical(percent)
	-- end,nil,nil)
end
--拖动协议，让slider也跟着动
function AgreementLayer:reversedMoveSlider( )
		local pointY = self.innerIayer:getPositionY()
		pointY = pointY * -1
		if self.innerIayerMaxHight < pointY then
			self.innerIayerMaxHight = pointY
		end
		local percent = (pointY/self.innerIayerMaxHight)*100
		self.Slider:setPercent(100 - percent)
end
Helper:classDefNodeGetInstance(AgreementLayer)

return AgreementLayer00000000000000