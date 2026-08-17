import { Radio } from '@lotus/ripple';

export function RadioAdvancedModeDemo() {
    return (
        <Radio mode="advanced" defaultChecked onChange={(checked: boolean) => console.log('radio changed', checked)}>
            高级模式（再次点击已选中项可取消选中）
        </Radio>
    );
}
