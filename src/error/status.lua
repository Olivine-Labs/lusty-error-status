--process config
local parseConfig = function(val)
  local ret = {}
  for k, v in pairs(val) do
    if type(v) == "table" then
      v = v[1]
    end
    k = v
    local channel = {}
    string.gsub(k, "([^:]+)", function(c) channel[#channel+1] = c end)
    ret[#ret] = channel
  end
  return ret
end

local prefix = parseConfig(config.prefix)
local suffix = parseConfig(config.suffix)
local status = {}

for k, v in pairs(config.status) do
  status[k] = parseConfig(v)
end

return {
  handler = function(context)
    local stat = status[context.response.status] or status[context.response.status/100%10]

    for i=1, #prefix do self:publish({unpack(prefix)}, context) end
    for i=1, #stat do self:publish({unpack(stat)}, context) end
    for i=1, #suffix do self:publish({unpack(suffix)}, context) end
  end,

  options = {
    predicate = function(context)

      local status = context.response.status

      if context.error then
        status = 500
      end

      --If xxx (eg 503) set OR x00 (eg, 500) code set then
      if status[status] or status[status/100%10] then
        return true
      end

      return false
    end
  }
}
