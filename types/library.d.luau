declare class Library
  ScreenGui: ScreenGui
  MainColor: Color3
  BackgroundColor: Color3
  AccentColor: Color3
  OutlineColor: Color3
  RiskColor: Color3
  Black: Color3
  FontColor: Color3
  Font: Enum.Font
  function CreateWindow(self, options: WindowOptions): Window
end

declare Library: Library

export type WindowOptions = {
  Title: string?,
  AutoShow: boolean?,
  TabPadding: number?,
  MenuFadeTime: number?,
  Position: UDim2?,
  Size: UDim2?,
  Center: boolean?,
  AnchorPoint: Vector2?
}

declare class WindowConstructor
  new: (options: WindowOptions) -> Window
end

declare class Window
  Instances: {
    Outer: Frame,
    Inner: Frame,
    WindowLabel: TextLabel,
    MainSectionOuter: Frame,
    MainSectionInner: Frame,
    TabArea: Frame,
    TabListLayout: UIListLayout,
    TabContainer: Frame
  }
  Tabs: { Tab }
  function SetTitle(self, title: string)
  function AddTab(self, name: string): Tab
end

export type Side = 'left' | 'right' | 'both'

declare class TabConstructor
  new: (window: Window, name: string) -> Tab
end

declare class Tab
  Instances: {
    Button: TextButton,
    Blocker: Frame,
    TabFrame: Frame,
    Container: ScrollingFrame,
    ListLayout: UIListLayout
  }
  function Show(self)
  function Hide(self)
  function IsSelected(self): boolean
  function AddChild(self, side: Side, child: GuiObject)
  function AddGroupBox(self, side: Side, options: GroupBoxOptions): GroupBox
end

export type GroupBoxOptions = {
  Title: string?,
  Collapsible: boolean?,
  Collapsed: boolean?
}

declare class GroupBoxConstructor
  new: (options: GroupBoxOptions) -> GroupBox
end

declare class GroupBox
  Instances: {
    Outer: Frame,
    Inner: Frame,
    Highlight: Frame,
    Label: TextLabel,
    Container: Frame,
    ListLayout: UIListLayout
  }
  function AddDropdown(self, options: DropdownOptions): Dropdown
end

export type DropdownOptions = {
  Title: string?,
  Type: ('players' | 'teams')?,
  Values: { string }?,
  Selected: { string }?,
  Multi: boolean?,
  AutoClose: boolean?,
  Compact: boolean?,
  Tooltip: string?,
  Callback: (selected: { string }) -> ()
}

declare class DropdownConstructor
  new: (options: DropdownOptions) -> Dropdown
end

declare class Dropdown

end
