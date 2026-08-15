import { track } from 'ripple';
import { Input } from '@lotus/ripple';

export function InputControlledDemo() @{
    let &[value] = track<string>('受控初始值');

    <Input value={value} onChange={(next: string) => { value = next; }} placeholder="受控组件" />
}
