-- @Author: BlahGeek
-- @Date:   2015-05-26
-- @Last Modified by:   BlahGeek
-- @Last Modified time: 2015-05-26

local template = require "resty.template"
local common = require "ShadowShorten.scripts.include.common"

local key = ngx.var[1]
local country = ngx.var.geoip_country_code

local red = common.new_redis()

local res, err = red:hmget("shorten:" .. key, "host", "uri", "blocked")
local host, uri, blocked = unpack(res)
if host == ngx.null then
    return common.exit(ngx.HTTP_NOT_FOUND)
end

red:set_keepalive(10000, 10)

if country == "CN" and blocked ~= "false" then
    return template.render("proxy.html", {
               domain = host,
               url = host .. uri,
               proxy = ngx.var.proxy_schema .. "://" .. key .. ngx.var.proxy_domain .. uri
           })
else
    return ngx.redirect(host .. uri)
end
