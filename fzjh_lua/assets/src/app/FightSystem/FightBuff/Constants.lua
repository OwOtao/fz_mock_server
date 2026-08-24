local Constants = {}

Constants.BuffSystemEventType = {}

Constants.BuffSystemEventType.UpdateRoleState = 1

-- 触发类型
Constants.BuffTriggerType = {}

-- 条件ID：1=持有Buff(属性加成or特殊控制)一直生效；参数：无（填0）
Constants.BuffTriggerType.State = 1
-- 条件ID：2=添加Buff；参数：无（填0）
Constants.BuffTriggerType.Add = 2
-- 条件ID：3=任意角色招式攻击结束；参数：无（填0）
Constants.BuffTriggerType.SomeBodyAttackEnd = 3
-- 条件ID：20=使用被动招式；参数：0=无特殊条件、1=需要命中成功、
-- 2=需要普通招架成功、3=需要格挡招架成功、4=需要轻功闪躲成功、
-- 5=需要轻功跳离成功
Constants.BuffTriggerType.UseAutoZhao = 20
-- 条件ID：21=使用主动招式；参数：0=全类型，1=攻击(主伤害)，2=释放(主辅助)；
-- 和主动招式类型;activeType对应
Constants.BuffTriggerType.UseActiveZhao = 21
-- 条件ID：22=使用主动功能按钮；参数：1=治疗、2=逃跑、3=易武
Constants.BuffTriggerType.UseActiveButton = 22
-- 条件ID：40=受到敌方被动招式；参数：0=无特殊条件、1=命中成功、
-- 2=普通招架成功、3=格挡招架成功、
-- 4=轻功闪躲成功、5=轻功跳离成功
Constants.BuffTriggerType.UnderAutoZhao = 40
-- 条件ID：41=受到敌方主动攻击；参数：0=任意，1=伤害类(攻击)，
-- 2=辅助类(释放)，3=恢复类
Constants.BuffTriggerType.UnderActiveZhao = 41
-- 条件ID：60=获得指定Buff；参数：BuffID
Constants.BuffTriggerType.GetBuffId = 60
-- 条件ID：61=获得指定buffClass类型Buff；参数：buffClass
Constants.BuffTriggerType.GetBuffClass = 61
-- 条件ID：62=获得任意Buff；参数：无（填0）
Constants.BuffTriggerType.GetAnyBuff = 62
-- 条件ID：80=当前Buff被删除；参数：无（填0）
Constants.BuffTriggerType.RemoveBuff = 62

-- 激活条件
Constants.BuffActiveType = {}
-- 条件ID：1=自身持有特定BuffID；参数：BuffID
Constants.BuffActiveType.SelfHasBuffID = 1
-- 条件ID：2=目标持有特定BuffID；参数：BuffID
Constants.BuffActiveType.TargetHasBuffID = 2
-- 条件ID：3=自身持有特定BuffClass；参数：BuffClass
Constants.BuffActiveType.SelfHasBuffClass = 3
-- 条件ID：4=目标持有特定BuffClass；参数：BuffClass
Constants.BuffActiveType.TargetHasBuffClass = 4
-- 条件ID：20=当前buff触发间隔N次；参数：间隔次数N
Constants.BuffActiveType.TriggerGap = 20
-- 条件ID：21=当前buff触发N次后；参数：延迟次数N
Constants.BuffActiveType.TriggerAfter = 21
-- 条件ID：40=自身持有指定武器类型；参数：武器第一类型
Constants.BuffActiveType.SelfWeaponType = 40
-- 条件ID：41=目标持有指定武器类型；参数：武器第一类型
Constants.BuffActiveType.TargetWeaponType = 41

-- 移除类型
Constants.BuffRemoveType = {}
-- 永不移除
Constants.BuffRemoveType.Never = 0
-- 触发多少轮后移除
Constants.BuffRemoveType.TriggerRound = 2
-- 离开战斗移除
Constants.BuffRemoveType.LeaveBattle = 4
-- 不持有指定武器类型移除
Constants.BuffRemoveType.NoWeaponType = 5
-- 护盾值为0移除
Constants.BuffRemoveType.ShieldZero = 6
-- 承伤量(扣除气血值)
Constants.BuffRemoveType.SufferDamge = 7

-- 效果类型
Constants.EffectType = {}

