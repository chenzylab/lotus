import { Avatar } from '@lotus/ripple';

export function AvatarEventDemo() {
    return <Avatar
        color="pink"
        onClick={() => console.log('avatar clicked')}
        onMouseEnter={() => console.log('avatar mouse enter')}
        onMouseLeave={() => console.log('avatar mouse leave')}
    >
        YJ
    </Avatar>;
}
