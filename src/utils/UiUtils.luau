local InputService = game:GetService('UserInputService')
local TextService = game:GetService('TextService')
local RenderStepped = game:GetService('RunService').RenderStepped
local Utils = require('./Utils')
local UiUtils = {}

--- Make the given instance draggable.
--- @param instance The instance to make draggable
function UiUtils:MakeDraggable(instance: GuiObject)
  instance.Active = true
  instance.InputBegan:Connect(function(input)
    local mouseButton = Enum.UserInputType.MouseButton1
    if input.UserInputType == mouseButton then
      local mousePos = InputService:GetMouseLocation()
      local pos = Vector2.new(mousePos.X - instance.AbsolutePosition.X, mousePos.Y - instance.AbsolutePosition.Y)

      while InputService:IsMouseButtonPressed(mouseButton) do
        mousePos = InputService:GetMouseLocation()
        instance.Position = UDim2.new(
          0, mousePos.X - pos.X + (instance.Size.X.Offset * instance.AnchorPoint.X),
          0, mousePos.Y - pos.Y + (instance.Size.Y.Offset * instance.AnchorPoint.Y)
        )
        RenderStepped:Wait()
      end
    end
  end)
end

--- Applies a text stroke to the given instance.
--- @param instance The instance to apply the text stroke to
function UiUtils:ApplyTextStroke(instance: TextLabel | TextBox | TextButton)
  Utils:CreateInstance('UIStroke', {
    Color = Color3.new(0, 0, 0),
    Thickness = 1,
    LineJoinMode = Enum.LineJoinMode.Miter,
    Parent = instance
  })
end

--- Create a container with a UIListLayout inside of it.
--- @param padding The padding to apply to the UIListLayout
function UiUtils:CreateContainer(padding: { x: number?, y: number? }): Frame
  local frame = Utils:CreateInstance('Frame', {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.Y
  })
  Utils:CreateInstance('UIListLayout', {
    Padding = UDim.new(padding.x or 0, padding.y or 0),
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = frame
  })
  return frame
end

--- Create a text label with the given properties.
--- @param properties A table of properties to set on the text label
function UiUtils:CreateLabel(properties: { [string]: any }): TextLabel
  local instance: TextLabel = Utils:CreateInstance('TextLabel', {
    BackgroundTransparency = 1,
    Font = Library.Font,
    TextColor3 = Library.FontColor,
    TextSize = 16,
    TextStrokeTransparency = 0
  })
  self:ApplyTextStroke(instance)

  return Utils:CreateInstance(instance, properties)
end

--- Create a text button with the given properties.
--- @param properties A table of properties to set on the text button
function UiUtils:CreateButton(properties: { [string]: any }): TextButton
  local instance: TextButton = Utils:CreateInstance('TextButton', {
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Library.OutlineColor,
    Font = Library.Font,
    TextColor3 = Library.FontColor,
    TextSize = 16,
    TextStrokeTransparency = 0
  })
  self:ApplyTextStroke(instance)

  return Utils:CreateInstance(instance, properties)
end

--- Add a tooltip to a GUI instance.
--- @param instance The instance to add the tooltip to
--- @param tooltip The tooltip to display
function UiUtils:AddTooltip(instance: GuiObject, tooltip: GuiObject)
  local isHovering = false
  instance.MouseEnter:Connect(function()
    isHovering = true
    tooltip.Visible = true

    while isHovering do
      local mousePos = InputService:GetMouseLocation()
      tooltip.Position = UDim2.fromOffset(mousePos.X + 15, mousePos.Y + 12)
      RenderStepped:Wait()
    end
  end)

  instance.MouseLeave:Connect(function()
    isHovering = false
    tooltip.Visible = false
  end)
end

--- Add a text tooltip to a GUI instance.
--- @param instance The instance to add the text tooltip to
--- @param text The text to display in the tooltip
function UiUtils:AddTextTooltip(instance: GuiObject, text: string | { string })
  local strs: { string }
  if type(text) == 'string' then
    strs = { text }
  else
    strs = text
  end

  local bounds = {}
  local largestX, largestY = 0, 0
  for _, str in ipairs(strs) do
    local bound = self:GetTextBounds(str, Library.Font, 16)
    bounds[str] = bound
    largestX = math.max(largestX, bound.X)
    largestY = math.max(largestY, bound.Y)
  end

  local tooltip = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderColor3 = Library.OutlineColor,
    Size = UDim2.fromOffset(largestX + 5, largestY + 4),
    ZIndex = 100,
    Visible = false,
    Parent = Library.ScreenGui
  })

  for str, bound in pairs(bounds) do
    self:CreateLabel({
      Position = UDim2.fromOffset(3, 1),
      Size = UDim2.fromOffset(bound.X, bound.Y),
      Text = str,
      TextSize = 14,
      TextColor3 = Library.FontColor,
      TextXAlignment = Enum.TextXAlignment.Left,
      ZIndex = tooltip.ZIndex + 1,
      Parent = tooltip
    })
  end

  self:AddTooltip(instance, tooltip)
end

--- Get the bounds of a string.
--- @param text The text to get the bounds of
--- @param font The font of the text
--- @param size The size of the text
function UiUtils:GetTextBounds(text: string, font: Enum.Font, size: number): Vector2
  local resolution = Utils:GetResolution()
  return TextService:GetTextSize(text, size, font, resolution)
end

return UiUtils
