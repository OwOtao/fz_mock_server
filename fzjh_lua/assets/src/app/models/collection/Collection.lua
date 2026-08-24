local function print()end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 信息收集模块
local Collection = {}

-- 保存到本地的luatable的key
local LUATABLE_KEY = md5:getMd5("collectionData")

-- 作弊数据保存结构
local collectionData = {}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建统计结构
-- @params name: 统计结构名称, url: 统计结构上传的url, uploadInterval: 上传的时间间隔, maxCount: 记录的最大条数
local function createRecord(name, url, uploadInterval, maxCount)
    maxCount = Helper:getDef(maxCount, 50) -- 默认最大条数
    local upperFirstName = string.upperFirst(name) -- 首字母大写
    local recordsTableName = name.."s" -- 数组后面加s

    -- 如果没有table, 则初始化table
    if type(collectionData[recordsTableName]) ~= "table" then
        collectionData[recordsTableName] = {}
    end

    -- 添加
    Collection["add"..upperFirstName] = function(self, record)
        local recordsTable = collectionData[recordsTableName] -- 获取数组
        table.insert(recordsTable, record)

        -- 判断是否超出数目
        if #recordsTable > maxCount then
            if PRINT_MODE == 1 then
                print("add"..upperFirstName..": 记录超出, 移除头部记录")
            end
            table.removeRange(recordsTable, 1, 1) -- 从头部移除超出的记录
        end

        self:save()

        -- add by XiaoZhiWei 2018/07/19 18:32:49 每次添加记录的时候都尝试提交
        if type(Collection["upload"..upperFirstName]) == "function" then
            Collection["upload"..upperFirstName](self)
        end
    end

    -- 移除
    Collection["remove"..upperFirstName] = function(self, from, to)
        local recordsTable = collectionData[recordsTableName] -- 获取数组
        table.removeRange(recordsTable, from, to)
        self:save()
    end

    -- 上传
    Collection["upload"..upperFirstName] = function(self)
        local recordsTable = collectionData[recordsTableName] -- 获取数组
        if PRINT_MODE == 1 then
            print("upload"..upperFirstName)
        end
        if #recordsTable > 0 then
            if PRINT_MODE == 1 then
                -- print("upload"..upperFirstName.." = "..luaTableEncode(recordsTable))
            end

            -- 判断上传时间间隔
            local uploadTime = Helper:getDef(collectionData["upload"..upperFirstName.."Time"], 0)
            local currTime = GetTime() == 0 and os.time() or GetTime()
            local elapsed = currTime - uploadTime
            uploadInterval = Helper:getRange(uploadInterval, 10) -- add by XiaoZhiWei 2018/07/19 18:33:53 最小间隔10秒
            print("uploadTime = "..tostring(uploadTime))
            print("uploadInterval = "..tostring(uploadInterval))
            print("elapsed = "..tostring(elapsed))
            if elapsed < uploadInterval then
                if PRINT_MODE == 1 then
                    -- 如果经过时间小于上传间隔时间, 则不上传
                    print("upload"..upperFirstName..": 经过时间小于上传间隔时间, 不予上传")
                end
                return
            end
            -- 设置上传时间
            collectionData["upload"..upperFirstName.."Time"] = currTime

            -- 提交到服务器
            local tmpRecordsTable = clone(recordsTable)
            HttpManagerEx:retryPostWithHeader(url, tmpRecordsTable, nil,
            function(response, status)
                if PRINT_MODE == 1 then
                    print("response = "..response)
                end
                if status == 200 then
                    -- 只要网络成功, 就移除作弊信息
                    local tmpRecordsTableCount = #tmpRecordsTable
                    Collection["remove"..upperFirstName](self, 1, tmpRecordsTableCount) -- 移除提交成功的作弊信息
                    if collectionData[upperFirstName.."SuccessFunc"] ~= nil then
                        collectionData[upperFirstName.."SuccessFunc"]()
                    end
                else
                    -- 上传失败, 重置上传时间
                    collectionData["upload"..upperFirstName.."Time"] = nil
                    if PRINT_MODE == 1 then
                        print("upload"..upperFirstName.." failed")
                    end
                end
            end)
        end
    end

    -- add by XiaoZhiWei 2017/11/08 19:39:56 设置上传回调方法
    Collection["set"..upperFirstName.."SuccessFunc"] = function(self, func)
        collectionData[upperFirstName.."SuccessFunc"] = Helper:getDef(func, function() print("22222222222")end) 
    end

    Collection["forceUpload"..upperFirstName] = function(self)
        local recordsTable = collectionData[recordsTableName] -- 获取数组
        if PRINT_MODE == 1 then
            print("upload"..upperFirstName)
        end
        if #recordsTable > 0 then
            if PRINT_MODE == 1 then
                -- print("upload"..upperFirstName.." = "..luaTableEncode(recordsTable))
            end

            -- 判断上传时间间隔
            local uploadTime = Helper:getDef(collectionData["upload"..upperFirstName.."Time"], 0)
            local currTime = GetTime() == 0 and os.time() or GetTime()
   
            -- 设置上传时间
            collectionData["upload"..upperFirstName.."Time"] = currTime

            -- 提交到服务器
            local tmpRecordsTable = clone(recordsTable)
            HttpManagerEx:retryPostWithHeader(url, tmpRecordsTable, nil,
            function(response, status)
                if PRINT_MODE == 1 then
                    print("response = "..response)
                end
                if status == 200 then
                    -- 只要网络成功, 就移除作弊信息
                    local tmpRecordsTableCount = #tmpRecordsTable
                    Collection["remove"..upperFirstName](self, 1, tmpRecordsTableCount) -- 移除提交成功的作弊信息
                    if collectionData[upperFirstName.."SuccessFunc"] ~= nil then
                        collectionData[upperFirstName.."SuccessFunc"]()
                    end
                else
                    -- 上传失败, 重置上传时间
                    collectionData["upload"..upperFirstName.."Time"] = nil
                    if PRINT_MODE == 1 then
                        print("upload"..upperFirstName.." failed")
                    end
                end
            end)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function Collection:init()
    self:load()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 载入
