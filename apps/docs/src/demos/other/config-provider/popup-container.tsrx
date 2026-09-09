import { track } from 'ripple';
import { ConfigProvider, Select } from '@lotus/ripple';

export function PopupContainerConfigProviderDemo() @{
    let &[containerNode] = track<HTMLDivElement | null>(null);

    <ConfigProvider getPopupContainer={() => containerNode}>
        <div
            ref={containerNode}
            style={{
                position: 'relative',
                padding: '16px',
                border: '1px dashed var(--lotus-color-border)',
                borderRadius: 'var(--lotus-border-radius-medium)',
            }}
        >
            <p style={{ margin: '0 0 12px', color: 'var(--lotus-color-text-secondary)' }}>
                下拉浮层会挂载在这个虚线容器内部（而非默认的 document.body）。
            </p>
            <Select
                aria-label="ConfigProvider getPopupContainer 示例"
                placeholder="点击展开下拉"
                optionList={[
                    { value: 'a', label: '选项 A' },
                    { value: 'b', label: '选项 B' },
                    { value: 'c', label: '选项 C' },
                ]}
            />
        </div>
    </ConfigProvider>
}
