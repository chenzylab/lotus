import { Descriptions } from '@lotus/ripple';

export function HorizontalDescriptionsDemo() @{
    <Descriptions
        layout="horizontal"
        column={2}
        data={[
            { key: '姓名', value: '张三' },
            { key: '部门', value: '前端组' },
            { key: '职位', value: '高级工程师', span: 2 },
        ]}
        aria-label="horizontal 布局 Descriptions"
    />
}
