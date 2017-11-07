-- Copyright (C) idevz (idevz.org)


local utils = require "motan.utils"

local _M = {
    _VERSION = '0.0.1'
}

local mt = { __index = _M }

function _M.new()
	local ext = {
		filter_fctrs = {},
		ha_fctrs = {},
		lb_fctrs = {},
		serialize_fctrs = {},
		endpoint_fctrs = {},
		registry_fctrs = {},
		registries = {},
	}
	return setmetatable(ext, mt)
end

local _new_index
_new_index = function(self, key, name, func)
	if type(func) ~= "function" then
		local err_msg = "None function for ext " .. key.. ": " .. name
		ngx.log(ngx.ERR, err_msg)
		return nil, err_msg
	end
	self[key][name] = func
	return true, nil
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_filter(self, name, func)
	return _new_index(self, "filter_fctrs", name, func)
end

function _M.get_filter(self, name)
	local key = utils.trim(name)
	local new_filter = self.filter_fctrs[key]
	if new_filter ~= nil then
		return new_filter()
	end
	ngx.log(ngx.ERR, "Didn't have a endpoint: " .. key)
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_ha(self, name, func)
	return _new_index(self, "ha_fctrs", name, func)
end

function _M.get_ha(self, url)
	local key = url.params["haStrategy"]
	local new_ha = self.ha_fctrs[key]
	if new_ha ~= nil then
		return new_ha(url)
	end
	ngx.log(ngx.ERR, "Didn't have a endpoint: " .. key)
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_lb(self, name, func)
	return _new_index(self, "lb_fctrs", name, func)
end

function _M.get_lb(self, url)
	local key = url.params["loadbalance"]
	local new_lb = self.lb_fctrs[key]
	if new_lb ~= nil then
		return new_lb(url)
	end
	ngx.log(ngx.ERR, "Didn't have a endpoint: " .. key)
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_serialization(self, name, func)
	return _new_index(self, "serialize_fctrs", name, func)
end

function _M.get_serialization(self, url)
	local key = url.params["loadbalance"]
	local new_serialize = self.serialize_fctrs[key]
	if new_serialize ~= nil then
		return new_serialize(url)
	end
	ngx.log(ngx.ERR, "Didn't have a endpoint: " .. key)
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_endpoint(self, name, func)
	return _new_index(self, "endpoint_fctrs", name, func)
end

function _M.get_endpoint(self, url)
	local key = url.protocol
	local new_endpoint = self.endpoint_fctrs[key]
	if new_endpoint ~= nil then
		return new_endpoint(url)
	end
	ngx.log(ngx.ERR, "Didn't have a endpoint: " .. key)
end


--+--------------------------------------------------------------------------------+--
function _M.regist_ext_registry(self, name, func)
	return _new_index(self, "registry_fctrs", name, func)
end

function _M.get_registry(self, url)
	local key = url:get_identity()
	local registries_cache = self.registries[key] or {}
	if registries_cache[self.registries[key]] ~= nil then
		return registries_cache
	else
		local registry = self.registry_fctrs[url.protocol]
		if registry ~= nil then
			registry_obj = registry(url)
			self.registries[key] = registry_obj
			return registry_obj
		else
			ngx.log(ngx.ERR, "Didn't have a registry: " .. key)
			return nil
		end
	end
end

return _M
