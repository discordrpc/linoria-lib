local Utils = {}

--- Safely call a function, catching any errors that may occur.
--- @param func The function to call
--- @param ... The arguments to pass to the function
function Utils:SafeCallback(func: (...any) -> any, ...: any)
  if type(func) ~= 'function' then
    return
  end

  local success, result = pcall(func, ...)
  if not success then
    warn('Error in callback:', result)
  end
end

--- Create a new instance with a set of properties.
--- @param class The class of the instance
--- @param properties A table of properties to set on the instance
function Utils:CreateInstance<T>(class: string | Instance, properties: { [string]: any }): T
  local instance: any
  if type(class) == 'string' then
    instance = Instance.new(class)
  else
    instance = class
  end

  for key, value in pairs(properties) do
    instance[key] = value
  end

  return instance
end

--- Get the resolution of the current screen.
function Utils:GetResolution(): Vector2
  return workspace.CurrentCamera.ViewportSize
end

return Utils
