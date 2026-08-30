import { track } from 'ripple';
import { ConfigProvider, DatePicker, Button, zhCN, enUS } from '@lotus/ripple';

export function LocaleConfigProviderDemo() @{
    let &[isEnglish] = track<boolean>(false);

    <ConfigProvider locale={isEnglish ? enUS : zhCN}>
        <div style={{ width: '280px' }}>
            <Button onClick={() => { isEnglish = !isEnglish; }}>
                {isEnglish ? 'Switch to 中文' : '切换到 English'}
            </Button>
            <div style={{ marginTop: '12px' }}>
                <DatePicker aria-label="ConfigProvider locale 示例 DatePicker" />
            </div>
        </div>
    </ConfigProvider>
}
