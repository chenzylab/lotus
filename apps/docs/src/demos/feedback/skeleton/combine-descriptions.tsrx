import { Skeleton, SkeletonParagraph, SkeletonTitle } from '@lotus/ripple';

/**
 * Semi 官方此处用 `Descriptions` 组件展示统计数字，lotus 尚未实现 Descriptions，
 * 用等价的原生 HTML 结构模拟同样的视觉效果（Skeleton 本身的用法不受影响）。
 */
export function CombineDescriptionsSkeletonDemo() {
    const placeholder = <div>
        <SkeletonParagraph rows={1} style={{ width: '80px', marginBottom: '10px' }} />
        <SkeletonTitle style={{ width: '120px' }} />
    </div>;

    return <Skeleton placeholder={placeholder} loading={true}>
        <div>
            <div style={{ color: 'var(--lotus-color-text-2)', marginBottom: '4px' }}>实际用户数量</div>
            <div style={{ fontSize: '20px', fontWeight: 'var(--lotus-font-weight-semibold)' }}>1,480,000</div>
        </div>
    </Skeleton>;
}
