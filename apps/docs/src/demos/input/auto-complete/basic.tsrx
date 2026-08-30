import { track } from 'ripple';
import { AutoComplete, TypographyText } from '@lotus/ripple';

const ALL_CITIES = ['北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '武汉'];

export function AutoCompleteBasicDemo() @{
    let &[result] = track<string[]>(ALL_CITIES);
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', width: '280px' }}>
        <AutoComplete
            data={result}
            placeholder="输入城市名搜索"
            showClear
            onSearch={(v) => {
                const input = String(v);
                result = input ? ALL_CITIES.filter((c) => c.includes(input)) : ALL_CITIES;
            }}
            onChange={(v) => { log = `选中：${v}`; }}
            aria-label="基础自动完成"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
