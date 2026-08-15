import { Skeleton, SkeletonParagraph, SkeletonButton, Button } from '@lotus/ripple';

export function CombineCenteredSkeletonDemo() {
    const wrapperStyle = {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '300px',
        marginBottom: '10px',
    };

    const placeholder = <div style={wrapperStyle}>
        <SkeletonParagraph style={wrapperStyle} rows={3} />
        <SkeletonButton />
    </div>;

    return <Skeleton placeholder={placeholder} loading={true} style={{ textAlign: 'center' }}>
        <div style={{ textAlign: 'center' }}>
            <p>Hi, Lotus dance dance.</p>
            <p>Hi, Lotus dance dance.</p>
            <Button>Button</Button>
        </div>
    </Skeleton>;
}
