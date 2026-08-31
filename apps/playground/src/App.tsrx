import { track } from 'ripple';
import { Button, ButtonGroup, IconButton, FloatButton, Resizable, Progress, Spin, Banner, Steps, Pagination, Popconfirm, BackTop, Anchor, Toast, Notification, Tree, Badge, Card, CardMeta, CardGroup, Empty, Descriptions, Collapse, CollapsePanel, Collapsible, List, ListItem, Timeline, TimelineItem, Image, ImagePreviewGroup, Carousel, Modal, SideSheet, Calendar, OverflowList, ScrollList, ScrollItem, Highlight, Cropper, UserGuide, Divider, Space, Row, Col, Switch, Tag, Tabs, Avatar, AvatarGroup, Layout, Header, Content, Footer, Sider, Tooltip, Popover, Breadcrumb, Skeleton, SkeletonAvatar, SkeletonImage, SkeletonTitle, SkeletonButton, SkeletonParagraph, Nav, NavHeader, NavItem, NavSub, NavFooter, Dropdown, DropdownMenu, DropdownItem, DropdownTitle, DropdownDivider, TypographyTitle, TypographyText, TypographyParagraph, TypographyNumeral, Input, TextArea, Checkbox, CheckboxGroup, Radio, RadioGroup, InputNumber, Select, Cascader, TreeSelect, AutoComplete, TimePicker, DatePicker, Slider, Rating, ColorPicker, type ColorValue, Transfer, Upload, type FileItem, type CustomRequestArgs, TagInput, PinCode, Table, type ColumnDef, Form, Field, ConfigProvider, zhCN, enUS, CodeHighlight, MarkdownRender, JsonViewer, Chat, type ChatMessage, AudioPlayer, VideoPlayer, Lottie, type AnimationItem, DragMove, HotKeys, Sidebar, SidebarMCPConfigure, type SidebarMCPOption, SidebarAnnotation, type SidebarAnnotationGroup, AiChatDialogue, type AiChatMessage as AiDialogueMessage, streamingResponseToMessage, type AiChatDialogueApi, AiChatInput, type AiChatInputApi, type AiInputMessageContent, Chart } from '@lotus/ripple';
import { IllustrationNoContent, IllustrationNotFound, IllustrationNoAccess } from '@lotus/illustrations';
import type { SelectOption, FormApi, FieldRenderProps, CropperApi } from '@lotus/ripple';
import { IconClose, IconPlus, IconSearch, IconSetting, IconTickCircle, IconAiBellLevel3, IconLotusLogo, IconLoading } from '@lotus/icons';
import { IconTag as IconTagLab, IconTable, IconAvatar as IconAvatarLab } from '@lotus/icons-lab';
import type { TagColor, TabItem, AvatarGroupItem, NavItemInput, TreeNodeData, CascaderNodeData } from '@lotus/ripple';

const tagColors: TagColor[] = ['blue', 'red', 'green', 'orange', 'purple', 'cyan', 'grey', 'white'];

const cascaderRegionData: CascaderNodeData[] = [
    {
        value: 'zhejiang',
        label: '浙江',
        children: [
            {
                value: 'hangzhou',
                label: '杭州',
                children: [
                    { value: 'xihu', label: '西湖区' },
                    { value: 'binjiang', label: '滨江区' },
                ],
            },
            { value: 'ningbo', label: '宁波', children: [{ value: 'yinzhou', label: '鄞州区' }] },
        ],
    },
    {
        value: 'jiangsu',
        label: '江苏',
        children: [
            { value: 'nanjing', label: '南京', children: [{ value: 'xuanwu', label: '玄武区' }] },
            { value: 'suzhou', label: '苏州', children: [{ value: 'gusu', label: '姑苏区' }] },
        ],
    },
    { value: 'shanghai', label: '上海', disabled: true, children: [{ value: 'pudong', label: '浦东新区' }] },
];

const cascaderVirtualizeData: CascaderNodeData[] = [
    {
        value: 'province-1',
        label: '省份 1（10000 个子节点）',
        children: Array.from({ length: 10000 }, (_, i) => ({ value: `city-${i}`, label: `城市 ${i}` })),
    },
];

const cascaderLazyData: CascaderNodeData[] = [
    { value: 'fruit', label: '水果', isLeaf: false },
    { value: 'vegetable', label: '蔬菜', isLeaf: false },
];

const treeSelectLazyData: TreeNodeData[] = [
    { key: 'fruit', label: '水果', isLeaf: false },
    { key: 'vegetable', label: '蔬菜', isLeaf: false },
];

const treeSelectVirtualizeData: TreeNodeData[] = [
    {
        key: 'root',
        label: '根节点（10000 个子节点）',
        children: Array.from({ length: 10000 }, (_, i) => ({ key: `node-${i}`, label: `节点 ${i}` })),
    },
];

const autoCompleteAllCities = ['北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '武汉', '西安', '苏州'];

// Cropper 演示用同源 SVG data URI：跨域图片会污染 canvas，getImageData/toDataURL 会被浏览器拒绝
// （SecurityError: The canvas has been tainted by cross-origin data），改用同源资源规避。
const CROPPER_DEMO_SRC =
    'data:image/svg+xml;base64,' +
    btoa(
        unescape(
            encodeURIComponent(
                '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600">' +
                    '<rect width="800" height="600" fill="#eef2ff"/>' +
                    '<circle cx="250" cy="300" r="180" fill="#60a5fa"/>' +
                    '<rect x="450" y="120" width="280" height="360" fill="#f472b6"/>' +
                    '<text x="400" y="580" font-size="28" text-anchor="middle" fill="#1e293b">lotus cropper demo</text>' +
                    '</svg>',
            ),
        ),
    );

const businessLineOptions: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

const genderOptions: SelectOption[] = [
    { value: 'male', label: '男' },
    { value: 'female', label: '女' },
];

const largeSelectOptionList: SelectOption[] = Array.from({ length: 10000 }, (_, i) => ({
    value: `option-${i}`,
    label: `选项 ${i}`,
}));

function lineTabList(): TabItem[] {
    return [
        { itemKey: '1', tab: '标签一', render: () => <div>内容一</div> },
        { itemKey: '2', tab: '标签二', render: () => <div>内容二</div> },
        { itemKey: '3', tab: '禁用标签', disabled: true, render: () => <div>不可达</div> },
        { itemKey: '4', tab: '标签四', render: () => <div>内容四</div> },
    ];
}

function closableTabList(): TabItem[] {
    return [
        { itemKey: 'a', tab: '可关闭 A', closable: true, render: () => <div>面板 A</div> },
        { itemKey: 'b', tab: '可关闭 B', closable: true, render: () => <div>面板 B</div> },
    ];
}

const treeDemoData: TreeNodeData[] = [
    {
        key: 'dept-1',
        label: '研发部',
        children: [
            {
                key: 'dept-1-1',
                label: '前端组',
                children: [
                    { key: 'dept-1-1-1', label: '张三' },
                    { key: 'dept-1-1-2', label: '李四' },
                ],
            },
            {
                key: 'dept-1-2',
                label: '后端组',
                children: [
                    { key: 'dept-1-2-1', label: '王五' },
                    { key: 'dept-1-2-2', label: '赵六', disabled: true },
                ],
            },
        ],
    },
    {
        key: 'dept-2',
        label: '产品部',
        children: [
            { key: 'dept-2-1', label: '刘七' },
            { key: 'dept-2-2', label: '陈八' },
        ],
    },
];

const transferListData = [
    { key: 'a1', label: '苹果' },
    { key: 'a2', label: '香蕉' },
    { key: 'a3', label: '樱桃' },
    { key: 'a4', label: '榴莲' },
    { key: 'a5', label: '芒果', disabled: true },
];

const transferGroupData = [
    { title: '水果', children: [{ key: 'g1', label: '苹果' }, { key: 'g2', label: '香蕉' }] },
    { title: '蔬菜', children: [{ key: 'g3', label: '西红柿' }, { key: 'g4', label: '黄瓜', disabled: true }] },
];

const transferManyData = Array.from({ length: 60 }, (_v, i) => ({ key: `m${i}`, label: `选项 ${i + 1}` }));

const transferControlledData = [
    { key: 'c1', label: '选项 A' },
    { key: 'c2', label: '选项 B' },
    { key: 'c3', label: '选项 C' },
];

const chartCategoryData = [
    { category: '一月', value: 38 },
    { category: '二月', value: 52 },
    { category: '三月', value: 61 },
    { category: '四月', value: 45 },
    { category: '五月', value: 70 },
];

const chartFunnelData = [
    { category: '访问', value: 1000 },
    { category: '注册', value: 620 },
    { category: '下单', value: 280 },
    { category: '支付', value: 120 },
];

const chartRadarData = [
    { category: '速度', value: 80, series: 'A' },
    { category: '力量', value: 65, series: 'A' },
    { category: '防御', value: 70, series: 'A' },
    { category: '敏捷', value: 90, series: 'A' },
    { category: '速度', value: 60, series: 'B' },
    { category: '力量', value: 85, series: 'B' },
    { category: '防御', value: 55, series: 'B' },
    { category: '敏捷', value: 70, series: 'B' },
];

function loadTreeChildren(node: TreeNodeData): Promise<TreeNodeData[]> {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve([
                { key: `${node.key}-c1`, label: `${node.label} 子节点 1` },
                { key: `${node.key}-c2`, label: `${node.label} 子节点 2`, isLeaf: false },
            ]);
        }, 600);
    });
}

// 模拟上传：无真实后端时用定时器伪造进度事件，演示 customRequest 完全接管
// 网络 IO 的能力（不发起真实 XHR）。
function mockUploadRequest(args: CustomRequestArgs) {
    let percent = 0;
    const timer = setInterval(() => {
        percent += 20;
        if (percent >= 100) {
            clearInterval(timer);
            args.onProgress(100);
            args.onSuccess({ url: `https://example.com/${args.fileName}` });
            return;
        }
        args.onProgress(percent);
    }, 200);
}

// Field 的 Comp 收到统一的 { value, disabled, onChange, onBlur, 'aria-label' }，
// 由这几个桥接组件把它接到具体输入组件各自的 props 形状上（Input 是
// onChange(value, event)，InputNumber/Select 是 onChange(value)）。
function FormUsernameInput(&{ id, value, disabled, validating, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Input
            id={id}
            value={value ?? ''}
            disabled={disabled}
            suffix={validating ? <IconLoading /> : undefined}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请输入用户名"
        />
    );
}

function FormAgeInput(&{ id, value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <InputNumber
            id={id}
            value={value}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请输入年龄"
        />
    );
}

function FormBusinessLineSelect(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Select
            optionList={businessLineOptions}
            value={value}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请选择业务线"
        />
    );
}

// 表单联动 demo：Semi 官方模式是"监听 Field 的 onChange，用 formApi.setValue 改另一个
// 字段"（Semi 没有专门的联动 API），此处用 Form 级别的 onValueChange 回调实现（在
// App 组件内部，能访问 formApi 闭包），比在具体 Field 桥接组件里访问闭包更符合
// Field 桥接函数应保持"纯粹转发 FieldRenderProps"的既有设计。
function FormGenderSelect(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Select
            optionList={genderOptions}
            value={value}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请选择性别"
        />
    );
}

function FormNoteInput(&{ id, value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Input
            id={id}
            value={value ?? ''}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="选择性别后自动填充"
        />
    );
}

function FormAgreeCheckbox(&{ value, disabled, onChange, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Checkbox
            checked={value ?? false}
            disabled={disabled}
            onChange={(checked) => onChange(checked)}
            aria-label={ariaLabel}
        >
            我同意用户协议
        </Checkbox>
    );
}

