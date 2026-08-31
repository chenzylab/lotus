import { CheckboxGroup, Checkbox } from '@lotus/ripple';

export function CheckboxGroupPureCardDemo() {
    return (
        <CheckboxGroup type="pureCard" defaultValue={['1', '3']} direction="vertical" aria-label="CheckboxGroup pureCard 示例">
            <Checkbox value="1" disabled extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Checkbox>
            <Checkbox value="2" disabled extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Checkbox>
            <Checkbox value="3" extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Checkbox>
            <Checkbox value="4" extra="lotus 是一个 tsrx + Ripple 编写的组件库" style={{ width: '280px' }}>
                单选框标题
            </Checkbox>
        </CheckboxGroup>
    );
}
