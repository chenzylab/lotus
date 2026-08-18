import { track } from 'ripple';
import { Button, ButtonGroup, IconButton, FloatButton, Resizable, Progress, Spin, Banner, Steps, Pagination, Popconfirm, BackTop, Anchor, Toast, Notification, Tree, Badge, Card, CardMeta, CardGroup, Empty, Descriptions, Divider, Space, Row, Col, Switch, Tag, Tabs, Avatar, AvatarGroup, Layout, Header, Content, Footer, Sider, Tooltip, Popover, Breadcrumb, Skeleton, SkeletonAvatar, SkeletonImage, SkeletonTitle, SkeletonButton, SkeletonParagraph, Nav, NavHeader, NavItem, NavSub, NavFooter, Dropdown, DropdownMenu, DropdownItem, DropdownTitle, DropdownDivider, TypographyTitle, TypographyText, TypographyParagraph, Input, TextArea, Checkbox, CheckboxGroup, Radio, RadioGroup, InputNumber, Select, Form, Field, ConfigProvider, zhCN, enUS } from '@lotus/ripple';
import { IllustrationNoContent, IllustrationNotFound, IllustrationNoAccess } from '@lotus/illustrations';
import type { SelectOption, FormApi, FieldRenderProps } from '@lotus/ripple';
import { IconClose, IconPlus, IconSearch, IconSetting, IconTickCircle, IconAiBellLevel3, IconLotusLogo } from '@lotus/icons';
import { IconTag as IconTagLab, IconTable, IconAvatar as IconAvatarLab } from '@lotus/icons-lab';
import type { TagColor, TabItem, AvatarGroupItem, NavItemInput, TreeNodeData } from '@lotus/ripple';

const tagColors: TagColor[] = ['blue', 'red', 'green', 'orange', 'purple', 'cyan', 'grey', 'white'];

const businessLineOptions: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

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

// Field 的 Comp 收到统一的 { value, disabled, onChange, onBlur, 'aria-label' }，
// 由这几个桥接组件把它接到具体输入组件各自的 props 形状上（Input 是
// onChange(value, event)，InputNumber/Select 是 onChange(value)）。
function FormUsernameInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Input
            value={value ?? ''}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请输入用户名"
        />
    );
}

function FormAgeInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <InputNumber
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
    let &[spinSpinning] = track<boolean>(true);
    let &[stepsCurrent] = track<number>(1);
    let &[paginationCurrentPage] = track<number>(3);
    let &[paginationPageSize] = track<number>(10);
    let &[checkboxControlledChecked] = track<boolean>(false);
    let &[checkboxGroupControlledValue] = track<Array<string | number>>(['A']);
    let &[radioControlledChecked] = track<boolean>(false);
    let &[radioGroupControlledValue] = track<string | number>('A');
    let &[inputNumberControlledValue] = track<number>(0);
    let &[selectControlledValue] = track<string>('douyin');
    let formApiRef: FormApi | undefined;
    let &[formSubmitResult] = track<string>('');
    let &[localeIsEnglish] = track<boolean>(false);
    let &[localeFormApiRef] = track<FormApi | undefined>(undefined);

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

        <Divider>FloatButton</Divider>

        {/* FloatButton 默认 position: fixed，演示区用 position: relative 覆盖以便并排展示 */}
        <div style={{ display: 'flex', gap: '16px', position: 'relative', height: '60px' }}>
            <FloatButton icon={<IconSetting />} aria-label="悬浮设置" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('float button clicked')} />
            <FloatButton icon={<IconAiBellLevel3 />} colorful aria-label="AI 悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('float button ai clicked')} />
            <FloatButton icon={<IconSetting />} shape="square" aria-label="方形悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
            <FloatButton icon={<IconSetting />} size="small" aria-label="小号悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
            <FloatButton icon={<IconSetting />} disabled aria-label="禁用悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} onClick={() => console.log('should not fire')} />
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

        <Space vertical align="start">
            <Progress percent={30} showInfo aria-label="line 基础进度条" />
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
            />
            <Button onClick={() => { progressPercent = progressPercent >= 100 ? 0 : progressPercent + 20; }}>切换 Progress 百分比</Button>
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
                    rules={[{ required: true, message: '用户名不能为空' }]}
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
            </div>
        </ConfigProvider>
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
