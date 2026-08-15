import { Skeleton, SkeletonAvatar, SkeletonTitle, SkeletonParagraph, Avatar } from '@lotus/ripple';

export function ActiveSkeletonDemo() {
    const wrapperStyle = { display: 'flex', alignItems: 'flex-start' };

    const placeholder = <div style={wrapperStyle}>
        <SkeletonAvatar style={{ marginRight: '12px' }} />
        <div>
            <SkeletonTitle style={{ width: '120px', marginBottom: '12px', marginTop: '12px' }} />
            <SkeletonParagraph style={{ width: '240px' }} rows={3} />
        </div>
    </div>;

    return <Skeleton placeholder={placeholder} loading={true} active>
        <div style={wrapperStyle}>
            <Avatar color="blue" style={{ marginRight: '12px' }}>UI</Avatar>
            <div>
                <h3>Lotus UI</h3>
                <p>Hi, Lotus dance dance.</p>
                <p>Hi, Lotus dance dance.</p>
                <p>Hi, Lotus dance dance.</p>
            </div>
        </div>
    </Skeleton>;
}
