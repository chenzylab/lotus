import { Input } from '@lotus/ripple';

export function InputBasicDemo() {
    return <Input defaultValue="默认值" placeholder="请输入" onChange={(value: string) => console.log('input changed', value)} />;
}
