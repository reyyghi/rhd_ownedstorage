Perms = {}

local perms = require 'config.perms'

function Perms.get(source, cb)
    local authorized = true
    if perms.enable then
        local licenseType = perms.type
        local pLicense = GetPlayerIdentifierByType(source, licenseType)
        local prefix = ('%s:'):format(licenseType)
        authorized = perms.list[pLicense:gsub(prefix, "")] or false
    end
    return cb and cb(authorized) or authorized
end