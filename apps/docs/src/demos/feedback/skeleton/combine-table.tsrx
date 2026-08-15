import { Skeleton, SkeletonTitle, SkeletonParagraph } from '@lotus/ripple';

/**
 * Semi 官方此处用 `Table` 组件展示表格骨架屏，lotus 尚未实现 Table，
 * 用原生 `<table>` 模拟同样的行列结构与骨架占位效果（Skeleton 本身的用法不受影响）。
 */
export function CombineTableSkeletonDemo() {
    const columns = ['Name', 'Age', 'Address'];
    const rows = [
        { name: 'John Brown', age: 32, address: 'New York No. 1 Lake Park' },
        { name: 'Jim Green', age: 42, address: 'London No. 1 Lake Park' },
        { name: 'Joe Black', age: 32, address: 'Sidney No. 1 Lake Park' },
        { name: 'Disabled User', age: 99, address: 'Sidney No. 1 Lake Park' },
    ];

    const placeholder = <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
            <tr>
                <th style={{ textAlign: 'left', padding: '8px' }}><SkeletonTitle style={{ width: '0', height: '16px' }} /></th>
                <th style={{ textAlign: 'left', padding: '8px' }}><SkeletonTitle style={{ width: '0', height: '16px' }} /></th>
                <th style={{ textAlign: 'left', padding: '8px' }}><SkeletonTitle style={{ width: '0', height: '16px' }} /></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '50px' }} rows={1} /></td>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '100px' }} rows={1} /></td>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '150px' }} rows={1} /></td>
            </tr>
            <tr>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '50px' }} rows={1} /></td>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '100px' }} rows={1} /></td>
                <td style={{ padding: '8px' }}><SkeletonParagraph style={{ width: '150px' }} rows={1} /></td>
            </tr>
        </tbody>
    </table>;

    return <Skeleton placeholder={placeholder} loading={true}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
                <tr>
                    @for (const col of columns; key col) {
                        <th style={{ textAlign: 'left', padding: '8px', borderBottom: '1px solid var(--lotus-color-border)' }}>{col}</th>
                    }
                </tr>
            </thead>
            <tbody>
                @for (const row of rows; key row.name) {
                    <tr>
                        <td style={{ padding: '8px' }}>{row.name}</td>
                        <td style={{ padding: '8px' }}>{row.age}</td>
                        <td style={{ padding: '8px' }}>{row.address}</td>
                    </tr>
                }
            </tbody>
        </table>
    </Skeleton>;
}
