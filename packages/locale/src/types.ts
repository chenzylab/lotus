export interface FormLocale {
  requiredError: string;
  patternError: string;
  minError: (min: number) => string;
  maxError: (max: number) => string;
}

export interface InputLocale {
  clear: string;
  showPassword: string;
  hidePassword: string;
}

export interface InputNumberLocale {
  clear: string;
  increase: string;
  decrease: string;
}

export interface TextAreaLocale {
  clear: string;
}

export interface SelectLocale {
  clear: string;
  /** filter 开启后搜索无匹配结果时的占位文案。 */
  emptyText: string;
}

export interface ModalLocale {
  okText: string;
  cancelText: string;
}

export interface CalendarLocale {
  allDay: string;
  remaining: (remained: number) => string;
  weekdays: [string, string, string, string, string, string, string];
  months: [string, string, string, string, string, string, string, string, string, string, string, string];
  formatHour: (hour: number) => string;
}

export interface UserGuideLocale {
  next: string;
  prev: string;
  skip: string;
  finish: string;
}

export interface TimePickerLocale {
  placeholder: string;
  placeholderRange: string;
  hour: string;
  minute: string;
  second: string;
  hourLabel: string;
  minuteLabel: string;
  secondLabel: string;
  AM: string;
  PM: string;
  begin: string;
  end: string;
}

export interface DatePickerLocale {
  placeholder: {
    date: string;
    dateRange: string;
    dateTime: string;
    dateTimeRange: string;
    month: string;
    monthRange: string;
    year: string;
  };
  weeks: [string, string, string, string, string, string, string];
  months: [string, string, string, string, string, string, string, string, string, string, string, string];
  monthText: (year: number, month: number) => string;
  confirm: string;
  cancel: string;
  clear: string;
  today: string;
  now: string;
  prevYearLabel: string;
  prevMonthLabel: string;
  nextMonthLabel: string;
  nextYearLabel: string;
}

export interface UploadLocale {
  uploadFail: (status: number) => string;
  networkError: string;
  statusUploadFail: string;
  statusValidateFail: string;
  statusSuccess: string;
  statusUploading: string;
  statusWaiting: string;
  progress: (name: string) => string;
  retry: (name: string) => string;
  replace: (name: string) => string;
  remove: (name: string) => string;
  dragMainText: string;
  dragAreaLabel: string;
  uploadButton: string;
  fileListLabel: string;
}

export interface ColorPickerLocale {
  saturationValue: string;
  hue: string;
  alpha: string;
  picker: string;
  hex: string;
  red: string;
  green: string;
  blue: string;
  saturation: string;
  value: string;
  toggleFormat: string;
  defaultLabel: string;
}

export interface TransferLocale {
  dragHandle: string;
  remove: (label: string) => string;
  itemCount: (n: number) => string;
  itemCountSelected: (n: number) => string;
  clearAll: string;
  selectAll: string;
  searchPlaceholder: string;
  emptyLeft: string;
  emptySearch: string;
  emptyRight: string;
  clear: string;
}

export interface AudioPlayerLocale {
  loadError: string;
  progress: string;
  prev: string;
  pause: string;
  play: string;
  next: string;
  rewind: string;
  forward: string;
  replay: string;
  rate: string;
  volume: string;
}

export interface VideoPlayerLocale {
  loadError: string;
  play: string;
  progress: string;
  pause: string;
  mute: string;
  unmute: string;
  volume: string;
  rate: string;
  pictureInPicture: string;
  fullscreen: string;
  exitFullscreen: string;
}

export interface PaginationLocale {
  total: (n: number) => string;
  prevPage: string;
  nextPage: string;
  pageLabel: (n: number) => string;
  pageSizeLabel: string;
  perPage: (n: number) => string;
  jumpTo: string;
  jumpToPageLabel: string;
  page: string;
}

export interface TableLocale {
  selectRow: string;
  selectAll: string;
  filterReset: string;
  filterConfirm: string;
  filterLabel: string;
  emptyTitle: string;
}

export interface TagInputLocale {
  dragHandle: (item: string) => string;
  closableTag: (item: string) => string;
  plainTag: (item: string) => string;
  moreTagsExpand: (n: number) => string;
  inputLabel: string;
  clearAll: string;
}

export interface JsonViewerLocale {
  expandAll: string;
  collapseAll: string;
  invalidData: string;
  collapseNode: string;
  expandNode: string;
  propertyCount: (n: number) => string;
  itemCount: (n: number) => string;
}

export interface TreeLocale {
  searchPlaceholder: string;
  clearSearch: string;
  emptyContent: string;
}

export interface BreadcrumbLocale {
  navLabel: string;
  expandEllipsis: string;
}

export interface TagLocale {
  close: string;
}

export interface CarouselLocale {
  prev: string;
  next: string;
}

export interface ToastLocale {
  close: string;
}

export interface PopconfirmLocale {
  confirm: string;
  cancel: string;
  close: string;
}

export interface TypographyLocale {
  collapseText: string;
  expandText: string;
  copy: string;
  copied: string;
}

