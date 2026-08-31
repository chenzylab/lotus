import { RadioGroup, Radio } from '@lotus/ripple';

export function RadioGroupPureCardDemo() {
    return (
        <RadioGroup type="pureCard" defaultValue="1" direction="vertical" aria-label="RadioGroup pureCard 示例">
            <Radio value="1" extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Radio>
            <Radio value="2" disabled extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Radio>
        </RadioGroup>
    );
}
