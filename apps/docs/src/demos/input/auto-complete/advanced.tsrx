import { track } from 'ripple';
import { AutoComplete, Button, TypographyText } from '@lotus/ripple';

const ALL_CITIES = ['北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '武汉'];

export function AutoCompleteAdvancedDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <div style={{ width: '160px' }}>
            <AutoComplete
                data={ALL_CITIES}
                dropdownMatchSelectWidth
                renderSelectedItem={(option) => `已选：${option.label}`}
                onSelectWithObject
                onSelect={(option) => { log = `onSelect: ${JSON.stringify(option)}`; }}
                placeholder="窄输入框，面板等宽"
                aria-label="AutoComplete renderSelectedItem 示例"
            />
        </div>
        <div style={{ width: '280px' }}>
            <AutoComplete
                data={ALL_CITIES}
                triggerRender={({ inputValue, open }) => (
                    <Button aria-label="AutoComplete triggerRender 示例">
                        {(inputValue as string) || '点击选择城市'}（{open ? '展开' : '收起'}）
                    </Button>
                )}
                onSelect={(v) => { log = `triggerRender onSelect: ${JSON.stringify(v)}`; }}
            />
        </div>
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
