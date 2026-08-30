import { Card, CardGroup } from '@lotus/ripple';

export function GroupCardDemo() @{
    <CardGroup spacing={12}>
        <Card style={{ width: '160px' }}>卡片一</Card>
        <Card style={{ width: '160px' }}>卡片二</Card>
        <Card style={{ width: '160px' }}>卡片三</Card>
    </CardGroup>
}
