import { Calendar, TypographyText } from '@lotus/ripple';

export function WeekCalendarDemo() @{
    <div style={{ width: '100%' }}>
        <Calendar
            mode="week"
            displayValue={new Date(2026, 0, 12)}
            height={400}
            markWeekend
            events={[
                { key: 'e1', start: new Date(2026, 0, 12, 9), end: new Date(2026, 0, 12, 10, 30) },
                { key: 'e2', allDay: true, start: new Date(2026, 0, 15), end: new Date(2026, 0, 16), children: <TypographyText style={{ color: 'inherit' }}>全天活动</TypographyText> },
            ]}
            aria-label="week 模式 Calendar"
        />
    </div>
}
