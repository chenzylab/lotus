import { track } from 'ripple';
import { Card, CardMeta, Avatar, Button } from '@lotus/ripple';

export function MetaAndLoadingCardDemo() @{
    let &[loading] = track<boolean>(true);

    <div style={{ width: '320px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Card loading={loading} shadows="hover">
            <CardMeta
                avatar={<Avatar color="blue">U</Avatar>}
                title="Lotus UI"
                description="精心打磨每一个组件的用户体验"
            />
        </Card>
        <Button onClick={() => { loading = !loading; }}>切换 loading</Button>
    </div>
}
