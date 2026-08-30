import { AutoComplete } from '@lotus/ripple';

const ALL_CITIES = ['北京', '上海', '广州', '深圳', '杭州'];

export function AutoCompleteActiveFirstDemo() @{
    <div style={{ width: '280px' }}>
        <AutoComplete
            data={ALL_CITIES}
            defaultActiveFirstOption
            placeholder="按方向键/回车试试"
            aria-label="默认高亮第一项"
        />
    </div>
}