-- 1=禁用被动招式
Constants.EffectType.BanAutoZhao = 1
-- 2=禁用主动招式
Constants.EffectType.BanActiveZhao = 2
-- 3=禁用轻功闪躲
Constants.EffectType.BanQinggongDodge = 3
-- 5=禁用普通招架
Constants.EffectType.BanNormalParry = 5
-- 7=驱散指定BuffClass类型
Constants.EffectType.RemoveBuffClass = 7
-- 8=免疫主动招式添加的指定BuffClass类型
Constants.EffectType.ImmuneActiveBuffClass = 8
-- 特殊效果类 11 被动招式随机基本武学(主动招式计算用的平均普通气血伤害也是基本武学的值) 无 无叠加 开发迭代2
Constants.EffectType.RandomBaseAutoZhao = 11

-- * **效果类型ID=12，影响当前主动招式剩余CD**
-- * 效果触发节点：3=被添加Buff
-- * 效果功能执行：被添加Buff的角色，所有主动冷却CD>0的指定类型主动招式，CD时间同时增加或者减少N秒。
-- * 只有主动招式剩余冷却CD>0的主动招式会受影响。
-- * effectTypeParam配置指定的主动招式类型，
-- * 格式：0=任意主动；1=主动招式攻击类，2=主动招式释放类。
-- * 对应类型：武功主动招式组合.xlsx 的 主动招式类型;activeType
-- * argsParam配置总Buff表效果伤害ID。
-- * ID读取 总Buff表效果伤害.xlsx 的 id
-- * 效果值N = 总Buff表效果伤害ID的公式返回值
-- * 效果值N单位：秒
-- * 公式返回值可正可负
-- * 主动招式CD受影响后值 = max(主动招式剩余冷却CD+效果值, 0)
-- * 效果生效表现：无特殊需求（用Buff添加表现即可）
Constants.EffectType.AddActiveZhaoRemainCD = 12

-- * **效果类型ID=13，将Buff持有者身上指定类型的Buff转移到Buff施放者身上**
-- * 效果触发节点：3=被添加Buff
-- * 效果功能执行：被添加Buff的角色，在获得Buff时，将身上指定类型的N个Buff转移到Buff施放者身上。
-- * effectTypeParam配置：可转移的Buff范围，配置格式：范围类型#抽取Buff数量
-- * 范围类型有：BuffAll=任何Buff、BuffClass=BuffClass类型、BuffID=BuffID类型
-- * 抽取Buff数量，配置整数。每个抽取平均随机。
-- * argsParam根据Buff范围配置对应参数：
-- * 范围=BuffAll，参数不填
-- * 范围=BuffClass，格式：BuffClass#BuffClass。BuffClass读取 `总Buff表.xlsx 的 [Buff类型;buffClass]`
-- * 范围=BuffID，格式：BuffID#BuffID。BuffID读取 `总Buff表.xlsx 的 [buff编号;id]`
-- * 转移Buff 包含Buff自身的参数，例如：Buff效果值、存活次数、护盾生命。
-- * 效果生效表现：
-- * 提示文本位置：T5=角色头顶弹字提示(招式组合)
-- * 招式组合结束，如果实际抽取到的Buff数量>0，在Buff施放者头顶弹出文本“窃取成功”。同时攻击目标身上buff删除（会显示buff删除文本）。
-- * 文本配置在Buff效果表
-- * 实际抽取到的Buff数量=0，不显示弹字。
Constants.EffectType.TransferBuff = 13

-- * **效果类型ID=14，使被动招式攻击普通气血伤害无法被护盾抵消**
-- * 效果触发节点：40=造成被动招式伤害
-- * 效果功能执行：Buff持有角色使用被动招式造成的气血伤害，受击者身上的气血护盾无法抵消伤害。

-- * 效果生效表现：无特殊表现。
-- * 效果值叠加方式：无
Constants.EffectType.RealDamage = 14

-- * **效果类型ID=15，战斗中将Buff持有者的武器卸下**
-- * 效果触发节点：3=被添加Buff
-- * 效果功能执行：Buff添加后，立刻将Buff持有者的武器改为拳脚，对应受击、武学、主动等都一起修改。被改变武器的角色，已经在攻击队列的主动会自动取消。

