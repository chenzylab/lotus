import { track } from 'ripple';
import { Chart, Button, Space } from '@lotus/ripple';

const categoryData = [
    { category: '一月', value: 38 },
    { category: '二月', value: 52 },
];

export function LoadingEmptyChartDemo() @{
    let &[loading] = track<boolean>(false);
    let &[empty] = track<boolean>(false);

    <Space vertical style={{ width: '100%' }}>
        <Space>
            <Button onClick={() => { loading = !loading; }}>切换 loading</Button>
            <Button onClick={() => { empty = !empty; }}>切换空数据</Button>
        </Space>
        <div style={{ width: '100%', height: '240px' }}>
            <Chart
                type="line"
                data={empty ? [{ id: 'line', values: [] }] : [{ id: 'line', values: categoryData }]}
                spec={{ xField: 'category', yField: 'value' }}
                width="100%"
                height="100%"
                loading={loading}
                aria-label="折线图"
            />
        </div>
    </Space>
}
