import { List, ListItem, Card } from '@lotus/ripple';

export function GridListDemo() @{
    <List
        grid={{ gutter: 12, span: 8 }}
        dataSource={['卡片一', '卡片二', '卡片三']}
        renderItem={(item: string) => <ListItem main={<Card>{item}</Card>} />}
        aria-label="grid 布局 List"
    />
}
