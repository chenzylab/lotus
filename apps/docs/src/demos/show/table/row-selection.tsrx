import { track } from 'ripple';
import { Table, TypographyText, type ColumnDef } from '@lotus/ripple';

interface Person {
    key: string;
    name: string;
    age: number;
    city: string;
}

const columns: ColumnDef<Person>[] = [
    { title: '姓名', dataIndex: 'name', key: 'name' },
    { title: '年龄', dataIndex: 'age', key: 'age' },
    { title: '城市', dataIndex: 'city', key: 'city' },
];

const data: Person[] = [
    { key: '1', name: '张三', age: 32, city: '北京' },
    { key: '2', name: '李四', age: 28, city: '上海' },
    { key: '3', name: '王五', age: 45, city: '深圳' },
];

export function RowSelectionTableDemo() @{
    let &[selectedKeys] = track<Array<string | number>>([]);

    <div>
        <Table
            columns={columns}
            dataSource={data}
            pagination={false}
            rowSelection={{
                selectedRowKeys: selectedKeys,
                onChange: (keys) => { selectedKeys = keys; },
            }}
            aria-label="Table 行选择"
        />
        <TypographyText type="secondary">{`已选：${selectedKeys.join(',')}`}</TypographyText>
    </div>
}
