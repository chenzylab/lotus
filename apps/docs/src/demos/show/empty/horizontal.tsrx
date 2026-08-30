import { Empty } from '@lotus/ripple';
import { IllustrationNotFound } from '@lotus/illustrations';

export function HorizontalEmptyDemo() @{
    <Empty
        layout="horizontal"
        image={<IllustrationNotFound style={{ width: '80px', height: '80px' }} />}
        title="页面走丢了"
        description="请检查地址是否正确"
        aria-label="horizontal 布局 Empty"
    />
}
