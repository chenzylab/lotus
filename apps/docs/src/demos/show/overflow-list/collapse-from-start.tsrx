import { OverflowList, Tag } from '@lotus/ripple';

export function CollapseFromStartOverflowListDemo() @{
    <div style={{ width: '260px', border: '1px dashed var(--lotus-color-border)', padding: '8px' }}>
        <OverflowList
            items={['标签一', '标签二', '标签三', '标签四', '标签五', '标签六']}
            collapseFrom="start"
            visibleItemRenderer={(item) => <Tag style={{ marginRight: '4px' }}>{item}</Tag>}
            overflowRenderer={(overflow) => <Tag color="grey">{`+${overflow.length}`}</Tag>}
            aria-label="collapseFrom start OverflowList"
        />
    </div>
}