function Collection:load()
    local data = DataBase:getLuaTable(LUATABLE_KEY)
    if PRINT_MODE == 1 then
        -- print("Collection:load, data = "..tostring(luaTableEncode(data)))
    end
    Helper:tableCover(collectionData, data) -- 通过存档覆盖当前结构
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 存储
function Collection:save()
    DataBase:setLuaTable(LUATABLE_KEY, collectionData)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建作弊记录统计
createRecord("cheat", "report_cheat", 0)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 内存作弊
-- @params valueName: 属性名; valueFrom: 属性原始值; valueTo: 属性修改值
function Collection:memoryCheat(userid, valueName, valueFrom, valueTo)
    self:addCheat({uid = userid, vn = valueName, vf = valueFrom, vt = valueTo, tm = GetTime()})
    if PRINT_MODE == 1 then
        print("内存作弊")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建错误记录统计
createRecord("errmsg", "upload_error_msg", 3600 * 12)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 记录错误
function Collection:recordErrmsg(errmsg)
    local userid = 0
    local role = User:getRole()
    if role then
        userid = Helper:getDef(role.userid, -1)
    end
    self:addErrmsg({uid = userid, errmsg = errmsg, tm = GetTime()})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 客户端加载错误日志收集 收集到之后 10秒内上传 最多收集5条 收到记录立马提交 
createRecord("loadErrmsg", "upload_error_msg", 10, 5)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 记录错误
function Collection:recordLoadErrmsg(loadErrmsg)
    self:addLoadErrmsg({uid = Game:getIdfv(), loadErrmsg = loadErrmsg, tm = os.time()})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/20 10:15:52
-- @desc 创建代理作弊记录
createRecord("proxy", "report_cheat", 3600 * 2)

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/20 10:16:59
-- @desc 收集代理记录
function Collection:addProxyRecord(userid, valueName, valueFrom, valueTo)
    self:addProxy({uid = userid, vn = valueName, vf = valueFrom, vt = valueTo, tm = GetTime()})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/07/20 09:02:37
-- @params 
-- @desc 客户端公平公正数据收集
createRecord("isEncrypt", "upload_error_msg", 10, 10)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 记录错误
function Collection:recordIsEncrypt(responseData)
    self:addIsEncrypt({uid = Game:getIdfv(), isEncryptResponseData = responseData, tm = os.time()})
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2016/11/14 21:07:41
-- -- @desc 创建请求异常统计记录
-- createRecord("response", "report_cheat", 600)

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2016/11/14 21:08:46
-- -- @desc 记录请求异常统计
-- function Collection:recordResponseError(userid, url, response)
--     self:addResponse({uid = userid, url = url, rep = response, tm = GetTime()})
-- end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 提交收集信息
function Collection:uploadCollection()
    self:uploadCheat() -- 提交作弊信息
    self:uploadErrmsg() -- 提交错误记录
    self:uploadProxy()
    self:uploadIsEncrypt()
    -- self:uploadResponse()
end

return Collection
000000000