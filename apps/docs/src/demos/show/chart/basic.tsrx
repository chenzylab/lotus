import { Chart } from '@lotus/ripple';

const categoryData = [
    { category: '一月', value: 38 },
    { category: '二月', value: 52 },
    { category: '三月', value: 61 },
    { category: '四月', value: 45 },
    { category: '五月', value: 70 },
];

export function BasicChartDemo() @{
    <div style={{ width: '100%', height: '280px' }}>
        <Chart
            type="bar"
            data={[{ id: 'bar', values: categoryData }]}
            spec={{ xField: 'category', yField: 'value' }}
            width="100%"
            height="100%"
            aria-label="月度数据柱状图"
        />
    </div>
}
