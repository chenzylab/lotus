import { Badge, Avatar } from '@lotus/ripple';

export function BasicBadgeDemo() @{
    <div style={{ display: 'flex', gap: '24px', alignItems: 'center' }}>
        <Badge count={5}>
            <Avatar color="blue">U</Avatar>
        </Badge>
        <Badge count={100} overflowCount={99}>
            <Avatar color="green">U</Avatar>
        </Badge>
        <Badge dot>
            <Avatar color="orange">U</Avatar>
        </Badge>
    </div>
}
