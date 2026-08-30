import { Calendar, TypographyText } from '@lotus/ripple';

export function MonthCalendarDemo() @{
    <div style={{ width: '100%' }}>
        <Calendar
            mode="month"
            displayValue={new Date(2026, 0, 12)}
            height={480}
            markWeekend
            events={[
                { key: 'm1', start: new Date(2026, 0, 5), end: new Date(2026, 0, 8), children: <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>项目排期</TypographyText> },
                { key: 'm2', start: new Date(2026, 0, 20), end: new Date(2026, 0, 20), children: <TypographyText style={{ color: 'inherit', fontSize: '12px' }}>单日里程碑</TypographyText> },
            ]}
            aria-label="month 模式 Calendar"
        />
    </div>
}
