import { track } from 'ripple';
import { ScrollList, ScrollItem, TypographyText } from '@lotus/ripple';

export function WheelCycledScrollListDemo() @{
    let &[hourIndex] = track<number>(8);
    let &[minuteIndex] = track<number>(30);

    <div style={{ width: '200px' }}>
        <ScrollList
            bodyHeight={180}
            header={
                <div style={{ display: 'flex', width: '100%' }}>
                    <div style={{ flex: 1, textAlign: 'center', padding: '4px 0' }}><TypographyText type="tertiary">时</TypographyText></div>
                    <div style={{ flex: 1, textAlign: 'center', padding: '4px 0' }}><TypographyText type="tertiary">分</TypographyText></div>
                </div>
            }
        >
            <ScrollItem
                list={Array.from({ length: 24 }, (_, i) => ({ value: i, text: String(i).padStart(2, '0') }))}
                cycled
                selectedIndex={hourIndex}
                onSelect={(data) => { hourIndex = data.index; }}
                aria-label="小时选择"
            />
            <ScrollItem
                list={Array.from({ length: 60 }, (_, i) => ({ value: i, text: String(i).padStart(2, '0') }))}
                selectedIndex={minuteIndex}
                onSelect={(data) => { minuteIndex = data.index; }}
                aria-label="分钟选择"
            />
        </ScrollList>
        <div style={{ marginTop: '8px' }}>
            <TypographyText type="tertiary">{`已选：${String(hourIndex).padStart(2, '0')}:${String(minuteIndex).padStart(2, '0')}`}</TypographyText>
        </div>
    </div>
}
