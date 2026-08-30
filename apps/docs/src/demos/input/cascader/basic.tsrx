import { track } from 'ripple';
import { Cascader, TypographyText, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
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
        ],
    },
];

export function CascaderBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', width: '280px' }}>
        <Cascader
            treeData={REGION_DATA}
            placeholder="请选择省市区"
            onChange={(v) => { log = `onChange: ${JSON.stringify(v)}`; }}
            aria-label="单选级联选择"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
