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
      { text: 'AutoComplete 自动完成', href: '/input/auto-complete' },
      { text: 'Cascader 级联选择', href: '/input/cascader' },
      { text: 'ColorPicker 拾色器', href: '/input/color-picker' },
      { text: 'DatePicker 日期选择器', href: '/input/date-picker' },
      { text: 'PinCode 验证码输入框', href: '/input/pin-code' },
      { text: 'Rating 评分', href: '/input/rating' },
      { text: 'Slider 滑块', href: '/input/slider' },
      { text: 'Form 表单', href: '/input/form' },
      { text: 'TagInput 标签输入框', href: '/input/tag-input' },
      { text: 'TextArea 多行输入框', href: '/input/text-area' },
      { text: 'TimePicker 时间选择器', href: '/input/time-picker' },
      { text: 'Transfer 穿梭框', href: '/input/transfer' },
      { text: 'TreeSelect 树形选择器', href: '/input/tree-select' },
      { text: 'Upload 上传', href: '/input/upload' },
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
      { text: 'AudioPlayer 音频播放器', href: '/show/audio-player' },
      { text: 'Badge 徽标', href: '/show/badge' },
      { text: 'Calendar 日历', href: '/show/calendar' },
      { text: 'Card 卡片', href: '/show/card' },
      { text: 'Carousel 走马灯', href: '/show/carousel' },
      { text: 'Collapse 折叠面板', href: '/show/collapse' },
      { text: 'Collapsible 展开收起容器', href: '/show/collapsible' },
      { text: 'Cropper 图片裁剪', href: '/show/cropper' },
      { text: 'Descriptions 描述列表', href: '/show/descriptions' },
      { text: 'Empty 空状态', href: '/show/empty' },
      { text: 'Highlight 关键词高亮', href: '/show/highlight' },
      { text: 'Image 图片', href: '/show/image' },
      { text: 'List 列表', href: '/show/list' },
      { text: 'Timeline 时间轴', href: '/show/timeline' },
    ],
  },
  {
    title: '导航类',
    items: [
      { text: 'Breadcrumb 面包屑', href: '/navigation/breadcrumb' },
      { text: 'Nav 导航', href: '/navigation/navigation' },
      { text: 'Tabs 标签页', href: '/navigation/tabs' },
      { text: 'Anchor 锚点', href: '/navigation/anchor' },
      { text: 'BackTop 回到顶部', href: '/navigation/back-top' },
      { text: 'Pagination 分页', href: '/navigation/pagination' },
      { text: 'Steps 步骤条', href: '/navigation/steps' },
      { text: 'Tree 树形控件', href: '/navigation/tree' },
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
  {
    title: '其他',
    items: [
      { text: 'ConfigProvider 全局配置', href: '/other/config-provider' },
    ],
  },
];
