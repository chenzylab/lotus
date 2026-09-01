import { TagInput, Tag } from '@lotus/ripple';

export function RenderTagItemTagInputDemo() @{
    <div style={{ width: '360px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <TagInput
            defaultValue={['custom-a', 'custom-b']}
            renderTagItem={(value, index, onClose) => (
                <Tag color="orange" onClose={onClose} closable>{`★ ${value}`}</Tag>
            )}
            aria-label="TagInput renderTagItem 示例"
        />
        <TagInput
            defaultValue={['这是一个很长很长的标签内容']}
            showContentTooltip={false}
            style={{ width: '200px' }}
            aria-label="TagInput showContentTooltip 关闭示例"
        />
    </div>
}
