import { Descriptions } from '@lotus/ripple';

export function BasicDescriptionsDemo() @{
    <Descriptions
        data={[
            { key: '姓名', value: '张三' },
            { key: '部门', value: '前端组' },
            { key: '职位', value: '高级工程师' },
        ]}
        aria-label="基础 Descriptions"
    />
}
