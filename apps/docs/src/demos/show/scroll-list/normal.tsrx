import { ScrollList, ScrollItem } from '@lotus/ripple';

export function NormalScrollListDemo() @{
    <div style={{ width: '120px' }}>
        <ScrollList bodyHeight={150}>
            <ScrollItem
                list={['苹果', '香蕉', '橙子', '葡萄', '西瓜'].map((v) => ({ value: v, text: v }))}
                mode="normal"
                aria-label="水果选择"
            />
        </ScrollList>
    </div>
}
