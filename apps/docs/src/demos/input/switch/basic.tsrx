import { Switch } from '@lotus/ripple';

export function SwitchBasicDemo() {
    return <Switch defaultChecked onChange={(checked: boolean) => console.log('switch changed', checked)} />;
}
