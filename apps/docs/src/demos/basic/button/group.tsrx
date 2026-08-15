import { Button, ButtonGroup } from '@lotus/ripple';

export function ButtonGroupDemo() {
    return <ButtonGroup aria-label="示例按钮组">
        <Button theme="outline" type="primary">上一步</Button>
        <Button theme="outline" type="primary">下一步</Button>
        <Button theme="outline" type="primary">完成</Button>
    </ButtonGroup>;
}
