import { Skeleton, SkeletonAvatar, SkeletonTitle, Avatar } from '@lotus/ripple';

export function CombineAvatarTitleSkeletonDemo() {
    const placeholder = <div style={{ display: 'flex', alignItems: 'center' }}>
        <SkeletonAvatar style={{ marginRight: '12px' }} />
        <SkeletonTitle style={{ width: '120px' }} />
    </div>;

    return <Skeleton placeholder={placeholder} loading={true}>
        <Avatar color="blue" style={{ marginRight: '12px' }}>UI</Avatar>
        <span>Lotus UI</span>
    </Skeleton>;
}
