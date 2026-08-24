local Formula = {}

local FormulaMap =
{
	qianneng1 =
	function(exp, fy, sklv, k)
		local pot = 0
		--潜能奖励公式
		if exp >= 1000 and exp < 2000 then
			pot = 18000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 2000 and exp < 5000 then
			pot = 12000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 5000 and exp < 15000 then
			pot = 10000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 15000 and exp < 80000 then
			pot = 8000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 80000 and exp < 300000 then
			pot = 4500 * 2 ^ (sklv / 140) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 300000 and exp < 500000 then
			pot = 4860 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 500000 and exp < 1000000 then
			pot = 5249 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 1000000 and exp < 5000000 then
			pot = 5668 * (2 ^ (sklv / 364)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 5000000 and exp < 15000000 then
			pot = 6122 * (2 ^ (sklv / 527)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 15000000 and exp < 30000000 then
			pot = 6612 * (2 ^ (sklv / 665)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 30000000 then
			pot = 7141 * ( 2 ^ (sklv / 1200)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		end
		return math.max(100, math.floor(pot))
	end,
	suiyin1 =
	function(exp, fy, sklv, k)
		-- 碎银奖励公式
		local money = 0

		if 1000 <= exp and exp < 2000 then
			money = 2500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 2000 <= exp and exp < 5000 then
			money = 2500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 5000 <= exp and exp <15000 then
			money = 2500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 15000 <= exp and exp < 80000 then
			money = 3000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 80000 <= exp and exp < 300000 then
			money = 3500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 300000 <= exp and exp < 500000 then
			money = 4000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 500000 <= exp and exp < 1000000 then
			money = 4800 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 1000000 <= exp and exp < 5000000 then
			money = 5500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 5000000 <= exp and exp < 15000000 then
			money = 6000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 15000000 <= exp and exp < 30000000 then
			money = 6000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		elseif 30000000 <= exp then
			money = 6500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * k

		end
		return math.max(100, math.floor(money))
	end,

	jingyan1 =
	function(exp, fy, sklv, k,Lv)
		local jingyan = 0

		if 1000 <= exp and exp < 2000 then
			--jingyan = 38000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 38000 * (2 * fy + 115)/(fy + 130) * math.random(85,115) / 100 / 3600 * k			

		elseif 2000 <= exp and exp < 5000 then
			--jingyan = 24000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 24000 * (2 * fy + 115)/(fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 5000 <= exp and exp < 15000 then
			--jingyan = 20000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 20000 * (2 * fy + 115)/(fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 15000 <= exp and exp < 80000 then
			--jingyan = 16000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 16000 * (2 * fy + 115)/(fy + 130) * math.random(85,115) /100 / 3600 * k
			
		elseif 80000 <= exp and exp < 300000 then
			--jingyan = 9000 * 2 ^ (sklv / 140) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 9000 * (6 * sklv + 140)/(Lv + sklv + 210)* (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 300000 <= exp and exp < 500000 then
			--jingyan = 9720 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 9720 * (10 * sklv + 166)/(Lv + sklv + 581)* (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 500000 <= exp and exp < 1000000 then
			--jingyan = 10498 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 10498 * (9 * sklv + 211)/(Lv + sklv + 633)* (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 1000000 <= exp and exp < 5000000 then
			--jingyan = 11337 * (2 ^ (sklv / 364)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 11337 * (6 * sklv + 364) / (Lv + sklv + 546) * (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 5000000 <= exp and exp < 15000000 then
			--jingyan = 12244 * (2 ^ (sklv / 527)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 12244 * (6 * sklv + 527) / (Lv + sklv + 790) * (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 15000000 <= exp and exp < 30000000 then
			--jingyan = 13224 * (2 ^ (sklv / 665)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 13224 * (6 * sklv + 655) / (Lv + sklv + 982) * (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		elseif 30000000 <= exp then
			--jingyan = 14282 * (2 ^ (sklv / 1200)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 14282 * (4 * sklv + 1200) / (sklv + 1800) * (2 * fy + 115) / (fy + 130) * math.random(85,115) / 100 / 3600 * k
			
		end
		return math.max(100, math.floor(jingyan))
	end,
	
	qianneng2 =
	function(exp, fy, sklv, k)
		local pot = 0
		--潜能奖励公式
		if exp >= 1000 and exp < 2000 then
			pot = 18000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 2000 and exp < 5000 then
			pot = 12000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 5000 and exp < 15000 then
			pot = 10000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 15000 and exp < 80000 then
			pot = 8000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 80000 and exp < 300000 then
			pot = 4500 * 2 ^ (sklv / 140) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 300000 and exp < 500000 then
			pot = 4860 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 500000 and exp < 1000000 then
			pot = 5249 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 1000000 and exp < 5000000 then
			pot = 5668 * (2 ^ (sklv / 364)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 5000000 and exp < 15000000 then
			pot = 6122 * (2 ^ (sklv / 527)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 15000000 and exp < 30000000 then
			pot = 6612 * (2 ^ (sklv / 665)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		elseif exp >= 30000000 then
			pot = 7141 * ( 2 ^ (sklv / 1200)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k

		end
		return math.max(100, math.floor(pot))
	end,
	suiyin2 =
	function(exp, fy, sklv, k)
		-- 碎银奖励公式
		local money = 0

		if 1000 <= exp and exp < 2000 then
			money = 2500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 2000 <= exp and exp < 5000 then
			money = 2500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 5000 <= exp and exp <15000 then
			money = 2500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 15000 <= exp and exp < 80000 then
			money = 3000 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 80000 <= exp and exp < 300000 then
			money = 3500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 300000 <= exp and exp < 500000 then
			money = 4000 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 500000 <= exp and exp < 1000000 then
			money = 4800 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 1000000 <= exp and exp < 5000000 then
			money = 5500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 5000000 <= exp and exp < 15000000 then
			money = 6000 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 15000000 <= exp and exp < 30000000 then
			money = 6000 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		elseif 30000000 <= exp then
			money = 6500 / 3600 * (108 + math.floor(0.5 * fy)) / 100 * k

		end
		return math.max(100, math.floor(money))
	end,
	jingyan2 =
	function(exp, fy, sklv, k,Lv)
		local jingyan = 0

		if 1000 <= exp and exp < 2000 then
			--jingyan = 38000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 38000 * (2 * fy + 115)/(fy + 130) / 3600 * k
			
		elseif 2000 <= exp and exp < 5000 then
			--jingyan = 24000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 24000 * (2 * fy + 115)/(fy + 130) / 3600 * k
			
		elseif 5000 <= exp and exp < 15000 then
			--jingyan = 20000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 20000 * (2 * fy + 115)/(fy + 130) / 3600 * k
			
		elseif 15000 <= exp and exp < 80000 then
			--jingyan = 16000 * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 16000 * (2 * fy + 115)/(fy + 130) / 3600 * k
			
		elseif 80000 <= exp and exp < 300000 then
			--jingyan = 9000 * 2 ^ (sklv / 140) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 9000 * (6 * sklv + 140)/(Lv + sklv + 210)* (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 300000 <= exp and exp < 500000 then
			--jingyan = 9720 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 9720 * (10 * sklv + 166)/(Lv + sklv + 581)* (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 500000 <= exp and exp < 1000000 then
			--jingyan = 10498 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 10498 * (9 * sklv + 211)/(Lv + sklv + 633)* (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 1000000 <= exp and exp < 5000000 then
			--jingyan = 11337 * (2 ^ (sklv / 364)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 11337 * (6 * sklv + 364) / (Lv + sklv + 546) * (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 5000000 <= exp and exp < 15000000 then
			--jingyan = 12244 * (2 ^ (sklv / 527)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 12244 * (6 * sklv + 527) / (Lv + sklv + 790) * (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 15000000 <= exp and exp < 30000000 then
			--jingyan = 13224 * (2 ^ (sklv / 665)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 13224 * (6 * sklv + 655) / (Lv + sklv + 982) * (2 * fy + 115) / (fy + 130) / 3600 * k
			
		elseif 30000000 <= exp then
			--jingyan = 14282 * (2 ^ (sklv / 1200)) * math.min(1.2, (108 + math.floor(0.5 * fy)) / 100) / 3600 * k
			jingyan = 14282 * (4 * sklv + 1200) / (sklv + 1800) * (2 * fy + 115) / (fy + 130) / 3600 * k
			
		end
		return math.max(100, math.floor(jingyan))
	end
}

function Formula:getFormula(name)
	return assert(FormulaMap[name])
end

return Formula00