-- > 例如：buff添加节点是攻击前，给敌人加buff，则这一次目标在受击过程是拳脚受击。
-- > buff添加节点是攻击后，给自己加buff，这次攻击还带着武器，招式组合结束才切换武器、主动。
-- * 效果生效表现：无特殊表现。
-- * 效果值叠加方式：无
Constants.EffectType.UnmountWeapon = 15

-- * **效果类型ID=16，禁用战斗易武、恢复、逃跑**

-- * 效果触发节点：4=使用战斗功能按钮
-- * 效果功能执行：无法使用功能按钮（可指定禁用功能）
-- * 指定类型配置在 `效果类型参数;effectTypeParam`
-- * 配置格式：功能类型#功能类型
-- * 功能类型：healthy=恢复、changeWeapon=易武、runAway=逃跑
-- * 效果生效表现：
-- * 玩家点击禁用的功能按钮时，tips弹出对应功能使用失败文本。
-- * 效果生效表现：无
Constants.EffectType.DisableFunction = 16

-- 武器切换
Constants.EffectType.ChangeWeapon = 17

-- 额外被动技能触发buff添加器
Constants.EffectType.ExtraAutoSkillBuffAdder = 18

-- 效果类型ID=19，被动攻击必定被轻功闪躲
-- 效果触发节点：13=造成被动招式攻击判定命中、15=造成被动招式攻击判定普通招架
-- 效果功能执行：判定改为轻功闪躲。如果被动攻击目标持有效果类型ID=3，禁用轻功闪躲，禁用优先，本次效果不执行。
-- 效果生效表现：无
Constants.EffectType.AutoSkillDodge = 19

-- 效果类型ID=20，被动攻击必定被普通招架

-- 效果触发节点：13=造成被动招式攻击判定命中、14=造成被动招式攻击判定轻功闪躲
-- 效果功能执行：判定改为普通招架。如果被动攻击目标持有效果类型ID=5，禁用普通招架，禁用优先，本次效果不执行。
-- 效果生效表现：无
-- 20=闪躲成功必定触发轻功跳离
Constants.EffectType.AutoSkillParry = 20

-- 21=必定触发轻功跳离(受主动攻击命中后)
-- 22=招架成功必定触发招架格挡
-- 23=必定触发格挡招架(受主动攻击命中后)
-- 30=被动招式伤害减免(减免值=公式返回值)
Constants.EffectType.AutoZhaoReductionOfInjurySub = 30
-- 31=被动招式伤害减免(比例)
Constants.EffectType.AutoZhaoReductionOfInjury = 31
-- 32=主动招式直接减免(减免值=公式返回值)
Constants.EffectType.ActiveZhaoReductionOfInjurySub = 32
-- 33=主动招式直接伤害减免(比例)
Constants.EffectType.ActiveZhaoReductionOfInjury = 33

-- * **效果类型ID=34，受非穿透属性被动招式攻击普通气血伤害固值减免N点**
-- * 效果触发节点：20=受被动招式攻击造成伤害
-- * 效果功能执行：Buff持有者受到的被动招式攻击，如果攻击者身上没有Buff效果=14，被动招式造成的气血伤害，伤害值会被修正N点，修正规则见 [角色战斗属性与战斗伤害/招式伤害计算公式/被动招式/被动招式实际伤害与分摊规则](角色战斗属性与战斗伤害) 内**单个招式气血伤害(Buff)**公式。
-- * 效果值N=argsParam配置的总Buff表效果伤害ID对应返回结果值。ID读取 总Buff表效果伤害.xlsx 的 id
-- * 效果生效表现：
-- * T1=角色头顶弹字提示(受击帧)，受招式攻击时，每个受击帧伤害弹字变成配置的文本，例如：`-0(卸力1000)`
-- * T4=界面战斗信息区伤害结算文本被替换，例如`$n卸开了$Bfd点伤害`
-- * 替换文本内包含动态参数，具体替换规则见 [输出文本动态参数说明](输出文本动态参数说明.xlsx)
-- * 效果值叠加方式：同效果类型ID效果值N的总和。
Constants.EffectType.UnderAutoZhaoPierceQiDamageReduction = 34

