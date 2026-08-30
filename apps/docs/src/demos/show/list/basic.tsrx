import { List, ListItem } from '@lotus/ripple';

export function BasicListDemo() @{
    <List bordered dataSource={['第一项', '第二项', '第三项']} renderItem={(item: string) => <ListItem main={item} />} aria-label="基础 List" />
}
