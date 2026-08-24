--@desc 悬兵洞相关的文本
local HomelandDesc = {}

local familyspecial = requireWithEncrypt("script.others.familyspecial")
local chatTopicList = familyspecial["chatTopic"]

--@RefType [src.app.models.HomelandModel.RoleLife#RoleLife]
local RoleLife = require("app.models.HomelandModel.RoleLife")

local temp = {
    yuanbao = "元宝",
    yinpiao = "银票"
}


--忠诚度成长数值对应的文本
--value 成长数值
function HomelandDesc:getGrowthText(value,name)
    if type(value) ~= "number" then
        return ""
    end
    local text = ""
    local list = {
        {index = 1, text = "#mz似乎与你更亲近了些。"},
        {index = 5, text = "#mz似乎与你更投机了。"},
        {index = 10, text ="#mz与你更亲近了。"},
        {index = 15, text ="#mz眼中透着一股炙热，与你的关系更进一步了。"},
        {index = 20, text ="#mz眼中透着一股炙热，与你更亲近了。"},
        {index = 30, text ="#mz眼神柔和中带着热切，与你更亲近了。"},
        {index = 50, text ="#mz与你更加默契了，你们更像一家人了。"},
        {index = 80, text ="#mz与你更加契合了，彼此开始心照不宣。"}
    }
    for i, v in ipairs(list) do
        if value > v.index then
            text = v.text
        end
    end
    text = self:subNameText(text,name)
    return text
end


--@desc: 墙壁相关描述文本
--@author:Liang SongQiang
--@time:2018-06-13 16:45:09
--@index:索引
function HomelandDesc:getCangJianShiDesc(index)
    local textArr = {
        ["小有斩获"] = "此处为藏剑室，用于存放各种兵器。走进其中，可以看见四周有好几处武器架，但上面兵器甚少，只是零零星星地挂着一些兵器。",
        ["什袭而藏"] = "此处为藏剑室，用于存放各种兵器。里面收藏的武器虽然算不上很多，但不乏珍品，让人眼前一亮。",
        ["琳琅满目"] = "此处为藏剑室，用于存放各种兵器。里面收藏的武器种类繁多，分门别类地挂在墙上，一片银光闪闪。",
        ["洋洋大观"] = "此处为藏剑室，用于存放各种兵器。走进其中，武器琳琅满目，让人目不暇接，刀剑棍鞭无一不在，种类之繁多，令人敬佩不已。",
        ["武库充实"] = "此处为藏剑室，用于存放各种兵器。只见其中兵器多如牛毛，难以数清，样样都是上品，光芒难以掩盖。",
        ["紫电清霜"] = "此处为藏剑室，用于存放各种兵器。其中藏兵数量令人惊叹，四下观望，落眼之处尽皆挂满兵器，珍品无数，价值连城。",
        ["剑胆琴心"] = "此处为藏剑室，用于存放各种兵器。房内武器已无法数清，藏兵数量之多，国库也不过如此，可见不少绝世神兵混于其中，散发着寒光。",
        ["地负海涵"] = "此处为藏剑室，用于存放各种兵器。走进房内宛如进入水晶龙宫，人言龙宫藏兵无数，此处想必绝不输给龙宫。",
        ["物华天宝"] = "此处为藏剑室，用于存放各种兵器。只见四周兵器数量多到令人叹为观止，每把均是上上乘的宝物，如烟海般浩瀚，如星辰般璀璨。",
        ["气冲牛斗"] = "此处为藏剑室，用于存放各种兵器，此处藏尽天下神兵利器，从古至今但凡有所耳闻的兵器，在此都能找到，为世间一奇。"
    }

    local text = ""
    if textArr[index] then
        text = textArr[index]
    else
        text = textArr["小有斩获"]
    end

    return text
end

--@desc: 获取墙壁描述
--@author:Liang SongQiang
--@time:2018-06-13 21:47:18
function HomelandDesc:getQiangBiDesc(index)
    local textArr = {
        ["小有斩获"] = "墙上挂着的武器零零散散，种类较少。",
        ["什袭而藏"] = "墙壁之上挂的武器虽不算多，但也有好几件珍品。",
        ["琳琅满目"] = "墙壁之上悬着不少武器，一眼望去鳞光闪闪。",
        ["洋洋大观"] = "墙壁之上分门别类地悬挂着各式武器，种类繁多。",
        ["武库充实"] = "墙上武器多如牛毛，光芒四射。",
        ["紫电清霜"] = "只见墙壁之上悬挂着数不胜数的兵器，珍宝无数，价值连城。",
        ["剑胆琴心"] = "墙上挂的兵器数之不清，绝世神兵隐于其中，散发着震慑人心的寒光。",
        ["地负海涵"] = "墙壁上藏天下奇兵，站在前面，宛如水晶龙宫。",
        ["物华天宝"] = "墙上挂着数不胜数的兵器，浩如烟海，灿若星辰。",
        ["气冲牛斗"] = "墙壁之上挂满神兵利器，从古至今，无一不全。"
    }

    local text = ""
    if textArr[index] then
        text = textArr[index]
    else
        text = textArr["小有斩获"]
    end
    return text
end

--@desc: 藏衣室文本
--@author:Liang SongQiang
--@time:2018-06-13 22:46:21
function HomelandDesc:getCangYiShiDesc(index)
    local textArr = {
        ["小有斩获"] = "此处是藏衣室，可以用来存放衣物首饰。这间藏衣室里面虽然放着好几个衣柜首饰柜，但其中藏品较少，看起来有点空荡荡的。",
        ["什袭而藏"] = "此处是藏衣室，可以用来存放衣物首饰。其中摆放着几个衣柜首饰柜，打开一看，里面放的东西虽然不多，但有几件算得上是珍品。",
        ["琳琅满目"] = "此处是藏衣室，可以用来存放衣物首饰。衣柜之中放着不少衣物，有些上品还被取出挂在墙上，供人观赏。",
        ["洋洋大观"] = "此处是藏衣室，可以用来存放衣物首饰。走进屋内左右各摆放着不少衣柜，有些衣柜打开着，里面存放的衣物数量庞大，已非常人所能企及。",
        ["武库充实"] = "此处是藏衣室，可以用来存放衣物首饰。房内左右整齐地摆放着两排衣柜，衣柜之中藏品丰富，大多数衣物都是珍品，已是价值不菲。",
        ["紫电清霜"] = "此处是藏衣室，可以用来存放衣物首饰。衣柜之中藏宝无数，随意取出一件，均是上乘质地，做工精细，柔软护体的衣物，令人心生艳羡。",
        ["剑胆琴心"] = "此处是藏衣室，可以用来存放衣物首饰。只见房内大大小小的衣柜均已被衣物塞满，多余的衣物则取出挂在墙上，墙上花花绿绿，五颜六色，各类衣物都有涉及。",
        ["地负海涵"] = "此处是藏衣室，可以用来存放衣物首饰。只见房内被大大小小的衣柜放满，打开来看，其中珍稀衣物无数，衣柜之内设置有小盒，小盒之中存放腰带鞋帽，大多质地优良，价值不菲，让人感叹主人当真富甲一方。",
        ["物华天宝"] = "此处是藏衣室，可以用来存放衣物首饰。打开衣柜，华贵之气扑面而来，其藏衣无数，又痒痒珍贵，数量之多，质地之优良，令人咂舌，想必皇家衣橱也不过如此。",
        ["气冲牛斗"] = "此处是藏衣室，可以用来存放衣物首饰。打开衣柜，映入眼帘的景象已非语言能形容，天南海北、从古至今的珍贵衣物均能在此找到，或丝或棉或麻或纱，每一件都是绝世宝物，令人叹为观止。"
    }

    local text = ""
    if not textArr[index] then
        text = textArr[index]
    else
        text = textArr["小有斩获"]
    end

    return text
end

--@desc: 衣柜描述文本
--@author:Liang SongQiang
--@time:2018-06-13 22:46:10
function HomelandDesc:getYiGuiDesc(index)
    local textArr = {
        ["小有斩获"] = "衣柜之中只放着几件衣物，一眼便能数出来。",
        ["什袭而藏"] = "衣柜之中衣物虽然不多，但珍品尚有些许。",
        ["琳琅满目"] = "衣柜中衣物已是不少，半个柜子都被存放得满满当当。",
        ["洋洋大观"] = "衣柜之中存放的衣物数不胜数，堆叠成厚厚一堆，整齐地摆放在一起。",
        ["武库充实"] = "衣柜中存放着大量珍品衣物，价值不菲。",
        ["紫电清霜"] = "衣柜之中藏宝无数，都是上乘衣物。",
        ["剑胆琴心"] = "衣柜之中已经满满当当，不少珍品藏在其中。",
        ["地负海涵"] = "衣柜之中珍宝无数，衣帽鞋腰每样都是价值不菲。",
        ["物华天宝"] = "衣柜之中存放衣物不计其数，样样都是稀世珍宝。",
        ["气冲牛斗"] = "衣柜之中囊括着天下奇珍衣物，藏无不尽，件件都是稀世珍宝。"
    }

    local text = ""
    if textArr[index] then
        text = textArr[index]
    else
        text = textArr["小有斩获"]
    end
    return text
end

--@desc: 获取吃饭文本
--@author:Liang SongQiang
--@time:2018-06-13 23:59:01
function HomelandDesc:getEatDesc(index)
    local textArr = {}

    if index >= 1 and index <= 15 then
        textArr = {"WHT你吃下了饭菜，感觉口味平淡无奇，除了不再饥饿之外，并没有什么别的不同。这饭菜味道淡淡，似乎没有放盐一般。你勉强吃完，却并不觉得有什么变化。你吃下饭菜，只觉味同嚼蜡，淡而无味。NOR"}
    elseif index >= 16 and index <= 45 then
        textArr = {
            "HIC厨子的手艺十分精湛，所做的饭菜不仅美味可口，肉菜搭配也十分均衡，你吃下以后，只觉体内血气充盈。NOR",
            "HIC你看了看饭菜，饭菜做得色香味俱全，有不少都是补血益气的食物，吃下去饥饿一扫而空。NOR",
            "HIC你左手一个水晶肘子，右手一个烧鸡腿，吃得满嘴油光，一顿饭下肚，觉得亏空的气血充盈不少。NOR"
        }
    elseif index >= 46 and index <= 60 then
        textArr = {
            "HIC这饭菜做得十分精致，尝起来味道也是上乘，其中加入了 促进伤口愈合的食物，你吃了下去，觉得似乎伤势好了不少。NOR",
            "HIC厨子在饭菜中加入了疗伤的药材，一份药膳美味可口，吃下以后对你的伤势大有裨益。NOR",
            "HIC你还没开吃就被饭菜的香气勾得食指大动，吃下以后更是难以忘怀的美味，吃完以后气力充足，连伤势都好了不少。NOR"
        }
    elseif index >= 61 and index <= 80 then
        textArr = {
            "HIC厨子今日来了兴致，给你做了不少各地的名菜，你一道道看去，什么西湖醋鱼、盐焗鸡、一品豆腐、夫妻肺片等，天南海北的美食齐聚于此，你一顿饭吃得尽兴，精力恢复不少。NOR",
            "HIC你看着厨子给你做的精致佳肴，顿时胃口大开，吃下去以后，腹中暖流涌动，似乎精神了不少。NOR",
            "HIC厨子做的菜不仅美味，还加入了提神醒脑之物。你吃下去觉得精神了些许。NOR"
        }
    elseif index > 80 and index <= 90 then
        textArr = {
            "HIC饭菜的香气十分诱人，你瞧了瞧饭菜，有荤有素有汤，令人食欲大开。吃饱喝足之后，你觉得体内真气充盈。NOR",
            "HIC厨子厨艺了得，你饱餐了一顿，浑身上下都有了力气，内力也似乎更容易凝聚了。NOR",
            "HIC这厨子小试身手做了一桌好菜，你将饭菜吃下，运了运气，只觉得真气运转自如。NOR"
        }
    elseif index >= 91 and index <= 95 then
        -- role:addAttr("qi", -reduceQi)
        textArr = {
            "WHT你满怀期待地吃下食物，谁知一阵诡异的味道充斥口中，随即胃里便是一阵翻江倒海。NOR",
            "WHT这饭菜糊成一团，颜色暧昧，气味诡异，你吃了一口，顿时吐了一地。NOR",
            "WHT这饭菜焦黑一团，是人能吃的玩意儿吗？！你直接转手扔掉，不敢再吃，但腹中饥饿未减，一整天都觉得没力气。NOR"
        }
    elseif index >= 96 and index <= 98 then
        textArr = {
            "WHT厨子的手艺有点潮，你吃下食物，上吐下泻了整整一宿。NOR",
            "WHT你吃下了饭菜，饭菜的味道实在不敢恭维，你难受了一整天，丹田之中耗损了不少内力。NOR",
            "WHT你从未吃过难吃到如此清奇境界的食物，似乎连昨晚的夜宵都要吐干净了。NOR"
        }
    elseif index == 99 then
        textArr = {
            "WHT你吃下了饭菜，但这诡异的味道让你下意识以为有人在其中下了毒。不久腹中绞痛，连呼吸都变得困难起来。NOR",
            "WHT厨子似乎将什么毒草不小心混了进去，你吃下之后呕血不止，差点小命玩儿完。NOR",
            "WHT你吃下了饭菜，感觉和吞剑没什么两样。NOR"
        }
    else
        textArr = {
            "WHT这饭菜闻起来还算可口，谁知吃起来这般难吃，你被耗损了不少精力。NOR",
            "WHT厨子今日似乎性情不好，给你下了些猛料，你吃了以后腹中难受，一整天都无精打采的。NOR",
            "WHT你看着眼前焦黑一片的食物，嘴角抽了抽，试着吃了一口，一股焦臭味直冲脑门，差点把你熏得晕了过去。NOR"
        }
    end

    return textArr
end

--@desc 书房的描述
function HomelandDesc:getShuFangDesc(index)
    local textArr = {
        ["BLU大浪淘沙"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，书架之上摆着不少藏书。",
        ["HIB兼收并蓄"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，书架靠墙而放，上下两层分门别类地放着不少书籍。",
        ["CYN充箱盈架"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，书架之下放着几口书箱，只见书架书箱都被书籍塞得满满当当。",
        ["HIC五花八门"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，书架整整齐齐地放着好几排，其上分门别类地存放着各类书籍。",
        ["GRN汗牛充栋"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，只见此处的藏书书架已经多得放不下了，不少书被摞成堆摆放在书架一旁、",
        ["YEL书盈四壁"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案右侧摆放的则是书架，书架上早已经被塞满，多余的书籍数不胜数，摆放得房间到处都是，处处散发着书卷气息。",
        ["HIY包罗万象"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书案的四周环绕的全是整齐一致的书架，书架将书案环绕在其中，其上摆放着各类书籍。",
        ["RED坐拥百城"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书房内摆放着高高低低的书架，书架之上存放着各种各样珍稀的书籍。",
        ["WHT浩如烟海"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。书房里里外外全是书架，书架之上藏书之多，涉及之广，令人叹为观止。",
        ["HIW灿若星河"] = "这间书房布局讲究，靠窗处放着书案，书案旁挂着一幅字画，书案上放着一壶清茶。除此之外，书房内的空间几乎全部被书架占满，此处收藏着数不胜数的书籍，下至寻常书籍，上至各种绝世真本，无一不在其中，令人眼花缭乱，赞叹不已。"
    }

    local text = ""
    if textArr[index] then
        text = textArr[index]
    else
        text = textArr["BLU大浪淘沙"]
    end

    return text
end

function HomelandDesc:getViewScene()
    local index = math.random(1, 4)
    local text = {
        [1] = {
            "你坐在湖心亭亭台之上，泡一壶香茗，于这湖中央，观赏起这翠微湖。",
            "你品了一口香茗，看向那湖边杨柳，柳枝微微下垂，随风而动，如美人下腰，动人心扉。",
            "眼光轻转，三月的微风温柔无比，吹皱了整个湖面，层层波纹荡向湖边，令人心怡神旷。",
            "碧潭清池，辉映着湖光山色，天朗气清，倒影在水底的白云苍狗，参差交错，恍如幻境。",
            "一壶香茗已尽,你淡然一笑，缓缓站起，负手而立，只觉神清气爽，无半点疲惫之感。"
        },
        [2] = {
            "你命人放下纱帘，坐于湖心亭阴凉之处，置一杯冰镇酸梅汤，开始观赏起翠微湖。",
            "夏日炎炎，蝉鸣不已，炙烈的阳光将整个翠微湖照得透亮，满湖荷花已经盛开，缕缕香气萦绕亭台之间。",
            "冰镇酸梅汤化了一些，碎冰发出清脆的碰撞声，时光似乎于此凝滞，偶有微风拂过，将荷花枝头点得弯了弯。",
            "静谧的午后过去，天色渐晚，眼前的景色都渡上了一层金黄。",
            "暑气开始消散，翠微湖上不知何时泛来一叶小舟，穿行荷叶之间，水波远远荡开。你卷起纱帘，望向天边斜阳，一日的疲惫都一扫而空。"
        },
        [3] = {
            "你独坐于湖心亭之上，看天边云卷云舒，望翠微湖景色，取玉箫在手，吹起萧来。",
            "此时已是深秋时分，翠微湖岸边落叶积了一地，更远处小山上栽种的漫山枫树火红一片，随风翩然起舞。",
            "玉箫声远远传开，与秋风共缠绵，声音似是呜咽，又似是有人在耳旁低语，忽而又消失不见，只换得一声叹息。",
            "林中传来扑棱声，一群大雁飞掠入云霄之中。今日望雁归去，却不知来年能否再见，想至此，你心中莫名有些失落。",
            "一曲奏罢，你将玉箫仔细收好，四周又回归平静。凉爽的秋风拂过发梢，你觉得此时如这秋日的天空一般澄明，再无半分疲惫。"
        },
        [4] = {
            "你身披大氅，拥炉在怀，独坐湖心亭，开始欣赏翠微湖的景色。",
            "此时已是寒冬，翠微湖湖面早已被冰封，湖面一片晶莹剔透，水天之际都是一望无际的白。",
            "翠微湖岸的松柏之上挂满冰柱，似是摇摇欲坠，树下积雪之上有一串不知道什么小兽留下的脚印，一直延伸到林子深处。",
            "天空之中开始飘起鹅毛大雪，呵气成冰，你怀里搂着暖炉，一阵阵暖意流遍全身。",
            "你站起身来，站到亭外，飞雪如柳絮落满你全身，你心中畅快，想着何日去踏雪寻梅，疲劳也不翼而飞。"
        }
    }

    return text[index]
end

function HomelandDesc:getReadBookByTeaDesc()
    local text = {
        "茶半盏，书一卷，微风拂过书页，展开一段黄金屋之中的奇缘。",
        "这书讲的是江湖之中的奇闻异事，书中世界光怪陆离，虽真假不可考，但书中人物个个深入人心，棱角分明，令人流连其中故事，难以自拔。",
        "故事环环相扣，越发精彩起来，你读得津津有味，连手中清茶已冷都未能察觉。",
        "故事逐渐进行到尾声，你抿了口茶，心中陈杂期待与不舍，将整本书看完。",
        "你靠椅合眼，手指拂过书页，眼前浮光掠影，书中世界一幕幕出现在眼前，书中人物的一言一语，都尚自萦绕在耳畔。"
    }

    return text
end

--@desc: 副本调息文本
--@author:Liang SongQiang
--@time:2018-06-14 14:30:32
function HomelandDesc:getPranaymaDesc()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local time = role:getTimeLimitFlagTime("真气加成")

    local textArr

    local text1 = {
        "小炉新香，余烟绕梁，你盘膝坐在蒲团上，胸中充斥着淡淡熏香，心静如水，开始调息起来。",
        "你拈了个呼吸吐纳的心诀，悠长的呼吸之间充斥着熏香的气息，真气比往日更加激荡。",
        "香炉中的熏香中有助长功力的药物，你的真气汇聚于丹田，身上一阵暖意。",
        "香味使得你气息平稳，心无旁骛，修炼的内力也更加精纯。",
        "你将天地雨露尽数纳为己用，丹田逐渐充盈，似乎浑身都散发着熏香的淡淡香气。",
        "你闻着淡淡香气，心中平静了不少，推内力过周天，内力充沛了不少。",
        "你的呼吸之间似乎都是香味，真气也在呼吸之间更加凝聚。",
        "香炉之中香味渐渐淡去，你的调息也走到尾声，真气比往日充沛了不少。"
    }

    local text2 = {
        "你盘膝坐在蒲团之上，平心静气，开始调息。",
        "自然呼吸吐纳之间，你的真气似乎增加了。",
        "胸中呼吸悠长，浊气被你缓缓吐出，体内一阵暖流涌动。",
        "你将丹田内真气缓缓推往周身经脉，运行一周天，真气似乎更加充沛了。",
        "你心无杂念，丹田之内开始缓缓凝聚真气。",
        "真气在你体内流畅运行，使得你浑身舒畅。",
        "你体内真气涌动，一阵阵暖流袭往全身。",
        "在你的呼吸之间，胸中真气激荡，似乎收益不小。"
    }

    if time ~= 0 then
        textArr = text1
    else
        textArr = text2
    end

    return textArr
end

--@desc: 获取副本闭关文本
--@author:Liang SongQiang
--@time:2018-06-14 14:58:27
function HomelandDesc:getBiGuanDesc()
    local textArr = {
        "你静坐于蒲团之上，将内力自丹田推出。",
        "真气在体内涌动，气贯膻中，左右各升，走丹阳，行任督，将凝滞积淤之处一一冲开。",
        "呼吸吐纳之间气息通畅，流转自如，气敛入脊，周身罔间，行气如九曲珠，无往不利。",
        "气行百骸小周天，又收归丹田之中。",
        "天地之间清升浊降，你缓缓吐出一口浊气，丹田内真气充盈，连绵不绝。"
    }

    return textArr
end

--@desc: 获取仓库的描述
--@author:Liang SongQiang
--@time:2018-06-14 23:40:56
function HomelandDesc:getChuWuGuiDesc(map, room)
    local function getRoomStateDesc(ckCount)
        local desc = "普普通通，没有特别之处的仓库"
        if 0 <= ckCount and ckCount < 25 then
            desc = "普普通通，没有特别之处的仓库"
        elseif 25 <= ckCount and ckCount < 75 then
            desc = "宽阔明亮，摆放整齐的仓库"
        elseif ckCount > 75 then
            desc = "宽阔气派，陈设豪华的仓库"
        end

        return desc
    end

    local function getItemStateDesc(items)
        local desc = ""

        if not items or MapIsEmpty(items) then
            desc = "这里空无一物，没有放东西"
            return desc
        end

        desc = "这里放着"

        for i = 1, 3 do
            if items[i] then
                local itemAttr = Item:getOneItemByKey(items[i].itemId)

                desc = desc .. itemAttr.name .. "，"
            end
        end
        desc = string.sub(desc, 1, -4)
        return desc
    end

    local function getCWStateDesc(ckCount, itemCount)
        local percent = (itemCount / ckCount) * 100

        local desc = ""

        if 0 <= percent and percent < 25 then
            desc = "东西零零散散地放着，仓库显得空荡荡的。"
        elseif 25 <= percent and percent < 50 then
            desc = "存放的宝物不算很多，但已属不易。"
        elseif 50 <= percent and percent < 75 then
            desc = "宝物琳琅满目，几乎将仓库放得满满当当，让人目不暇接。"
        elseif 75 <= percent then
            desc = "此处集天下奇珍异宝，无所不有，令人大开眼界，叹为观止，感叹其主人真可谓富甲天下。"
        end

        return desc
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    if not map.mid or fq.mid ~= map.mid then
        return
    end

    local ckItems = role:getckItems()

    local ckCount = role:getAttr("ckLimit")

    local text = "这是一间"

    text = text .. getRoomStateDesc(ckCount) .. "，"

    text = text .. getItemStateDesc(ckItems) .. "。"

    text = text .. getCWStateDesc(ckCount, #ckItems)

    return text
end

--@desc: 初始管家谈话
--@author:Liang SongQiang
--@time:2018-06-19 01:43:46
function HomelandDesc:getGuanJiaOrginTalkDesc(role)
    local text = {
        "YEL" .. role.name .. "：我本是这房屋的管家，在这房中已待了有些年月了，实是不愿离开，若是少侠不弃，在下愿成为少侠的管家，这费用少收点也无妨。",
        "YEL" .. role.name .. "：少侠，在下听说您新置房屋，特上门来求个管家之职，不知少侠意下如何？",
        "YEL" .. role.name .. "：少侠，您这房屋好生气派，这选址亦是风水皆宜之处，在下不才，这管家之事略知一二，少侠若是有意，聘我为房屋管家，如何？"
    }
    local randomNum = math.random(1, #text)

    return text[randomNum]
end

--@desc:每日第一次管家交谈文本
--@author:Liang SongQiang
--@time:2018-06-23 18:10:28
--@role:
function HomelandDesc:getGuanJiaDayFirstTalk(role)
    local text = ""

    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)
    local tb =
        switch(
        tostring(lv),
        {
            ["1"] = "我初来驾到，还不便帮#ch#整改房屋，还请#ch#稍等几日，待我熟悉家中情况之后再做处理。",
            ["2"] = "房屋情况我已经了解，您如果有一些简单的事情可找我商谈，我最近正在联系，估计再过不久我便可为#ch#招募仆人了。",
            ["3"] = "目前我正在联系一些房屋改造的工人，如果成功的话，您日后便可自由改造房屋了。",
            ["4"] = "目前您可以任意改动房间了，但我如今能力有限，",
            ["5"] = "目前您已经可以任意改动房间，招募仆人了，我也会努力联系更多的匠人，宣传您的名称，这样您就可以改造更多房间招募更多好的仆从。",
            ["6"] = "目前您已经可以任意改动房间，招募仆人了，我也会努力联系更多的匠人，宣传您的名称，这样您就可以改造更多房间招募更多好的仆从。",
            ["7"] = "#ch#您可以自由改造房屋，招募仆从，有什么事情吩咐我一句即可。"
        }
    )

    text =
        "YEL" ..
        role.name ..
            "：#ch#，今日家中一切我都已经安排妥当了，" ..
                tb .. "\nCYN" .. role.name .. "跟你说起了屋内的诸多事务，经过这一番交谈，你与" .. role.name .. "又亲近了不少。"

    text = self:subChengHuText(text)

    return text
end

--@desc: 称号填充
--@author:Liang SongQiang
--@time:2018-06-29 15:34:02
function HomelandDesc:subChengHuText(text)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local sex = role:getAttr("sex")

    local age = role:getAge()

    local ch =
        switch(
        sex,
        {
            ["男"] = function()
                if age > 30 then
                    return "老爷"
                end

                return "少爷"
            end,
            ["女"] = function()
                if age > 30 then
                    return "夫人"
                end

                return "小姐"
            end
        }
    )

    text = string.gsub(text, "#ch#", ch)

    return text
end

--文本名字填充
function HomelandDesc:subNameText(text, name)
    text = string.gsub(text, "#mz", name)

    return text
end

--获取房主交谈文本
function HomelandDesc:getFzTalkDesc(status, jobTypeAttr, role, map)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local text = ""
    
    if status == "闹事" then
        text = jobTypeAttr.talk6
    else
        if map and not HomelandRoleUtil:checkRoleIsInRightRoom(role,map) then
            text = jobTypeAttr.talk5
        elseif status == "正常" then
            text = jobTypeAttr.talk1
        end
    end

    text = self:subChengHuText(text)

    return "YEL" .. role.name .. "：" .. text
end

--获取客人交谈文本
function HomelandDesc:getKrTalkDesc(status, jobTypeAttr, role, map)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local text = ""

    if status == "闹事" then
        text = jobTypeAttr.talk8
    else
        if map and not HomelandRoleUtil:checkRoleIsInRightRoom(role,map) then
            text = jobTypeAttr.talk5
        elseif status == "正常" then
            text = jobTypeAttr.talk3
        end
    end

    text = "YEL" .. role.name .. "：" .. text

    return text
end

--获取正常交谈文本
function HomelandDesc:getNorTalkDesc(status, jobTypeAttr, role, map)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local text = ""

    if status == "闹事" then
        text = jobTypeAttr.talk8
    else
        if map and not HomelandRoleUtil:checkRoleIsInRightRoom(role,map) then
            text = jobTypeAttr.talk5
        elseif status == "正常" then
            text = jobTypeAttr.talk7
        end
    end

    text = "YEL" .. role.name .. "：" .. text
    text = self:subChengHuText(text)

    return text
end

--@desc 房间扩建文本
function HomelandDesc:getEnlargeRoomDesc(map)
    local gj = map:getRole("guanjia1001")

    local textArr = {
        "你将扩建房间的要求和资金都交给了" .. gj.name .. "，" .. gj.name .. "听完了你的要求点了点头，随后匆匆忙忙地走了出去。",
        gj.name .. "随即便去购置木材、石料等物，又招揽匠师，择黄道吉日，破土动工。",
        "匠人们逐步将要扩建的房间建造了出来，事情进行地十分顺利，您要求扩建的新房间已是建成了。"
    }

    return textArr
end

--@desc: 做饭文本
--@author:Liang SongQiang
--@time:2018-06-29 15:33:45
function HomelandDesc:getMakeDinnerText()
    local textAttr = {
        "厨子动手生火，又将一应蔬果蛋肉取来，开始洗菜切菜地忙活起来。",
        "不一会儿，一顿饭食已经是制作完毕。"
    }
    return textAttr
end

--@desc: 获取仆人描述
--@author:Liang SongQiang
--@time:2018-07-30 10:45:15
function HomelandDesc:getRoleDcs(role, isNeedAgeDesc, isNeedLookDesc, isNeedQiDesc, isNeedPriceDesc)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    isNeedAgeDesc = Helper:getDef(isNeedAgeDesc, true)
    isNeedLookDesc = Helper:getDef(isNeedLookDesc, true)
    isNeedQiDesc = Helper:getDef(isNeedQiDesc, true)
    isNeedPriceDesc = Helper:getDef(isNeedPriceDesc, true)
    local desc = ""
    local sex = "他"
    if role.sex == "女" then
        sex = "她"
    end

    local dsc = ""
    if role.dsc then
        dsc = role.dsc --初始化进去的人物属性
    end

    -- -------------------------------------------------------------------
    -- local jobstr = HomelandRoleUtil:getCHAJobTypeName(role.jobType)
    -- local characterStr = HomelandRoleUtil:getCHAXingGeName(role.character)
    -- local fidelityStr = HomelandRoleUtil:getGuanJiaFidelity(role.defaultZhongCheng)

    desc = desc .. sex .. "就是" .. tostring(role.name) .. "。" .. tostring(dsc) .. "\n"

    -- if jobstr then
    --     desc = desc..sex.."是一名"..jobstr..","
    -- end

    -- if characterStr then
    --     desc = desc..sex.."的性格"..characterStr..","
    -- end

    -- if fidelityStr then
    --     desc = desc..fidelityStr.."。\n"
    -- end

    if isNeedAgeDesc == true then
        desc = desc .. sex .. "看起来约" .. role:getAgeDsc() .. "，"
    end

    if role:getFaceDsc() ~= nil and isNeedLookDesc == true then
        desc = desc .. sex .. "生得" .. role:getFaceDsc() .. "NOR。\n"
    end
    if isNeedQiDesc == true then
        desc = desc .. sex .. "的武功看来" .. role:getKongfuDsc() .. "NOR" .. "，出手似乎" .. role:getJialiDsc() .. "NOR。\n"

        desc = desc .. sex .. "看起来" .. role:getQiDsc() .. "NOR。\n"
    end
    if isNeedPriceDesc == true and role.price and temp[role.price_unit] then
        local priceStr = "雇佣价格:"
        if role.jobType == "guanjia001" then
            priceStr = priceStr .. role.price .. temp[role.price_unit]
        else
            priceStr = priceStr .. math.floor((role.price / 14)) .. temp[role.price_unit] .. "/天"
        end

        desc = desc .. "\n \n\nYEL" .. priceStr
    end

    return desc
end

--@desc: 搬家文本
--@author:Liang SongQiang
--@time:2018-06-30 15:25:47
function HomelandDesc:getMoveHouseText()
    local text =
        "锣鼓喧天，鞭炮齐鸣。|#AAAA四邻纷纷贺喜，处处打点一新，你正式搬入了新家。|#AAAA于此，你再不是无根漂萍，见惯江湖风雨，终有栖身之地。|#AAAA想往后引流觞曲水，宴四方知己，或布衣躬耕，笑谈天下之事.    |#AAAA凡心之所向，都能逐一偿之，又岂非人间快事？"

    return text
end

function HomelandDesc:getMoveLandText(dpId)
    --@RefType [src.app.models.HomelandModel.DiQiModel#DiQiModel]
    local DiQiModel = require("app.models.HomelandModel.DiQiModel")

    local dpInfo = DiQiModel:getDpInfoById(dpId)

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local map = role:getMapById(dpInfo.fbId)

    local mapName = map.name

    local dpName = dpInfo.name

    local text =
        "平安福地，紫微指栋，吉庆人家，春风架梁。|#AAAA你搬入了#dn#，此乃是#mn#富庶之地，周遭邻里无不是非富即贵之人。|#AAAA中隐隐于市，处市井繁华之地，建阔屋高堂。|#AAAA高朋满座，胜友如云，邻里好友皆来祝贺你的乔迁之喜。|#AAAA乔迁之宴，一直到半夜方才结束，宾主尽欢，一一送走好友邻里，你心中不禁升起些许满足之感。"

    text = string.gsub(text, "#dn#", dpName)
    text = string.gsub(text, "#mn#", mapName)

    return text
end

--@desc: 开始读书的文本
--@author:Liang SongQiang
--@time:2018-06-30 15:31:53
--@bookName: 书名
function HomelandDesc:getStartReadDesc(bookName,isBookHouse,isUseShuTong,shuTongName)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    
    local text = ""
    if isBookHouse == 1 then
        if isUseShuTong == 1 then
            text = "HIC你走入书房，从书架上取下一本" .. bookName .. "HIC交给了书童"..shuTongName.."。\n"
            text = text ..shuTongName.. "接过书籍，朗声读了起来，声音充斥着整个书房，你悠然地听着，逐渐融入其中.."
        else
            text = "HIC你走入书房，最终从书架上取下一本【" .. bookName .. "HIC】，走到书桌前坐下。\n"
            text = text .. "HIC你认真地品味着书中的文字，慢慢地融入其中。"
        end
    else
        text = "HIC你捧起书本，一头扎进去，沉浸其中。"
    end

    return text
end

--@desc: 结束阅读
--@author:Liang SongQiang
--@time:2018-06-30 15:37:56
--@bookName: 书名
function HomelandDesc:getEndReadDesc(bookName,isBookHouse,isUseShuTong)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local text = ""
    if isBookHouse == 1 then
        if isUseShuTong == 1 then
            --@desc 经验上限到达的情况。
            --HIC你听着这书中之句，只觉晦涩难懂，再无精进，于是便叫停了本次读书。
            text = "HIC书童朗读了许久，已是口干舌燥，不能再读了，你见此状便也就此叫停。"
        else
            text = "HIC你敛了敛神，站起了身，将" .. bookName .. "HIC放回书柜，书房静逸的氛围让你受益不浅。"
        end
    else
        text = "YEL你敛了敛心神，打算给自己找些事情做。"
    end

    return text
end

function HomelandDesc:getEmployLayerTitalDsc(num)
    local dsc = ""
    if num == 0 then
        dsc = "#ch#，已经没有来应聘的了！"
    elseif num == 1 then
        dsc = "#ch#，这是最近上门来求工作的，是否要雇佣？"
    elseif num > 1 then
        dsc = "#ch#，这几人是最近上门来求工作的，是否要雇佣？"
    end

    dsc = self:subChengHuText(dsc)
    return dsc
end

--获取赏赐文本
function HomelandDesc:getAwardText(role)
   	local characterId = role.character
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local characterAttr = HomelandRoleUtil:getCharacterAttr(characterId)

    local text = characterAttr.rewardtext

    text = self:subChengHuText(text)

    text = self:subNameText(text, role.name)

    return text
end

--获取遣散文本
function HomelandDesc:getFiredText(role)
   	local characterId = role.character
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local characterAttr = HomelandRoleUtil:getCharacterAttr(characterId)

    local text = characterAttr.leavetext

    text = self:subChengHuText(text)

    text = self:subNameText(text, role.name)

    return text
end

--根据身世获取闲聊文本
--shenShiId 身世Id
--result 成功/失败
function HomelandDesc:getChatText(role, result)
    local chatId = ""
    local text = ""

    if result == true then
        local chatIdList = RoleLife:getSuccessChatIdList(role.shenShi)
        chatId = chatIdList[math.random(1, #chatIdList)]
        local chatAttr = chatTopicList[chatId]
        if chatAttr == nil then
            print("资源错误，familyspecial[chatTopic]表中没有 没有此chatId = ",chatId)
            return
        end
        text = chatAttr.succ
    elseif result == false then
        local chatIdList = RoleLife:getFailChatIdList(role.shenShi)
        chatId = chatIdList[math.random(1, #chatIdList)]
        local chatAttr = chatTopicList[chatId]
        if chatAttr == nil then
            print("资源错误，familyspecial[chatTopic]表中没有 没有此chatId = ",chatId)
            return
        end
        text = chatAttr.fail
    end

    text = self:subChengHuText(text)

    text = self:subNameText(text, role.name)

    return text
end

--获取身世信息
function HomelandDesc:getShenShiInFo(role)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)
    local shenShiId = role.shenShi
    if role.jobType == "guanjia001" then
        return "无"
    end
    local text = RoleLife:getLifeInfoTextByLv(shenShiId, lv)

    return text
end

--获取交谈新增身世文本
function HomelandDesc:getTalkShenShiText(role)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local text = RoleLife:getTalkText(role.shenShi)

    text = self:subChengHuText(text)

    text = self:subNameText(text,role.name)

    return "YEL"..role.name.."："..text
end

-- 获取身世事件后交谈文本;talktext1
function HomelandDesc:getTalkTextAfteLifeEvent(role)
    local text = RoleLife:getTalkAftEventText(role.shenShi)

    text = self:subChengHuText(text)

    text = self:subNameText(text,role.name)

    return "YEL"..role.name.."："..text
end

-- 获取身世事件后闲聊文本;liftEvent1
function HomelandDesc:getChatTextAfteLifeEvent(role)
    local life = RoleLife:getLifeInfo(role.shenShi)

    local textArr = string.split(life.lifeEvent1, ";")
    
    local text = textArr[math.random(1, #textArr)] or ""

    text = self:subNameText(text, role.name)

    return text
end

-- -- 获取事件中对话文本;eventtalk
-- function HomelandDesc:getTalkTextLiftEventing(role)
--     local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--     local shenShiId = role.shenShi
--     local life = lifeList[shenShiId]
--     local text = ""

--     text = life.eventtalk

--     text = self:subChengHuText(text)

--     return text
-- end

--@desc 派遣任务文本
function HomelandDesc:getStartDispatchTaskDesc(taskId, map, npcId, successRate)
    local textArr = {
        "你将#tn#委托给了#nn#。",
        "HIC你将#tn#告知了#nn#。得知来龙去脉，#nn#敛容拱手道：“为主公分忧，是我等分内之事。此事交给我吧。”言毕，就飘然而去。NOR",
        "#nn#还承诺到，会飞鸽传书将任务中的见闻持续传达回来，说完这一切便转身出去了。",
        "没过多久，一只信鸽飞了进来，带来了一张小纸条。"
    }

    local text = {}

    local npcName = map:getRole(npcId).name

    --@RefType [src.app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
    local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
    local taskName = DispatchTaskManager:getDispatchTaskName(taskId)

    for i = 1, #textArr do
        local t = string.gsub(textArr[i], "#tn#", taskName)
        t = string.gsub(t, "#nn#", npcName)
        table.insert(text, t)
    end

    return text
end

--@desc: 获取解锁身世时的输出文本
--@author:Liang SongQiang
--@time:2018-08-02 14:10:46
--@lifeId: 身世Id
--@name: npc名字
function HomelandDesc:getChatByShenShiDesc(lifeId, name)
    local text = RoleLife:getChatByLifeDesc(lifeId)

    text = self:subChengHuText(text)

    text = self:subNameText(text,name)

    return text
end

--@desc: 获取身世任务弹窗标题
--@author:Liang SongQiang
--@time:2018-08-03 21:48:53
--@lifeId 身世ID
function HomelandDesc:getShenShiTaskDialogTitle(lifeId,role)
    local text = RoleLife:getDialogTitle(lifeId)

    text = self:subChengHuText(text)

    text = self:subNameText(text,role.name)
    return text
end

--@desc: 获取身世概况
--@author:Liang SongQiang
--@time:2018-08-03 21:51:27
function HomelandDesc:getShenShiDescription(lifeId,role)
    local text = RoleLife:getLifeDesc(lifeId)

    text = self:subChengHuText(text)

    text = self:subNameText(text,role.name)
    
    return text
end

--@desc: 获取任务标题
--@author:Liang SongQiang
--@time:2018-08-03 21:56:22
function HomelandDesc:getShenShiTitle(lifeId)
    local title = RoleLife:getLifeTitle()

    return title
end

--@desc: 获取接受任务时的输出文本
--@author:Liang SongQiang
--@time:2018-08-04 16:14:36
function HomelandDesc:getAcceptTaskText(lifeId,name)
    local text = RoleLife:getAcceptTaskText(lifeId)

    text = self:subChengHuText(text)
    
    text = self:subNameText(text,name)

    return text
end


function HomelandDesc:getUseShuAnText()
    local text = ""

    local textArr = {
        "HIY你在书案前坐下，收拾心情，用簪花小楷写了一封邀请函，邀请收信人来家中一叙。NOR",
        "HIY你在书案前坐下，略微思索后，用柳体写了一封邀请函，邀请收信人来家中一叙。NOR",
        "HIY你在书案前坐下，思绪翻涌，用狂草写了一封邀请函，邀请收信人来家中一叙。NOR",
    }

    text = textArr[math.random(1,#textArr)]

    return text
end

return HomelandDesc
0000000000