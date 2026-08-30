/**
 * 左侧分类导航数据结构，对齐 Semi 官网左侧导航的分组样式（2026-08-12 实测截图）。
 * 分组与 `specs/component-inventory.md` 的 Phase 分类、`packages/ripple/src/<category>/`
 * 目录结构保持一致，新增已完成组件时在此同步补充链接项。
 */

export interface NavItem {
  text: string;
  href: string;
}

export interface NavGroup {
  title: string;
  items: NavItem[];
}

export const navGroups: NavGroup[] = [
  {
    title: '基础',
    items: [
      { text: 'Button 按钮', href: '/basic/button' },
      { text: 'Divider 分割线', href: '/basic/divider' },
      { text: 'Space 间距', href: '/basic/space' },
      { text: 'Grid 栅格', href: '/basic/grid' },
      { text: 'Layout 布局', href: '/basic/layout' },
      { text: 'Typography 排版', href: '/basic/typography' },
      { text: 'IconButton 图标按钮', href: '/basic/icon-button' },
      { text: 'FloatButton 悬浮按钮', href: '/basic/float-button' },
      { text: 'Resizable 可调整大小', href: '/basic/resizable' },
      { text: 'DragMove 拖拽移动', href: '/basic/drag-move' },
      { text: 'HotKeys 快捷键', href: '/basic/hotkeys' },
    ],
  },
  {
    title: '输入类',
    items: [
      { text: 'Input 输入框', href: '/input/input' },
      { text: 'Switch 开关', href: '/input/switch' },
      { text: 'Checkbox 多选框', href: '/input/checkbox' },
      { text: 'Radio 单选框', href: '/input/radio' },
      { text: 'InputNumber 数字输入框', href: '/input/input-number' },
      { text: 'Select 选择器', href: '/input/select' },
      { text: 'Form 表单', href: '/input/form' },
    ],
  },
  {
    title: '展示类',
    items: [
      { text: 'Tag 标签', href: '/show/tag' },
      { text: 'Avatar 头像', href: '/show/avatar' },
      { text: 'Tooltip 文字提示', href: '/show/tooltip' },
      { text: 'Popover 气泡卡片', href: '/show/popover' },
      { text: 'Dropdown 下拉菜单', href: '/show/dropdown' },
    ],
  },
  {
    title: '导航类',
    items: [
      { text: 'Breadcrumb 面包屑', href: '/navigation/breadcrumb' },
      { text: 'Nav 导航', href: '/navigation/navigation' },
      { text: 'Tabs 标签页', href: '/navigation/tabs' },
    ],
  },
  {
    title: '反馈类',
    items: [
      { text: 'Banner 通栏提示', href: '/feedback/banner' },
      { text: 'Notification 通知', href: '/feedback/notification' },
      { text: 'Popconfirm 气泡确认框', href: '/feedback/popconfirm' },
      { text: 'Progress 进度条', href: '/feedback/progress' },
      { text: 'Skeleton 骨架屏', href: '/feedback/skeleton' },
      { text: 'Spin 加载中', href: '/feedback/spin' },
      { text: 'Toast 提示', href: '/feedback/toast' },
    ],
  },
];
