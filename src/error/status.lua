--process config

local prefix, suffix = config.prefix, config.suffix

return {
  handler = function(context)
    local status =  config.status[context.response.status] or config.status[context.response.status/100%10]

    for i=1, #prefix do self:publish({unpack(prefix)}, context) end
    for i=1, #status do self:publish({unpack(status)}, context) end
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
