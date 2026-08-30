import { Empty, Button } from '@lotus/ripple';
import { IllustrationNoContent } from '@lotus/illustrations';

export function BasicEmptyDemo() @{
    <Empty
        image={<IllustrationNoContent style={{ width: '150px', height: '150px' }} />}
        title="暂无数据"
        description="当前列表没有任何内容"
        aria-label="基础 Empty"
    >
        <Button type="primary" theme="borderless">立即创建</Button>
    </Empty>
}