-- * **效果类型ID=35，受非穿透属性被动招式攻击普通气血伤害固值减免N%**
-- * 效果触发节点：20=受被动招式攻击造成伤害
-- * 效果功能执行：同 效果类型ID=34
-- * 效果生效表现：同 效果类型ID=34
-- * 效果值叠加方式：同效果类型ID效果值N%的最大值。
Constants.EffectType.UnderAutoZhaoPierceQiDamageRateReduction = 35

-- 伤害结算类 40 造成被动招式攻击伤害比例N%影响目标当前属性 effectTypeParam配置指定目标类型和影响属性类型，N=argsParam配置的总Buff表效果伤害ID对应返回结果值 算最大值 Buff效果携带者使用被动招式攻击时触发效果，预计造成的X点伤害 影响指定目标的指定当前属性，属性按N%比例增加或者减少int(X*N%)点。 界面战斗信息区新增描述文本，角色头顶弹字提示（自身或者目标都有），界面战斗信息区伤害结算文本被替换 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID 。 影响目标，自身=self、受击者=def。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id	不填	迭代3新增
Constants.EffectType.SelfAutoZhaoEffectCurrAttr = 40

-- 伤害结算类 41 造成主动招式直接伤害比例N%影响目标当前属性 effectTypeParam配置指定目标类型和影响属性类型，N=argsParam配置的总Buff表效果伤害ID对应返回结果值 算最大值 Buff效果携带者使用主动招式攻击时触发效果，预计造成的X点直接伤害 影响指定目标的指定当前属性，属性按N%比例增加或者减少int(X*N%)点。 界面战斗信息区新增描述文本，角色头顶弹字提示（自身或者目标都有），界面战斗信息区伤害结算文本被替换 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID 。 影响目标，自身=self、受击者=def。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id	不填	迭代3新增
Constants.EffectType.SelfActiveZhaoEffectCurrAttr = 41

-- 伤害结算类 42 受被动招式攻击伤害按N%影响目标当前属性 effectTypeParam配置指定目标类型和影响属性类型，N=argsParam配置的总Buff表效果伤害ID对应返回结果值 算最大值 Buff效果携带者受被动招式攻击时触发效果，预计受到X点伤害（X是受30~33影响后的伤害量） 影响指定目标的指定当前属性，属性按N%比例增加或者减少int(X*N%)点。指定目标可配置0=自身或者1=攻击者。 界面战斗信息区新增描述文本，角色头顶弹字提示（自身或者目标都有），界面战斗信息区伤害结算文本被替换 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID 。 影响目标，自身=self、攻击者=atk。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id	不填	迭代3新增
Constants.EffectType.TargetAutoZhaoEffectCurrAttr = 42

-- 伤害结算类 43 受主动招式直接伤害比例N%影响目标当前属性 effectTypeParam配置指定目标类型和影响属性类型，N=argsParam配置的总Buff表效果伤害ID对应返回结果值 算最大值 Buff效果携带者受主动招式攻击，预计受到X点伤害直接伤害（X是受30~33影响后的伤害量） 影响指定目标的指定当前属性，属性按N%比例增加或者减少int(X*N%)点。指定目标可配置0=自身或者1=攻击者。 界面战斗信息区新增描述文本，角色头顶弹字提示（自身或者目标都有），界面战斗信息区伤害结算文本被替换 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID 。 影响目标，自身=self、攻击者=atk。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id	不填	迭代3新增
Constants.EffectType.TargetActiveZhaoEffectCurrAttr = 43

-- 需要开发 100=比例影响当前属性 qi=当前气血、qiMax=当前气血上限、neili=当前内力 百分比dynamicArg1，填写小数
Constants.EffectType.FixedMulCurrAttr = 100

-- 需要开发 101=比例影响属性 这里放战斗属性ID 百分比dynamicArg1，填写小数，可正负
Constants.EffectType.FixedMulAttr = 101

-- 需要开发 120=动态影响固定值当前属性 qi=当前气血、qiMax=当前气血上限、neili=当前内力 主动攻击伤害表的ID 主动基础伤害 填伤害增长倍率dynamicArg1
Constants.EffectType.AddCurrAttr = 120

-- 需要开发 121=动态影响固定值属性加成 这里放战斗属性ID 主动攻击伤害表的ID 主动基础伤害 填伤害增长倍率dynamicArg1
Constants.EffectType.AddAttr = 121

