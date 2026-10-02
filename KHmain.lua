local PlaceId = game.PlaceId
local LoaderVersion = "1.0.0"

local KYOSH_KEY = "KYOSH--_ZtTnqFxbHQKi-Tp2cbTJd8bbC8y0Um"

local API = "https://kh-hub.onrender.com/api/loader"

local function urlEncode(value)
    value = tostring(value)

    return value:gsub("([^%w%-_%.~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
end

local function requestScript(scriptName)

    local url =
        API
        .. "?place=" .. urlEncode(PlaceId)
        .. "&version=" .. urlEncode(LoaderVersion)
        .. "&script=" .. urlEncode(scriptName)

    if not request then
        error("KYOSH: This environment does not provide request().")
    end

    print("📡 KYOSH requesting:")
    print("   Place:", PlaceId)
    print("   Script:", scriptName)

    local response = request({
        Url = url,
        Method = "GET",

        Headers = {
            ["X-KYOSH-KEY"] = KYOSH_KEY
        }
    })

    if not response or response.StatusCode ~= 200 then

        local status =
            response and response.StatusCode or "unknown"

        local body =
            response and response.Body or ""

        error(
            "KYOSH loader rejected: HTTP "
            .. tostring(status)
            .. "\n"
            .. body
        )
    end

    if not response.Body or response.Body == "" then
        error("KYOSH: Empty script response.")
    end

    local fn, compileError =
        loadstring(response.Body)

    if not fn then
        error(
            "KYOSH: Script compile failed: "
            .. tostring(compileError)
        )
    end

    local ok, runtimeError =
        pcall(fn)

    if not ok then
        error(
            "KYOSH: Script runtime failed: "
            .. tostring(runtimeError)
        )
    end

    print("✅ KYOSH loaded:", scriptName)
end

if PlaceId == 107778070777162 then

    requestScript("eggcounter")

    task.wait(0.5)

    requestScript("main")


elseif PlaceId == 97598239454123 then

    requestScript("main")

elseif PlaceId == 102868797705537 then

    requestScript("ghoulshop")

else

    error(
        "KYOSH: Unsupported PlaceId "
        .. tostring(PlaceId)
    )
end


print("🛡️ KYOSH loader finished")