export function App() @{
    let &[inputControlledValue] = track<string>('受控初始值');
    let &[inputExternalControlledValue] = track<string>('初始值');
    let &[textAreaControlledValue] = track<string>('初始内容');
    let &[switchControlledChecked] = track<boolean>(false);
    let &[progressPercent] = track<number>(30);
    let &[buttonMouseEventLog] = track<string>('');
    let &[motionProgressPercent] = track<number>(30);
    let &[spinSpinning] = track<boolean>(true);
    let &[stepsCurrent] = track<number>(1);
    let &[paginationCurrentPage] = track<number>(3);
    let &[paginationPageSize] = track<number>(10);
    let &[checkboxControlledChecked] = track<boolean>(false);
    let &[collapseControlledActiveKey] = track<string[]>([]);
    let &[collapsibleOpen] = track<boolean>(false);
    let &[carouselControlledIndex] = track<number>(0);
    let &[carouselMounted] = track<boolean>(true);
    let &[modalBasicVisible] = track<boolean>(false);
    let &[modalCustomFooterVisible] = track<boolean>(false);
    let &[modalAsyncVisible] = track<boolean>(false);
    let &[modalControlledVisible] = track<boolean>(false);
    let &[modalFullScreenVisible] = track<boolean>(false);
    let &[modalCenteredVisible] = track<boolean>(false);
    let &[modalNoMaskCloseVisible] = track<boolean>(false);
    let &[modalAfterCloseLog] = track<string>('');
    let &[sideSheetRightVisible] = track<boolean>(false);
    let &[sideSheetLeftVisible] = track<boolean>(false);
    let &[sideSheetTopVisible] = track<boolean>(false);
    let &[sideSheetBottomVisible] = track<boolean>(false);
    let &[sideSheetKeepDomVisible] = track<boolean>(false);
    let &[sideSheetNoMaskCloseVisible] = track<boolean>(false);
    let &[sideSheetAfterVisibleChangeLog] = track<string>('');
    let &[calendarWeekAnchor] = track<Date>(new Date(2026, 0, 15));
    let &[calendarMonthAnchor] = track<Date>(new Date(2026, 0, 15));
    let &[calendarClickLog] = track<string>('');
    let &[scrollHourIndex] = track<number>(3);
    let &[scrollMinuteIndex] = track<number>(0);
    let &[scrollControlledIndex] = track<number>(2);
    let &[checkboxGroupControlledValue] = track<Array<string | number>>(['A']);
    let &[radioControlledChecked] = track<boolean>(false);
    let &[radioGroupControlledValue] = track<string | number>('A');
    let &[inputNumberControlledValue] = track<number>(0);
    let &[selectControlledValue] = track<string>('douyin');
    let &[cascaderControlledValue] = track<Array<string | number>>(['zhejiang', 'hangzhou', 'xihu']);
    let &[cascaderMultipleValue] = track<Array<Array<string | number>>>([]);
    let &[cascaderChangeLog] = track<string>('');
    let &[cascaderLazyTreeData] = track<CascaderNodeData[]>(cascaderLazyData);
    let &[treeSelectControlledValue] = track<string>('dept-1-1-1');
    let &[treeSelectChangeLog] = track<string>('');
    let &[treeSelectLazyTreeData] = track<TreeNodeData[]>(treeSelectLazyData);
    let &[autoCompleteSearchResult] = track<string[]>(autoCompleteAllCities);
    let &[autoCompleteChangeLog] = track<string>('');
    let &[autoCompleteControlledValue] = track<string>('北京');
    let &[autoCompleteLoading] = track<boolean>(false);
    let &[autoCompleteLoadingResult] = track<string[]>([]);
    let &[timePickerChangeLog] = track<string>('');
    let &[timePickerRangeChangeLog] = track<string>('');
    let &[timePickerControlledValue] = track<Date | null>(null);
    let &[datePickerChangeLog] = track<string>('');
    let &[datePickerRangeChangeLog] = track<string>('');
    let &[datePickerControlledValue] = track<Date | null>(new Date(2024, 2, 5));
    let &[sliderChangeLog] = track<string>('');
    let &[sliderRangeChangeLog] = track<string>('');
    let &[sliderControlledValue] = track<number>(30);
    let &[ratingChangeLog] = track<string>('');
    let &[ratingHalfChangeLog] = track<string>('');
    let &[ratingControlledValue] = track<number>(3);
    let &[colorPickerChangeLog] = track<string>('');
    let &[colorPickerNoAlphaValue] = track<ColorValue>({
        hsva: { h: 200, s: 80, v: 90, a: 1 },
        rgba: { r: 46, g: 184, b: 230, a: 1 },
        hex: '#2eb8e6',
    });
    let &[transferValue] = track<Array<string | number>>(['a1', 'a3']);
    let &[transferGroupValue] = track<Array<string | number>>([]);
    let &[transferTreeValue] = track<Array<string | number>>([]);
    let &[transferControlledValue] = track<Array<string | number>>(['c1']);
    let &[uploadFileList] = track<FileItem[]>([]);
    let &[uploadDragFileList] = track<FileItem[]>([]);
    let &[uploadPictureFileList] = track<FileItem[]>([]);
    let &[uploadChangeLog] = track<string>('');
    let &[tagInputValue] = track<string[]>(['苹果', '香蕉']);
    let &[tagInputChangeLog] = track<string>('');
    let &[tagInputFoldValue] = track<string[]>(['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6']);
    let &[tagInputDragValue] = track<string[]>(['red', 'green', 'blue', 'yellow']);
    let &[tagInputControlledValue] = track<string[]>(['a', 'b']);
    let &[pinCodeChangeLog] = track<string>('');
    let &[pinCodeCompleteLog] = track<string>('');
    let &[pinCodeControlledValue] = track<string>('123');
    let &[pinCodeDynamicFormat] = track<'number' | 'mixed'>('number');
    let &[iconButtonDynamicDisabled] = track<boolean>(true);
    let &[iconButtonDynamicClickLog] = track<string>('');
    let &[floatButtonDynamicDisabled] = track<boolean>(true);
    let &[floatButtonDynamicClickLog] = track<string>('');

    interface TablePerson {
        key: string;
        name: string;
        age: number;
        city: string;
        dept: string;
        children?: TablePerson[];
    }
    const tableBasicColumns: ColumnDef<TablePerson>[] = [
        { title: '姓名', dataIndex: 'name', key: 'name' },
        { title: '年龄', dataIndex: 'age', key: 'age', sorter: (a, b) => a.age - b.age },
        {
            title: '城市',
            dataIndex: 'city',
            key: 'city',
            filters: [
                { text: '北京', value: '北京' },
                { text: '上海', value: '上海' },
                { text: '深圳', value: '深圳' },
            ],
            onFilter: (value, record) => record.city === value,
        },
    ];
    const tableBasicData: TablePerson[] = [
        { key: '1', name: '张三', age: 32, city: '北京', dept: '研发' },
        { key: '2', name: '李四', age: 28, city: '上海', dept: '产品' },
        { key: '3', name: '王五', age: 45, city: '深圳', dept: '研发' },
        { key: '4', name: '赵六', age: 24, city: '北京', dept: '设计' },
        { key: '5', name: '孙七', age: 36, city: '上海', dept: '运营' },
    ];

    let &[tableChangeLog] = track<string>('');
    let &[tableSelectedKeys] = track<Array<string | number>>([]);

    const tableVirtualizeData: TablePerson[] = Array.from({ length: 10000 }, (_, i) => ({
        key: String(i),
        name: `用户 ${i}`,
        age: 20 + (i % 40),
        city: ['北京', '上海', '深圳'][i % 3]!,
        dept: '研发',
    }));
    let &[tableVirtualizeSelectedKeys] = track<Array<string | number>>([]);

    const tablePageColumns: ColumnDef<TablePerson>[] = [
        { title: '姓名', dataIndex: 'name', key: 'name' },
        { title: '年龄', dataIndex: 'age', key: 'age', sorter: (a, b) => a.age - b.age },
        { title: '部门', dataIndex: 'dept', key: 'dept' },
    ];
    const tablePageData: TablePerson[] = Array.from({ length: 23 }, (_, i) => ({
        key: `p${i + 1}`,
        name: `员工${i + 1}`,
        age: 22 + (i % 20),
        city: i % 2 === 0 ? '北京' : '上海',
        dept: i % 3 === 0 ? '研发' : i % 3 === 1 ? '产品' : '设计',
    }));

    const tableTreeColumns: ColumnDef<TablePerson>[] = [
        { title: '姓名', dataIndex: 'name', key: 'name' },
        { title: '部门', dataIndex: 'dept', key: 'dept' },
    ];
    const tableTreeData: TablePerson[] = [
        {
            key: 't1',
            name: '研发中心',
            age: 0,
            city: '',
            dept: '研发',
            children: [
                { key: 't1-1', name: '前端组', age: 0, city: '', dept: '研发' },
                { key: 't1-2', name: '后端组', age: 0, city: '', dept: '研发' },
            ],
        },
        {
            key: 't2',
            name: '产品中心',
            age: 0,
            city: '',
            dept: '产品',
            children: [{ key: 't2-1', name: '产品组', age: 0, city: '', dept: '产品' }],
        },
    ];

    const tableExpandColumns: ColumnDef<TablePerson>[] = [
        { title: '姓名', dataIndex: 'name', key: 'name' },
        { title: '部门', dataIndex: 'dept', key: 'dept' },
    ];

    const tableFixedColumns: ColumnDef<TablePerson>[] = [
        { title: '姓名', dataIndex: 'name', key: 'name', fixed: 'left', width: 120 },
        { title: '年龄', dataIndex: 'age', key: 'age', width: 100 },
        { title: '城市', dataIndex: 'city', key: 'city', width: 120 },
        { title: '部门', dataIndex: 'dept', key: 'dept', width: 120 },
        { title: '操作', key: 'action', fixed: 'right', width: 100, render: () => <a href="javascript:void(0)">编辑</a> },
    ];

    let formApiRef: FormApi | undefined;
    let &[formSubmitResult] = track<string>('');
    let linkageFormApiRef: FormApi | undefined;

    function handleLinkageValueChange(_values: Record<string, unknown>, changed: Record<string, unknown>) {
        if ('sex' in changed) {
            linkageFormApiRef?.setValue('note', changed.sex === 'male' ? 'Hi male' : 'Hi female!');
        }
    }
    let &[localeIsEnglish] = track<boolean>(false);
    let &[localeFormApiRef] = track<FormApi | undefined>(undefined);
    let &[configProviderThemeMode] = track<'light' | 'dark' | undefined>(undefined);
    let &[configProviderModalVisible] = track<boolean>(false);
    let &[configProviderDirection] = track<'ltr' | 'rtl'>('ltr');
    let &[rtlSidebarVisible] = track<boolean>(false);
    let &[rtlSidebarMode] = track<'main' | 'code'>('main');
    let &[cropperResultUrl] = track<string>('');
    let &[cropperZoom] = track<number>(1);
    let &[chatMessages] = track<ChatMessage[]>(() => [
        { id: 'demo-1', role: 'assistant', content: '你好，我可以帮你做什么？', status: 'complete' } as ChatMessage,
        { id: 'demo-2', role: 'user', content: '介绍一下 lotus 组件库', status: 'complete' } as ChatMessage,
    ]);
    let &[cropperRotate] = track<number>(0);
    let &[cropperApiResultUrl] = track<string>('');
    let cropperApiRef: CropperApi | undefined;
    let &[userGuideVisible] = track<boolean>(false);
    let lottieInstance: AnimationItem | null = null;
    let &[lottieMounted] = track<boolean>(true);
    let &[videoPlayerMounted] = track<boolean>(true);
    let &[hotKeyTriggerCount] = track<number>(0);
    let &[hotKeyClickLog] = track<string>('');
    let &[chartEventLog] = track<string>('');
    let &[chartExportLog] = track<string>('');
    let &[chartLoading] = track<boolean>(false);
    let &[sidebarVisible] = track<boolean>(false);
    let &[sidebarMode] = track<'main' | 'code' | 'file'>('main');
    let &[sidebarBackWardLog] = track<string>('');
    const sidebarCodeDetail = { key: 'code-1', name: 'demo.json', isJson: true, content: JSON.stringify({ hello: 'world', count: 3 }, null, 2) };
    const sidebarFileDetail = { key: 'file-1', name: 'readme.txt', content: '<p>这是一段可编辑的富文本内容。</p>' };
    let &[aiDialogueMessages] = track<AiDialogueMessage[]>(() => [
        { id: 'ai-msg-1', role: 'user', content: '帮我查一下北京今天的天气' },
        {
            id: 'ai-msg-2',
            role: 'assistant',
            status: 'completed',
            content: [
                { type: 'reasoning', summary: ['用户想查询天气，需要调用天气工具获取北京的实时数据。'] },
                { type: 'tool_call', call_id: 'call-1', name: 'get_weather', arguments: '{"city":"北京"}', status: 'completed', output: '{"temp":24,"condition":"晴"}' },
                { type: 'output_text', text: '北京今天 **24°C**，晴朗，适合出行。' },
            ],
        },
    ] as AiDialogueMessage[]);
    let aiDialogueApi: AiChatDialogueApi | undefined;
    let aiStreamState: any = null;
    let &[aiStreamingLog] = track<string>('');
    let aiInputApi: AiChatInputApi | undefined;
    let &[aiInputSentLog] = track<string>('');
    let &[aiInputGenerating] = track<boolean>(false);
    let &[aiInputReferences] = track<Array<{ id: string; name?: string; content?: string }>>([
        { id: 'ref-1', name: 'design-doc.md', content: '设计文档引用片段' },
    ]);
    let &[userGuideCurrent] = track<number>(0);
    let &[userGuideLog] = track<string>('');
    let &[userGuideModalVisible] = track<boolean>(false);
    let userGuideStepAEl: HTMLElement | undefined;
    let userGuideStepBEl: HTMLElement | undefined;
    let userGuideStepCEl: HTMLElement | undefined;

    <>
    <div style={{ padding: '32px' }}>
        <Space wrap>
            @for (const color of tagColors; key color) {
                <Tag color={color} type="light">{color}</Tag>
            }
        </Space>

        <Divider />

        <Space wrap>
            @for (const color of tagColors; key color) {
                <Tag color={color} type="solid">{color}</Tag>
            }
        </Space>

        <Divider />

        <Space wrap>
            @for (const color of tagColors; key color) {
                <Tag color={color} type="ghost">{color}</Tag>
            }
        </Space>

        <Divider />

        <Space>
            <Tag size="small" color="blue">small</Tag>
            <Tag size="default" color="blue">default</Tag>
            <Tag size="large" color="blue">large</Tag>
            <Tag
                color="green"
                closable
                onClose={() => console.log('tag closed')}
            >
                可关闭标签
            </Tag>
        </Space>

        <Divider>Tag：colorful / gradient（AI 多彩风格）</Divider>

        <Space wrap>
            <Tag type="solid" colorful>solid colorful</Tag>
            <Tag type="solid" colorful gradient>solid colorful gradient</Tag>
            <Tag type="light" colorful>light colorful</Tag>
            <Tag type="light" colorful gradient>light colorful gradient</Tag>
            <Tag type="ghost" colorful>ghost colorful</Tag>
            <Tag type="ghost" colorful gradient>ghost colorful gradient</Tag>
        </Space>

        <Divider />

        <Tabs tabList={lineTabList()} type="line" onChange={(key) => console.log('line tab changed', key)} />

        <Divider />

        <Tabs tabList={lineTabList()} type="card" />

        <Divider />

        <Tabs tabList={lineTabList()} type="button" size="small" />

        <Divider />

        <Tabs
            tabList={closableTabList()}
            type="line"
            onTabClose={(key) => console.log('tab closed', key)}
        />

        <Divider />

        <Space>
            <Switch defaultChecked onChange={(c) => console.log('uncontrolled switch', c)} />
            <Switch disabled />
            <Switch checked loading />
            <Switch size="large" defaultChecked />
            <Switch size="small" defaultChecked />
        </Space>

        <Divider>Switch：受控（外部按钮驱动）</Divider>

        <Space>
            <Switch checked={switchControlledChecked} onChange={(c: boolean) => { switchControlledChecked = c; }} aria-label="Switch 受控示例" />
            <Button onClick={() => { switchControlledChecked = !switchControlledChecked; }}>切换 Switch</Button>
        </Space>

        <Divider />

        <Space>
            <Button onClick={() => console.log('lotus button clicked')}>默认按钮</Button>
            <Button disabled onClick={() => console.log('should not fire')}>禁用按钮</Button>
            <Button loading onClick={() => console.log('should not fire')}>加载中按钮</Button>
        </Space>

        <Divider>Button：type × theme 矩阵</Divider>

        <Space vertical align="start">
            <Space>
                <Button type="primary" theme="solid">primary solid</Button>
                <Button type="secondary" theme="solid">secondary solid</Button>
                <Button type="tertiary" theme="solid">tertiary solid</Button>
                <Button type="warning" theme="solid">warning solid</Button>
                <Button type="danger" theme="solid">danger solid</Button>
            </Space>
            <Space>
                <Button type="primary" theme="light">primary light</Button>
                <Button type="secondary" theme="light">secondary light</Button>
                <Button type="tertiary" theme="light">tertiary light</Button>
                <Button type="warning" theme="light">warning light</Button>
                <Button type="danger" theme="light">danger light</Button>
            </Space>
            <Space>
                <Button type="primary" theme="outline">primary outline</Button>
                <Button type="secondary" theme="outline">secondary outline</Button>
                <Button type="tertiary" theme="outline">tertiary outline</Button>
                <Button type="warning" theme="outline">warning outline</Button>
                <Button type="danger" theme="outline">danger outline</Button>
            </Space>
            <Space>
                <Button type="primary" theme="borderless">primary borderless</Button>
                <Button type="secondary" theme="borderless">secondary borderless</Button>
                <Button type="tertiary" theme="borderless">tertiary borderless</Button>
                <Button type="warning" theme="borderless">warning borderless</Button>
                <Button type="danger" theme="borderless">danger borderless</Button>
            </Space>
        </Space>

        <Divider>Button：size / disabled / block</Divider>

        <Space>
            <Button size="large" theme="solid">large</Button>
            <Button size="default" theme="solid">default</Button>
            <Button size="small" theme="solid">small</Button>
            <Button theme="solid" disabled>disabled solid</Button>
            <Button theme="outline" disabled>disabled outline</Button>
        </Space>
        <div style={{ marginTop: '12px' }}>
            <Button theme="solid" block onClick={() => console.log('block button clicked')}>block 按钮</Button>
        </div>

        <Divider>Button：colorful（AI 多彩风格）</Divider>

        <Space>
            <Button type="primary" theme="solid" colorful>primary solid colorful</Button>
            <Button type="tertiary" theme="solid" colorful>tertiary solid colorful</Button>
            <Button type="primary" theme="light" colorful>primary light colorful</Button>
            <Button type="primary" theme="borderless" colorful>primary borderless colorful</Button>
            <Button type="secondary" theme="solid" colorful>secondary colorful（应静默无效果）</Button>
        </Space>

        <Divider>Button：noHorizontalPadding / contentClassName / 鼠标事件透传</Divider>

        <Space>
            <Button icon={<IconTickCircle />} aria-label="无水平内边距按钮" noHorizontalPadding />
            <Button icon={<IconTickCircle />} aria-label="仅去左侧内边距" noHorizontalPadding="left">仅左</Button>
            <Button contentClassName="demo-button-content-marker" aria-label="内容自定义类名按钮">内容类名</Button>
            <Button
                aria-label="鼠标事件按钮"
                onMouseDown={() => { buttonMouseEventLog = 'mousedown'; }}
                onMouseEnter={() => { buttonMouseEventLog = 'mouseenter'; }}
                onMouseLeave={() => { buttonMouseEventLog = 'mouseleave'; }}
            >
                悬停/按下我
            </Button>
            <TypographyText type="secondary" aria-label="鼠标事件日志">{buttonMouseEventLog}</TypographyText>
        </Space>

        <Divider>ButtonGroup</Divider>

        <ButtonGroup aria-label="示例按钮组">
            <Button theme="outline">左</Button>
            <Button theme="outline">中</Button>
            <Button theme="outline">右</Button>
        </ButtonGroup>

        <Divider>IconButton</Divider>

        <Space>
            <IconButton icon={<IconSetting />} aria-label="设置" onClick={() => console.log('icon button clicked')} />
            <IconButton icon={<IconClose />} type="danger" theme="solid" aria-label="关闭" />
            <IconButton icon={<IconSearch />} theme="outline" aria-label="搜索" />
            <IconButton icon={<IconPlus />} size="large" aria-label="新增（large）" />
            <IconButton icon={<IconTickCircle />} size="small" aria-label="确认（small）" />
            <IconButton icon={<IconSetting />} disabled aria-label="禁用图标按钮" onClick={() => console.log('should not fire')} />
            <IconButton icon={<IconSetting />} loading aria-label="加载中图标按钮" onClick={() => console.log('should not fire')} />
        </Space>

        <Divider>IconButton：disabled 运行时动态切换（回归防护：非函数字面量 track() 固化快照会让 disabled 变化后点击回调永远被拦截，详见 specs 踩坑 #94）</Divider>

        <Space>
            <IconButton
                icon={<IconSetting />}
                disabled={iconButtonDynamicDisabled}
                aria-label="IconButton 动态禁用示例"
                onClick={() => { iconButtonDynamicClickLog = '点击生效'; }}
            />
            <Button onClick={() => { iconButtonDynamicDisabled = !iconButtonDynamicDisabled; }}>
                切换 IconButton 禁用态
            </Button>
            <TypographyText type="secondary" aria-label="IconButton 动态禁用日志">{iconButtonDynamicClickLog}</TypographyText>
        </Space>

        <Divider>FloatButton</Divider>

        {/* FloatButton 默认 position: fixed，演示区用 position: relative 覆盖以便并排展示 */}
        <div style={{ display: 'flex', gap: '16px', position: 'relative', height: '60px' }}>
            <FloatButton icon={<IconSetting />} aria-label="悬浮设置" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('float button clicked')} />
            <FloatButton icon={<IconAiBellLevel3 />} colorful aria-label="AI 悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('float button ai clicked')} />
            <FloatButton icon={<IconSetting />} shape="square" aria-label="方形悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
            <FloatButton icon={<IconSetting />} size="small" aria-label="小号悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
            <FloatButton icon={<IconSetting />} disabled aria-label="禁用悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('should not fire')} />
            <FloatButton icon={<IconSetting />} badge={{ count: 5 }} aria-label="带角标的悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
        </div>

        <Divider>FloatButton：disabled 运行时动态切换（回归防护：与 IconButton 同一根因，详见 specs 踩坑 #94）</Divider>

        <div style={{ display: 'flex', gap: '16px', alignItems: 'center', position: 'relative', height: '60px' }}>
            <FloatButton
                icon={<IconSetting />}
                disabled={floatButtonDynamicDisabled}
                aria-label="FloatButton 动态禁用示例"
                style={{ position: 'relative', right: 'auto', bottom: 'auto' }}
                onClick={() => { floatButtonDynamicClickLog = '点击生效'; }}
            />
            <Button onClick={() => { floatButtonDynamicDisabled = !floatButtonDynamicDisabled; }}>
                切换 FloatButton 禁用态
            </Button>
            <TypographyText type="secondary" aria-label="FloatButton 动态禁用日志">{floatButtonDynamicClickLog}</TypographyText>
        </div>

        <Divider>Resizable</Divider>

        <Resizable
            defaultWidth={240}
            defaultHeight={120}
            minWidth={120}
            minHeight={80}
            maxWidth={480}
            maxHeight={320}
            aria-label="可调整大小容器"
            onChange={(size) => console.log('resizable changed', size.width, size.height)}
            onResizeEnd={(size) => console.log('resizable resize end', size.width, size.height)}
        >
            <div style={{ padding: '12px' }}>拖拽边缘或角落调整大小</div>
        </Resizable>

        <Divider>Progress</Divider>

        <Space vertical align="start" style={{ width: '320px' }}>
            <Progress percent={30} showInfo aria-label="line 基础进度条" style={{ width: '100%' }} />
            <Progress percent={70} type="circle" showInfo aria-label="circle 基础进度条" />
            <Progress
                percent={progressPercent}
                showInfo
                stroke={[
                    { percent: 0, color: '#f93920' },
                    { percent: 50, color: '#fc8800' },
                    { percent: 100, color: '#3bb346' },
                ]}
                strokeGradient
                aria-label="多段渐变进度条（受控，按钮驱动）"
                style={{ width: '100%' }}
            />
            <Button onClick={() => { progressPercent = progressPercent >= 100 ? 0 : progressPercent + 20; }}>切换 Progress 百分比</Button>
            <Progress percent={30} showInfo format={(p) => `第 ${Math.round(p / 10)} 步，共 10 步`} aria-label="自定义 format 文案进度条（验证 aria-valuetext 跟随 format 而非原始百分比）" style={{ width: '100%' }} />
            <Progress percent={motionProgressPercent} showInfo motion={false} aria-label="禁用动画的进度条（验证 motion=false 时 CSS transition 被禁用）" style={{ width: '100%' }} />
            <Button onClick={() => { motionProgressPercent = motionProgressPercent >= 100 ? 0 : motionProgressPercent + 20; }}>切换禁用动画的 Progress 百分比</Button>
        </Space>

        <Divider>Spin</Divider>

        <Space vertical align="start">
            <Spin spinning aria-label="独立 Spin 指示器" />
            <Spin spinning delay={200} aria-label="延迟显示的 Spin（delay=200ms）" />
            <Spin spinning={spinSpinning} aria-label="包裹内容的 Spin">
                <div style={{ width: '200px', height: '100px', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
                    被包裹的内容区域
                </div>
            </Spin>
            <Button onClick={() => { spinSpinning = !spinSpinning; }}>切换 Spin 加载态</Button>
        </Space>

        <Divider>Banner</Divider>

        <Space vertical style={{ width: '100%' }}>
            <Banner type="info" title="信息提示" description="这是一条 info 类型的通栏提示" onClose={() => console.log('banner info closed')} />
            <Banner type="success" title="操作成功" bordered fullMode={false} />
            <Banner type="warning" title="警告" description="bordered + fullMode=false 卡片模式" bordered fullMode={false} />
            <Banner type="danger" title="错误" closeIcon={null} />
        </Space>

        <Divider>Steps</Divider>

        <Steps
            type="fill"
            current={stepsCurrent}
            items={[
                { title: '第一步', description: '填写基本信息' },
                { title: '第二步', description: '确认订单' },
                { title: '第三步', description: '完成支付' },
                { title: '第四步', description: '交易完成' },
            ]}
            onChange={(c) => { stepsCurrent = c; }}
            aria-label="fill 类型步骤条"
        />

        <Space style={{ marginTop: '12px' }}>
            <Button onClick={() => { stepsCurrent = Math.max(0, stepsCurrent - 1); }}>上一步</Button>
            <Button onClick={() => { stepsCurrent = Math.min(3, stepsCurrent + 1); }}>下一步</Button>
        </Space>

        <Steps
            type="basic"
            current={1}
            status="error"
            direction="vertical"
            style={{ marginTop: '24px', maxWidth: '300px' }}
            items={[
                { title: '步骤一', description: '已完成' },
                { title: '步骤二', description: '当前步骤出错' },
                { title: '步骤三', description: '待处理' },
            ]}
            aria-label="basic 类型垂直步骤条（error 状态）"
        />

        <Divider>Pagination</Divider>

        <Space vertical align="start" style={{ width: '100%' }}>
            <Pagination
                total={95}
                currentPage={paginationCurrentPage}
                pageSize={paginationPageSize}
                showSizeChanger
                showQuickJumper
                showTotal
                onPageChange={(p) => { paginationCurrentPage = p; console.log('pagination page changed', p); }}
                onPageSizeChange={(s) => { paginationPageSize = s; }}
                aria-label="基础分页器（受控）"
            />
            <Pagination total={500} defaultCurrentPage={10} size="small" aria-label="小尺寸分页器（省略号截断）" />
        </Space>

        <Divider>Popconfirm</Divider>

        <Space>
            <Popconfirm
                title="确认删除？"
                description="删除后无法恢复"
                onConfirm={() => console.log('popconfirm confirmed')}
                onCancel={() => console.log('popconfirm cancelled')}
            >
                <Button type="danger" theme="outline">删除（同步回调）</Button>
            </Popconfirm>
            <Popconfirm
                title="提交前确认"
                onConfirm={() => new Promise<void>((resolve) => setTimeout(() => { console.log('async confirm resolved'); resolve(); }, 600))}
            >
                <Button type="primary" theme="outline">提交（异步回调，600ms）</Button>
            </Popconfirm>
            <Popconfirm
                title="onVisibleChange 回归测试"
                onConfirm={() => {}}
                onCancel={() => {}}
                onVisibleChange={(v) => console.log('popconfirm visible changed: ' + v)}
            >
                <Button theme="outline">带 onVisibleChange 日志</Button>
            </Popconfirm>
        </Space>

        <Divider>Anchor</Divider>

        <div style={{ display: 'flex', gap: '24px' }}>
            <Anchor
                links={[
                    { href: '#anchor-section-1', title: '第一节' },
                    { href: '#anchor-section-2', title: '第二节' },
                    { href: '#anchor-section-3', title: '第三节' },
                ]}
                getContainer={() => document.getElementById('anchor-scroll-container')!}
                onChange={(current) => console.log('anchor changed', current)}
                aria-label="锚点导航"
            />
            <div id="anchor-scroll-container" style={{ width: '400px', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
                <div id="anchor-section-1" style={{ height: '250px' }}>第一节内容</div>
                <div id="anchor-section-2" style={{ height: '250px' }}>第二节内容</div>
                <div id="anchor-section-3" style={{ height: '250px' }}>第三节内容</div>
            </div>
        </div>

        <Divider>Toast</Divider>

        <Space>
            <Button onClick={() => Toast.info('这是一条 info 提示')}>Toast.info</Button>
            <Button onClick={() => Toast.success({ content: '操作成功', showClose: true })}>Toast.success（可关闭）</Button>
            <Button onClick={() => { Toast.warning('警告一'); Toast.error('错误二'); Toast.info('信息三'); }}>连续触发 3 条</Button>
            <Button onClick={() => Toast.destroyAll()}>destroyAll</Button>
        </Space>

        <Divider>Notification</Divider>

        <Space>
            <Button onClick={() => Notification.info({ title: '通知标题', content: '这是通知内容', position: 'topRight' })}>Notification.info（topRight）</Button>
            <Button onClick={() => Notification.success({ title: '成功', content: '操作已完成', position: 'bottomLeft' })}>Notification.success（bottomLeft）</Button>
            <Button onClick={() => { Notification.warning({ title: '警告一', position: 'topRight' }); Notification.error({ title: '错误二', position: 'topRight' }); }}>连续触发 2 条（topRight）</Button>
            <Button onClick={() => Notification.destroyAll()}>Notification.destroyAll</Button>
        </Space>

        <Divider>Tree</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div>
                <TypographyText type="secondary">单选（默认展开 dept-1）</TypographyText>
                <Tree
                    treeData={treeDemoData}
                    defaultExpandedKeys={['dept-1']}
                    onSelect={(key, selected, node) => console.log('tree select', key, selected, node)}
                    aria-label="单选 Tree"
                />
            </div>

            <div>
                <TypographyText type="secondary">多选（三态级联，全部展开，含禁用节点）</TypographyText>
                <Tree
                    treeData={treeDemoData}
                    multiple
                    defaultExpandAll
                    onChange={(value) => console.log('tree multiple change', value)}
                    aria-label="多选 Tree（三态级联）"
                />
            </div>

            <div>
                <TypographyText type="secondary">搜索过滤（仅展示匹配结果）</TypographyText>
                <Tree
                    treeData={treeDemoData}
                    filterTreeNode
                    showFilteredOnly
                    searchPlaceholder="搜索姓名或部门"
                    onSearch={(input) => console.log('tree search', input)}
                    aria-label="搜索过滤 Tree"
                />
            </div>

            <div>
                <TypographyText type="secondary">懒加载（异步 loadData，600ms 延迟）</TypographyText>
                <Tree
                    treeData={[
                        { key: 'lazy-1', label: '懒加载节点 1' },
                        { key: 'lazy-2', label: '懒加载节点 2' },
                    ]}
                    loadData={loadTreeChildren}
                    onLoad={(loadedKeys, node) => console.log('tree load', loadedKeys, node)}
                    aria-label="懒加载 Tree"
                />
            </div>
        </Space>

        <Divider>Badge</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '20px' }}>
            <Space style={{ gap: '24px' }}>
                <Badge count={5} aria-label="Badge 数字 5">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={0} aria-label="Badge 数字 0（不会自动隐藏）">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={128} overflowCount={99} aria-label="Badge 超出 overflowCount 显示 99+">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge dot aria-label="Badge 红点模式">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count="VIP" type="warning" aria-label="Badge 自定义字符串内容">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
            </Space>

            <Space style={{ gap: '24px' }}>
                <Badge count={9} type="primary" aria-label="Badge type=primary">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={9} type="danger" aria-label="Badge type=danger">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={9} type="warning" aria-label="Badge type=warning">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={9} type="success" aria-label="Badge type=success">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
            </Space>

            <Space style={{ gap: '24px' }}>
                <Badge count={9} type="danger" theme="solid" aria-label="Badge theme=solid">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={9} type="danger" theme="light" aria-label="Badge theme=light">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={9} type="danger" theme="inverted" aria-label="Badge theme=inverted">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
            </Space>

            <Space style={{ gap: '24px' }}>
                <Badge count={4} position="leftTop" aria-label="Badge position=leftTop">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={4} position="rightBottom" aria-label="Badge position=rightBottom">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
                <Badge count={4} position="leftBottom" aria-label="Badge position=leftBottom">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
            </Space>

            <Space style={{ gap: '24px' }}>
                <Badge count={3} aria-label="独立展示 Badge（无 children）" />
                <Badge onClick={() => console.log('badge clicked')} count={7} aria-label="Badge onClick">
                    <div style={{ width: '32px', height: '32px', background: 'var(--lotus-color-fill-0)', borderRadius: '4px' }} />
                </Badge>
            </Space>
        </Space>

        <Divider>Card</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '20px' }}>
            <Row gutter={16} style={{ width: '100%' }}>
                <Col span={8}>
                    <Card title="基础卡片" aria-label="基础 Card">
                        <TypographyText>卡片内容区域，展示任意文本或组件。</TypographyText>
                    </Card>
                </Col>
                <Col span={8}>
                    <Card
                        title="带额外内容"
                        headerExtraContent={<Button theme="borderless" size="small">更多</Button>}
                        aria-label="带 headerExtraContent 的 Card"
                    >
                        <TypographyText>headerExtraContent 出现在标题右侧。</TypographyText>
                    </Card>
                </Col>
                <Col span={8}>
                    <Card
                        title="无边框 + hover 阴影"
                        bordered={false}
                        shadows="hover"
                        aria-label="无边框 hover 阴影 Card"
                    >
                        <TypographyText>鼠标悬浮查看阴影效果。</TypographyText>
                    </Card>
                </Col>
            </Row>

            <Row gutter={16} style={{ width: '100%' }}>
                <Col span={8}>
                    <Card
                        cover={<div style={{ height: '120px', background: 'var(--lotus-color-fill-0)' }} />}
                        title="带封面"
                        aria-label="带 cover 的 Card"
                    >
                        <TypographyText>cover 渲染在标题下方、内容区上方。</TypographyText>
                    </Card>
                </Col>
                <Col span={8}>
                    <Card
                        title="带底部操作"
                        actions={[
                            <Button theme="borderless" size="small">编辑</Button>,
                            <Button theme="borderless" size="small" type="danger">删除</Button>,
                        ]}
                        aria-label="带 actions 的 Card"
                    >
                        <TypographyText>actions 是数组形式的底部操作区。</TypographyText>
                    </Card>
                </Col>
                <Col span={8}>
                    <Card
                        title="带 footer 分割线"
                        footer={<TypographyText type="tertiary">页脚内容</TypographyText>}
                        footerLine
                        aria-label="带 footer 的 Card"
                    >
                        <TypographyText>footerLine 控制页脚上方是否有分割线。</TypographyText>
                    </Card>
                </Col>
            </Row>

            <Row gutter={16} style={{ width: '100%' }}>
                <Col span={8}>
                    <Card loading aria-label="loading 中的 Card">
                        <TypographyText>这段内容在 loading 时不会显示。</TypographyText>
                    </Card>
                </Col>
                <Col span={8}>
                    <Card aria-label="带 Card.Meta 的 Card">
                        <CardMeta
                            avatar={<Avatar size="small">语</Avatar>}
                            title="语雀"
                            description="蚂蚁集团出品的专业云端知识库"
                        />
                    </Card>
                </Col>
            </Row>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">CardGroup（spacing=16）</TypographyText>
                <CardGroup aria-label="CardGroup 示例">
                    <Card style={{ width: '200px' }} title="卡片一"><TypographyText>内容一</TypographyText></Card>
                    <Card style={{ width: '200px' }} title="卡片二"><TypographyText>内容二</TypographyText></Card>
                    <Card style={{ width: '200px' }} title="卡片三"><TypographyText>内容三</TypographyText></Card>
                </CardGroup>
            </div>
        </Space>

        <Divider>Empty</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '32px' }}>
            <Empty title="暂无数据" description="换个筛选条件试试" aria-label="纯文字 Empty（无 image）" />

            <Empty
                image={<IllustrationNoContent style={{ width: '150px', height: '150px' }} />}
                title="暂无内容"
                description="当前没有可展示的数据"
                aria-label="带插图的 Empty"
            />

            <Empty
                image={<IllustrationNotFound style={{ width: '150px', height: '150px' }} />}
                title="页面未找到"
                description="请检查链接是否正确"
                aria-label="带操作按钮的 Empty"
            >
                <Button theme="solid">返回首页</Button>
            </Empty>

            <Empty
                image={<IllustrationNoAccess style={{ width: '80px', height: '80px' }} />}
                title="无访问权限"
                description="请联系管理员开通权限"
                layout="horizontal"
                aria-label="horizontal 布局的 Empty"
            />
        </Space>

        <Divider>Descriptions</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">vertical 布局（默认，逐条独立一行）</TypographyText>
                <Descriptions
                    data={[
                        { key: '姓名', value: '张三' },
                        { key: '部门', value: '前端组' },
                        { key: '入职时间', value: '2023-01-15' },
                    ]}
                    aria-label="vertical Descriptions"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">horizontal 布局（column=3，span 控制占列）</TypographyText>
                <Descriptions
                    layout="horizontal"
                    column={3}
                    data={[
                        { key: '姓名', value: '张三' },
                        { key: '部门', value: '前端组' },
                        { key: '职级', value: 'P6' },
                        { key: '简介', value: '负责组件库基础设施建设', span: 3 },
                        { key: '邮箱', value: 'zhangsan@example.com', span: 2 },
                        { key: '状态', value: '在职' },
                    ]}
                    aria-label="horizontal Descriptions"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">align=plain（key 后跟冒号，inline 展示）</TypographyText>
                <Descriptions
                    align="plain"
                    data={[
                        { key: '姓名', value: '张三' },
                        { key: '部门', value: '前端组' },
                        { key: '入职时间', value: '2023-01-15' },
                    ]}
                    aria-label="plain Descriptions"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">row（双行/网格展示，value 加粗）</TypographyText>
                <Descriptions
                    row
                    data={[
                        { key: '姓名', value: '张三' },
                        { key: '部门', value: '前端组' },
                        { key: '入职时间', value: '2023-01-15' },
                    ]}
                    aria-label="row Descriptions"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">hidden 隐藏条目 + value 懒渲染函数</TypographyText>
                <Descriptions
                    data={[
                        { key: '姓名', value: '张三' },
                        { key: '内部字段', value: '不应显示', hidden: true },
                        { key: '当前时间', value: () => '懒渲染函数返回值' },
                    ]}
                    aria-label="hidden 与懒渲染 Descriptions"
                />
            </div>
        </Space>

        <Divider>Collapse</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">基础用法（可同时展开多个）</TypographyText>
                <Collapse defaultActiveKey={['1']} aria-label="基础 Collapse">
                    <CollapsePanel itemKey="1" header="第一节">
                        <TypographyText>第一节内容，展开收起有 max-height 过渡动画。</TypographyText>
                    </CollapsePanel>
                    <CollapsePanel itemKey="2" header="第二节">
                        <TypographyText>第二节内容。</TypographyText>
                    </CollapsePanel>
                    <CollapsePanel itemKey="3" header="禁用面板" disabled>
                        <TypographyText>点击 header 不会展开。</TypographyText>
                    </CollapsePanel>
                </Collapse>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">accordion（手风琴模式，展开一个自动收起其他）</TypographyText>
                <Collapse accordion defaultActiveKey="a" aria-label="accordion Collapse">
                    <CollapsePanel itemKey="a" header="面板 A">
                        <TypographyText>面板 A 内容。</TypographyText>
                    </CollapsePanel>
                    <CollapsePanel itemKey="b" header="面板 B">
                        <TypographyText>面板 B 内容。</TypographyText>
                    </CollapsePanel>
                    <CollapsePanel itemKey="c" header="面板 C">
                        <TypographyText>面板 C 内容。</TypographyText>
                    </CollapsePanel>
                </Collapse>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">expandIconPosition=left + extra 附加内容</TypographyText>
                <Collapse defaultActiveKey={['x']} expandIconPosition="left" aria-label="left 图标 Collapse">
                    <CollapsePanel itemKey="x" header="带 extra 的面板" extra={<TypographyText type="tertiary">额外信息</TypographyText>}>
                        <TypographyText>图标在左侧，header 右侧有 extra 内容。</TypographyText>
                    </CollapsePanel>
                </Collapse>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">受控用法（外部按钮驱动 activeKey）</TypographyText>
                <Space style={{ marginBottom: '8px' }}>
                    <Button onClick={() => { collapseControlledActiveKey = ['p1']; }}>展开面板一</Button>
                    <Button onClick={() => { collapseControlledActiveKey = []; }}>全部收起</Button>
                </Space>
                <Collapse activeKey={collapseControlledActiveKey} onChange={(keys) => { collapseControlledActiveKey = keys; }} aria-label="受控 Collapse">
                    <CollapsePanel itemKey="p1" header="面板一">
                        <TypographyText>由外部按钮驱动展开状态。</TypographyText>
                    </CollapsePanel>
                    <CollapsePanel itemKey="p2" header="面板二">
                        <TypographyText>面板二内容。</TypographyText>
                    </CollapsePanel>
                </Collapse>
            </div>
        </Space>

        <Divider>Collapsible</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '12px' }}>
            <TypographyText type="secondary">无头展开容器，触发器与 UI 完全自定义（非 Panel 语义）</TypographyText>
            <Button onClick={() => { collapsibleOpen = !collapsibleOpen; }} aria-label="Collapsible 触发按钮">
                {collapsibleOpen ? '收起' : '显示更多'}
            </Button>
            <Collapsible isOpen={collapsibleOpen} aria-label="基础 Collapsible">
                <div style={{ padding: '12px', background: 'var(--lotus-color-fill-0)' }}>
                    <TypographyText>这是任意内容，可以是段落、图片或其他组件，没有 header/itemKey 结构。</TypographyText>
                </div>
            </Collapsible>

            <TypographyText type="secondary">keepDOM（收起时保留 DOM，不销毁重建）</TypographyText>
            <Collapsible isOpen={collapsibleOpen} keepDOM aria-label="keepDOM Collapsible">
                <div style={{ padding: '12px', background: 'var(--lotus-color-fill-0)' }}>
                    <TypographyText>keepDOM=true，收起后这段内容仍在 DOM 中（只是不可见）。</TypographyText>
                </div>
            </Collapsible>
        </Space>

        <Divider>List</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">基础用法（dataSource + renderItem）</TypographyText>
                <List
                    bordered
                    dataSource={['第一条内容', '第二条内容', '第三条内容']}
                    renderItem={(item) => <TypographyText>{item}</TypographyText>}
                    aria-label="基础 List"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">header/main/extra 模板用法</TypographyText>
                <List
                    header={<TypographyText>团队成员</TypographyText>}
                    footer={<TypographyText type="tertiary">共 2 人</TypographyText>}
                    dataSource={[
                        { name: '张三', role: '前端工程师' },
                        { name: '李四', role: '后端工程师' },
                    ]}
                    renderItem={(item) => (
                        <ListItem
                            header={<TypographyText>{item.name}</TypographyText>}
                            main={<TypographyText type="tertiary">{item.role}</TypographyText>}
                            extra={<Button size="small" theme="borderless">详情</Button>}
                        />
                    )}
                    aria-label="模板 List"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">layout=horizontal（横向排列）</TypographyText>
                <List
                    layout="horizontal"
                    dataSource={['A', 'B', 'C']}
                    renderItem={(item) => <TypographyText style={{ padding: '0 16px' }}>{item}</TypographyText>}
                    aria-label="horizontal List"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">grid 布局（响应式栅格）</TypographyText>
                <List
                    grid={{ gutter: 16, xs: 24, sm: 12, md: 8 }}
                    dataSource={['卡片一', '卡片二', '卡片三']}
                    renderItem={(item) => (
                        <Card title={item}><TypographyText>grid item 内容</TypographyText></Card>
                    )}
                    aria-label="grid List"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">loading（Spin 遮罩） / 空状态</TypographyText>
                <Space style={{ width: '100%', gap: '16px' }}>
                    <div style={{ flex: 1 }}>
                        <List loading bordered dataSource={['A', 'B']} renderItem={(item) => <TypographyText>{item}</TypographyText>} aria-label="loading List" />
                    </div>
                    <div style={{ flex: 1 }}>
                        <List bordered dataSource={[]} aria-label="empty List" />
                    </div>
                </Space>
            </div>
        </Space>

        <Divider>Timeline</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">基础用法（dataSource，type 语义色）</TypographyText>
                <Timeline
                    dataSource={[
                        { content: '创建服务现场', time: '2023-09-01 09:00', type: 'success' },
                        { content: '定位问题原因', time: '2023-09-01 10:30', type: 'ongoing' },
                        { content: '发布修复补丁', time: '2023-09-01 14:00', type: 'warning' },
                        { content: '服务恢复正常', time: '2023-09-01 15:20', type: 'default' },
                    ]}
                    aria-label="基础 Timeline"
                />
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">JSX children 用法（自定义 color / extra / dot）</TypographyText>
                <Timeline aria-label="JSX Timeline">
                    <TimelineItem index={0} time="2023-08-01" color="#722ed1" extra={<TypographyText type="tertiary">附加说明信息</TypographyText>}>
                        自定义颜色节点
                    </TimelineItem>
                    <TimelineItem index={1} time="2023-08-02" dot={<IconTickCircle style={{ color: 'var(--lotus-color-success)' }} />}>
                        自定义图标节点
                    </TimelineItem>
                    <TimelineItem index={2} time="2023-08-03" type="error">
                        错误节点
                    </TimelineItem>
                </Timeline>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">mode=alternate（左右交替）</TypographyText>
                <Timeline
                    mode="alternate"
                    dataSource={[
                        { content: '节点一（左）', time: '09:00' },
                        { content: '节点二（右）', time: '10:00' },
                        { content: '节点三（左）', time: '11:00' },
                    ]}
                    aria-label="alternate Timeline"
                />
            </div>
        </Space>

        <Divider>Image</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div>
                <TypographyText type="secondary">基础用法（点击可预览大图）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Image
                        src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png"
                        alt="示例图片"
                        width={120}
                        height={120}
                        aria-label="基础 Image"
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">加载失败 fallback</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Image
                        src="https://not-exist.invalid/broken.png"
                        width={120}
                        height={120}
                        preview={false}
                        aria-label="加载失败 Image"
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">ImagePreviewGroup（多图批量预览，点击任意一张后可左右切换）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <ImagePreviewGroup>
                        <Space style={{ gap: '8px' }}>
                            <Image src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png?i=1" width={80} height={80} aria-label="Group 图片一" />
                            <Image src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png?i=2" width={80} height={80} aria-label="Group 图片二" />
                            <Image src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png?i=3" width={80} height={80} aria-label="Group 图片三" />
                        </Space>
                    </ImagePreviewGroup>
                </div>
            </div>
        </Space>

        <Divider>Carousel</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">基础用法（autoPlay，箭头+指示器）</TypographyText>
                <div style={{ marginTop: '8px', marginBottom: '8px' }}>
                    <Button onClick={() => { carouselMounted = !carouselMounted; }}>
                        {carouselMounted ? '卸载 Carousel（验证 autoPlay 定时器清理）' : '重新挂载 Carousel'}
                    </Button>
                </div>
                @if (carouselMounted) {
                    <div style={{ width: '400px', height: '200px' }}>
                        <Carousel
                            items={[
                                <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-primary-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>第一页</TypographyText></div>,
                                <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-success-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>第二页</TypographyText></div>,
                                <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-warning-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>第三页</TypographyText></div>,
                            ]}
                            aria-label="基础 Carousel"
                        />
                    </div>
                }
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">animation=fade，theme=primary，indicatorType=line</TypographyText>
                <div style={{ width: '400px', height: '200px', marginTop: '8px' }}>
                    <Carousel
                        animation="fade"
                        theme="primary"
                        indicatorType="line"
                        autoPlay={false}
                        items={[
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-primary-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>Fade 1</TypographyText></div>,
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-success-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>Fade 2</TypographyText></div>,
                        ]}
                        aria-label="fade Carousel"
                    />
                </div>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">受控用法（外部按钮驱动 activeIndex）</TypographyText>
                <Space style={{ marginBottom: '8px' }}>
                    <Button onClick={() => { carouselControlledIndex = 0; }}>跳到第一页</Button>
                    <Button onClick={() => { carouselControlledIndex = 2; }}>跳到第三页</Button>
                </Space>
                <div style={{ width: '400px', height: '200px' }}>
                    <Carousel
                        activeIndex={carouselControlledIndex}
                        onChange={(index) => { carouselControlledIndex = index; }}
                        autoPlay={false}
                        items={[
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-primary-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>受控 1</TypographyText></div>,
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-success-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>受控 2</TypographyText></div>,
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-warning-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>受控 3</TypographyText></div>,
                        ]}
                        aria-label="受控 Carousel"
                    />
                </div>
            </div>
        </Space>

        <Divider>Modal</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div>
                <TypographyText type="secondary">基础用法</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalBasicVisible = true; }}>打开基础 Modal</Button>
                    <Modal
                        visible={modalBasicVisible}
                        title="基础 Modal"
                        onOk={() => { modalBasicVisible = false; }}
                        onCancel={() => { modalBasicVisible = false; }}
                        afterClose={() => { modalAfterCloseLog = `afterClose 触发于 ${Date.now()}`; }}
                        aria-label="基础 Modal"
                    >
                        <TypographyText>这是 Modal 的内容区域。</TypographyText>
                    </Modal>
                    <div style={{ marginTop: '8px' }}>
                        <TypographyText type="tertiary">{modalAfterCloseLog}</TypographyText>
                    </div>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">自定义 footer</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalCustomFooterVisible = true; }}>打开自定义 footer Modal</Button>
                    <Modal
                        visible={modalCustomFooterVisible}
                        title="自定义 footer"
                        footer={
                            <Button theme="solid" type="danger" onClick={() => { modalCustomFooterVisible = false; }}>
                                我知道了
                            </Button>
                        }
                        onCancel={() => { modalCustomFooterVisible = false; }}
                        aria-label="自定义 footer Modal"
                    >
                        <TypographyText>只有一个自定义按钮的 footer。</TypographyText>
                    </Modal>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">Promise-aware loading（onOk 返回 Promise，1s 后自动关闭）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalAsyncVisible = true; }}>打开异步 Modal</Button>
                    <Modal
                        visible={modalAsyncVisible}
                        title="异步确认"
                        onOk={() => new Promise<void>((resolve) => {
                            setTimeout(() => {
                                modalAsyncVisible = false;
                                resolve();
                            }, 1000);
                        })}
                        onCancel={() => { modalAsyncVisible = false; }}
                        aria-label="异步 Modal"
                    >
                        <TypographyText>点击「确定」后按钮进入 loading 态，1 秒后自动关闭。</TypographyText>
                    </Modal>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">受控用法 + ESC 关闭 + centered</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalControlledVisible = true; }}>打开受控 Modal（居中，可按 ESC 关闭）</Button>
                    <Modal
                        visible={modalControlledVisible}
                        title="受控 + 居中"
                        centered
                        onOk={() => { modalControlledVisible = false; }}
                        onCancel={() => { modalControlledVisible = false; }}
                        aria-label="受控居中 Modal"
                    >
                        <TypographyText>centered 垂直居中，支持 ESC 关闭。</TypographyText>
                    </Modal>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">fullScreen 全屏模式</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalFullScreenVisible = true; }}>打开全屏 Modal</Button>
                    <Modal
                        visible={modalFullScreenVisible}
                        title="全屏 Modal"
                        fullScreen
                        onOk={() => { modalFullScreenVisible = false; }}
                        onCancel={() => { modalFullScreenVisible = false; }}
                        aria-label="全屏 Modal"
                    >
                        <TypographyText>fullScreen 模式下内容铺满视口。</TypographyText>
                    </Modal>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">size 预设对比（large + closable=false + maskClosable=false）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { modalNoMaskCloseVisible = true; }}>打开 large Modal（禁用遮罩点击关闭 &amp; 关闭按钮）</Button>
                    <Modal
                        visible={modalNoMaskCloseVisible}
                        title="large + 禁用遮罩关闭"
                        size="large"
                        closable={false}
                        maskClosable={false}
                        onOk={() => { modalNoMaskCloseVisible = false; }}
                        onCancel={() => { modalNoMaskCloseVisible = false; }}
                        aria-label="large 无遮罩关闭 Modal"
                    >
                        <TypographyText>点击遮罩不会关闭，也没有右上角关闭按钮，只能通过底部按钮关闭。</TypographyText>
                    </Modal>
                </div>
            </div>
        </Space>

        <Divider>SideSheet</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div>
                <TypographyText type="secondary">基础用法（placement=right，默认）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { sideSheetRightVisible = true; }}>打开右侧 SideSheet</Button>
                    <SideSheet
                        visible={sideSheetRightVisible}
                        title="右侧 SideSheet"
                        onCancel={() => { sideSheetRightVisible = false; }}
                        afterVisibleChange={(v) => { sideSheetAfterVisibleChangeLog = `afterVisibleChange(${v}) 触发于 ${Date.now()}`; }}
                        footer={
                            <Space>
                                <Button theme="light" type="tertiary" onClick={() => { sideSheetRightVisible = false; }}>取消</Button>
                                <Button theme="solid" type="primary" onClick={() => { sideSheetRightVisible = false; }}>确定</Button>
                            </Space>
                        }
                        aria-label="右侧 SideSheet"
                    >
                        <TypographyText>这是 SideSheet 的内容区域。</TypographyText>
                    </SideSheet>
                    <div style={{ marginTop: '8px' }}>
                        <TypographyText type="tertiary">{sideSheetAfterVisibleChangeLog}</TypographyText>
                    </div>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">placement=left</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { sideSheetLeftVisible = true; }}>打开左侧 SideSheet</Button>
                    <SideSheet
                        visible={sideSheetLeftVisible}
                        placement="left"
                        title="左侧 SideSheet"
                        onCancel={() => { sideSheetLeftVisible = false; }}
                        aria-label="左侧 SideSheet"
                    >
                        <TypographyText>从左侧滑入。</TypographyText>
                    </SideSheet>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">placement=top / bottom</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Space>
                        <Button onClick={() => { sideSheetTopVisible = true; }}>打开顶部 SideSheet</Button>
                        <Button onClick={() => { sideSheetBottomVisible = true; }}>打开底部 SideSheet</Button>
                    </Space>
                    <SideSheet
                        visible={sideSheetTopVisible}
                        placement="top"
                        title="顶部 SideSheet"
                        height={200}
                        onCancel={() => { sideSheetTopVisible = false; }}
                        aria-label="顶部 SideSheet"
                    >
                        <TypographyText>从顶部滑入，height=200。</TypographyText>
                    </SideSheet>
                    <SideSheet
                        visible={sideSheetBottomVisible}
                        placement="bottom"
                        title="底部 SideSheet"
                        height={200}
                        onCancel={() => { sideSheetBottomVisible = false; }}
                        aria-label="底部 SideSheet"
                    >
                        <TypographyText>从底部滑入，height=200。</TypographyText>
                    </SideSheet>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">keepDOM：关闭后内容不卸载，仅 CSS 隐藏</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { sideSheetKeepDomVisible = true; }}>打开 keepDOM SideSheet</Button>
                    <SideSheet
                        visible={sideSheetKeepDomVisible}
                        keepDOM
                        title="keepDOM SideSheet"
                        onCancel={() => { sideSheetKeepDomVisible = false; }}
                        aria-label="keepDOM SideSheet"
                    >
                        <TypographyText>关闭后这段内容仍在 DOM 中，只是被 display:none 隐藏。</TypographyText>
                    </SideSheet>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">size=large + closable=false + maskClosable=false</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button onClick={() => { sideSheetNoMaskCloseVisible = true; }}>打开 large SideSheet（禁用遮罩点击关闭 &amp; 关闭按钮）</Button>
                    <SideSheet
                        visible={sideSheetNoMaskCloseVisible}
                        title="large + 禁用遮罩关闭"
                        size="large"
                        closable={false}
                        maskClosable={false}
                        footer={<Button theme="solid" type="primary" onClick={() => { sideSheetNoMaskCloseVisible = false; }}>关闭</Button>}
                        aria-label="large 无遮罩关闭 SideSheet"
                    >
                        <TypographyText>点击遮罩不会关闭，也没有右上角关闭按钮，只能通过底部按钮关闭。</TypographyText>
                    </SideSheet>
                </div>
            </div>
        </Space>

        <Divider>Calendar</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">week 模式：普通事件、同时段重叠事件、跨天事件、全天事件</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Calendar
                        mode="week"
                        displayValue={calendarWeekAnchor}
                        height={480}
                        markWeekend
                        onClick={(_e, value) => { calendarClickLog = `点击了 ${value.toLocaleString()}`; }}
                        events={[
                            { key: 'e1', start: new Date(2026, 0, 12, 9), end: new Date(2026, 0, 12, 10, 30) },
                            { key: 'e2', start: new Date(2026, 0, 12, 9), end: new Date(2026, 0, 12, 10, 30), children: <TypographyText style={{ color: 'inherit' }}>并排会议</TypographyText> },
                            { key: 'e3', start: new Date(2026, 0, 13, 22), end: new Date(2026, 0, 14, 1), children: <TypographyText style={{ color: 'inherit' }}>跨天夜间任务</TypographyText> },
                            { key: 'e4', allDay: true, start: new Date(2026, 0, 15), end: new Date(2026, 0, 16), children: <TypographyText style={{ color: 'inherit' }}>全天活动</TypographyText> },
                        ]}
                        renderEvent={(event) => <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>{event.children ?? '默认事件'}</TypographyText>}
                        aria-label="week Calendar"
                    />
                    <div style={{ marginTop: '8px' }}>
                        <TypographyText type="tertiary">{calendarClickLog}</TypographyText>
                    </div>
                </div>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">month 模式：跨天横条事件按贪心分层布局</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Calendar
                        mode="month"
                        displayValue={calendarMonthAnchor}
                        height={480}
                        markWeekend
                        onClick={(_e, value) => { calendarClickLog = `点击了 ${value.toLocaleString()}`; }}
                        events={[
                            { key: 'm1', start: new Date(2026, 0, 5), end: new Date(2026, 0, 8), children: <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>项目排期 A</TypographyText> },
                            { key: 'm2', start: new Date(2026, 0, 7), end: new Date(2026, 0, 10), children: <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>项目排期 B（与 A 重叠，自动分行）</TypographyText> },
                            { key: 'm3', start: new Date(2026, 0, 20), end: new Date(2026, 0, 20), children: <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>单日里程碑</TypographyText> },
                        ]}
                        aria-label="month Calendar"
                    />
                </div>
            </div>
        </Space>

        <Divider>OverflowList</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">容器足够宽时全部显示</TypographyText>
                <div style={{ marginTop: '8px', width: '100%' }}>
                    <OverflowList
                        items={['苹果', '香蕉', '橙子']}
                        visibleItemRenderer={(item) => <Tag style={{ marginRight: '4px' }}>{item}</Tag>}
                        overflowRenderer={(overflow) => <Tag color="grey">{`+${overflow.length}`}</Tag>}
                        aria-label="宽容器 OverflowList"
                    />
                </div>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">窄容器：超出部分折叠为 "+N"（collapseFrom=end，默认）</TypographyText>
                <div style={{ marginTop: '8px', width: '260px', border: '1px dashed var(--lotus-color-border)', padding: '8px' }}>
                    <OverflowList
                        items={['标签一', '标签二', '标签三', '标签四', '标签五', '标签六']}
                        visibleItemRenderer={(item) => <Tag style={{ marginRight: '4px' }}>{item}</Tag>}
                        overflowRenderer={(overflow) => <Tag color="grey">{`+${overflow.length}`}</Tag>}
                        aria-label="窄容器 OverflowList"
                    />
                </div>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">collapseFrom=start：折叠头部、保留尾部</TypographyText>
                <div style={{ marginTop: '8px', width: '260px', border: '1px dashed var(--lotus-color-border)', padding: '8px' }}>
                    <OverflowList
                        items={['标签一', '标签二', '标签三', '标签四', '标签五', '标签六']}
                        collapseFrom="start"
                        visibleItemRenderer={(item) => <Tag style={{ marginRight: '4px' }}>{item}</Tag>}
                        overflowRenderer={(overflow) => <Tag color="grey">{`+${overflow.length}`}</Tag>}
                        aria-label="collapseFrom start OverflowList"
                    />
                </div>
            </div>

            <div style={{ width: '100%' }}>
                <TypographyText type="secondary">minVisibleItems=2：即使容器很窄也至少保留 2 项</TypographyText>
                <div style={{ marginTop: '8px', width: '120px', border: '1px dashed var(--lotus-color-border)', padding: '8px' }}>
                    <OverflowList
                        items={['标签一', '标签二', '标签三', '标签四']}
                        minVisibleItems={2}
                        visibleItemRenderer={(item) => <Tag style={{ marginRight: '4px' }}>{item}</Tag>}
                        overflowRenderer={(overflow) => <Tag color="grey">{`+${overflow.length}`}</Tag>}
                        aria-label="minVisibleItems OverflowList"
                    />
                </div>
            </div>
        </Space>

        <Divider>ScrollList</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '24px' }}>
            <div>
                <TypographyText type="secondary">wheel 模式（默认）+ cycled 循环滚动：时/分两列组合模拟时间选择器</TypographyText>
                <div style={{ marginTop: '8px', width: '200px' }}>
                    <ScrollList bodyHeight={180} header={<div style={{ display: 'flex', width: '100%' }}><div style={{ flex: 1, textAlign: 'center', padding: '4px 0' }}><TypographyText type="tertiary">时</TypographyText></div><div style={{ flex: 1, textAlign: 'center', padding: '4px 0' }}><TypographyText type="tertiary">分</TypographyText></div></div>}>
                        <ScrollItem
                            list={Array.from({ length: 24 }, (_, i) => ({ value: i, text: String(i).padStart(2, '0') }))}
                            cycled
                            selectedIndex={scrollHourIndex}
                            onSelect={(data) => { scrollHourIndex = data.index; }}
                            aria-label="小时选择"
                        />
                        <ScrollItem
                            list={Array.from({ length: 60 }, (_, i) => ({ value: i, text: String(i).padStart(2, '0') }))}
                            selectedIndex={scrollMinuteIndex}
                            onSelect={(data) => { scrollMinuteIndex = data.index; }}
                            aria-label="分钟选择"
                        />
                    </ScrollList>
                    <div style={{ marginTop: '8px' }}>
                        <TypographyText type="tertiary">{`已选：${String(scrollHourIndex).padStart(2, '0')}:${String(scrollMinuteIndex).padStart(2, '0')}`}</TypographyText>
                    </div>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">normal 模式：普通点击列表，无中心线吸附</TypographyText>
                <div style={{ marginTop: '8px', width: '120px' }}>
                    <ScrollList bodyHeight={150}>
                        <ScrollItem
                            list={['苹果', '香蕉', '橙子', '葡萄', '西瓜'].map((v) => ({ value: v, text: v }))}
                            mode="normal"
                            aria-label="水果选择"
                        />
                    </ScrollList>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">禁用项：跳过点击和吸附命中</TypographyText>
                <div style={{ marginTop: '8px', width: '120px' }}>
                    <ScrollList bodyHeight={150}>
                        <ScrollItem
                            list={[
                                { value: 0, text: '选项一' },
                                { value: 1, text: '选项二（禁用）', disabled: true },
                                { value: 2, text: '选项三' },
                                { value: 3, text: '选项四' },
                            ]}
                            aria-label="含禁用项选择"
                        />
                    </ScrollList>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">受控用法：外部按钮驱动 selectedIndex</TypographyText>
                <Space style={{ marginBottom: '8px' }}>
                    <Button onClick={() => { scrollControlledIndex = 0; }}>跳到第一项</Button>
                    <Button onClick={() => { scrollControlledIndex = 4; }}>跳到第五项</Button>
                </Space>
                <div style={{ width: '120px' }}>
                    <ScrollList bodyHeight={150}>
                        <ScrollItem
                            list={['A', 'B', 'C', 'D', 'E'].map((v) => ({ value: v, text: v }))}
                            selectedIndex={scrollControlledIndex}
                            onSelect={(data) => { scrollControlledIndex = data.index; }}
                            aria-label="受控选择"
                        />
                    </ScrollList>
                </div>
            </div>
        </Space>

        <Divider>Highlight</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div>
                <TypographyText type="secondary">基础用法：单个关键词高亮</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="The quick brown fox jumps over the lazy dog" searchWords={['fox']} aria-label="基础 Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">多个关键词同时高亮</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="The quick brown fox jumps over the lazy dog" searchWords={['quick', 'lazy', 'dog']} aria-label="多关键词 Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">重叠关键词自动合并（搜索 "abc" 和 "bcd"，命中 "abcd" 应合并为一段，不重复渲染）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="xxabcdxx" searchWords={['abc', 'bcd']} aria-label="重叠合并 Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">caseSensitive：大小写敏感（搜索 "Fox" 只命中大写开头）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="Fox fox FOX" searchWords={['Fox']} caseSensitive aria-label="大小写敏感 Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">autoEscape：关键词含正则特殊字符时按字面量匹配</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="Price: $9.99 (discounted)" searchWords={['$9.99']} aria-label="特殊字符转义 Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">ComplexSearchWord：不同关键词各自指定高亮样式</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight
                        sourceString="Error: connection failed. Warning: retry limit reached."
                        searchWords={[
                            { text: 'Error', style: { backgroundColor: 'var(--lotus-color-danger-light-default)', color: 'var(--lotus-color-danger)' } },
                            { text: 'Warning', style: { backgroundColor: 'var(--lotus-color-warning-light-default)', color: 'var(--lotus-color-warning)' } },
                        ]}
                        aria-label="ComplexSearchWord Highlight"
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">component=span：非 mark 标签渲染高亮</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="Rendered with a span tag instead of mark" searchWords={['span']} component="span" aria-label="span component Highlight" />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">关键词不存在时原样显示，无高亮</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Highlight sourceString="Nothing matches here" searchWords={['xyz']} aria-label="无匹配 Highlight" />
                </div>
            </div>
        </Space>

        <Divider>Cropper</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div>
                <TypographyText type="secondary">基础用法：拖拽移动/缩放裁切框，滚轮缩放图片，拖拽图片平移</TypographyText>
                <div style={{ marginTop: '8px', width: '400px', height: '300px' }}>
                    <Cropper
                        src={CROPPER_DEMO_SRC}
                        style={{ width: '100%', height: '100%' }}
                        aria-label="基础 Cropper"
                        onCrop={(canvas: HTMLCanvasElement) => { cropperResultUrl = canvas.toDataURL(); }}
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">导出预览（裁切框/缩放/旋转变化后 onCrop 实时回调）</TypographyText>
                <div style={{ marginTop: '8px', width: '200px', height: '150px', border: '1px solid var(--lotus-color-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
                    @if (cropperResultUrl) {
                        <img src={cropperResultUrl} aria-label="Cropper 导出预览" style={{ maxWidth: '100%', maxHeight: '100%' }} />
                    }
                </div>
            </div>

            <div>
                <TypographyText type="secondary">aspectRatio 锁定宽高比 = 16/9，shape=round 圆形裁切框</TypographyText>
                <div style={{ marginTop: '8px', width: '400px', height: '300px' }}>
                    <Cropper
                        src={CROPPER_DEMO_SRC}
                        aspectRatio={16 / 9}
                        shape="round"
                        style={{ width: '100%', height: '100%' }}
                        aria-label="锁定比例 Cropper"
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">受控 zoom + rotate（外部按钮驱动）</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Space style={{ marginBottom: '8px' }}>
                        <Button size="small" onClick={() => { cropperZoom = Math.min(3, Number((cropperZoom + 0.2).toFixed(2))); }}>放大</Button>
                        <Button size="small" onClick={() => { cropperZoom = Math.max(0.1, Number((cropperZoom - 0.2).toFixed(2))); }}>缩小</Button>
                        <Button size="small" onClick={() => { cropperRotate = (cropperRotate + 90) % 360; }}>旋转 90°</Button>
                        <TypographyText aria-label="Cropper zoom 值">zoom: {cropperZoom.toFixed(2)} / rotate: {cropperRotate}</TypographyText>
                    </Space>
                    <div style={{ width: '400px', height: '300px' }}>
                        <Cropper
                            src={CROPPER_DEMO_SRC}
                            zoom={cropperZoom}
                            rotate={cropperRotate}
                            onZoomChange={(z: number) => { cropperZoom = z; }}
                            style={{ width: '100%', height: '100%' }}
                            aria-label="受控 Cropper"
                        />
                    </div>
                </div>
            </div>

            <div>
                <TypographyText type="secondary">getCropperApi 命令式获取裁切结果</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Space style={{ marginBottom: '8px' }}>
                        <Button
                            size="small"
                            onClick={() => {
                                const canvas = cropperApiRef?.getCropperCanvas();
                                if (canvas) cropperApiResultUrl = canvas.toDataURL();
                            }}
                        >
                            获取裁切结果
                        </Button>
                    </Space>
                    <div style={{ width: '400px', height: '300px' }}>
                        <Cropper
                            src={CROPPER_DEMO_SRC}
                            getCropperApi={(api: CropperApi) => { cropperApiRef = api; }}
                            style={{ width: '100%', height: '100%' }}
                            aria-label="命令式 Cropper"
                        />
                    </div>
                    <div style={{ marginTop: '8px', width: '200px', height: '150px', border: '1px solid var(--lotus-color-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
                        @if (cropperApiResultUrl) {
                            <img src={cropperApiResultUrl} aria-label="命令式 Cropper 导出预览" style={{ maxWidth: '100%', maxHeight: '100%' }} />
                        }
                    </div>
                </div>
            </div>
        </Space>

        <Divider>UserGuide</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div>
                <TypographyText type="secondary">popup 模式：依次高亮下方三个按钮，支持上一步/下一步/跳过，ESC 跳过，方向键切换</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Space style={{ marginBottom: '16px' }}>
                        <Button size="small" onClick={() => { userGuideVisible = true; }}>开始引导</Button>
                        <TypographyText aria-label="UserGuide 事件日志">{userGuideLog}</TypographyText>
                    </Space>
                    <Space style={{ gap: '24px' }}>
                        <span ref={(node: HTMLElement) => { userGuideStepAEl = node; }}><Button theme="light">步骤一目标</Button></span>
                        <span ref={(node: HTMLElement) => { userGuideStepBEl = node; }}><Button theme="light">步骤二目标</Button></span>
                        <span ref={(node: HTMLElement) => { userGuideStepCEl = node; }}><Button theme="light">步骤三目标</Button></span>
                    </Space>
                    <UserGuide
                        visible={userGuideVisible}
                        current={userGuideCurrent}
                        steps={[
                            { target: () => userGuideStepAEl ?? null, title: '第一步', description: '这是第一个目标元素的说明文案。', position: 'bottom' },
                            { target: () => userGuideStepBEl ?? null, title: '第二步', description: '这是第二个目标元素的说明文案，spotlightPadding 覆盖为 0。', position: 'bottom', spotlightPadding: 0 },
                            { target: () => userGuideStepCEl ?? null, title: '第三步', description: '最后一步，点击完成结束引导。', position: 'top', theme: 'primary' },
                        ]}
                        onChange={(current: number) => { userGuideCurrent = current; userGuideLog = `onChange: ${current}`; }}
                        onNext={(current: number) => { userGuideLog = `onNext -> ${current}`; }}
                        onPrev={(current: number) => { userGuideLog = `onPrev -> ${current}`; }}
                        onSkip={() => { userGuideLog = 'onSkip'; userGuideVisible = false; userGuideCurrent = 0; }}
                        onFinish={() => { userGuideLog = 'onFinish'; userGuideVisible = false; userGuideCurrent = 0; }}
                        aria-label="popup UserGuide"
                    />
                </div>
            </div>

            <div>
                <TypographyText type="secondary">modal 模式：居中弹窗轮播式介绍，无目标元素高亮</TypographyText>
                <div style={{ marginTop: '8px' }}>
                    <Button size="small" onClick={() => { userGuideModalVisible = true; }}>打开 modal 引导</Button>
                    <UserGuide
                        mode="modal"
                        visible={userGuideModalVisible}
                        steps={[
                            { title: '欢迎使用 lotus', description: 'lotus 是对齐 Semi Design 能力的 Ripple 组件库。' },
                            { title: '功能强大', description: '涵盖基础、导航、数据录入、数据展示等多个分类的组件。' },
                            { title: '开始使用', description: '点击完成关闭本引导，开始探索吧。' },
                        ]}
                        onFinish={() => { userGuideModalVisible = false; }}
                        onSkip={() => { userGuideModalVisible = false; }}
                        aria-label="modal UserGuide"
                    />
                </div>
            </div>
        </Space>

        <Divider />

        <Divider>带文字的分割线</Divider>

        <Divider dashed align="left">左对齐虚线</Divider>

        <Row gutter={16}>
            <Col span={24} md={12} lg={8}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>Col A</div>
            </Col>
            <Col span={24} md={12} lg={8}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>Col B</div>
            </Col>
            <Col span={24} md={24} lg={8}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>Col C</div>
            </Col>
        </Row>

        <Divider>Grid：pull / push / span=0</Divider>

        <Row>
            <Col span={18} push={6}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>col-18 push-6</div>
            </Col>
            <Col span={6} pull={18}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>col-6 pull-18</div>
            </Col>
        </Row>

        <Row>
            <Col span={12}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>col-12（可见）</div>
            </Col>
            <Col span={0}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>col-0（应隐藏）</div>
            </Col>
            <Col span={12}>
                <div style={{ background: 'var(--lotus-color-fill-0)', padding: '16px' }}>col-12（可见）</div>
            </Col>
        </Row>

        <Divider>Avatar：尺寸</Divider>

        <Space align="center">
            <Avatar size="extra-extra-small" alt="User">U</Avatar>
            <Avatar size="extra-small" alt="User">U</Avatar>
            <Avatar size="small" alt="User">U</Avatar>
            <Avatar size="default" alt="User">U</Avatar>
            <Avatar size="medium" alt="User">U</Avatar>
            <Avatar size="large" alt="User">U</Avatar>
            <Avatar size="extra-large" alt="User">U</Avatar>
        </Space>

        <Divider>Avatar：颜色</Divider>

        <Space>
            <Avatar alt="Alice Swift">AS</Avatar>
            <Avatar color="red" alt="Bob Matteo">BM</Avatar>
            <Avatar color="light-blue" alt="Taylor Joy">TJ</Avatar>
            <Avatar color="white" alt="White">W</Avatar>
        </Space>

        <Divider>Avatar：形状 / 图片 / 自适应字符</Divider>

        <Space align="center">
            <Avatar shape="square" color="amber" alt="User">U</Avatar>
            <Avatar gap={4} color="green">Lotus</Avatar>
            <Avatar
                alt="avatar image"
                src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png"
            />
        </Space>

        <Divider>Avatar：额外边框 / 动效 / Slot</Divider>

        <Space align="center">
            <Avatar color="amber" border alt="border">T</Avatar>
            <Avatar color="amber" border={{ motion: true }} contentMotion alt="border-motion">T</Avatar>
            <Avatar
                color="amber"
                size="large"
                topSlot={{ text: '直播', gradientStart: 'rgb(255,23,100)', gradientEnd: 'rgb(237,52,148)' }}
                alt="top-slot"
            >
                T
            </Avatar>
            <Avatar
                color="amber"
                size="large"
                bottomSlot={{ shape: 'square', bgColor: '#FE2C55', text: '直播中' }}
                alt="bottom-slot"
            >
                T
            </Avatar>
        </Space>

        <Divider>AvatarGroup</Divider>

        <AvatarGroup
            maxCount={3}
            items={([
                { color: 'red', alt: 'Lisa LeBlanc', children: 'LL' },
                { alt: 'Caroline Xiao', children: 'CX' },
                { color: 'amber', alt: 'Rafal Matin', children: 'RM' },
                { color: 'green', alt: 'Zank Lance', children: 'ZL' },
                { color: 'blue', alt: 'Youself Zhang', children: 'YZ' },
            ]) as AvatarGroupItem[]}
        />

        <Divider>Layout：三行布局</Divider>

        <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
            <Header style={{ height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)', textAlign: 'center' }}>Header</Header>
            <Content style={{ height: '120px', lineHeight: '120px', textAlign: 'center' }}>Content</Content>
            <Footer style={{ height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)', textAlign: 'center' }}>Footer</Footer>
        </Layout>

        <Divider>Layout：侧边栏布局</Divider>

        <Layout style={{ border: '1px solid var(--lotus-color-border)' }} hasSider>
            <Sider style={{ width: '120px', background: 'var(--lotus-color-fill-2)' }}>Sider</Sider>
            <Layout>
                <Header style={{ height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)', textAlign: 'center' }}>Header</Header>
                <Content style={{ height: '120px', lineHeight: '120px', textAlign: 'center' }}>Content</Content>
                <Footer style={{ height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)', textAlign: 'center' }}>Footer</Footer>
            </Layout>
        </Layout>

        <Divider>Tooltip：位置 + 触发方式</Divider>

        <Space>
            <Tooltip content="hover 触发" position="top">
                <Button theme="solid">hover top</Button>
            </Tooltip>
            <Tooltip content="点击触发" trigger="click" position="bottom">
                <Button theme="solid" type="secondary">click bottom</Button>
            </Tooltip>
            <Tooltip content="左侧展示" position="left">
                <Button theme="solid" type="tertiary">left</Button>
            </Tooltip>
            <Tooltip content="右侧展示" position="right">
                <Button theme="solid" type="warning">right</Button>
            </Tooltip>
            <Tooltip content="condition=false 不响应" condition={false}>
                <Button theme="outline">condition off</Button>
            </Tooltip>
        </Space>

        <Divider>Popover：任意 JSX 内容 + click 触发</Divider>

        <Space>
            <Popover
                trigger="click"
                content={
                    <div style={{ width: '200px' }}>
                        <p style={{ margin: '0 0 8px' }}>自定义卡片内容</p>
                        <Tag color="green">支持任意 JSX</Tag>
                    </div>
                }
            >
                <Button theme="solid">click 打开卡片</Button>
            </Popover>
            <Popover content="hover 触发 popover" showArrow>
                <Button theme="solid" type="secondary">hover + 箭头</Button>
            </Popover>
        </Space>

        <Divider>Breadcrumb：基础 + 图标 + 自定义分隔符</Divider>

        <Breadcrumb
            routes={['首页', '组件', '导航', '面包屑']}
            onClick={(route) => console.log('breadcrumb clicked', route.name)}
        />
        <div style={{ marginTop: '12px' }}>
            <Breadcrumb separator=">" routes={['首页', '组件', '当前页']} />
        </div>

        <Divider>Breadcrumb：折叠（7 级，maxItemCount=4）</Divider>

        <Breadcrumb routes={['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']} />

        <Divider>Breadcrumb：moreType=popover</Divider>

        <Breadcrumb
            moreType="popover"
            routes={['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']}
        />

        <Divider>Breadcrumb：showTooltip 截断</Divider>

        <div style={{ marginBottom: '8px' }}>默认行为（150px 截断+Tooltip）</div>
        <Breadcrumb routes={['首页', '当这个页面标题很长很长很长时需要省略', '详情页']} />
        <div style={{ marginTop: '12px', marginBottom: '8px' }}>不截断</div>
        <Breadcrumb showTooltip={{ width: 'auto' }} routes={['首页', '当这个页面标题很长很长很长时需要省略', '详情页']} />
        <div style={{ marginTop: '12px', marginBottom: '8px' }}>从中间截断</div>
        <Breadcrumb showTooltip={{ ellipsisPos: 'middle' }} routes={['首页', '当这个页面标题很长很长很长时需要省略', '详情页']} />

        <Divider>Skeleton：基础元素</Divider>

        <Space>
            <SkeletonAvatar />
            <SkeletonImage style={{ width: '80px', height: '80px' }} />
            <SkeletonTitle style={{ width: '120px' }} />
            <SkeletonButton />
        </Space>
        <SkeletonParagraph rows={3} style={{ width: '240px', marginTop: '12px' }} aria-label="Skeleton 基础元素 Paragraph" />

        <Divider>Skeleton：loading 切换</Divider>

        <Skeleton loading={true} placeholder={<SkeletonAvatar />} aria-label="Skeleton loading 切换">
            <Avatar color="blue">U</Avatar>
        </Skeleton>

        <Divider>Skeleton：加载动画（active）</Divider>

        <Skeleton
            active
            loading={true}
            aria-label="Skeleton 加载动画（active）"
            placeholder={
                <div style={{ display: 'flex', alignItems: 'flex-start' }}>
                    <SkeletonAvatar style={{ marginRight: '12px' }} />
                    <div>
                        <SkeletonTitle style={{ width: '120px', marginBottom: '12px', marginTop: '12px' }} />
                        <SkeletonParagraph style={{ width: '240px' }} rows={3} />
                    </div>
                </div>
            }
        >
            <div>已加载完成</div>
        </Skeleton>

        <Divider>Nav：基础垂直导航 + 多级 SubNav</Divider>

        <div style={{ width: '240px', height: '360px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav
                header={{ text: 'Lotus UI', logo: <span style={{ fontSize: '20px' }}>🌸</span> }}
                items={verticalNavItems}
                defaultSelectedKeys={['home']}
                footer={{ collapseButton: true }}
                onSelect={(data) => console.log('nav select', data)}
                onCollapseChange={(collapsed) => console.log('nav collapse', collapsed)}
            />
        </div>

        <Divider>Nav：折叠态（isCollapsed）</Divider>

        <div style={{ width: '60px', height: '360px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav items={verticalNavItems} defaultSelectedKeys={['home']} isCollapsed={true} />
        </div>

        <Divider>Nav：水平模式（mode=horizontal）</Divider>

        <div style={{ border: '1px solid var(--lotus-color-border)' }}>
            <Nav mode="horizontal" items={verticalNavItems} defaultSelectedKeys={['home']} />
        </div>

        <Divider>Nav：renderWrapper（模拟路由集成）</Divider>

        <div style={{ width: '240px', height: '200px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav
                items={verticalNavItems}
                defaultSelectedKeys={['home']}
                renderWrapper={({ itemElement, isSubNav, item }) => (
                    <div data-router-wrapped={item.itemKey} data-is-subnav={isSubNav}>{itemElement}</div>
                )}
            />
        </div>

        <Divider>Dropdown：基础用法</Divider>

        <Dropdown
            trigger="click"
            position="bottomLeft"
            render={
                <DropdownMenu>
                    <DropdownTitle>分组一</DropdownTitle>
                    <DropdownItem icon={<span>📦</span>}>选项 1</DropdownItem>
                    <DropdownItem icon={<span>⚙️</span>}>选项 2</DropdownItem>
                    <DropdownItem disabled icon={<span>🚫</span>}>禁用项</DropdownItem>
                    <DropdownDivider />
                    <DropdownTitle>分组二</DropdownTitle>
                    <DropdownItem type="warning">警告项</DropdownItem>
                    <DropdownItem type="danger">危险项</DropdownItem>
                </DropdownMenu>
            }
        >
            <Button theme="outline" type="tertiary">点击展开菜单</Button>
        </Dropdown>

        <Divider>Nav：JSX 写法（children 组合）</Divider>

        <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav
                bodyStyle={{ height: '200px' }}
                defaultOpenKeys={['user', 'union-management']}
                onSelect={(data) => console.log('jsx nav select', data)}
            >
                <NavHeader logo={<span style={{ fontSize: '20px' }}>🌸</span>} text="Lotus 运营后台" />
                <NavItem itemKey="union" text="活动管理" />
                <NavSub itemKey="user" text="用户管理">
                    <NavItem itemKey="active" text="活跃用户" />
                    <NavItem itemKey="negative" text="非活跃用户" />
                </NavSub>
                <NavSub itemKey="union-management" text="任务管理">
                    <NavItem itemKey="notice" text="任务设置" />
                    <NavItem itemKey="query" text="任务查询" />
                </NavSub>
                <NavFooter collapseButton />
            </Nav>
        </div>

        <Divider>Nav：limitIndent=false 按层级缩进</Divider>

        <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav
                limitIndent={false}
                defaultOpenKeys={['job', 'mission1']}
                items={[
                    { itemKey: 'user', text: '用户管理', icon: <span>👤</span> },
                    {
                        text: '任务平台',
                        icon: <span>📋</span>,
                        itemKey: 'job',
                        items: [
                            '任务管理',
                            {
                                text: '任务1',
                                icon: <span>📄</span>,
                                itemKey: 'mission1',
                                items: ['任务2', { text: '任务3拆解', itemKey: 'mission3', items: ['子任务1', '子任务2'] }],
                            },
                        ],
                    },
                ]}
            />
        </div>

        <Divider>Typography：Title 六级标题</Divider>

        <div>
            <TypographyTitle heading={1}>一级标题</TypographyTitle>
            <TypographyTitle heading={2}>二级标题</TypographyTitle>
            <TypographyTitle heading={3}>三级标题</TypographyTitle>
            <TypographyTitle heading={4}>四级标题</TypographyTitle>
            <TypographyTitle heading={5}>五级标题</TypographyTitle>
            <TypographyTitle heading={6}>六级标题</TypographyTitle>
        </div>

        <Divider>Typography：Text 类型 / 修饰</Divider>

        <Space wrap>
            <TypographyText>默认文本</TypographyText>
            <TypographyText type="secondary">次要文本</TypographyText>
            <TypographyText type="tertiary">三级文本</TypographyText>
            <TypographyText type="warning">警示文本</TypographyText>
            <TypographyText type="danger">危险文本</TypographyText>
            <TypographyText mark>标记文本</TypographyText>
            <TypographyText code>code 文本</TypographyText>
            <TypographyText delete>删除线文本</TypographyText>
            <TypographyText underline>下划线文本</TypographyText>
            <TypographyText strong>加粗文本</TypographyText>
            <TypographyText disabled>禁用文本</TypographyText>
            <TypographyText link={{ href: 'https://example.com', target: '_blank' }}>链接文本</TypographyText>
        </Space>

        <Divider>Typography：Text 可复制 / 省略</Divider>

        <Space vertical align="start">
            <TypographyText copyable children="点击右侧图标可复制这段文本" onClick={() => console.log('typography text clicked')} />
            <div style={{ width: '160px' }}>
                <TypographyText ellipsis={{ showTooltip: true }} children="这是一段很长很长很长很长很长很长的文本，用于测试末尾省略效果" />
            </div>
            <div style={{ width: '160px' }}>
                <TypographyText ellipsis={{ pos: 'middle' }} children="这是一段很长很长很长很长很长很长的文本，用于测试中间省略效果" />
            </div>
        </Space>

        <Divider>Typography：Paragraph</Divider>

        <div style={{ maxWidth: '480px' }}>
            <TypographyParagraph>
                这是一段默认间距的段落文本，用于展示 Paragraph 组件在正常场景下的排版效果，包含较长的中文内容以便观察折行表现。
            </TypographyParagraph>
            <TypographyParagraph spacing="extended">
                这是一段宽松行距的段落文本（spacing="extended"），行间距会更大，适合大段正文阅读场景。
            </TypographyParagraph>
            <TypographyParagraph
                ellipsis={{ rows: 2, expandable: true }}
                children="这是一段可展开收起的多行省略段落文本，默认只显示两行，点击展开按钮后可以看到完整内容，这段文本足够长以触发多行截断效果。"
            />
        </div>

        <Divider>Typography：Numeral 数值格式化</Divider>

        <Space vertical align="start">
            <TypographyNumeral rule="percentages" precision={2} aria-label="百分比格式化" children="0.4567" />
            <TypographyNumeral rule="bytes-decimal" precision={2} aria-label="字节格式化（十进制）" children="1500000" />
            <TypographyNumeral rule="exponential" truncate="floor" precision={2} aria-label="科学计数法格式化" children="Total revenue: $ 1992.15" />
        </Space>

        <Divider>Typography：component 自定义渲染元素</Divider>

        <Space vertical align="start">
            <TypographyText component="div" aria-label="Text 渲染为 div">Text 渲染为 div（默认应为 span）</TypographyText>
            <TypographyTitle heading={3} component="div" aria-label="Title 渲染为 div">Title heading=3 但渲染为 div（默认应为 h3）</TypographyTitle>
            <TypographyParagraph component="span" aria-label="Paragraph 渲染为 span">Paragraph 渲染为 span（默认应为 p）</TypographyParagraph>
        </Space>

        <Divider>Input：基本 / 尺寸 / 禁用</Divider>

        <Space vertical align="start">
            <Input defaultValue="默认值" placeholder="请输入" onChange={(v: string) => console.log('input changed', v)} />
            <Space>
                <Input size="large" placeholder="large" />
                <Input size="default" placeholder="default" />
                <Input size="small" placeholder="small" />
            </Space>
            <Input disabled defaultValue="禁用状态" />
            <Input borderless defaultValue="无边框模式" />
        </Space>

        <Divider>Input：前后缀 / 前后置标签 / 清除 / 密码</Divider>

        <Space vertical align="start">
            <Input prefix="￥" suffix="RMB" placeholder="金额" />
            <Input addonBefore="https://" addonAfter=".com" placeholder="example" />
            <Input showClear defaultValue="hover 或 focus 时可清除" />
            <Input mode="password" defaultValue="secret123" />
        </Space>

        <Divider>Input：校验状态 / 受控组件</Divider>

        <Space vertical align="start">
            <Input validateStatus="warning" defaultValue="警示状态" />
            <Input validateStatus="error" defaultValue="错误状态" />
            <Input value={inputControlledValue} onChange={(v: string) => { inputControlledValue = v; }} placeholder="受控组件" />
        </Space>

        <Divider>Input：受控（外部按钮驱动，非本组件自身交互触发）</Divider>

        <Space>
            <Input value={inputExternalControlledValue} onChange={(v: string) => { inputExternalControlledValue = v; }} placeholder="外部按钮驱动" aria-label="Input 外部受控示例" />
            <Button onClick={() => { inputExternalControlledValue = inputExternalControlledValue + '!'; }}>追加感叹号</Button>
        </Space>

        <Divider>TextArea：多行输入框</Divider>

        <Space vertical align="start">
            <div style={{ width: '360px' }}>
                <TextArea defaultValue="默认多行文本内容" rows={4} onChange={(v: string) => console.log('textarea changed', v)} />
            </div>
            <div style={{ width: '360px' }}>
                <TextArea placeholder="自动扩展高度" autosize={{ minRows: 2, maxRows: 6 }} />
            </div>
            <div style={{ width: '360px' }}>
                <TextArea placeholder="带字数统计与清除按钮" maxCount={50} showClear defaultValue="可清除且带字数统计" />
            </div>
        </Space>

        <Divider>TextArea：受控（外部按钮驱动）</Divider>

        <Space vertical align="start">
            <div style={{ width: '360px' }}>
                <TextArea value={textAreaControlledValue} onChange={(v: string) => { textAreaControlledValue = v; }} rows={3} aria-label="TextArea 外部受控示例" />
            </div>
            <Button onClick={() => { textAreaControlledValue = textAreaControlledValue + '\n新增一行'; }}>追加一行</Button>
        </Space>

        <Divider>Icons：@lotus/icons 验证图标</Divider>

        <Space style={{ fontSize: '24px' }}>
            <IconClose />
            <IconPlus />
            <IconSearch />
            <IconSetting />
            <IconTickCircle />
        </Space>
        <Space style={{ marginTop: '12px', fontSize: '16px', color: 'var(--lotus-color-danger)' }}>
            <IconClose />
            <IconTickCircle style={{ color: 'var(--lotus-color-success)' }} />
        </Space>
        <Space style={{ marginTop: '12px', fontSize: '32px' }}>
            <IconAiBellLevel3 style={{ color: 'var(--lotus-color-primary)' }} />
            <IconTagLab />
            <IconTable />
            <IconLotusLogo style={{ color: 'var(--lotus-color-primary)' }} />
        </Space>
        {/* mask id 唯一化验证：同一页面渲染多个 IconAvatar 实例，确认每个 mask 互不干扰。 */}
        <Space style={{ marginTop: '12px', fontSize: '48px' }}>
            <IconAvatarLab />
            <IconAvatarLab />
            <IconAvatarLab />
        </Space>

        <Divider>Checkbox：基本 / 辅助文本 / 禁用 / indeterminate</Divider>

        <Space vertical align="start">
            <Checkbox onChange={(c: boolean) => console.log('checkbox changed', c)} aria-label="示例">Lotus Design</Checkbox>
            <Checkbox
                extra="Lotus 是由社区共同设计开发并维护的组件库"
                aria-label="带辅助文本示例"
            >
                带辅助文本
            </Checkbox>
            <Checkbox defaultChecked={false} disabled aria-label="禁用未选中示例">禁用未选中</Checkbox>
            <Checkbox defaultChecked disabled aria-label="禁用已选中示例">禁用已选中</Checkbox>
            <Checkbox indeterminate aria-label="indeterminate 示例">indeterminate</Checkbox>
        </Space>

        <Divider>Checkbox：受控</Divider>

        <Space>
            <Checkbox
                checked={checkboxControlledChecked}
                onChange={(c: boolean) => { checkboxControlledChecked = c; }}
                aria-label="受控示例"
            >
                受控 checkbox
            </Checkbox>
            <Button onClick={() => { checkboxControlledChecked = !checkboxControlledChecked; }}>切换</Button>
        </Space>

        <Divider>CheckboxGroup：数组方式 / 垂直</Divider>

        <CheckboxGroup
            options={[
                { value: 'A', label: 'A' },
                { value: 'B', label: 'B' },
                { value: 'C', label: 'C', disabled: true },
            ]}
            defaultValue={['A', 'B']}
            aria-label="CheckboxGroup 数组方式示例"
        />

        <Divider>CheckboxGroup：JSX 方式 / 水平 / 受控</Divider>

        <CheckboxGroup
            direction="horizontal"
            value={checkboxGroupControlledValue}
            onChange={(v: Array<string | number>) => { checkboxGroupControlledValue = v; }}
            aria-label="CheckboxGroup JSX 方式示例"
            children={
                <>
                    <Checkbox value="A">A</Checkbox>
                    <Checkbox value="B">B</Checkbox>
                    <Checkbox value="C">C</Checkbox>
                </>
            }
        />

        <Divider>Radio：基本 / 辅助文本 / 禁用</Divider>

        <Space vertical align="start">
            <Radio name="radio-basic" onChange={(c: boolean) => console.log('radio changed', c)} aria-label="Radio 示例">Lotus Design</Radio>
            <Radio name="radio-extra" extra="Lotus 是由社区共同设计开发并维护的组件库" aria-label="Radio 带辅助文本示例">带辅助文本</Radio>
            <Radio name="radio-disabled-unchecked" defaultChecked={false} disabled aria-label="Radio 禁用未选中示例">禁用未选中</Radio>
            <Radio name="radio-disabled-checked" defaultChecked disabled aria-label="Radio 禁用已选中示例">禁用已选中</Radio>
        </Space>

        <Divider>Radio：受控（外部按钮驱动）</Divider>

        <Space>
            <Radio
                name="radio-controlled"
                checked={radioControlledChecked}
                onChange={(c: boolean) => { radioControlledChecked = c; }}
                aria-label="Radio 受控示例"
            >
                受控 radio
            </Radio>
            <Button onClick={() => { radioControlledChecked = !radioControlledChecked; }}>切换 Radio</Button>
        </Space>

        <Divider>RadioGroup：数组方式 / 垂直</Divider>

        <RadioGroup
            direction="vertical"
            options={[
                { value: 'A', label: 'A' },
                { value: 'B', label: 'B' },
                { value: 'C', label: 'C', disabled: true },
            ]}
            defaultValue="A"
            name="radio-group-array"
            aria-label="RadioGroup 数组方式示例"
        />

        <Divider>RadioGroup：JSX 方式 / 水平 / 受控</Divider>

        <RadioGroup
            direction="horizontal"
            value={radioGroupControlledValue}
            onChange={(v: string | number) => { radioGroupControlledValue = v; }}
            name="radio-group-jsx"
            aria-label="RadioGroup JSX 方式示例"
            children={
                <>
                    <Radio value="A">A</Radio>
                    <Radio value="B">B</Radio>
                    <Radio value="C">C</Radio>
                </>
            }
        />

        <Divider>InputNumber：基本 / 步进 / 边界 / 禁用</Divider>

        <Space vertical align="start">
            <div style={{ width: '200px' }}>
                <InputNumber
                    defaultValue={0}
                    onChange={(v: number | undefined) => console.log('inputnumber changed', v)}
                    aria-label="InputNumber 基本示例"
                />
            </div>
            <div style={{ width: '200px' }}>
                <InputNumber min={1} max={10} defaultValue={1} aria-label="InputNumber 边界示例" />
            </div>
            <div style={{ width: '200px' }}>
                <InputNumber step={5} defaultValue={0} aria-label="InputNumber 步进示例" />
            </div>
            <div style={{ width: '200px' }}>
                <InputNumber defaultValue={5} disabled aria-label="InputNumber 禁用示例" />
            </div>
            <div style={{ width: '200px' }}>
                <InputNumber defaultValue={5} showClear hideButtons aria-label="InputNumber 无步进器可清除示例" />
            </div>
            <div style={{ width: '200px' }}>
                <InputNumber defaultValue={100} prefix="￥" suffix="元" aria-label="InputNumber 前后缀示例" />
            </div>
        </Space>

        <Divider>InputNumber：受控（外部按钮驱动）</Divider>

        <Space>
            <div style={{ width: '200px' }}>
                <InputNumber
                    value={inputNumberControlledValue}
                    onChange={(v: number | undefined) => { if (v !== undefined) inputNumberControlledValue = v; }}
                    aria-label="InputNumber 受控示例"
                />
            </div>
            <Button onClick={() => { inputNumberControlledValue = inputNumberControlledValue + 10; }}>加 10</Button>
        </Space>

        <Divider>Select：基本 / 尺寸 / 禁用 / 校验状态</Divider>

        <Space vertical align="start">
            <div style={{ width: '200px' }}>
                <Select
                    optionList={businessLineOptions}
                    defaultValue="douyin"
                    placeholder="请选择业务线"
                    onChange={(v) => console.log('select changed', v)}
                    aria-label="Select 基本示例"
                />
            </div>
            <div style={{ width: '200px' }}>
                <Select optionList={businessLineOptions} size="small" defaultValue="douyin" aria-label="Select 小尺寸示例" />
            </div>
            <div style={{ width: '200px' }}>
                <Select optionList={businessLineOptions} size="large" defaultValue="douyin" aria-label="Select 大尺寸示例" />
            </div>
            <div style={{ width: '200px' }}>
                <Select optionList={businessLineOptions} disabled defaultValue="douyin" aria-label="Select 禁用示例" />
            </div>
            <div style={{ width: '200px' }}>
                <Select optionList={businessLineOptions} validateStatus="error" placeholder="请选择" aria-label="Select 错误状态示例" />
            </div>
            <div style={{ width: '200px' }}>
                <Select optionList={businessLineOptions} showClear defaultValue="douyin" aria-label="Select 可清除示例" />
            </div>
        </Space>

        <Divider>Select：virtualize + filter（1万条选项虚拟滚动 + 搜索，对齐 Transfer 已验证的 base/virtual-list.ts 实现模式）</Divider>

        <div style={{ width: '200px' }}>
            <Select
                optionList={largeSelectOptionList}
                virtualize={{ height: 240, itemSize: 32 }}
                filter
                searchPlaceholder="搜索选项"
                placeholder="1万条选项"
                aria-label="Select 虚拟滚动示例"
            />
        </div>

        <Divider>Select：filter（内置匹配，searchPosition=trigger 默认叠加在触发器）</Divider>

        <div style={{ width: '280px' }}>
            <Select
                optionList={businessLineOptions}
                filter
                placeholder="请选择业务线"
                aria-label="Select filter trigger 示例"
            />
        </div>

        <Divider>Select：filter（searchPosition=dropdown，搜索框固定在面板顶部）</Divider>

        <div style={{ width: '280px' }}>
            <Select
                optionList={businessLineOptions}
                filter
                searchPosition="dropdown"
                searchPlaceholder="搜索业务线"
                placeholder="请选择业务线"
                aria-label="Select filter dropdown 示例"
            />
        </div>

        <Divider>Select：多选</Divider>

        <div style={{ width: '280px' }}>
            <Select
                optionList={businessLineOptions}
                multiple
                defaultValue={['douyin', 'xigua']}
                placeholder="请选择业务线"
                onChange={(v) => console.log('select multiple changed', v)}
                aria-label="Select 多选示例"
            />
        </div>

        <Divider>Select：多选 + filter（trigger 模式下输入框与已选 tags 共存）</Divider>

        <div style={{ width: '320px' }}>
            <Select
                optionList={businessLineOptions}
                multiple
                filter
                placeholder="请选择业务线"
                aria-label="Select 多选 filter 示例"
            />
        </div>

        <Divider>Select：受控（外部按钮驱动）</Divider>

        <Space>
            <div style={{ width: '200px' }}>
                <Select
                    optionList={businessLineOptions}
                    value={selectControlledValue}
                    onChange={(v) => { if (typeof v === 'string') selectControlledValue = v; }}
                    aria-label="Select 受控示例"
                />
            </div>
            <Button onClick={() => { selectControlledValue = selectControlledValue === 'douyin' ? 'xigua' : 'douyin'; }}>切换 Select</Button>
        </Space>

        <Divider>Cascader：单选（非叶子节点点击展开下一级）</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div style={{ width: '280px' }}>
                <Cascader
                    treeData={cascaderRegionData}
                    placeholder="请选择省市区"
                    onChange={(v) => { cascaderChangeLog = `单选 onChange: ${JSON.stringify(v)}`; }}
                    aria-label="Cascader 单选"
                />
            </div>
            <TypographyText type="secondary" aria-label="Cascader 单选事件日志">{cascaderChangeLog}</TypographyText>
        </Space>

        <Divider>Cascader：多选（三态级联 + tag 折叠展示）</Divider>

        <div style={{ width: '320px' }}>
            <Cascader
                treeData={cascaderRegionData}
                multiple
                showClear
                placeholder="请选择多个地区"
                onChange={(v) => { cascaderChangeLog = `多选 onChange: ${JSON.stringify(v)}`; }}
                aria-label="Cascader 多选"
            />
        </div>

        <Divider>Cascader：搜索（内置路径文本匹配，仅展示叶子节点结果）</Divider>

        <div style={{ width: '280px' }}>
            <Cascader
                treeData={cascaderRegionData}
                filterTreeNode
                searchPlaceholder="搜索地区"
                placeholder="请选择省市区"
                aria-label="Cascader 搜索"
            />
        </div>

        <Divider>Cascader：virtualize（单列 10000 个子节点虚拟滚动，对齐 Select 已验证的实现模式）</Divider>

        <div style={{ width: '280px' }}>
            <Cascader
                treeData={cascaderVirtualizeData}
                virtualize={{ height: 240, itemSize: 32 }}
                filterTreeNode
                searchPlaceholder="搜索城市"
                placeholder="请选择"
                aria-label="Cascader 虚拟滚动示例"
            />
        </div>

        <Divider>Cascader：受控（外部按钮驱动）</Divider>

        <Space>
            <div style={{ width: '280px' }}>
                <Cascader
                    treeData={cascaderRegionData}
                    value={cascaderControlledValue}
                    onChange={(v) => { if (Array.isArray(v) && typeof v[0] !== 'object') cascaderControlledValue = v as Array<string | number>; }}
                    aria-label="Cascader 受控示例"
                />
            </div>
            <Button
                onClick={() => {
                    cascaderControlledValue = cascaderControlledValue[0] === 'zhejiang'
                        ? ['jiangsu', 'suzhou', 'gusu']
                        : ['zhejiang', 'hangzhou', 'xihu'];
                }}
            >
                切换 Cascader
            </Button>
        </Space>

        <Divider>Cascader：受控拒绝更新（回归防护：onChange 拒绝更新时点击/清除不应污染 UI）</Divider>

        <div style={{ width: '280px' }}>
            <Cascader
                treeData={cascaderRegionData}
                value={['zhejiang', 'hangzhou', 'xihu']}
                onChange={() => {}}
                showClear
                aria-label="Cascader 受控拒绝更新示例"
            />
        </div>

        <Divider>Cascader：懒加载（loadData 异步追加子节点）</Divider>

        <div style={{ width: '280px' }}>
            <Cascader
                treeData={cascaderLazyTreeData}
                placeholder="请选择分类"
                loadData={(entity) => {
                    return new Promise((resolve) => {
                        setTimeout(() => {
                            cascaderLazyTreeData = cascaderLazyTreeData.map((node) => {
                                if (node.value !== entity.value) return node;
                                const children = entity.value === 'fruit'
                                    ? [{ value: 'apple', label: '苹果' }, { value: 'banana', label: '香蕉' }]
                                    : [{ value: 'carrot', label: '胡萝卜' }, { value: 'potato', label: '土豆' }];
                                return { ...node, children };
                            });
                            resolve();
                        }, 400);
                    });
                }}
                aria-label="Cascader 懒加载"
            />
        </div>

        <Divider>TreeSelect：单选</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div>
                <div style={{ width: '280px' }}>
                    <TreeSelect
                        treeData={treeDemoData}
                        placeholder="请选择员工"
                        onChange={(v) => { treeSelectChangeLog = `单选 onChange: ${JSON.stringify(v)}`; }}
                        aria-label="TreeSelect 单选"
                    />
                </div>
                <TypographyText type="secondary" aria-label="TreeSelect 事件日志">{treeSelectChangeLog}</TypographyText>
            </div>
        </Space>

        <Divider>TreeSelect：多选（三态级联 + tag 折叠展示）</Divider>

        <div style={{ width: '320px' }}>
            <TreeSelect
                treeData={treeDemoData}
                multiple
                showClear
                maxTagCount={2}
                placeholder="请选择部门/员工"
                aria-label="TreeSelect 多选"
            />
        </div>

        <Divider>TreeSelect：多选 checkRelation=unRelated（选中态互不联动）</Divider>

        <div style={{ width: '320px' }}>
            <TreeSelect
                treeData={treeDemoData}
                multiple
                checkRelation="unRelated"
                showClear
                placeholder="请选择（不联动父子）"
                aria-label="TreeSelect unRelated"
            />
        </div>

        <Divider>TreeSelect：virtualize（10000 个子节点虚拟滚动，对齐 Select/Cascader 已验证的实现模式）</Divider>

        <div style={{ width: '280px' }}>
            <TreeSelect
                treeData={treeSelectVirtualizeData}
                virtualize={{ height: 240, itemSize: 32 }}
                defaultExpandedKeys={['root']}
                filterTreeNode
                searchPlaceholder="搜索节点"
                placeholder="请选择"
                aria-label="TreeSelect 虚拟滚动示例"
            />
        </div>

        <Divider>TreeSelect：搜索</Divider>

        <div style={{ width: '280px' }}>
            <TreeSelect
                treeData={treeDemoData}
                filterTreeNode
                searchPlaceholder="搜索姓名/部门"
                placeholder="请选择员工"
                aria-label="TreeSelect 搜索"
            />
        </div>

        <Divider>TreeSelect：受控（外部按钮驱动）</Divider>

        <Space>
            <div style={{ width: '280px' }}>
                <TreeSelect
                    treeData={treeDemoData}
                    value={treeSelectControlledValue}
                    onChange={(v) => { if (typeof v === 'string') treeSelectControlledValue = v; }}
                    aria-label="TreeSelect 受控示例"
                />
            </div>
            <Button
                onClick={() => {
                    treeSelectControlledValue = treeSelectControlledValue === 'dept-1-1-1' ? 'dept-2-1' : 'dept-1-1-1';
                }}
            >
                切换 TreeSelect
            </Button>
        </Space>

        <Divider>TreeSelect：受控拒绝更新（回归防护：onChange 拒绝更新时点击/清除不应污染 UI）</Divider>

        <div style={{ width: '280px' }}>
            <TreeSelect
                treeData={treeDemoData}
                value="dept-1-1-1"
                onChange={() => {}}
                showClear
                aria-label="TreeSelect 受控拒绝更新示例"
            />
        </div>

        <Divider>TreeSelect：懒加载（loadData 异步追加子节点）</Divider>

        <div style={{ width: '280px' }}>
            <TreeSelect
                treeData={treeSelectLazyTreeData}
                placeholder="请选择分类"
                loadData={(node) => {
                    return new Promise((resolve) => {
                        setTimeout(() => {
                            const children = node.key === 'fruit'
                                ? [{ key: 'apple', label: '苹果' }, { key: 'banana', label: '香蕉' }]
                                : [{ key: 'carrot', label: '胡萝卜' }, { key: 'potato', label: '土豆' }];
                            resolve(children);
                        }, 400);
                    });
                }}
                aria-label="TreeSelect 懒加载"
            />
        </div>

        <Divider>AutoComplete：基础用法（onSearch 里自行过滤候选项，组件本身不做匹配）</Divider>

        <Space vertical align="start" style={{ width: '100%', gap: '16px' }}>
            <div>
                <div style={{ width: '280px' }}>
                    <AutoComplete
                        data={autoCompleteSearchResult}
                        placeholder="输入城市名搜索"
                        showClear
                        onSearch={(v) => {
                            const input = String(v);
                            autoCompleteSearchResult = input
                                ? autoCompleteAllCities.filter((c) => c.includes(input))
                                : autoCompleteAllCities;
                        }}
                        onChange={(v) => { autoCompleteChangeLog = `onChange: ${JSON.stringify(v)}`; }}
                        aria-label="AutoComplete 基础"
                    />
                </div>
                <TypographyText type="secondary" aria-label="AutoComplete 事件日志">{autoCompleteChangeLog}</TypographyText>
            </div>
        </Space>

        <Divider>AutoComplete：defaultActiveFirstOption（打开面板默认高亮第一项，回车直接选中）</Divider>

        <div style={{ width: '280px' }}>
            <AutoComplete
                data={autoCompleteAllCities}
                defaultActiveFirstOption
                placeholder="按方向键/回车试试"
                aria-label="AutoComplete defaultActiveFirstOption"
            />
        </div>

        <Divider>AutoComplete：受控（外部按钮驱动）</Divider>

        <Space>
            <div style={{ width: '280px' }}>
                <AutoComplete
                    data={autoCompleteAllCities}
                    value={autoCompleteControlledValue}
                    onChange={(v) => { autoCompleteControlledValue = String(v); }}
                    aria-label="AutoComplete 受控示例"
                />
            </div>
            <Button
                onClick={() => {
                    autoCompleteControlledValue = autoCompleteControlledValue === '北京' ? '上海' : '北京';
                }}
            >
                切换 AutoComplete
            </Button>
        </Space>

        <Divider>AutoComplete：loading（远程搜索加载态）</Divider>

        <div style={{ width: '280px' }}>
            <AutoComplete
                data={autoCompleteLoadingResult}
                loading={autoCompleteLoading}
                placeholder="模拟远程搜索"
                onSearch={(v) => {
                    const input = String(v);
                    if (!input) { autoCompleteLoadingResult = []; autoCompleteLoading = false; return; }
                    autoCompleteLoading = true;
                    setTimeout(() => {
                        autoCompleteLoadingResult = autoCompleteAllCities.filter((c) => c.includes(input));
                        autoCompleteLoading = false;
                    }, 500);
                }}
                aria-label="AutoComplete loading"
            />
        </div>

        <Divider>TimePicker：基础用法（type=time，24 小时制）</Divider>

        <div style={{ width: '240px' }}>
            <TimePicker
                onChange={(v) => { timePickerChangeLog = `变化：${v ? (v as Date).toLocaleTimeString() : 'null'}`; }}
                aria-label="TimePicker 基础"
            />
            <TypographyText type="secondary" aria-label="TimePicker 事件日志">{timePickerChangeLog}</TypographyText>
        </div>

        <Divider>TimePicker：12 小时制 + 秒步进</Divider>

        <div style={{ width: '260px' }}>
            <TimePicker use12Hours secondStep={10} aria-label="TimePicker 12小时制" />
        </div>

        <Divider>TimePicker：timeRange（范围选择，左右双列）</Divider>

        <div style={{ width: '320px' }}>
            <TimePicker
                type="timeRange"
                onChange={(v) => {
                    const pair = v as [Date | null, Date | null];
                    timePickerRangeChangeLog = `变化：${pair[0]?.toLocaleTimeString() ?? 'null'} ~ ${pair[1]?.toLocaleTimeString() ?? 'null'}`;
                }}
                aria-label="TimePicker 范围"
            />
            <TypographyText type="secondary" aria-label="TimePicker 范围事件日志">{timePickerRangeChangeLog}</TypographyText>
        </div>

        <Divider>TimePicker：禁用小时/分钟 + 隐藏禁用项</Divider>

        <div style={{ width: '240px' }}>
            <TimePicker
                disabledHours={() => [0, 1, 2, 3, 4, 5, 22, 23]}
                disabledMinutes={(h) => (h === 9 ? [0, 15, 30, 45] : [])}
                hideDisabledOptions
                aria-label="TimePicker 禁用项"
            />
        </div>

        <Divider>TimePicker：受控（外部按钮驱动）</Divider>

        <div style={{ width: '240px' }}>
            <TimePicker
                value={timePickerControlledValue}
                onChange={(v) => { timePickerControlledValue = v as Date | null; }}
                aria-label="TimePicker 受控示例"
            />
            <Button
                onClick={() => {
                    const d = new Date();
                    d.setHours(14, 30, 0, 0);
                    timePickerControlledValue = timePickerControlledValue ? null : d;
                }}
            >
                切换 TimePicker
            </Button>
        </div>

        <Divider>DatePicker：基础用法（type=date）</Divider>

        <div style={{ width: '260px' }}>
            <DatePicker
                onChange={(v) => { datePickerChangeLog = `变化：${v ? (v as Date).toDateString() : 'null'}`; }}
                aria-label="DatePicker 基础"
            />
            <TypographyText type="secondary" aria-label="DatePicker 事件日志">{datePickerChangeLog}</TypographyText>
        </div>

        <Divider>DatePicker：dateRange（范围选择，双面板）</Divider>

        <div style={{ width: '520px' }}>
            <DatePicker
                type="dateRange"
                onChange={(v) => {
                    const pair = v as [Date | null, Date | null];
                    datePickerRangeChangeLog = `变化：${pair?.[0]?.toDateString() ?? 'null'} ~ ${pair?.[1]?.toDateString() ?? 'null'}`;
                }}
                aria-label="DatePicker 范围"
            />
            <TypographyText type="secondary" aria-label="DatePicker 范围事件日志">{datePickerRangeChangeLog}</TypographyText>
        </div>

        <Divider>DatePicker：禁用日期（周末不可选）</Divider>

        <div style={{ width: '260px' }}>
            <DatePicker
                disabledDate={(d) => d.getDay() === 0 || d.getDay() === 6}
                aria-label="DatePicker 禁用周末"
            />
        </div>

        <Divider>DatePicker：快捷选项 presets</Divider>

        <div style={{ width: '260px' }}>
            <DatePicker
                presets={[
                    { text: '今天', start: () => new Date() },
                    { text: '一周后', start: () => { const d = new Date(); d.setDate(d.getDate() + 7); return d; } },
                ]}
                aria-label="DatePicker presets"
            />
        </div>

        <Divider>DatePicker：dateTime（日期时间联动）</Divider>

        <div style={{ width: '260px' }}>
            <DatePicker type="dateTime" aria-label="DatePicker 日期时间" />
        </div>

        <Divider>DatePicker：month / year 类型（年月滚轮）</Divider>

        <div style={{ display: 'flex', gap: '16px' }}>
            <div style={{ width: '200px' }}>
                <DatePicker type="month" aria-label="DatePicker 月份" />
            </div>
            <div style={{ width: '200px' }}>
                <DatePicker type="year" aria-label="DatePicker 年份" />
            </div>
        </div>

        <Divider>DatePicker：受控（外部按钮驱动）</Divider>

        <div style={{ width: '260px' }}>
            <DatePicker
                value={datePickerControlledValue}
                onChange={(v) => { datePickerControlledValue = v as Date | null; }}
                aria-label="DatePicker 受控示例"
            />
            <Button
                onClick={() => {
                    datePickerControlledValue = datePickerControlledValue ? null : new Date(2024, 2, 5);
                }}
            >
                切换 DatePicker
            </Button>
        </div>

        <Divider>Slider：基础用法</Divider>

        <div style={{ width: '320px' }}>
            <Slider
                onChange={(v) => { sliderChangeLog = `变化：${v}`; }}
                aria-label="Slider 基础"
            />
            <TypographyText type="secondary" aria-label="Slider 事件日志">{sliderChangeLog}</TypographyText>
        </div>

        <Divider>Slider：range 双滑块</Divider>

        <div style={{ width: '320px' }}>
            <Slider
                range
                defaultValue={[20, 80]}
                onChange={(v) => { sliderRangeChangeLog = `变化：${JSON.stringify(v)}`; }}
                aria-label="Slider 范围"
            />
            <TypographyText type="secondary" aria-label="Slider 范围事件日志">{sliderRangeChangeLog}</TypographyText>
        </div>

        <Divider>Slider：marks 刻度标记 + step=10</Divider>

        <div style={{ width: '320px' }}>
            <Slider
                step={10}
                marks={{ 0: '0°C', 20: '20°C', 40: '40°C', 60: '60°C', 80: '80°C', 100: '100°C' }}
                aria-label="Slider 刻度"
            />
        </div>

        <Divider>Slider：禁用</Divider>

        <div style={{ width: '320px' }}>
            <Slider disabled defaultValue={40} aria-label="Slider 禁用" />
        </div>

        <Divider>Slider：vertical 垂直方向</Divider>

        <div style={{ height: '200px', display: 'flex', gap: '32px' }}>
            <Slider vertical defaultValue={30} aria-label="Slider 垂直" />
        </div>

        <Divider>Slider：受控（外部按钮驱动）</Divider>

        <div style={{ width: '320px' }}>
            <Slider
                value={sliderControlledValue}
                onChange={(v) => { sliderControlledValue = v as number; }}
                aria-label="Slider 受控示例"
            />
            <Button onClick={() => { sliderControlledValue = sliderControlledValue === 30 ? 70 : 30; }}>
                切换 Slider
            </Button>
        </div>

        <Divider>Rating：基础用法</Divider>

        <div style={{ width: '260px' }}>
            <Rating
                onChange={(v) => { ratingChangeLog = `变化：${v}`; }}
                aria-label="Rating 基础"
            />
            <TypographyText type="secondary" aria-label="Rating 事件日志">{ratingChangeLog}</TypographyText>
        </div>

        <Divider>Rating：allowHalf 半星 + 自定义 count</Divider>

        <div style={{ width: '260px' }}>
            <Rating
                allowHalf
                count={10}
                defaultValue={3.5}
                onChange={(v) => { ratingHalfChangeLog = `变化：${v}`; }}
                aria-label="Rating 半星"
            />
            <TypographyText type="secondary" aria-label="Rating 半星事件日志">{ratingHalfChangeLog}</TypographyText>
        </div>

        <Divider>Rating：allowClear=false（点击已选值不清零）</Divider>

        <div style={{ width: '260px' }}>
            <Rating allowClear={false} defaultValue={3} aria-label="Rating 不可清零" />
        </div>

        <Divider>Rating：small 尺寸 + 禁用</Divider>

        <div style={{ display: 'flex', gap: '24px' }}>
            <Rating size="small" defaultValue={4} aria-label="Rating 小尺寸" />
            <Rating disabled defaultValue={2} aria-label="Rating 禁用" />
        </div>

        <Divider>Rating：受控（外部按钮驱动）</Divider>

        <div style={{ width: '260px' }}>
            <Rating
                value={ratingControlledValue}
                onChange={(v) => { ratingControlledValue = v; }}
                aria-label="Rating 受控示例"
            />
            <Button onClick={() => { ratingControlledValue = ratingControlledValue === 3 ? 5 : 3; }}>
                切换 Rating
            </Button>
        </div>

        <Divider>Rating：受控（onChange 拒绝更新，验证点击不会把 UI 带偏）</Divider>

        <div style={{ width: '260px' }}>
            <Rating value={3} onChange={() => {}} aria-label="Rating 受控拒绝更新示例" />
        </div>

        <Divider>ColorPicker：基础用法（直接展开面板）</Divider>

        <div>
            <ColorPicker
                onChange={(v) => { colorPickerChangeLog = `变化：${v.hex}`; }}
                aria-label="ColorPicker 基础"
            />
            <TypographyText type="secondary" aria-label="ColorPicker 事件日志">{colorPickerChangeLog}</TypographyText>
        </div>

        <Divider>ColorPicker：usePopover + 自定义触发器</Divider>

        <div>
            <ColorPicker usePopover aria-label="ColorPicker 弹层">
                <Button>点击选择颜色</Button>
            </ColorPicker>
        </div>

        <Divider>ColorPicker：alpha=false（无透明度条）</Divider>

        <div>
            <ColorPicker
                alpha={false}
                value={colorPickerNoAlphaValue}
                onChange={(v) => { colorPickerNoAlphaValue = v; }}
                aria-label="ColorPicker 无透明度"
            />
        </div>

        <Divider>ColorPicker：受控拒绝更新（回归防护：onChange 拒绝更新时拖拽/输入不应污染 UI）</Divider>

        <div>
            <ColorPicker
                value={{ hsva: { h: 200, s: 80, v: 90, a: 1 }, rgba: { r: 46, g: 175, b: 230, a: 1 }, hex: '#2eafe6' }}
                onChange={() => {}}
                aria-label="ColorPicker 受控拒绝更新示例"
            />
        </div>

        <Divider>Transfer：基础用法（type=list，含搜索/全选/禁用项）</Divider>

        <div>
            <Transfer
                dataSource={transferListData}
                value={transferValue}
                onChange={(v) => { transferValue = v; }}
                aria-label="Transfer 基础"
            />
        </div>

        <Divider>Transfer：type=groupList 分组</Divider>

        <div>
            <Transfer
                type="groupList"
                dataSource={transferGroupData}
                value={transferGroupValue}
                onChange={(v) => { transferGroupValue = v; }}
                aria-label="Transfer 分组"
            />
        </div>

        <Divider>Transfer：type=treeList 树形</Divider>

        <div>
            <Transfer
                type="treeList"
                dataSource={treeDemoData}
                value={transferTreeValue}
                onChange={(v) => { transferTreeValue = v; }}
                aria-label="Transfer 树形"
            />
        </div>

        <Divider>Transfer：draggable 拖拽排序已选列表</Divider>

        <div>
            <Transfer
                dataSource={transferListData}
                draggable
                aria-label="Transfer 拖拽"
            />
        </div>

        <Divider>Transfer：virtualize 虚拟化已选列表（60 项数据）</Divider>

        <div>
            <Transfer
                dataSource={transferManyData}
                virtualize={{ height: 240, itemSize: 40 }}
                aria-label="Transfer 虚拟化"
            />
        </div>

        <Divider>Transfer：disabled 整体禁用</Divider>

        <div>
            <Transfer
                dataSource={transferListData}
                value={['a1']}
                disabled
                aria-label="Transfer 禁用"
            />
        </div>

        <Divider>Transfer：受控（外部按钮驱动）</Divider>

        <div>
            <Transfer
                dataSource={transferControlledData}
                value={transferControlledValue}
                onChange={(v) => { transferControlledValue = v; }}
                aria-label="Transfer 受控示例"
            />
            <Button onClick={() => { transferControlledValue = transferControlledValue.length > 0 ? [] : ['c1', 'c2']; }}>
                切换 Transfer 选中值
            </Button>
        </div>

        <Divider>Upload：基础用法（listType=list，点击触发，customRequest 模拟上传）</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                customRequest={mockUploadRequest}
                fileList={uploadFileList}
                onChange={(list) => { uploadFileList = list; uploadChangeLog = `变化：${list.length} 个文件`; }}
                aria-label="Upload 基础"
            />
            <TypographyText type="secondary" aria-label="Upload 事件日志">{uploadChangeLog}</TypographyText>
        </div>

        <Divider>Upload：draggable 拖拽上传区域</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                customRequest={mockUploadRequest}
                draggable
                fileList={uploadDragFileList}
                onChange={(list) => { uploadDragFileList = list; }}
                aria-label="Upload 拖拽"
            />
        </div>

        <Divider>Upload：listType=picture 图片墙 + multiple 多选</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                customRequest={mockUploadRequest}
                listType="picture"
                multiple
                accept="image/*"
                fileList={uploadPictureFileList}
                onChange={(list) => { uploadPictureFileList = list; }}
                aria-label="Upload 图片墙"
            />
        </div>

        <Divider>Upload：limit=2 + maxSize 限制</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                customRequest={mockUploadRequest}
                multiple
                limit={2}
                maxSize={5000}
                onExceed={() => { uploadChangeLog = '超出数量限制'; }}
                aria-label="Upload 限制"
            />
        </div>

        <Divider>Upload：受控拒绝更新（回归防护：onChange 拒绝更新时移除文件不应污染 UI）</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                customRequest={mockUploadRequest}
                fileList={[{ uid: 'reject-1', name: 'locked.png', size: 2048, status: 'success', percent: 100 }]}
                onChange={() => {}}
                aria-label="Upload 受控拒绝更新示例"
            />
        </div>

        <Divider>Upload：disabled 禁用</Divider>

        <div>
            <Upload
                action="https://example.com/upload"
                disabled
                defaultFileList={[{ uid: 'd1', name: 'readonly.png', size: 2048, status: 'success', percent: 100 }]}
                aria-label="Upload 禁用"
            />
        </div>

        <Divider>TagInput：基础用法（Enter/逗号新增，Backspace 删除最后一个）</Divider>

        <div style={{ width: '360px' }}>
            <TagInput
                value={tagInputValue}
                onChange={(v) => { tagInputValue = v; tagInputChangeLog = `变化：${v.join(',')}`; }}
                placeholder="输入后按 Enter 或逗号添加"
                aria-label="TagInput 基础"
            />
            <TypographyText type="secondary" aria-label="TagInput 事件日志">{tagInputChangeLog}</TypographyText>
        </div>

        <Divider>TagInput：maxTagCount 折叠 + showRestTagsPopover</Divider>

        <div style={{ width: '260px' }}>
            <TagInput
                value={tagInputFoldValue}
                onChange={(v) => { tagInputFoldValue = v; }}
                maxTagCount={3}
                aria-label="TagInput 折叠"
            />
        </div>

        <Divider>TagInput：draggable 拖拽排序</Divider>

        <div style={{ width: '360px' }}>
            <TagInput
                value={tagInputDragValue}
                onChange={(v) => { tagInputDragValue = v; }}
                draggable
                aria-label="TagInput 拖拽"
            />
        </div>

        <Divider>TagInput：showClear + allowDuplicates=false + max=5</Divider>

        <div style={{ width: '360px' }}>
            <TagInput
                defaultValue={['x']}
                showClear
                allowDuplicates={false}
                max={5}
                aria-label="TagInput 限制"
            />
        </div>

        <Divider>TagInput：disabled 禁用</Divider>

        <div style={{ width: '360px' }}>
            <TagInput defaultValue={['只读1', '只读2']} disabled aria-label="TagInput 禁用" />
        </div>

        <Divider>TagInput：受控（外部按钮驱动）</Divider>

        <div style={{ width: '360px' }}>
            <TagInput
                value={tagInputControlledValue}
                onChange={(v) => { tagInputControlledValue = v; }}
                aria-label="TagInput 受控示例"
            />
            <Button onClick={() => { tagInputControlledValue = tagInputControlledValue.length > 0 ? [] : ['a', 'b']; }}>
                切换 TagInput 选中值
            </Button>
        </div>

        <Divider>TagInput：受控拒绝更新（回归防护：onChange 拒绝更新时退格/删除标签不应污染 UI）</Divider>

        <div style={{ width: '360px' }}>
            <TagInput
                value={['locked-a', 'locked-b']}
                onChange={() => {}}
                aria-label="TagInput 受控拒绝更新示例"
            />
        </div>

        <Divider>PinCode：基础用法（format=number，6 位）</Divider>

        <div>
            <PinCode
                onChange={(v) => { pinCodeChangeLog = `变化：${v}`; }}
                onComplete={(v) => { pinCodeCompleteLog = `完成：${v}`; }}
                autoFocus={false}
                aria-label="PinCode 基础"
            />
            <TypographyText type="secondary" aria-label="PinCode 事件日志">{pinCodeChangeLog}</TypographyText>
            <TypographyText type="secondary" aria-label="PinCode 完成日志">{pinCodeCompleteLog}</TypographyText>
        </div>

        <Divider>PinCode：format=mixed，count=4</Divider>

        <div>
            <PinCode count={4} format="mixed" autoFocus={false} aria-label="PinCode 混合格式" />
        </div>

        <Divider>PinCode：size=large + validateStatus=error</Divider>

        <div>
            <PinCode size="large" validateStatus="error" defaultValue="12" autoFocus={false} aria-label="PinCode 错误态" />
        </div>

        <Divider>PinCode：disabled 禁用</Divider>

        <div>
            <PinCode disabled defaultValue="123456" autoFocus={false} aria-label="PinCode 禁用" />
        </div>

        <Divider>PinCode：受控（外部按钮驱动）</Divider>

        <div>
            <PinCode
                value={pinCodeControlledValue}
                onChange={(v) => { pinCodeControlledValue = v; }}
                count={4}
                autoFocus={false}
                aria-label="PinCode 受控示例"
            />
            <Button onClick={() => { pinCodeControlledValue = pinCodeControlledValue === '' ? '9876' : ''; }}>
                切换 PinCode 值
            </Button>
        </div>

        <Divider>PinCode：format 运行时动态切换（回归防护：Foundation opts 固化会让 format 切换后字符校验永远沿用挂载时刻的旧格式，详见 specs 踩坑 #98/#102）</Divider>

        <div>
            <PinCode
                count={4}
                format={pinCodeDynamicFormat}
                autoFocus={false}
                aria-label="PinCode format 动态切换示例"
            />
            <Button onClick={() => { pinCodeDynamicFormat = pinCodeDynamicFormat === 'number' ? 'mixed' : 'number'; }}>
                切换 PinCode format（当前：{pinCodeDynamicFormat}）
            </Button>
        </div>

        <Divider>Table：基础用法（排序 + 筛选）</Divider>

        <div>
            <Table
                columns={tableBasicColumns}
                dataSource={tableBasicData}
                pagination={false}
                onChange={(info) => { tableChangeLog = `sort=${JSON.stringify(info.sortState)} filter=${JSON.stringify(info.filterState)}`; }}
                aria-label="Table 基础"
            />
            <TypographyText type="secondary" aria-label="Table 变化日志">{tableChangeLog}</TypographyText>
        </div>

        <Divider>Table：行选择（checkbox 多选 + 全选）</Divider>

        <div>
            <Table
                columns={tableBasicColumns}
                dataSource={tableBasicData}
                pagination={false}
                rowSelection={{
                    selectedRowKeys: tableSelectedKeys,
                    onChange: (keys) => { tableSelectedKeys = keys; },
                }}
                aria-label="Table 行选择"
            />
            <TypographyText type="secondary" aria-label="Table 选中日志">{`已选：${tableSelectedKeys.join(',')}`}</TypographyText>
        </div>

        <Divider>Table：内置分页</Divider>

        <div>
            <Table
                columns={tablePageColumns}
                dataSource={tablePageData}
                pagination={{ pageSize: 5 }}
                aria-label="Table 分页"
            />
        </div>

        <Divider>Table：树形数据（父子级联选择）</Divider>

        <div>
            <Table
                columns={tableTreeColumns}
                dataSource={tableTreeData}
                pagination={false}
                rowSelection={{}}
                defaultExpandedRowKeys={['t1']}
                aria-label="Table 树形数据"
            />
        </div>

        <Divider>Table：展开行（expandedRowRender）</Divider>

        <div>
            <Table
                columns={tableExpandColumns}
                dataSource={tableBasicData}
                pagination={false}
                expandedRowRender={(record) => <span>{`${record.name} 的详细信息：城市 ${record.city}，年龄 ${record.age}`}</span>}
                aria-label="Table 展开行"
            />
        </div>

        <Divider>Table：固定列（左右两侧 fixed）</Divider>

        <div style={{ width: '400px' }}>
            <Table
                columns={tableFixedColumns}
                dataSource={tableBasicData}
                pagination={false}
                scroll={{ x: 700 }}
                aria-label="Table 固定列"
            />
        </div>

        <Divider>Table：virtualize（1万行数据 + scroll.y 固定高度虚拟滚动，对齐 Select/Cascader/TreeSelect 已验证的实现模式；叠加行选择验证勾选态不受虚拟化裁剪影响）</Divider>

        <div>
            <Table
                columns={tableBasicColumns}
                dataSource={tableVirtualizeData}
                pagination={false}
                scroll={{ y: 240 }}
                virtualize={{ itemSize: 44 }}
                rowSelection={{
                    selectedRowKeys: tableVirtualizeSelectedKeys,
                    onChange: (keys) => { tableVirtualizeSelectedKeys = keys; },
                }}
                aria-label="Table 虚拟滚动示例"
            />
            <TypographyText type="secondary" aria-label="Table 虚拟滚动选中日志">{`已选：${tableVirtualizeSelectedKeys.length} 条`}</TypographyText>
        </div>

        <Divider>Table：loading / bordered / size</Divider>

        <div>
            <Space vertical style={{ width: '100%' }}>
                <Table columns={tableBasicColumns} dataSource={tableBasicData} pagination={false} loading aria-label="Table loading" />
                <Table columns={tableBasicColumns} dataSource={tableBasicData} pagination={false} bordered size="small" aria-label="Table bordered small" />
            </Space>
        </div>

        <Divider>Table：空数据</Divider>

        <div>
            <Table columns={tableBasicColumns} dataSource={[]} pagination={false} aria-label="Table 空数据" />
        </div>

        <Divider>Form：基本表单 + 校验规则 + formApi</Divider>

        <div style={{ width: '360px' }}>
            <Form
                initValues={{ username: '', age: undefined, businessLine: undefined, agree: false }}
                getFormApi={(api) => { formApiRef = api; }}
                onSubmit={(values) => { formSubmitResult = `提交成功：${JSON.stringify(values)}`; }}
                onSubmitFail={(errors) => { formSubmitResult = `提交失败：${JSON.stringify(errors)}`; }}
            >
                <Field
                    field="username"
                    label="用户名"
                    rules={[
                        { required: true, message: '用户名不能为空' },
                        {
                            validator: (value) =>
                                new Promise<string | undefined>((resolve) => {
                                    setTimeout(() => resolve(value === 'admin' ? '用户名已被占用' : undefined), 600);
                                }),
                        },
                    ]}
                    Comp={FormUsernameInput}
                />
                <Field
                    field="age"
                    label="年龄"
                    rules={[{ required: true, message: '年龄不能为空' }, { min: 18, message: '未满 18 岁' }]}
                    Comp={FormAgeInput}
                />
                <Field
                    field="businessLine"
                    label="业务线"
                    rules={[{ required: true, message: '请选择业务线' }]}
                    Comp={FormBusinessLineSelect}
                />
                <Field
                    field="agree"
                    noLabel
                    rules={[{ validator: (value) => (value ? undefined : '请先同意用户协议') }]}
                    Comp={FormAgreeCheckbox}
                />
                <Space>
                    <Button htmlType="submit">提交</Button>
                    <Button htmlType="reset">重置</Button>
                    <Button onClick={() => formApiRef?.setValue('username', '预填用户名')}>外部设置用户名</Button>
                </Space>
            </Form>
            @if (formSubmitResult) {
                <div style={{ marginTop: '12px' }}>{formSubmitResult}</div>
            }
        </div>

        <Divider>Form：字段联动（Semi 无专门联动 API，监听 onValueChange + formApi.setValue 驱动关联字段）</Divider>

        <div style={{ width: '360px' }}>
            <Form
                initValues={{ sex: undefined, note: '' }}
                getFormApi={(api) => { linkageFormApiRef = api; }}
                onValueChange={handleLinkageValueChange}
            >
                <Field field="sex" label="性别" Comp={FormGenderSelect} />
                <Field field="note" label="备注" Comp={FormNoteInput} />
            </Form>
        </div>

        <Divider>ConfigProvider：切换 locale 后文案实时更新（不重新挂载）</Divider>

        <ConfigProvider locale={localeIsEnglish ? enUS : zhCN}>
            <div style={{ width: '360px' }}>
                <Space style={{ marginBottom: '12px' }}>
                    <Button onClick={() => { localeIsEnglish = !localeIsEnglish; }}>
                        {localeIsEnglish ? 'Switch to 中文' : '切换到 English'}
                    </Button>
                </Space>
                <Form
                    initValues={{ localeUsername: '' }}
                    getFormApi={(api) => { localeFormApiRef = api; }}
                >
                    <Field
                        field="localeUsername"
                        label="Username / 用户名"
                        rules={[{ required: true }]}
                        Comp={FormUsernameInput}
                    />
                </Form>
                <div style={{ width: '200px', marginTop: '12px' }}>
                    <Input showClear defaultValue="lotus" aria-label="ConfigProvider Input 示例" />
                </div>
                <div style={{ width: '240px', marginTop: '12px' }}>
                    <DatePicker aria-label="ConfigProvider DatePicker 示例" />
                </div>
                <div style={{ width: '160px', marginTop: '12px' }}>
                    <TimePicker use12Hours aria-label="ConfigProvider TimePicker 示例" />
                </div>
                <div style={{ width: '320px', marginTop: '12px' }}>
                    <Calendar mode="week" height={200} aria-label="ConfigProvider Calendar 示例" />
                </div>
            </div>
        </ConfigProvider>

        <Divider>ConfigProvider：mode 切换暗色主题（写入 document.documentElement 的 data-theme，全局生效，对齐 Semi 暗色模式的全局语义——但 Semi 的 ConfigProvider 本身并不承载主题能力，这是 lotus 自己 Phase 5 spec 承诺的能力）</Divider>

        <ConfigProvider mode={configProviderThemeMode}>
            <div style={{ padding: '16px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
                <Space style={{ marginBottom: '12px' }}>
                    <Button onClick={() => { configProviderThemeMode = configProviderThemeMode === 'dark' ? 'light' : 'dark'; }}>
                        {configProviderThemeMode === 'dark' ? '切换到 light' : '切换到 dark'}
                    </Button>
                </Space>
                <Space>
                    <Button theme="solid" type="primary">Button</Button>
                    <Input style={{ width: '160px' }} defaultValue="Input" aria-label="ConfigProvider mode 示例 Input" />
                    <Select
                        style={{ width: '160px' }}
                        optionList={businessLineOptions}
                        placeholder="Select"
                        aria-label="ConfigProvider mode 示例 Select"
                    />
                    <Button onClick={() => { configProviderModalVisible = true; }}>打开 mode 示例 Modal</Button>
                </Space>
                <Modal
                    visible={configProviderModalVisible}
                    title="mode 示例 Modal"
                    onOk={() => { configProviderModalVisible = false; }}
                    onCancel={() => { configProviderModalVisible = false; }}
                    aria-label="ConfigProvider mode 示例 Modal"
                >
                    这个 Modal 也会跟随 mode 切换
                </Modal>
                <div style={{ marginTop: '12px' }}>
                    <Table
                        dataSource={[{ key: '1', name: '张三', age: 28 }]}
                        columns={[
                            { title: '姓名', key: 'name', dataIndex: 'name' },
                            { title: '年龄', key: 'age', dataIndex: 'age' },
                        ]}
                        aria-label="ConfigProvider mode 示例 Table"
                    />
                </div>
            </div>
        </ConfigProvider>

        <Divider>ConfigProvider：direction 切换 RTL（写入原生 dir 属性到 document.documentElement，Tag/Slider 等组件的 CSS 逻辑属性与 JS 拖拽方向随之镜像）</Divider>

        <ConfigProvider direction={configProviderDirection}>
            <div style={{ padding: '16px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
                <Space style={{ marginBottom: '12px' }}>
                    <Button onClick={() => { configProviderDirection = configProviderDirection === 'rtl' ? 'ltr' : 'rtl'; }}>
                        {configProviderDirection === 'rtl' ? '切换到 ltr' : '切换到 rtl'}
                    </Button>
                    <Button onClick={() => { rtlSidebarVisible = true; }}>打开 RTL 示例 Sidebar</Button>
                </Space>
                <div style={{ marginBottom: '12px' }}>
                    <Tag closable aria-label="ConfigProvider direction 示例 Tag">RTL 示例标签</Tag>
                </div>
                <div style={{ width: '320px' }}>
                    <Slider defaultValue={30} aria-label="ConfigProvider direction 示例 Slider" />
                </div>
                <div style={{ marginTop: '12px' }}>
                    <Pagination total={95} defaultCurrentPage={1} aria-label="ConfigProvider direction 示例 Pagination" />
                </div>
                <div style={{ marginTop: '12px', width: '280px' }}>
                    <DatePicker aria-label="ConfigProvider direction 示例 DatePicker" />
                </div>
                <div style={{ marginTop: '12px', width: '400px', height: '160px' }}>
                    <Carousel
                        items={[
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-primary-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>RTL 1</TypographyText></div>,
                            <div style={{ width: '100%', height: '100%', background: 'var(--lotus-color-success-light-default)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TypographyText>RTL 2</TypographyText></div>,
                        ]}
                        autoPlay={false}
                        aria-label="ConfigProvider direction 示例 Carousel"
                    />
                </div>
                <div style={{ marginTop: '12px', width: '400px' }}>
                    <AudioPlayer
                        audioUrl={[
                            { src: '/demo-track-1.mp3', title: 'RTL 曲目一' },
                            { src: '/demo-track-2.mp3', title: 'RTL 曲目二' },
                        ]}
                        aria-label="ConfigProvider direction 示例 AudioPlayer"
                    />
                </div>
                <Sidebar
                    visible={rtlSidebarVisible}
                    title="RTL 示例 Sidebar"
                    mode={rtlSidebarMode}
                    renderMainContent={() => (
                        <div style={{ padding: '12px' }}>
                            <Button onClick={() => { rtlSidebarMode = 'code'; }}>进入 RTL 详情视图</Button>
                            <div style={{ marginTop: '8px' }}>RTL 模式下应贴视口左侧，resize 手柄在其右边缘。</div>
                        </div>
                    )}
                    renderDetailContent={() => <div style={{ padding: '12px' }}>RTL 详情视图：返回箭头应指向右侧。</div>}
                    onBackWard={() => { rtlSidebarMode = 'main'; }}
                    onCancel={() => { rtlSidebarVisible = false; rtlSidebarMode = 'main'; }}
                    resizable
                    aria-label="ConfigProvider direction 示例 Sidebar"
                />
            </div>
        </ConfigProvider>

        <Divider>CodeHighlight：代码高亮</Divider>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', maxWidth: '640px' }}>
            <CodeHighlight
                class="demo-code-highlight-ts"
                language="typescript"
                code={`function greet(name: string): string {\n  return \`Hello, \${name}!\`;\n}\n\nconsole.log(greet('lotus'));`}
            />
            <CodeHighlight
                class="demo-code-highlight-css"
                language="css"
                lineNumber={false}
                code={`.lotus-button {\n  border-radius: 4px;\n  background: var(--lotus-color-primary);\n}`}
            />
            <CodeHighlight
                class="demo-code-highlight-json"
                language="json"
                defaultTheme={false}
                code={`{\n  "name": "lotus",\n  "version": "0.0.0"\n}`}
            />
        </div>

        <Divider>MarkdownRender：Markdown 渲染</Divider>

        <div style={{ maxWidth: '640px' }}>
            <MarkdownRender
                class="demo-markdown-render"
                raw={`# 标题一\n\n段落文本，包含 **加粗** 和 *斜体*，以及 [链接](https://example.com)。\n\n- 列表项一\n- 列表项二\n\n| 姓名 | 年龄 |\n| --- | --- |\n| 张三 | 20 |\n| 李四 | 25 |\n\n\`\`\`ts\nfunction greet(name: string): string {\n  return \`Hello, \${name}!\`;\n}\n\`\`\`\n\n行内代码 \`const a = 1\` 示例。\n\n<script>alert('xss')<\/script>\n\n> 引用文本示例。\n`}
            />
        </div>

        <Divider>JsonViewer：JSON 查看器</Divider>

        <div style={{ display: 'flex', gap: '24px', flexWrap: 'wrap' }}>
            <div style={{ width: '360px' }}>
                <JsonViewer
                    class="demo-json-viewer-default"
                    value={{
                        name: 'lotus',
                        version: '0.0.0',
                        private: true,
                        keywords: ['ripple', 'tsrx', 'ui'],
                        author: { name: '张三', age: 20 },
                        homepage: null,
                    }}
                />
            </div>
            <div style={{ width: '360px' }}>
                <JsonViewer
                    class="demo-json-viewer-expanded"
                    defaultExpandDepth={Infinity}
                    showCopy={false}
                    value={{ a: { b: { c: [1, 2, 3] } } }}
                />
            </div>
        </div>

        <Divider>Chat：聊天组件（基础版）</Divider>

        <div class="demo-chat" style={{ width: '480px', height: '420px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
            <Chat
                chats={chatMessages}
                roleConfig={{
                    user: { name: '我' },
                    assistant: { name: 'lotus 助手' },
                }}
                hints={['介绍一下组件库', '如何开始使用']}
                onChatsChange={(next) => { chatMessages = next; }}
                onMessageSend={(content) => console.log('chat send:', content)}
            />
        </div>

        <Divider>AudioPlayer：音频播放器</Divider>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div class="demo-audio-player-single" style={{ width: '360px' }}>
                <AudioPlayer audioUrl="/demo-track-1.mp3" />
            </div>
            <div class="demo-audio-player-playlist" style={{ width: '360px' }}>
                <AudioPlayer
                    theme="light"
                    audioUrl={[
                        { src: '/demo-track-1.mp3', title: '演示曲目一' },
                        { src: '/demo-track-2.mp3', title: '演示曲目二' },
                    ]}
                />
            </div>
        </div>

        <Divider>VideoPlayer：视频播放器</Divider>

        <div style={{ marginBottom: '8px' }}>
            <Button onClick={() => { videoPlayerMounted = !videoPlayerMounted; }}>
                {videoPlayerMounted ? '卸载 VideoPlayer（验证定时器/监听器清理）' : '重新挂载 VideoPlayer'}
            </Button>
        </div>
        @if (videoPlayerMounted) {
            <div class="demo-video-player" style={{ width: '480px' }}>
                <VideoPlayer src="/demo-video.mp4" width="100%" height="270px" />
            </div>
        }

        <Divider>Lottie：动画</Divider>

        <div class="demo-lottie-wrap" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            @if (lottieMounted) {
                <div class="demo-lottie" style={{ width: '160px', height: '160px', border: '1px solid var(--lotus-color-border)' }}>
                    <Lottie
                        params={{ path: '/demo-lottie.json' }}
                        width="160px"
                        height="160px"
                        getAnimationInstance={(instance) => { lottieInstance = instance; }}
                    />
                </div>
            }
            <Space>
                <Button onClick={() => lottieInstance?.play()}>播放</Button>
                <Button onClick={() => lottieInstance?.pause()}>暂停</Button>
                <Button onClick={() => lottieInstance?.stop()}>停止</Button>
                <Button onClick={() => lottieInstance?.setSpeed(2)}>2 倍速</Button>
                <Button onClick={() => { lottieMounted = !lottieMounted; }}>
                    {lottieMounted ? '卸载 Lottie（验证 destroy 清理）' : '重新挂载 Lottie'}
                </Button>
            </Space>
        </div>

        <Divider>DragMove：拖拽移动</Divider>

        <div class="demo-drag-move-constrainer" style={{ position: 'relative', width: '400px', height: '240px', border: '1px solid var(--lotus-color-border)', overflow: 'hidden' }}>
            <DragMove class="demo-drag-move-target" constrainer="parent">
                <div style={{
                    width: '80px',
                    height: '80px',
                    background: 'var(--lotus-color-primary)',
                    color: '#fff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: 'var(--lotus-border-radius-medium)',
                    userSelect: 'none',
                }}>
                    拖我
                </div>
            </DragMove>
        </div>

        <Divider>HotKeys：快捷键</Divider>

        <div class="demo-hotkeys" style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <span>按下</span>
            <HotKeys
                hotKeys={['control', 's']}
                preventDefault={true}
                onHotKey={() => { hotKeyTriggerCount = hotKeyTriggerCount + 1; }}
            />
            <span class="demo-hotkeys-count">触发次数：{hotKeyTriggerCount}</span>
        </div>

        <Divider>HotKeys：onClick 可点击提示徽标（回归防护：键盘用户应能用 Enter/Space 等效触发点击，Class C 补齐键盘无障碍）</Divider>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <HotKeys
                hotKeys={['control', 'k']}
                aria-label="HotKeys 可点击示例"
                onClick={() => { hotKeyClickLog = '点击生效'; }}
            />
            <TypographyText type="secondary" aria-label="HotKeys 点击日志">{hotKeyClickLog}</TypographyText>
        </div>

        <Divider>Sidebar：AI 侧边信息栏</Divider>

        <div class="demo-sidebar">
            <Space>
                <Button onClick={() => { sidebarMode = 'main'; sidebarVisible = true; }}>打开主视图</Button>
                <Button onClick={() => { sidebarMode = 'code'; sidebarVisible = true; }}>打开代码详情</Button>
                <Button onClick={() => { sidebarMode = 'file'; sidebarVisible = true; }}>打开文件详情</Button>
            </Space>
            <div class="demo-sidebar-backward-log">{sidebarBackWardLog}</div>

            <Sidebar
                visible={sidebarVisible}
                mode={sidebarMode}
                title="AI 助手"
                detailContent={sidebarMode === 'code' ? sidebarCodeDetail : sidebarMode === 'file' ? sidebarFileDetail : undefined}
                options={[
                    { key: 'mcp', name: 'MCP 工具配置' },
                    { key: 'annotation', name: '引用溯源' },
                ]}
                renderMainContent={() => (
                    <div class="demo-sidebar-main">
                        <SidebarMCPConfigure
                            options={[
                                { value: 'web-search', label: 'Web Search', desc: '联网搜索工具', active: true, disabled: true, configure: true } as SidebarMCPOption,
                                { value: 'calculator', label: 'Calculator', desc: '数值计算工具', active: false },
                            ]}
                            customOptions={[{ value: 'my-tool', label: '我的自定义工具', active: false, configure: true } as SidebarMCPOption]}
                        />
                        <SidebarAnnotation
                            info={[
                                {
                                    key: 'group-1',
                                    header: '参考资料',
                                    annotations: [
                                        { type: 'text', title: 'lotus 组件库文档', detail: '对齐 Semi Design 的 tsrx 组件库', siteName: 'lotus docs', order: 1 },
                                    ],
                                } as SidebarAnnotationGroup,
                            ]}
                        />
                    </div>
                )}
                onCancel={() => { sidebarVisible = false; }}
                onBackWard={() => {
                    sidebarBackWardLog = `返回触发：${sidebarMode}`;
                    sidebarMode = 'main';
                }}
            />
        </div>

        <Divider>AiChatDialogue：AI 对话</Divider>

        <div class="demo-ai-chat-dialogue" style={{ height: '360px', border: '1px solid var(--lotus-color-border)', borderRadius: '8px' }}>
            <AiChatDialogue
                chats={aiDialogueMessages}
                roleConfig={{ user: { name: '我' }, assistant: { name: 'Lotus AI' } }}
                hints={['介绍一下 lotus 组件库', '帮我写一段 TypeScript 代码']}
                showReset={true}
                onChatsChange={(next: AiDialogueMessage[]) => { aiDialogueMessages = next; }}
                onMessageGoodFeedback={() => console.log('good feedback')}
                onMessageBadFeedback={() => console.log('bad feedback')}
                getAiChatDialogueApi={(api: AiChatDialogueApi) => { aiDialogueApi = api; }}
            />
        </div>
        <div class="demo-ai-chat-dialogue-controls" style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
            <Button
                onClick={() => {
                    const chunks = [
                        { type: 'response.output_item.added', sequence_number: 0, output_index: 0, item: { type: 'message' } },
                        { type: 'response.output_text.delta', sequence_number: 1, output_index: 0, content_index: 0, delta: '这是' },
                    ];
                    const result = streamingResponseToMessage(chunks, aiStreamState);
                    aiStreamState = result?.nextState ?? null;
                    const message = result?.message;
                    if (message) {
                        aiDialogueMessages = [...aiDialogueMessages, { ...message, id: 'ai-stream-demo' }];
                        aiStreamingLog = '流式消息已开始';
                    }
                }}
            >模拟流式回复开始</Button>
            <Button
                onClick={() => {
                    const chunks = [{ type: 'response.output_text.delta', sequence_number: 2, output_index: 0, content_index: 0, delta: '流式增量文本，逐步追加。' }];
                    const result = streamingResponseToMessage(chunks, aiStreamState);
                    aiStreamState = result?.nextState ?? null;
                    const message = result?.message;
                    if (message) {
                        aiDialogueMessages = aiDialogueMessages.map((m) => (m.id === 'ai-stream-demo' ? { ...message, id: 'ai-stream-demo' } : m));
                        aiStreamingLog = '流式消息已追加增量';
                    }
                }}
            >追加流式增量</Button>
            <Button
                onClick={() => {
                    const chunks = [{ type: 'response.completed', sequence_number: 3, response: { status: 'completed' } }];
                    const result = streamingResponseToMessage(chunks, aiStreamState);
                    aiStreamState = result?.nextState ?? null;
                    const message = result?.message;
                    if (message) {
                        aiDialogueMessages = aiDialogueMessages.map((m) => (m.id === 'ai-stream-demo' ? { ...message, id: 'ai-stream-demo' } : m));
                        aiStreamingLog = '流式消息已完成（回归防护：aria-live 应从生成期间的 off 恢复为 polite，详见 specs 踩坑记录）';
                    }
                }}
            >标记流式完成</Button>
            <Button onClick={() => aiDialogueApi?.scrollToTop()}>滚动到顶部</Button>
            <Button onClick={() => aiDialogueApi?.scrollToBottom()}>滚动到底部</Button>
            <span class="demo-ai-streaming-log">{aiStreamingLog}</span>
        </div>

        <Divider>AiChatInput：AI 输入框</Divider>

        <div class="demo-ai-chat-input" style={{ maxWidth: '600px' }}>
            <AiChatInput
                placeholder="输入消息，或按 / 触发技能..."
                skillHotKey="/"
                skills={[
                    { value: 'translate', label: '翻译', hasTemplate: true },
                    { value: 'summarize', label: '总结' },
                ]}
                suggestions={['介绍一下 lotus 组件库', '帮我写一段 TypeScript 代码']}
                onSuggestClick={(s) => aiInputApi?.setContent(typeof s === 'string' ? s : s.content)}
                references={aiInputReferences}
                onReferenceDelete={(r) => { aiInputReferences = aiInputReferences.filter((x) => x.id !== r.id); }}
                showTemplateButton={true}
                renderTemplate={(skill, onTemplateClick) => (
                    <div style={{ padding: '8px' }}>
                        <div style={{ marginBottom: '4px', fontSize: '12px', color: 'var(--lotus-color-text-2)' }}>{skill.label} 模版</div>
                        <div
                            style={{ padding: '4px 8px', cursor: 'pointer', fontSize: '13px' }}
                            onClick={() => onTemplateClick('帮我把这段翻译成英文：')}
                        >翻译模版</div>
                    </div>
                )}
                mcpOptions={[{ value: 'search', label: 'Web Search', active: true }, { value: 'calc', label: 'Calculator', active: false }]}
                onMcpConfigureClick={() => console.log('mcp configure clicked')}
                uploadProps={{ action: '/api/upload' }}
                generating={aiInputGenerating}
                onStopGenerate={() => { aiInputGenerating = false; }}
                onMessageSend={(message: AiInputMessageContent) => {
                    aiInputSentLog = JSON.stringify(message);
                    aiInputGenerating = true;
                }}
                getAiChatInputApi={(api: AiChatInputApi) => { aiInputApi = api; }}
            />
            <div class="demo-ai-input-sent-log" style={{ marginTop: '8px', fontSize: '12px', color: 'var(--lotus-color-text-2)', wordBreak: 'break-all' }}>{aiInputSentLog}</div>
        </div>

        <Divider>Chart：图表（柱状/折线/面积/饼图/漏斗/雷达）</Divider>

        <div class="demo-chart-grid" style={{ display: 'grid', gridTemplateColumns: 'repeat(3, minmax(0, 1fr))', gap: '16px' }}>
            <div class="demo-chart-bar" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="bar"
                    data={[{ id: 'bar', values: chartCategoryData }]}
                    spec={{ xField: 'category', yField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 柱状图示例"
                />
            </div>
            <div class="demo-chart-line" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="line"
                    data={[{ id: 'line', values: chartCategoryData }]}
                    spec={{ xField: 'category', yField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 折线图示例"
                />
            </div>
            <div class="demo-chart-area" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="area"
                    data={[{ id: 'area', values: chartCategoryData }]}
                    spec={{ xField: 'category', yField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 面积图示例"
                />
            </div>
            <div class="demo-chart-pie" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="pie"
                    data={[{ id: 'pie', values: chartCategoryData }]}
                    spec={{ categoryField: 'category', valueField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 饼图示例"
                />
            </div>
            <div class="demo-chart-funnel" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="funnel"
                    data={[{ id: 'funnel', values: chartFunnelData }]}
                    spec={{ categoryField: 'category', valueField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 漏斗图示例"
                />
            </div>
            <div class="demo-chart-radar" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="radar"
                    data={[{ id: 'radar', values: chartRadarData }]}
                    spec={{ categoryField: 'category', valueField: 'value', seriesField: 'series' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 雷达图示例"
                />
            </div>
        </div>

        <Divider>Chart：点击/悬浮数据点触发事件回调</Divider>

        <div class="demo-chart-event" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
            <Chart
                type="bar"
                data={[{ id: 'bar', values: chartCategoryData }]}
                spec={{ xField: 'category', yField: 'value' }}
                width="100%"
                height="100%"
                aria-label="Chart 事件回调示例"
                onClick={({ datum }) => { chartEventLog = `点击：${JSON.stringify(datum)}`; }}
                onHover={({ datum }) => { chartEventLog = `悬浮：${JSON.stringify(datum)}`; }}
            />
        </div>
        <TypographyText type="secondary" aria-label="Chart 事件日志">{chartEventLog}</TypographyText>

        <Divider>Chart：导出图片按钮</Divider>

        <div class="demo-chart-export" style={{ width: '100%', height: '260px', border: '1px solid var(--lotus-color-border)' }}>
            <Chart
                type="line"
                data={[{ id: 'line', values: chartCategoryData }]}
                spec={{ xField: 'category', yField: 'value' }}
                width="100%"
                height="100%"
                aria-label="Chart 导出图片示例"
                showExportButton
                exportFileName="lotus-chart-demo"
                onExport={() => { chartExportLog = '已触发导出'; }}
            />
        </div>
        <TypographyText type="secondary" aria-label="Chart 导出日志">{chartExportLog}</TypographyText>

        <Divider>Chart：loading / 空数据态</Divider>

        <Space>
            <div class="demo-chart-loading" style={{ width: '260px', height: '200px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="bar"
                    data={[{ id: 'bar', values: chartCategoryData }]}
                    spec={{ xField: 'category', yField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 加载中示例"
                    loading={chartLoading}
                />
            </div>
            <div class="demo-chart-empty-demo" style={{ width: '260px', height: '200px', border: '1px solid var(--lotus-color-border)' }}>
                <Chart
                    type="bar"
                    data={[{ id: 'bar', values: [] }]}
                    spec={{ xField: 'category', yField: 'value' }}
                    width="100%"
                    height="100%"
                    aria-label="Chart 空数据示例"
                />
            </div>
            <Button onClick={() => { chartLoading = !chartLoading; }}>切换 Chart 加载态</Button>
        </Space>
    </div>
    <BackTop visibilityHeight={200} aria-label="回到顶部（playground 演示）" onClick={() => console.log('back-top clicked')} />
    </>
}

const verticalNavItems: NavItemInput[] = [
    { itemKey: 'home', text: '首页', icon: <span>🏠</span> },
    {
        itemKey: 'components',
        text: '组件',
        icon: <span>🧩</span>,
        items: [
            { itemKey: 'basic', text: '基础组件' },
            {
                itemKey: 'nested',
                text: '嵌套子导航',
                items: [
                    { itemKey: 'nested-a', text: '子项 A' },
                    { itemKey: 'nested-b', text: '子项 B' },
                ],
            },
        ],
    },
    { itemKey: 'disabled-item', text: '禁用项', disabled: true },
    { itemKey: 'about', text: '关于', link: 'https://example.com' },
];