export interface SideSheetLocale {
  close: string;
}

export interface ListLocale {
  emptyContent: string;
}

export interface CropperLocale {
  cropBox: string;
}

export interface BadgeLocale {
  unreadMessage: string;
}

export interface TabsLocale {
  closeTab: string;
}

export interface BackTopLocale {
  label: string;
}

export interface NotificationLocale {
  close: string;
}

export interface BannerLocale {
  close: string;
}

export interface ImagePreviewLocale {
  prev: string;
  next: string;
  zoomIn: string;
  zoomOut: string;
  rotate: string;
  download: string;
  close: string;
}

export interface NavLocale {
  expandNav: string;
  collapseNav: string;
}

export interface PinCodeLocale {
  digitLabel: (index: number, count: number) => string;
}

export interface ResizableLocale {
  handleLabel: (direction: 'top' | 'right' | 'bottom' | 'left' | 'topRight' | 'bottomRight' | 'bottomLeft' | 'topLeft') => string;
}

export interface ChartLocale {
  emptyTitle: string;
  exportImage: string;
}

export interface RichTextEditorLocale {
  undo: string;
  redo: string;
  heading1: string;
  heading2: string;
  heading3: string;
  bulletList: string;
  orderedList: string;
  blockquote: string;
  codeBlock: string;
  alignLeft: string;
  alignCenter: string;
  alignRight: string;
  bold: string;
  italic: string;
  strike: string;
  inlineCode: string;
  linkUrlPrompt: string;
  insertLink: string;
  insertImage: string;
}

export interface AiChatDialogueLocale {
  selectMessage: string;
  copy: string;
  edit: string;
  like: string;
  dislike: string;
  regenerate: string;
  reference: string;
  delete: string;
  messageListLabel: string;
  backToBottom: string;
  suggestionHints: string;
  cancel: string;
  save: string;
  thinking: string;
  thoughtCompleted: string;
}

export interface AiToolCallLocale {
  inProgress: string;
  completed: string;
  failed: string;
  params: string;
  output: string;
}

export interface ChatLocale {
  placeholder: string;
  messageList: string;
  quickHints: string;
  inputLabel: string;
  sendLabel: string;
  sendButton: string;
}

export interface ChatMessageLocale {
  contextDivider: string;
  generating: string;
  copy: string;
  like: string;
  dislike: string;
  delete: string;
}

export interface AiChatInputLocale {
  placeholder: string;
  template: string;
  stopGenerate: string;
  send: string;
  referenceList: string;
  removeReference: string;
  attachmentList: string;
  removeAttachment: string;
  suggestionLabel: string;
  skillListLabel: string;
}

export interface SidebarLocale {
  back: string;
  close: string;
}

export interface McpConfigureLocale {
  innerTools: string;
  customTools: string;
  searchPlaceholder: string;
  emptyCustom: string;
  emptyAvailable: string;
  addTool: string;
  edit: string;
  configure: string;
  alwaysEnabledTip: string;
}

export interface ConfigureMcpLocale {
  configure: string;
}

export interface LocaleShape {
  code: string;
  dir: 'ltr' | 'rtl';
  Form: FormLocale;
  Input: InputLocale;
  InputNumber: InputNumberLocale;
  TextArea: TextAreaLocale;
  Select: SelectLocale;
  Modal: ModalLocale;
  Calendar: CalendarLocale;
  UserGuide: UserGuideLocale;
  TimePicker: TimePickerLocale;
  DatePicker: DatePickerLocale;
  Upload: UploadLocale;
  ColorPicker: ColorPickerLocale;
  Transfer: TransferLocale;
  AudioPlayer: AudioPlayerLocale;
  VideoPlayer: VideoPlayerLocale;
  Pagination: PaginationLocale;
  Table: TableLocale;
  TagInput: TagInputLocale;
  JsonViewer: JsonViewerLocale;
  Tree: TreeLocale;
  Breadcrumb: BreadcrumbLocale;
  Tag: TagLocale;
  Carousel: CarouselLocale;
  Toast: ToastLocale;
  Popconfirm: PopconfirmLocale;
  Typography: TypographyLocale;
  SideSheet: SideSheetLocale;
  List: ListLocale;
  Cropper: CropperLocale;
  Badge: BadgeLocale;
  Tabs: TabsLocale;
  BackTop: BackTopLocale;
  Notification: NotificationLocale;
  Banner: BannerLocale;
  ImagePreview: ImagePreviewLocale;
  Nav: NavLocale;
  PinCode: PinCodeLocale;
  Resizable: ResizableLocale;
  Chart: ChartLocale;
  RichTextEditor: RichTextEditorLocale;
  AiChatDialogue: AiChatDialogueLocale;
  AiToolCall: AiToolCallLocale;
  Chat: ChatLocale;
  ChatMessage: ChatMessageLocale;
  AiChatInput: AiChatInputLocale;
  Sidebar: SidebarLocale;
  McpConfigure: McpConfigureLocale;
  ConfigureMcp: ConfigureMcpLocale;
}