-- 主动招式攻击伤害值 = 被动招式攻击均值 * 攻击伤害强度返回值 * 伤害增长倍率dynamicArg1 + 主动基础伤害
-- dynamicArg1=从 武功主动招式组合.xlsx 传值过来的

-- 消耗影响类 200 体力消耗 固值影响N "体力消耗的影响见文档[角色战斗属性与战斗伤害]。
-- effectTypeParam配置消耗来源招式类型，在dynamicArg1配置比例影响值N" 格式：0=被动和主动；1=被动招式，2=主动招式 格式：小数 预留扩展设计，暂不开发
Constants.EffectType.AddTiliCost = 200

-- 消耗影响类 201 体力消耗 比例影响N% 同200 格式：小数 预留扩展设计，暂不开发
Constants.EffectType.MulTiliCost = 201
-- 消耗影响类 210 内力消耗 固值影响N 同200 格式：小数 预留扩展设计，暂不开发
Constants.EffectType.AddNeiliCost = 210
-- 消耗影响类 211 内力消耗 比例影响N% 同200 格式：小数 预留扩展设计，暂不开发
Constants.EffectType.MulNeiliCost = 211
-- 需要新增QTE事件表（待新建）

-- 属性影响类 130 角色气血护盾生命值修正N点并激活气血护盾 N=argsParam配置的总Buff表效果伤害ID对应返回结果值，影响见文档[角色战斗属性与战斗伤害] 各自计算 | 不填 总Buff表效果伤害ID。ID读取 总Buff表效果伤害.xlsx 的 id 迭代3新增
Constants.EffectType.ShieldHp = 130

-- * **效果类型ID=141，角色特殊战斗属性固值修正N点**
-- * 效果触发节点：无特殊触发节点，持有Buff期间生效
-- * 效果功能执行：影响角色战斗属性，影响公式见 [角色战斗属性与战斗伤害/角色特殊战斗属性/被动气血伤害免伤值](角色战斗属性与战斗伤害) 和 [角色战斗属性与战斗伤害/角色特殊战斗属性/主动气血伤害免伤值](角色战斗属性与战斗伤害)
-- * effectTypeParam配置角色属性ID，格式：影响的具体属性ID查看 `表[角色特殊战斗属性].id`
-- * argsParam配置 计算免伤的效果伤害ID#计算免伤上限的效果伤害ID。
-- * 效果伤害ID读取 `表[总Buff表效果伤害].id`
-- * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值
-- * 效果生效表现：无
-- * 效果值叠加方式：同效果类型ID效果值N的总和。
Constants.EffectType.SpecialAttrValueFix = 140

-- 判定影响类 300 普通闪躲成功，概率影响目标指定角色当前属性N点 "可输入4个参数。
-- 参数1：影响目标，在argsParam配置。
-- 参数2：影响的角色当前属性，在effectTypeParam配置。
-- 参数3：影响值，在argsParam配置具体值或者伤害公式ID（通过ID计算的返回值就是实际影响值）。
-- 参数4：生效概率，在argsParam配置。" 算总和 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID#生效概率 。 影响目标，自身=self、攻击者=atk。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id。生效概率，配置范围1~100，可以调用Buff传入的动态参数。	迭代4新增
Constants.EffectType.TargetAutoDodgeEffectCurrAttr = 300

-- 判定影响类 301 普通招架成功，概率影响目标指定角色当前属性N点 "可输入4个参数。
-- 参数1：影响目标，在argsParam配置。
-- 参数2：影响的角色当前属性，在effectTypeParam配置。
-- 参数3：影响值，在argsParam配置具体值或者伤害公式ID（通过ID计算的返回值就是实际影响值）。
-- 参数4：生效概率，在argsParam配置。" 算总和 | 格式：影响属性类型，qi=当前气血、qiMax=当前气血上限、neili=当前内力 格式：影响目标#效果伤害ID#生效概率 。 影响目标，自身=self、攻击者=atk。效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id。生效概率，配置范围1~100，可以调用Buff传入的动态参数。	迭代3新增
Constants.EffectType.TargetAutoParryEffectCurrAttr = 301

