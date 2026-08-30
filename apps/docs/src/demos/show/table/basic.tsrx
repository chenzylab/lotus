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

const data: Person[] = [
    { key: '1', name: '张三', age: 32, city: '北京' },
    { key: '2', name: '李四', age: 28, city: '上海' },
    { key: '3', name: '王五', age: 45, city: '深圳' },
    { key: '4', name: '赵六', age: 24, city: '北京' },
    { key: '5', name: '孙七', age: 36, city: '上海' },
];

export function BasicTableDemo() @{
    let &[changeLog] = track<string>('');

    <div>
        <Table
            columns={columns}
            dataSource={data}
            pagination={false}
            onChange={(info) => { changeLog = `sort=${JSON.stringify(info.sortState)} filter=${JSON.stringify(info.filterState)}`; }}
            aria-label="Table 基础"
        />
        <TypographyText type="secondary">{changeLog}</TypographyText>
    </div>
}
