return function()
    local luaTableEncode, luaTableDecode = require("app.extends.tableToString")()

    local function getStringWidth(str)
        local width = 0
        local strLen = string.len(str)
        -- print("strLen = "..tostring(strLen))
        local pos = 1
        while pos <= strLen do
            local byte = string.byte(str, pos)
            -- print("pos = "..tostring(pos))
            -- print("byte = "..tostring(byte))
            if byte <= 127 then
                width = width + 1
                pos = pos + 1
            else
                width = width + 2
                pos = pos + 3
            end
        end
        return width
    end

    -- 生成包围框
    local framePlaceholders =
    {
        {"┌", "┄", "┐"},
        {"┆", " ", "┆"},
        {"└", "┄", "┘"},
        -- {"┌", "─", "┐"},
        -- {"│", " ", "│"},
        -- {"└", "─", "┘"},
        -- {"┏", "┅", "┓"},
        -- {"┇", " ", "┇"},
        -- {"┗", "┅", "┛"},
        -- {"┏", "━", "┓"},
        -- {"┃", " ", "┃"},
        -- {"┗", "━", "┛"},
    }

    local function printLog(...)

        local frameWidth = 1
        local frameHeight = 1
        local placeholder = " " -- 占位符

        local args = {...}
        local lines = {}
        local line = ""

        -- 添加行
        local function appendLine(line, str)
            -- print("type(line) = "..type(line))
            -- print("type(str) = "..type(str))
            -- print("line = "..line)
            -- print("str = "..str)

            line = line .. str

            local newlinePos = string.find(line, "\n")
            while newlinePos do
                local firstStr = string.sub(line, 1, newlinePos - 1)
                local secondStr = string.sub(line, newlinePos + 1)
                -- print("firstStr = "..firstStr)
                -- print("secondStr = "..secondStr)
                table.insert(lines, firstStr)
                line = secondStr
                newlinePos = string.find(line, "\n")
            end
            return tostring(line)
        end

        -- 遍历添加所有字符串
        for i, v in ipairs(args) do
            line = appendLine(line, luaTableEncode(v))
        end
        -- 如果还有没添加完的行, 直接加入lines
        if string.len(line) > 0 then
            table.insert(lines, line)
        end

        -- 计算输出区域
        local width = 0
        local height = #lines
        for i, v in ipairs(lines) do
            width = math.max(width, getStringWidth(v))
        end
        if width % 2 ~= 0 then
            width = width + 1
        end

        -- 填充输出区域
        for i, line in ipairs(lines) do
            lines[i] = line .. string.rep(placeholder, width - getStringWidth(line))
        end

        if height > 0 and width > 0 then
            -- 生成包围圈
            do
                -- 横向
                for i = 1, frameHeight do
                    -- 顶部
                    table.insert(lines, 1, string.rep(framePlaceholders[1][2], width / getStringWidth(framePlaceholders[1][2])))
                    -- 底部
                    table.insert(lines, string.rep(framePlaceholders[3][2], width / getStringWidth(framePlaceholders[3][2])))
                end

                -- 纵向
                for i = 1, frameWidth do
                    -- 左部
                    for i, v in ipairs(lines) do
                        if i > 1 and i < #lines then
                            lines[i] = framePlaceholders[2][1] .. v
                        end
                    end
                    -- 右部
                    for i, v in ipairs(lines) do
                        if i > 1 and i < #lines then
                            lines[i] = v .. framePlaceholders[2][3]
                        end
                    end
                end
                -- 四个角
                -- 左上
                lines[1] = framePlaceholders[1][1] .. lines[1]
                -- 右上
                lines[1] = lines[1] .. framePlaceholders[1][3]
                -- 左下
                lines[#lines] = framePlaceholders[3][1] .. lines[#lines]
                -- 右下
                lines[#lines] = lines[#lines] .. framePlaceholders[3][3]

                -- 加换行
                table.insert(lines, 1, string.rep(" ", width))
                table.insert(lines, string.rep(" ", width))
            end

            if PRINT_MODE == 1 then
                -- 打印输出每一行日志
                for i, line in ipairs(lines) do
                    print(line)
                    -- io.write(line.."\n")
                end
            end

        end
    end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 扩展, pringLogWithTitle
    local function logt(title, ...)
        local arg1 = "标题: " .. tostring(title)
        local width1 = getStringWidth(arg1)
        if width1 % 2 ~= 0 then
            width1 = width1 + 1
            arg1 = arg1 .. " "
        end
        printLog(arg1, framePlaceholders[2][3], "\n" .. string.rep(framePlaceholders[1][2], width1 / getStringWidth(framePlaceholders[1][2])) .. framePlaceholders[3][3] .."\n", ...)
    end

    -- local function printLog()
    -- end
    --
    -- local function logt()
    -- end

    return printLog, logt
end
00000000