-- 效果类型ID=311，普通招架成功，根据受到伤害影响目标指定角色当前属性N点
-- 参数1：影响目标,在argsParam配置。
-- 参数2：影响的角色当前属性，在effectTypeParam配置。
-- 参数3：效果值修正值公式ID,在argsParam配置具体值或者伤害公式ID（通过ID计算的返回值就是实际影响值）。
-- 参数4：生效概率,在argsParam配置。
Constants.EffectType.TargetAutoParryOnHitDamageEffectCurrAttr = 311

-- 效果叠加类型
Constants.EffectStackType = {}
Constants.EffectStackType.Nil = 1
Constants.EffectStackType.Add = 2
Constants.EffectStackType.Max = 3

Constants.EffectSackTypeMap = {
    -- 1=禁用被动招式
    [Constants.EffectType.BanAutoZhao] = Constants.EffectStackType.Nil,
    -- 2=禁用主动招式
    [Constants.EffectType.BanActiveZhao] = Constants.EffectStackType.Nil,
    -- 3=禁用轻功闪躲
    [Constants.EffectType.BanQinggongDodge] = Constants.EffectStackType.Nil,
    -- 5=禁用普通招架
    [Constants.EffectType.BanNormalParry] = Constants.EffectStackType.Nil,
    -- 7=驱散指定BuffClass类型
    [Constants.EffectType.RemoveBuffClass] = Constants.EffectStackType.Nil,
    -- 8=免疫主动招式添加的指定BuffClass类型
    [Constants.EffectType.ImmuneActiveBuffClass] = Constants.EffectStackType.Nil,
    -- 特殊效果类 11 被动招式随机基本武学(主动招式计算用的平均普通气血伤害也是基本武学的值) 无 无叠加 开发迭代2
    [Constants.EffectType.RandomBaseAutoZhao] = Constants.EffectStackType.Nil,
    -- 30-33
    [Constants.EffectType.AutoZhaoReductionOfInjurySub] = Constants.EffectStackType.Add,
    [Constants.EffectType.AutoZhaoReductionOfInjury] = Constants.EffectStackType.Max,
    [Constants.EffectType.ActiveZhaoReductionOfInjurySub] = Constants.EffectStackType.Add,
    [Constants.EffectType.ActiveZhaoReductionOfInjury] = Constants.EffectStackType.Max,
    -- 40-43
    [Constants.EffectType.SelfAutoZhaoEffectCurrAttr] = Constants.EffectStackType.Max,
    [Constants.EffectType.SelfActiveZhaoEffectCurrAttr] = Constants.EffectStackType.Max,
    [Constants.EffectType.TargetAutoZhaoEffectCurrAttr] = Constants.EffectStackType.Max,
    [Constants.EffectType.TargetActiveZhaoEffectCurrAttr] = Constants.EffectStackType.Max,
    -- 100-101
    [Constants.EffectType.FixedMulCurrAttr] = Constants.EffectStackType.Max,
    [Constants.EffectType.FixedMulAttr] = Constants.EffectStackType.Add,
    -- 120-121
    [Constants.EffectType.AddCurrAttr] = Constants.EffectStackType.Add,
    [Constants.EffectType.AddAttr] = Constants.EffectStackType.Add,
    -- 130
    [Constants.EffectType.ShieldHp] = Constants.EffectStackType.Add,
    -- 200-201
    [Constants.EffectType.AddTiliCost] = Constants.EffectStackType.Add,
    [Constants.EffectType.MulTiliCost] = Constants.EffectStackType.Max,
    -- 210-211
    [Constants.EffectType.AddNeiliCost] = Constants.EffectStackType.Add,
    [Constants.EffectType.MulNeiliCost] = Constants.EffectStackType.Max,
    -- 300-301
    [Constants.EffectType.TargetAutoDodgeEffectCurrAttr] = Constants.EffectStackType.Add,
    [Constants.EffectType.TargetAutoParryEffectCurrAttr] = Constants.EffectStackType.Add,
    [Constants.EffectType.TargetAutoParryOnHitDamageEffectCurrAttr] = Constants.EffectStackType.Add
}

-- 角色击中类型
Constants.HitType = {}
Constants.HitType.Nil = 0
Constants.HitType.Hit = 1
Constants.HitType.NormalParry = 10
Constants.HitType.ParryParry = 11
Constants.HitType.DodgeAway = 20
Constants.HitType.DodgeJump = 21

