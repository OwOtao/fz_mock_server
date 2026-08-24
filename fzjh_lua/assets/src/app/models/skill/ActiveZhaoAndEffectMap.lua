return function()
    local activeZhaoMap =
        {
            kuangzhanyin =
            {
                id = "kuangzhanyin",
                name = "狂战印",
                type = "释放",
                effects = "kuangzhanyin",
                cd = 0
            }
        }
    
    
    local effectMap =
        {
            dadiaobingqi =
            {
                id = "dadiaobingqi",
                name = "打掉兵器",
                desc = "打掉兵器",
                                
                target = "自己",
                type = "打掉兵器",
                arg1 = 1
            }
        }
    
    return activeZhaoMap, effectMap
end000