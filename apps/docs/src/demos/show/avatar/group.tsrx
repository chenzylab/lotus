import { AvatarGroup } from '@lotus/ripple';
import type { AvatarGroupItem } from '@lotus/ripple';

const ITEMS: AvatarGroupItem[] = [
    { key: '1', color: 'red', children: '安' },
    { key: '2', color: 'orange', children: '柏' },
    { key: '3', color: 'green', children: '晨' },
    { key: '4', color: 'blue', children: '东' },
    { key: '5', color: 'purple', children: '峰' },
];

export function AvatarGroupDemo() {
    return <AvatarGroup items={ITEMS} maxCount={3} size="default" />;
}