-- 效果刷新节点类型
Constants.EffectUpdateNodeType = {}
Constants.EffectUpdateNodeType.Nil = 0
Constants.EffectUpdateNodeType.BeforeAttack = 1
Constants.EffectUpdateNodeType.AfterAttack = 2

--@desc buff添加器组分类
Constants.ADDER_TYPE = {
    ACTIVE = 1,
    AUTO = 2,
    ENTER_FIGHT = 3
}

Constants.ADDER_CONDITION_TYPE = {
    HAS_BUFF_ID = 1,
    HAS_BUFF_CLASS = 2,
    HAS_BUFF_LAYER = 3,
    HAS_NOT_BUFF_BY_ID = 4,
    HAS_NOT_BUFF_BY_CLASS = 5,
    HAS_WEAPON_FIRST_TYPE = 10,
    HAS_WEAPON = 11,
    NO_HAS_WEAPON_FIRST_TYPE = 12,
    CHARACTER_ATTRS = 20
}

--@desc buff添加器触发节点类型
Constants.ADDER_TRIGGER_TYPE = {
    ACTIVE_COMB_START = 1,
    AUTO_ATTACK_ALL_HIT = 10,
    AUTO_ATTACK_HAS_PARRY = 11,
    AUTO_ATTACK_HAS_DODGE = 12,
    ENTER_START_FIGHT = 20,
    AUTO_TARGET_BE_ATTACK_ALL_HIT = 30,
    AUTO_TARGET_BE_ATTACK_HAS_PARRY = 31,
    AUTO_TARGET_BE_ATTACK_HAS_DODGE = 32
}

--@desc 添加器执行添加buff的节点类型
Constants.ADD_BUFF_NODE_TYEP = {
    -- 0=主动攻击前添加buff、
    ACTIVE_COMB_START = 0,
    -- 1=主动攻击后添加buff
    ACTIVE_COMB_FINISH = 1,
    -- 10=被动攻击前添加buff、
    AUTO_COMB_START = 10,
    -- 11=被动攻击后添加buff
    AUTO_COMB_FINISH = 11,
    -- 20=入场添加Buff
    ENTER_START_FIGHT = 20
}

--@desc buff 存活次数减少条件类型
Constants.REDUCE_LIVES_CON_TYPE = {
    -- 场内任意角色招式攻击结束
    ANY_COMB_FINISH = 3,
    -- Buff持有者使用被动招式
    ATTACKER_AUTO_COMB_FINISH = 20,
    -- Buff持有者使用主动招式
    ATTACKER_ACTIVE_COMB_FINISH = 21,
    --@desc 使用功能按钮（eg. 治疗、逃跑、易武）
    CHARACTER_USE_OPERACTION_ACTION = 22,
    -- Buff持有者受到敌方被动招式
    TARGET_AUTO_COMB_FINISH = 40,
    -- Buff持有者受到敌方主动攻击
    TARGET_ACTIVE_COMB_FINISH = 41,
    -- Buff持有者获得指定Buff
    CHARACTER_ADD_BUFF_ID = 60,
    -- Buff持有者获得指定buffClass类型Buff
    CHARACTER_ADD_BUFF_CLASS = 61,
    -- Buff持有者获得任意Buff
    CHARACTER_ADD_ANY_BUFF = 62
}

--@desc buff生效相关节点定义
Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE = {
    OnBuffAdd = 1,
    OnBuffRemove = 2,
    OnAnyCombStart = 11,
    OnAnyCombFinish = 12,
    OnAutoCombStart = 21,
    OnAutoZhaoStart = 22,
    OnAutoZhaoAttack = 23,
    OnAutoZhaoFinish = 24,
    OnAutoCombFinish = 25,
    OnActiveCombStart = 41,
    OnActiveZhaoStart = 42,
    OnActiveZhaoAttack = 43,
    OnActiveZhaoFinish = 44,
    OnActiveCombFinish = 45,
    OnUseQiRecoverAction = 101,
    OnUseYiwuAction = 102,
    OnUseRunawayAction = 103
}

Constants.BUFF_TRIGGER_ON_NODE_TYPE = Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@desc 删除buff条件类型
Constants.DELETE_BUFF_CON_TYPE = {
    LIVES_ZERO = 1,
    OTHER_SYSTEM_TO_DELETE = 2
}

return Constants
0000000000000